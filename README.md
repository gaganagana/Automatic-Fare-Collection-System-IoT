# Smart Transit & IoT Fare Automation Portfolio

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Arduino](https://img.shields.io/badge/Arduino-UNO-00979D?logo=arduino&logoColor=white)](https://arduino.cc)
[![ESP8266](https://img.shields.io/badge/NodeMCU-ESP8266-E7352C?logo=espressif&logoColor=white)](https://espressif.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Master of Computer Applications (MCA) Project Repository**  
> **Student Researcher:** [Gagana C P](https://github.com/gaganagana)  
> **Institution:** Community Institute of Management Studies, Bengaluru (Affiliated to Bengaluru City University)

This repository contains the complete source code, hardware firmware, mobile software, circuit designs, academic reports, and visual assets for two distinct automated public transit engineering projects developed during my Master of Computer Applications program.

---

## Academic Project Architecture

```
Repository Root
│
├── Minor-Project/
│   └── Automatic-Fare-Collection-System-with-Voice-Alert/
│       ├── Arduino/          # Standalone Arduino UNO firmware (ATmega328P)
│       ├── Circuit/          # Schematic & hardware wiring diagram
│       ├── Screenshots/      # Physical prototype breadboard photos
│       ├── Documentation/    # Official MCA Minor Project Thesis (PDF)
│       └── README.md         # Minor project technical report
│
├── Main-Project/
│   └── Smart-Bus-IoT-Fare-Collection/
│       ├── Arduino/          # Arduino UNO + NodeMCU ESP8266 Wi-Fi firmware
│       ├── Flutter-App/      # Production Flutter cross-platform mobile application
│       ├── Screenshots/      # 42 mobile UI captures + 8 physical hardware photos
│       ├── Circuit/          # Pinout tables, voltage divider & Mermaid diagram
│       ├── Documentation/    # Official MCA Major Project Thesis (DOCX) & Firestore rules
│       └── README.md         # Comprehensive Major project engineering guide
│
└── README.md                 # Master repository navigation (this file)
```

---

## Side-by-Side Project Comparison

| Dimension | 1. MCA Minor Project | 2. MCA Major Project (Final Thesis) |
| :--- | :--- | :--- |
| **Official Title** | **Automatic Fare Collection System with Voice Alert** | **Smart Bus – IoT-Based Smart Bus Fare Collection and Real-Time Tracking with Flutter Application** |
| **Core Objective** | Standalone embedded prototype to automate cash collection and validate RFID passenger card tapping. | Full-stack transit ecosystem bridging physical bus hardware to mobile devices and cloud infrastructure. |
| **Microcontrollers** | 1x Arduino UNO (ATmega328P) | Dual Core: Arduino UNO (Master) + NodeMCU ESP8266 (Wi-Fi Relay) |
| **Connectivity** | Standalone / Offline (No wireless link) | Local Wi-Fi (HTTP REST, WebSockets) + Google Firebase Cloud |
| **Mobile Application** | None (Operates purely via hardware LCD & audio) | **Cross-platform Flutter application** (Android / iOS / Web) |
| **Audio Voice Alert** | Single-language audio playback (DFPlayer Mini) | **Bilingual voice synthesis** (Kannada & English SD tracks + Flutter TTS) |
| **Fare Mechanism** | Dynamic distance fare ($10/stage, min $10) | Dynamic distance fare synced in real time to digital cloud wallets |
| **Commuter Security** | Physical turnstile gate lock | In-app one-tap card lock/unlock, biometric auth, login alert emails |
| **Fintech Top-Up** | Manual admin recharge via hardware buttons | **Online wallet top-up via Razorpay payment gateway integration** |
| **Route Tracking** | Fixed hardware stage counter (Buttons A0/A1) | **Interactive live transit route map with 18 Bengaluru stops** |

---

## 1. MCA Minor Project Summary

* **Folder:** [`Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert`](Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert/)
* **Technologies:** C++ / Arduino IDE, MFRC522 RFID (13.56 MHz), DFPlayer Mini MP3, SG90 Micro Servos, 16x2 I2C LCD, L293D Motor Driver.
* **Core Achievement:** Designed and demonstrated an autonomous physical fare-gate prototype that scans contactless RFID smart cards, computes travel fares based on boarding and deboarding stages, plays audio feedback, and automatically actuates barrier turnstiles while eliminating paper ticket waste.
* **Full Documentation:** Read the [Minor Project README](Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert/README.md).

---

## 2. MCA Major Project Summary

* **Folder:** [`Main-Project/Smart-Bus-IoT-Fare-Collection`](Main-Project/Smart-Bus-IoT-Fare-Collection/)
* **Technologies:** Flutter 3.x, Dart 3.x, Arduino UNO, NodeMCU ESP8266, Google Firebase Auth & Cloud Firestore, Google Maps API, Razorpay Payment Gateway, Gmail SMTP Mailer.
* **Core Achievement:** Architected and deployed an end-to-end intelligent transit management ecosystem. Real-world passenger card taps on the physical bus turnstile are captured by an Arduino UNO, forwarded wirelessly over a safe 3.3V voltage-divided UART bridge through a NodeMCU ESP8266 to an embedded Flutter HTTP server (Shelf) and Cloud Firestore. The Flutter mobile app provides real-time digital wallet balances, lost card locking, bilingual English/Kannada UI & voice alerts, live GPS bus simulation across 18 Bengaluru BMTC stops, and in-app wallet recharge.
* **Full Documentation:** Read the [Major Project README](Main-Project/Smart-Bus-IoT-Fare-Collection/README.md).

---

## Hardware Safety & Electrical Architecture

```
[5V / 2A Regulated Power Supply]
      │
      ├───────────────────────┬──────────────────────┬──────────────────────┐
      ▼                       ▼                      ▼                      ▼
[Arduino UNO]           [16x2 I2C LCD]         [SG90 Servos]         [DFPlayer Mini]
(Pin A2 5V TX)          (SDA/SCL on A4/A5)     (Entry: D4, Exit: A3) (SoftwareSerial D2/D3)
      │
   [1 kΩ]
      │
      ├───► [NodeMCU ESP8266 Pin D2 (3.3V Safe RX)]
      │
   [2 kΩ]
      │
   [System Common Ground (GND)]
```

> **Important:** The 1kΩ / 2kΩ voltage divider is mandatory to prevent the Arduino UNO's 5V TTL logic from damaging the 3.3V-tolerant ESP8266 GPIO pins.

---

## Author & Academic Citation

**Gagana C P**  
MCA Graduate | Full Stack & IoT Developer  
* GitHub: [@gaganagana](https://github.com/gaganagana)  
* Portfolio: [https://gaganagana.github.io](https://gaganagana.github.io)  
* Department of Master of Computer Applications, Community Institute of Management Studies, Bengaluru.
