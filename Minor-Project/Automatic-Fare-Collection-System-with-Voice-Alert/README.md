# Automatic Fare Collection System with Voice Alert

> **MCA Minor Project**  
> **Student:** Gagana C P  
> **Institution:** Community Institute of Management Studies, Bengaluru (Affiliated to Bengaluru City University)  

---

## About This Project

I built this project as my MCA minor project. It is a standalone physical hardware prototype designed to automate bus ticketing using contactless RFID smart cards, audio voice prompts, and motorized barrier gates.

In local public buses, conductors have to manually collect cash, issue small paper tickets, and hand back loose coins. During crowded peak hours, this causes delays and disputes. I wanted to build a working prototype to test how RFID cards and voice alerts can handle ticketing without cash.

---

## Hardware Components Used

| Component | Purpose in the Project |
| :--- | :--- |
| **Arduino UNO (ATmega328P)** | Central microcontroller running the ticketing logic and controlling all peripherals. |
| **MFRC522 RFID Reader (13.56 MHz)** | Reads commuter card UIDs over SPI when tapped at the entry or exit. |
| **DFPlayer Mini + 3W Speaker** | Plays recorded voice prompts from a micro-SD card (welcome, exit, low balance). |
| **16x2 I2C LCD Display** | Shows passenger balance, stop numbers, fare debited, and error messages. |
| **2x SG90 Servo Motors** | Open and close the physical entry and exit barrier turnstiles (0° closed, 90° open). |
| **L293D Motor Driver & DC Motor** | Simulates the bus moving between stops during testing. |
| **Push Buttons (Pins A0 & A1)** | Used as START and STOP inputs to advance bus stops during the demonstration. |

---

## How It Works

1. **Boarding at Entry:**
   * The passenger taps their RFID card on the reader.
   * If the card has at least ₹10, the entry servo opens the gate (rotates to 90°), the DFPlayer announces "Welcome aboard", the 16x2 LCD shows the balance, and the Arduino records the entry stop.
   * If the balance is under ₹10, the gate stays closed (0°) and the speaker announces "Insufficient balance".
2. **Deboarding at Exit:**
   * The passenger taps their card at the exit reader.
   * The Arduino calculates the number of stages travelled:
     $$\text{Fare} = \text{Stages Travelled} \times ₹10 \quad (\text{Minimum } ₹10)$$
   * The fare is deducted, the LCD displays the new balance, the DFPlayer plays "Exit recorded, thank you", and the exit servo opens the barrier.

---

## Hardware Pin Connections

```text
Arduino Pin       Connected Device       Function
─────────────────────────────────────────────────────────────────────────────
3.3V              MFRC522 VCC            Power (Must be 3.3V, not 5V)
GND               System Ground          Common ground rail
D2                DFPlayer RX            Audio Serial TX (through 1kΩ resistor)
D3                DFPlayer TX            Audio Serial RX
D4                Servo 1 (Entry Gate)   PWM gate control (0° to 90°)
D5                L293D IN1              DC Motor forward
D6                L293D IN2              DC Motor stop / reverse
D9                MFRC522 RST            SPI Reset
D10               MFRC522 SDA / SS       SPI Slave Select
D11               MFRC522 MOSI           SPI Master Out Slave In
D12               MFRC522 MISO           SPI Master In Slave Out
D13               MFRC522 SCK            SPI Clock
A0                START Button           Button to start bus simulation
A1                STOP Button            Button to advance bus stop
A2                Servo 2 (Exit Gate)    PWM gate control (0° to 90°)
A4                16x2 LCD SDA           I2C Data
A5                16x2 LCD SCL           I2C Clock
```

---

## Photos of the Prototype

| Hardware Setup | Turnstile Gate Assembly | Working Module |
| :---: | :---: | :---: |
| ![Hardware Setup](Screenshots/01_Physical_Hardware_Setup.jpg) | ![Turnstile Assembly](Screenshots/02_Dual_Turnstiles_and_RFID.jpg) | ![Working Module](Screenshots/03_Working_Module_Overview.jpg) |
| *Arduino UNO, breadboard, and wiring* | *Servo barrier gate and RFID card reader* | *LCD display and audio testing* |

---

## What I Learned

* How to interface multiple SPI and I2C sensors with an Arduino UNO.
* Managing servo angles and timing with `millis()` so audio playback doesn't freeze the card scanner.
* Using internal pull-up resistors on Arduino analog pins (A0 and A1) to connect simple push buttons.

---

## Project Documentation

The complete academic report submitted for this minor project is available in [`Documentation/MCA_Minor_Project_Report.pdf`](Documentation/MCA_Minor_Project_Report.pdf).
