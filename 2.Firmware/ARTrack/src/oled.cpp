#include "oled.h"

Adafruit_SSD1306 display = Adafruit_SSD1306(128, 64, &WIRE);


void oled_init(){
  Wire.begin(12, 11);
  Serial.println("OLED FeatherWing test");
  // SSD1306_SWITCHCAPVCC = generate display voltage from 3.3V internally
  display.begin(SSD1306_SWITCHCAPVCC, 0x3C); // Address 0x3C for 128x32

  Serial.println("OLED begun");
  // Show image buffer on the display hardware.
  // Since the buffer is intialized with an Adafruit splashscreen
  // internally, this will display the splashscreen.
  //display.display();
  //delay(1000);

  // Clear the buffer.
  display.clearDisplay();
  display.setRotation(1);
  display.display();

  // text display tests
  display.setTextSize(0.5);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0,0);
  display.print("ARTrack\n");
  display.print("ARTrack\n");
  display.print("ARTrack\n");
  display.print("ARTrack\n");
  display.print("ARTrack\n");
  display.print("ARTrack\n");
  display.print("Init!\n");
  display.println("---------");
  display.println("Waiting\nfor APP");
  display.setCursor(0,0);
  display.display(); // actually display all of the above
}

void oled_show_rx(const std::string& data){
  display.setRotation(1);
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0,0);
  display.println("\n");
  const char* json = data.c_str();
  StaticJsonDocument<256> doc; // 调整大小以适应你的 JSON 数据
  deserializeJson(doc, json);
  const char* nextStepDescription = doc["nextStepDescription"]; // 提取描述
  char direction[50]="Go\nStraight.";
  strncpy(direction, nextStepDescription, sizeof(direction)); // 使用 nextStepDescription
  display.println(direction);
  //display.println(data.c_str());
  display.println("\n ");
  display.setCursor(0,0);
}


void oled_show(const std::string& data) {
    StaticJsonDocument<256> doc; // 调整大小以适应你的 JSON 数据
    const char* json = data.c_str();
    deserializeJson(doc, json);
    const char* nextStepDescription = doc["nextStepDescription"]; // 提取描述
    float distanceRemaining = doc["distanceRemaining"]; // 提取剩余距离

    srand(time(NULL));
    float speedValue = 15.8 + (rand() % 51) / 100.0;
    char speed[6];
    sprintf(speed, "%.1f", speedValue);

    char direction[50]="Go\nStraight.";
    strncpy(direction, nextStepDescription, sizeof(direction)); // 使用 nextStepDescription
    direction[sizeof(direction) - 1] = '\0'; // 确保字符串以 null 结尾

    char dist[5]="62.2";
    sprintf(dist, "%.1f", distanceRemaining); // 格式化剩余距离

    //char direction[20] ="Go\nStraight."; // 指令
    char time1[11] = "7:46 P.M."; // 时间
    //char dist[8] = "62.21"; // 距离

    display.setRotation(1);
    display.setTextSize(1);
    display.setTextColor(SSD1306_WHITE);
    display.setCursor(0,0);
    //display.println("\n");
    display.println(time1);

    display.println("\n");
    display.setTextSize(2);
    display.println(speed);
    display.setTextSize(1);
    display.println("km/h");
  
    display.println("  ");
    display.println(direction);
    display.print("Prog:"); display.println(dist);
    display.setCursor(0,0);
}

