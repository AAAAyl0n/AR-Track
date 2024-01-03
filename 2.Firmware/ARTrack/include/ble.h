#ifndef BLE_HANDLER_H
#define BLE_HANDLER_H

#include "head.h"

class BLEHandler {
public:
    BLEHandler();
    void init(const char* deviceName);
    void start();
    void update();

    const std::string& getReceivedData() const { return receivedData; } // 访问接收数据的方法
    bool deviceConnected;
    bool oldDeviceConnected;

private:
    std::string receivedData; // 存储接收到的数据
    uint8_t txValue;
    BLEServer* pServer;
    BLECharacteristic* pTxCharacteristic;

    class MyServerCallbacks : public BLEServerCallbacks {
    public:
        MyServerCallbacks(BLEHandler* handler) : m_handler(handler) {}
        void onConnect(BLEServer* pServer);
        void onDisconnect(BLEServer* pServer);

    private:
        BLEHandler* m_handler;
    };

    class MyCallbacks : public BLECharacteristicCallbacks {
    public:
        MyCallbacks(BLEHandler* handler) : m_handler(handler) {}
        void onWrite(BLECharacteristic* pCharacteristic);

    private:
        BLEHandler* m_handler;
    };
};

#endif // BLE_HANDLER_H
