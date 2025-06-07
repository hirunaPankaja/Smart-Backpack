# 🎒 Smart IoT Backpack

The **Smart Backpack** is an innovative IoT-based system designed for students, hikers, and commuters. It enhances safety, health, and organization by integrating various smart sensors and modules with mobile app control.

---

## 🧠 Features

- ⚖️ **Weight Tracking**  
  Detects the weight of the backpack using a load cell and alerts users if it exceeds a healthy carrying limit.

- 🌡️ **Internal Pressure Monitoring**  
  Measures internal air pressure using a barometric sensor to ensure safe environmental conditions (e.g., high altitudes).

- 💧 **Water Leak Detection**  
  Uses a moisture sensor to detect leaks or wet conditions inside the bag and alert the user in real time.

- 📍 **Lost Item Reminders & RFID Tracking**  
  RFID module with tagged items ensures all essentials are packed. Alerts are triggered if items are missing.

- 🚨 **Fall Detection**  
  MPU9250 gyroscope sensor detects unusual movement or falls and can trigger alerts.

- 📱 **Mobile App Integration**  
  Control and monitor backpack functionalities via a custom-built smartphone application (Bluetooth or WiFi).

---

## 🧩 Hardware Components

- **NodeMCU ESP32S** – WiFi-enabled microcontroller  
- **MPU9250** – 3-Axis Accelerometer and Gyroscope  
- **BMP280** – Barometric pressure sensor  
- **YL-83** – Soil/moisture sensor (used for water leak detection)  
- **RFID Module** + **RFID Tags** – For item tracking  
- **50Kg Load Cell** + **HX711** – For accurate weight measurement  
- **3.7v Lipo Battery** – Power supply  

---

## 📱 Mobile Application

- Built using XML , Kotlin
- Displays:
  - Current weight
  - Missing items
  - Pressure and moisture levels
  - Fall alerts
- Sends real-time notifications and alerts

---

## 🎥 3D Animation or Diagram

To better understand how the components are set up in the backpack, refer to the diagram or animation:
![3D Smart Backpack View](backpack-view.gif)


---
- The schematic diagram will be uploaded soon.
---

## 🚀 Future Improvements

- GPS Tracking for bag location
- Voice assistant integration
- Solar-powered charging
- Cloud data sync and analytics dashboard

---

## 🛠️ Built With

- **Arduino IDE**
- **ESP32 Libraries**
- **Flutter / React Native (Mobile App)**
- **Fritzing / TinkerCAD / Autodesk Fusion (for circuit simulation or diagrams)**

---

## 👨‍💻 Contributors

- [Hiruna Pankaja](https://github.com/hirunaPankaja) – Hardware & Software Engineer  
- [Dhanani Chathumini](https://github.com/DhananiChathumini) – Mobile App Developer  
- [Vikum Prabhath](https://github.com/VikumPrabhath) – Hardware & Software Engineer  
- [Yasith Pasindu](https://github.com/yasithh1) – Hardware & Software Engineer



