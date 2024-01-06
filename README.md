# ARTrack

## Overview

该库包含了AR-Track的所有资料，包括PCB、固件代码、建模文件以及上位机软件代码（ios）

This repository contains all the materials for AR-Track, including PCB, firmware code, modeling files, and upper computer software code (iOS).

![效果图](https://github.com/AHANAyl0n/AR-Track/blob/main/5.Docs/%E6%95%88%E6%9E%9C%E5%9B%BE.png)

ARTrack是一个非机动车AR抬头显示（HUD）。它设计灵感来源于飞机驾驶舱的HUD系统，旨在将关键信息直观地展示在骑行用户的视线范围内，从而减少分心、提高驾驶安全性，并提供一些个性化的设置。它允许骑手在保持对周围环境的高度关注的同时，快速获取速度、导航和通信数据。

ARTrack is a non-motorized vehicle AR Heads-Up Display (HUD). It is designed with inspiration from aircraft cockpit HUD systems, aiming to intuitively present key information within the rider's line of sight, reducing distractions, enhancing driving safety, and offering some personalized settings. It allows riders to quickly access speed, navigation, and communication data while maintaining a high level of awareness of their surrounding environment.

![使用效果](https://github.com/AAAAyl0n/AR-Track/blob/main/5.Docs/%E4%BD%BF%E7%94%A8%E6%95%88%E6%9E%9C.jpg)

该设备通过低功耗蓝牙与手机通信，手机上获取的导航会通过蓝牙发送json格式的数据包到这个设备上，经设备处理，解码，排版后显示出来.

This device communicates with a smartphone via low-power Bluetooth. Navigation data obtained on the phone is transmitted to this device in JSON format via Bluetooth. After being processed, decoded, and formatted by the device, it is displayed.

## 文件目录

### 1.Hardware

硬件设计：PCB文件 BOM表

### 2.Firmware

固件：esp32烧录的程序

### 3.Software

软件：swift工程

![APP开发界面](https://github.com/AHANAyl0n/AR-Track/blob/main/5.Docs/APP%E5%BC%80%E5%8F%91%E7%95%8C%E9%9D%A2.jpg)

### 4.Fusion-Model

3D模型 未整理

### 5.Docs

记录文档

![pic](https://github.com/AAAAyl0n/AR-Track/blob/main/5.Docs/pic1.jpg)
