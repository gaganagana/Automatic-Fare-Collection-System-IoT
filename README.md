# Smart Bus: IoT-Driven Cashless Fare & Voice Alert System

[![Arduino](https://img.shields.io/badge/Platform-Arduino%20UNO-00979D.svg?logo=arduino)](https://www.arduino.cc/)
[![C++](https://img.shields.io/badge/Language-Embedded%20C%2FC%2B%2B-blue.svg?logo=c%2B%2B)](https://isocpp.org/)
[![RFID](https://img.shields.io/badge/Sensor-MFRC522%20RFID-orange.svg)](#hardware-specifications--pinout)
[![Audio](https://img.shields.io/badge/Module-DFPlayer%20Mini-yellow.svg)](#audio-announcement-system-dfplayer-mini)
[![Display](https://img.shields.io/badge/Display-16x2%20I2C%20LCD-green.svg)](#hardware-specifications--pinout)

An automated public transit fare collection and passenger announcement system built using **Arduino UNO**, **MFRC522 RFID**, **DFPlayer Mini**, **I2C LCD**, and **Servo-actuated gate mechanisms**.

---

## 📌 Project Overview

Traditional public transit ticketing relies heavily on physical paper tickets and cash transactions, which causes boarding bottlenecks, fare evasion, and operational delays.

**Smart Bus** solves this with an integrated, contactless embedded ticketing system:
1. **Contactless RFID Tap-In / Tap-Out**: Passengers tap an RFID card at boarding and alighting. The microcontroller verifies the card UID, tracks entry/exit stages, and automatically calculates and deducts distance-based fares.
2. **Automated Turnstile / Gate Actuation**: Two SG90 servo motors simulate entry and exit gates that open only upon successful card validation and sufficient balance.
3. **Multi-Stop Voice Announcement System**: A DFPlayer Mini module announces station stops (e.g., Kempegowda, Maharani College, KR Circle), boarding prompts (*"Please tap your card"*), successful fare deductions, and warning chimes (*"Insufficient balance"*, *"Invalid card"*).
4. **Visual Telemetry**: A 16x2 I2C LCD displays real-time system status, current stop names, passenger card balance, and fare deduction details.
5. **Transit Simulation**: Integrated DC motor drive simulates vehicle motion between scheduled bus stops.

---

## 🛠️ Hardware Specifications & Pinout

| Component | Interface / Protocol | Arduino UNO Pin Assignment |
| :--- | :--- | :--- |
| **MFRC522 RFID Reader** | SPI Protocol | **SDA (SS)**: Pin 10 <br> **SCK**: Pin 13 <br> **MOSI**: Pin 11 <br> **MISO**: Pin 12 <br> **RST**: Pin 9 |
| **DFPlayer Mini (MP3)** | SoftwareSerial | **RX**: Pin 3 (via resistor) <br> **TX**: Pin 2 |
| **16x2 LCD Display** | I2C Protocol (`0x27` / `0x3F`) | **SDA**: Pin A4 <br> **SCL**: Pin A5 |
| **Entry Servo Motor** | PWM | **Signal**: Pin 7 |
| **Exit Servo Motor** | PWM | **Signal**: Pin 8 |
| **L293D Motor Driver** | Digital Out | **IN1**: Pin 5 <br> **IN2**: Pin 6 |
| **Navigation Controls** | Analog / Digital In | **START Button**: Pin A0 <br> **STOP Button**: Pin A1 |

---

## ⚙️ System Architecture & Workflow

```text
       ┌─────────────────┐       ┌──────────────────────┐
       │   RFID Smart    │       │     START / STOP     │
       │    Card Tap     │       │    Trip Pushbuttons  │
       └────────┬────────┘       └──────────┬───────────┘
                │                           │
                ▼                           ▼
       ┌────────────────────────────────────────────────┐
       │             Arduino UNO (ATmega328P)           │
       │     Core Logic: 2nd_final.ino (556 Lines)      │
       └───────┬─────────────┬─────────────┬────────────┘
               │             │             │
               ▼             ▼             ▼
      ┌────────────────┐ ┌───────────────┐ ┌─────────────┐
      │  MFRC522 RFID  │ │  DFPlayer     │ │ 16x2 I2C    │
      │  Card State &  │ │  Voice Alerts │ │ LCD Screen  │
      │  Fare Math     │ │  & Bus Stops  │ │ Live Status │
      └────────────────┘ └───────────────┘ └─────────────┘
               │
               ▼
      ┌─────────────────────────────────┐
      │   Actuation: Servos & L293D     │
      │   - Entry Gate (7° -> 90°)      │
      │   - Exit Gate  (8° -> 90°)      │
      │   - Vehicle Motor Simulation    │
      └─────────────────────────────────┘
```

---

## 🔊 Audio Announcement System (DFPlayer Mini)

Voice tracks stored on the SD card (`/01/` folder):

| Track Number | Voice Announcement Description | Trigger Event |
| :--- | :--- | :--- |
| `002.mp3` | *"Please tap your card"* | Standby prompt / Stop pressed |
| `003.mp3` | *"Entry successful"* | Valid passenger card tapped at entry |
| `004.mp3` | *"Exit successful, thank you for travelling with us"* | Valid passenger card tapped at exit with fare deducted |
| `005.mp3` | *"Invalid card, please try again"* | Unregistered card UID scanned |
| `006.mp3` | *"Insufficient balance"* | Card balance below minimum required fare |
| `007.mp3` | *"Bus currently at Kempegowda. Starting shortly."* | Route initiation |
| `008.mp3` – `024.mp3` | Consecutive transit stops (Maharani College, KR Circle, ..., 16th Main BTM) | START button pressed along the simulated route |

---

## 📸 Hardware Setup & Circuit Schematics

### Physical Prototype Implementation
<p align="center">
  <img src="https://github.com/user-attachments/assets/63603d71-0497-421d-9fb4-e2a645a0ad77" width="650" alt="Smart Bus Hardware Prototype" />
</p>

### Circuit Schematic & Pin Wiring
<p align="center">
  <img src="https://github.com/user-attachments/assets/a62a979a-dc61-4769-b72b-4a97880b033f" width="650" alt="Circuit Wiring Schematic" />
</p>

### Gate Control & Component Assembly
<p align="center">
  <img src="https://github.com/user-attachments/assets/d0502b04-b2af-422c-b622-e323fcec8b5e" width="360" alt="Hardware Module Assembly" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/ea5059c8-745d-4ad6-b4d8-2877dcefc154" width="360" alt="Servo Gate Control Assembly" />
</p>

---

## 📂 Repository Structure

```text
├── 2nd_final.ino                # Complete Arduino firmware source code (556 lines)
├── circuitdiagram.png.png       # High-resolution wiring and schematic diagram
├── New folder/
│   ├── Images/                  # Hardware prototype photographs
│   ├── Circuit Diagram/         # Circuit design documentation
│   └── Project_report.pdf       # Comprehensive engineering project report
└── README.md                    # Project documentation
```

---

## 🚀 Getting Started

### Prerequisites
1. **Arduino IDE** (version 1.8.x or 2.x).
2. Required Arduino Libraries:
   - `MFRC522` by GithubCommunity
   - `LiquidCrystal_I2C` by Frank de Brabander
   - `DFRobotDFPlayerMini` by DFRobot
   - `Servo` (built-in)
   - `SPI` & `Wire` (built-in)

### Flashing the Microcontroller
1. Connect your **Arduino UNO** to your computer via USB.
2. Open `2nd_final.ino` in the Arduino IDE.
3. Select board: `Tools` > `Board` > `Arduino Uno`.
4. Select the matching serial port: `Tools` > `Port`.
5. Click **Verify**, then **Upload**.
6. Format a microSD card as FAT32, place the MP3 voice tracks inside an `/01/` folder, and insert it into the DFPlayer Mini.

---

## 🔮 Future Enhancements & Major Project Architecture

As detailed in the project engineering documentation:
- **Cloud Synchronization**: Integrating **NodeMCU ESP8266** over Wi-Fi to synchronize real-time card balances with a **Google Firebase Cloud Firestore** database.
- **Mobile Passenger Portal**: A **Flutter** cross-platform mobile application allowing passengers to view live card balances, transaction histories, and recharge their travel cards remotely.
- **GPS Telemetry**: Integrating a **NEO-6M GPS module** for automated route progression based on geographic coordinates.
