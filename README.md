# Smart Bus & Automatic Fare Collection Projects

> **MCA Academic Project Repository**  
> **Student:** Gagana C P  
> **Institution:** Community Institute of Management Studies (CIMS), Bengaluru  
> **Affiliated to:** Bengaluru City University  

This repository contains two academic projects I developed during my Master of Computer Applications (MCA) program:

1. **Minor Project:** [Automatic Fare Collection System with Voice Alert](Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert/) &mdash; A standalone physical hardware prototype built using Arduino UNO, RFID cards, audio voice prompts, and motorized barrier gates.
2. **Major Project:** [Smart Bus &ndash; IoT-Based Fare Collection & Real-Time Tracking](Main-Project/Smart-Bus-IoT-Fare-Collection/) &mdash; My final year project that builds on the earlier hardware idea by connecting it with a Flutter mobile application and Firebase over Wi-Fi.

I organized both projects together in this repository so faculty members, interviewers, and recruiters can see how the project evolved from an offline hardware test into a connected mobile system.

---

## Repository Structure

```text
Automatic-Fare-Collection-System-IoT/
│
├── Minor-Project/
│   └── Automatic-Fare-Collection-System-with-Voice-Alert/
│       ├── Arduino/          # Arduino UNO sketch (standalone hardware)
│       ├── Circuit/          # Circuit diagram & pin connections
│       ├── Screenshots/      # Physical prototype photos
│       ├── Documentation/    # Official MCA Minor Project report (PDF)
│       └── README.md         # Minor project documentation
│
├── Main-Project/
│   └── Smart-Bus-IoT-Fare-Collection/
│       ├── Arduino/          # Arduino UNO & NodeMCU ESP8266 firmware
│       ├── Flutter-App/      # Full Flutter mobile application
│       ├── Screenshots/      # Mobile UI screens & hardware photos
│       ├── Circuit/          # Pinout table, wiring guide & voltage divider
│       ├── Documentation/    # Official MCA Major Project report (DOCX)
│       └── README.md         # Major project documentation
│
├── .gitignore
└── README.md                 # This file
```

---

## Comparison Between the Two Projects

| Feature | Minor Project | Major Project |
| :--- | :--- | :--- |
| **Project Role** | MCA Minor Project | MCA Major (Final Year) Project |
| **Hardware** | Arduino UNO | Arduino UNO + NodeMCU ESP8266 |
| **Connectivity** | Standalone / Offline | Local Wi-Fi + Google Firebase |
| **Mobile App** | None (Operates via LCD & audio) | Flutter mobile application (Android / iOS) |
| **Voice Announcements** | English audio tracks (DFPlayer Mini) | Bilingual audio (Kannada & English tracks) |
| **Fare Calculation** | ₹10 per stage travelled (minimum ₹10) | ₹10 per stage, synced with mobile wallet |
| **Card Security** | Physical turnstile gate lock | In-app card lock/unlock toggle for lost cards |
| **Wallet Recharge** | Manual hardware balance check | In-app test top-up via Razorpay (test mode) |
| **Route Tracking** | Push buttons (A0 / A1) to change stop | Simulated 18-stop Bengaluru route on interactive map |

---

## Project Summaries

### 1. [Minor Project: Automatic Fare Collection System](Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert/)
* **What it does:** Automates bus ticketing by scanning 13.56 MHz RFID cards, opening servo turnstiles, and playing voice confirmations for entry, exit, and low balance.
* **Hardware used:** Arduino UNO, MFRC522 RFID, DFPlayer Mini, 16x2 I2C LCD, SG90 servo motors, and L293D motor driver.
* **Documentation:** Read the [Minor Project README](Minor-Project/Automatic-Fare-Collection-System-with-Voice-Alert/README.md).

### 2. [Major Project: Smart Bus with Flutter Application](Main-Project/Smart-Bus-IoT-Fare-Collection/)
* **What it does:** Extends the fare collection idea by sending card tap events from Arduino through an ESP8266 Wi-Fi module to a Flutter mobile app. Passengers can check balances, lock lost cards, top up in test mode, and track stops along a simulated route.
* **Technologies used:** Flutter, Dart, NodeMCU ESP8266, Arduino UNO, Firebase Auth, Cloud Firestore, DFPlayer Mini, and Razorpay (test mode).
* **Documentation:** Read the [Major Project README](Main-Project/Smart-Bus-IoT-Fare-Collection/README.md).

---

## About Me

**Gagana C P**  
MCA Student, Community Institute of Management Studies, Bengaluru  
* Portfolio: [gaganagana.github.io](https://gaganagana.github.io)  
* Resume: [Download Resume (PDF)](https://gaganagana.github.io/assets/Gagana_CP_Resume.pdf)  
* LinkedIn: [linkedin.com/in/gaganacp](https://www.linkedin.com/in/gaganacp/)  
* GitHub: [@gaganagana](https://github.com/gaganagana)  
* Email: [gaganacp2002@gmail.com](mailto:gaganacp2002@gmail.com)
