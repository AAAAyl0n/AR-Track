#ifndef _OLED_H
#define _OLED_H

#include "head.h"

void oled_init();
void oled_show(const std::string& data);
void oled_show_rx(const std::string& data);

extern Adafruit_SSD1306 display;

#endif