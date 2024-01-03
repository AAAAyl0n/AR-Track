#include "ble.h"

BLEHandler::BLEHandler() : txValue(0), pServer(NULL), pTxCharacteristic(NULL), deviceConnected(false), oldDeviceConnected(false) {}

void BLEHandler::init(const char* deviceName) {
    BLEDevice::init(deviceName);
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks(this));
}

void BLEHandler::start() {
    BLEService* pService = pServer->createService(SERVICE_UUID);
    pTxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_TX, BLECharacteristic::PROPERTY_NOTIFY);
    pTxCharacteristic->addDescriptor(new BLE2902());
    BLECharacteristic* pRxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_RX, BLECharacteristic::PROPERTY_WRITE);
    pRxCharacteristic->setCallbacks(new MyCallbacks(this));

    pService->start();
    pServer->getAdvertising()->start();
}

void BLEHandler::update() {
    if (deviceConnected) {
        pTxCharacteristic->setValue(&txValue, 1);
        pTxCharacteristic->notify();
        txValue++;
        delay(2000);
    }

    if (!deviceConnected && oldDeviceConnected) {
        delay(500);
        pServer->startAdvertising();
        oldDeviceConnected = deviceConnected;
    }

    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }
}

void BLEHandler::MyServerCallbacks::onConnect(BLEServer* pServer) {
    m_handler->deviceConnected = true;
}

void BLEHandler::MyServerCallbacks::onDisconnect(BLEServer* pServer) {
    m_handler->deviceConnected = false;
}

void BLEHandler::MyCallbacks::onWrite(BLECharacteristic* pCharacteristic) {
    std::string rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
        m_handler->receivedData = rxValue; // 更新BLEHandler的receivedData成员
    }
}
