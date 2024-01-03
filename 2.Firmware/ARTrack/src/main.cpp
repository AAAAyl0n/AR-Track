#include "head.h"

BLEHandler bleHandler;
unsigned long lastBLEUpdate = 0;
unsigned long lastScreenUpdate = 0;

const unsigned long BLE_UPDATE_INTERVAL = 500;  // 2 seconds

void setup() {
    Serial.begin(115200);
    oled_init();
    bleHandler.init("ARtrack");
    bleHandler.start();
    Serial.println("waiting...");
    delay(1000);
    display.clearDisplay();
}

void loop() {

  unsigned long currentMillis = millis();
  if (currentMillis - lastBLEUpdate >= BLE_UPDATE_INTERVAL) {
        bleHandler.update();
        lastBLEUpdate = currentMillis;
  }
  const std::string& data = bleHandler.getReceivedData();
  
  display.clearDisplay();
  oled_show(data);
  delay(10);
  yield();
  display.display();

}

