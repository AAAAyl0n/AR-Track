//
//  navi.swift
//  cenima
//
//  Created by Aniurm on 2023/11/27.
//

import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxNavigationNative
import CoreBluetooth

let SERVICE_UUID = CBUUID(string: "12a59900-17cc-11ec-9621-0242ac130002")

// class to storing data we want to send
class NavigationData: Encodable {
    var distanceRemaining: Double
    var nextStepDescription: String
    
    enum CodingKeys: String, CodingKey {
        case distanceRemaining
        case nextStepDescription
    }
    
    init(distanceRemaining: Double, nextStepDescription: String) {
        self.distanceRemaining = distanceRemaining
        self.nextStepDescription = nextStepDescription
    }
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error when encoding NavigationData to JSON: \(error)")
            return nil
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CLLocationCoordinate2DMake(38.9131752, -77.0324047)
        let destination = CLLocationCoordinate2DMake(38.8977, -77.0365)
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        
        Directions.shared.calculate(options) { [weak self] (_, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let strongSelf = self else {
                    return
                }
                
                // For demonstration purposes, simulate locations if the Simulate Navigation option is on.

                let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
                                                                customRoutingProvider: NavigationSettings.shared.directions,
                                                                credentials: NavigationSettings.shared.directions.credentials,
                                                                simulating: true ? .always : .onPoorGPS)
                
                // Define a customized `topBanner` to display route alerts during turn-by-turn navigation, and pass it to `NavigationOptions`.
                let topAlertsBannerViewController = TopAlertsBarViewController()
                let navigationOptions = NavigationOptions(navigationService: navigationService,
                                                          topBanner: topAlertsBannerViewController)
                let navigationViewController = NavigationViewController(for: indexedRouteResponse,
                                                                        navigationOptions: navigationOptions)

                let parentSafeArea = navigationViewController.view.safeAreaLayoutGuide
                topAlertsBannerViewController.view.topAnchor.constraint(equalTo: parentSafeArea.topAnchor).isActive = true
                
                navigationViewController.modalPresentationStyle = .fullScreen
                
                strongSelf.present(navigationViewController, animated: true)
            }
        }
    }
}

// MARK: - TopAlertsBarViewController
class TopAlertsBarViewController: ContainerViewController {
    var bluetoothViewModel = BluetoothViewModel() // Add a property for the Bluetooth view model
    
    lazy var topAlertsBannerView: InstructionsBannerView = {
        let banner = InstructionsBannerView()
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.layer.cornerRadius = 25
        banner.layer.opacity = 0.8
        return banner
    }()
    
    override func viewDidLoad() {
        view.addSubview(topAlertsBannerView)
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        // To change top banner size and position change layout constraints directly.
        let topAlertsBannerViewConstraints: [NSLayoutConstraint] = [
            topAlertsBannerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            topAlertsBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            topAlertsBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            topAlertsBannerView.heightAnchor.constraint(equalToConstant: 100.0),
            topAlertsBannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        NSLayoutConstraint.activate(topAlertsBannerViewConstraints)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupConstraints()
    }
    
    public func updateAlerts(alerts: [String]) {
        
        // Change the property of`primaryLabel: InstructionLabel`.
        let text = alerts.joined(separator: "\n")
        topAlertsBannerView.primaryLabel.text = text
        topAlertsBannerView.primaryLabel.numberOfLines = 0
        topAlertsBannerView.primaryLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    // MARK: - NavigationServiceDelegate implementation
    
    public func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        topAlertsBannerView.update(for: instruction)
    }
    
    public func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
        topAlertsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
    }
    
    public func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        // Call the BLE send function with the updated navigation details
        guard let navigationData = NavigationData(distanceRemaining: progress.currentLegProgress.currentStepProgress.distanceRemaining, nextStepDescription: progress.upcomingStep?.description ?? "Unknown").toJSONString() else {
            print("Error when encoding NavigationData to JSON")
            return
        }
        bluetoothViewModel.sendData(navigationData)
        print("Status: Sent data: \(navigationData)")
        
        topAlertsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
        let allAlerts = progress.upcomingRouteAlerts.filter({ !$0.description.isEmpty }).map({ $0.description })
        if !allAlerts.isEmpty {
            updateAlerts(alerts: allAlerts)
        } else {
            // If there's no usable route alerts in the route progress, displaying `currentVisualInstruction` instead.
            let instruction = progress.currentLegProgress.currentStepProgress.currentVisualInstruction
            topAlertsBannerView.primaryLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            topAlertsBannerView.update(for: instruction)
        }
    }
}

// MARK: - MapboxCoreNavigation.RouteAlert to String implementation
extension MapboxDirections.Incident: CustomStringConvertible {
    
    public var alertDescription: String {
        guard let kind = self.kind else { return self.description }
        if let impact = self.impact, let lanesBlocked = self.lanesBlocked {
            return "A \(impact) \(kind) ahead blocking \(lanesBlocked)"
        } else if let impact = self.impact {
            return "A \(impact) \(kind) ahead"
        } else {
            return "A \(kind) ahead blocking \(self.lanesBlocked!)"
        }
    }
}

extension MapboxCoreNavigation.RouteAlert: CustomStringConvertible {

    public var description: String {
        let distance = Int64(self.distanceToStart)
        guard distance > 0 && distance < 500 else { return "" }
        
        switch roadObject.kind {
        case .incident(let incident?):
            return "\(incident.alertDescription) in \(distance)m."
        case .tunnel(let alert?):
            if let alertName = alert.name {
                return "Tunnel \(alertName) in \(distance)m."
            } else {
                return "A tunnel in \(distance)m."
            }
        case .borderCrossing(let alert?):
            return "Crossing border from \(alert.from) to \(alert.to) in \(distance)m."
        case .serviceArea(let alert?):
            switch alert.type {
            case .restArea:
                return "Rest area in \(distance)m."
            case .serviceArea:
                return "Service area in \(distance)m."
            }
        case .tollCollection(let alert?):
            switch alert.type {
            case .booth:
                return "Toll booth in \(distance)m."
            case .gantry:
                return "Toll gantry in \(distance)m."
            }
        default:
            return ""
        }
    }
}

// bool to check whether we found writable characteristic
var isReady: Bool = false

class BluetoothViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?

    // Record the device we want to connect to.
    private var peripheral: CBPeripheral?

    var writableCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
        self.peripheral = nil
        self.writableCharacteristic = nil
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
            print("Status: Scanning for peripherals...")
        } else {
            print("Error: Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // We want the device with the name "ARTrack"
        if peripheral.name == "ARtrack" {
            self.centralManager?.stopScan()
            self.peripheral = peripheral
            self.centralManager?.connect(peripheral, options: nil)
            print("Status: Found ARTrack!")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            print("Status: Connected to ARTrack!")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print("Log: All services: \(peripheral.services ?? [])")

        if let service = peripheral.services?.first(where: { $0.uuid == SERVICE_UUID }) {
            print("Log: Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        print("Log: All characteristics: \(service.characteristics ?? [])")

        for characteristic in service.characteristics ?? [] {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
                isReady = true
                print("Log: Discovered writable characteristic: \(characteristic)")
            }
        }
    }

    func sendData(_ data: String) {
        if !isReady {
            print("Error: Not ready to send data")
            return
        }
        // log
        if let peripheral = self.peripheral, let characteristic = writableCharacteristic {
            let dataToSend = data.data(using: .utf8)
            peripheral.writeValue(dataToSend!, for: characteristic, type: .withResponse)
            print("I'm going to send data: \(data)")
        }
    }
}
