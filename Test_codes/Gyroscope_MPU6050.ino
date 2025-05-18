#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Wire.h>

// Your WiFi information (like your home address)
#define WIFI_SSID "Dialog 4G 566"       // Put your WiFi name here
#define WIFI_PASSWORD "c06855C1" // Put your WiFi password here

// Your Firebase information (from the config you copied)
#define FIREBASE_HOST "esp32-test-a1771-default-rtdb.asia-southeast1.firebasedatabase.app" // Without "https://" or "/"
#define FIREBASE_AUTH "ysNQiwmicmtA3RAZ99fN65bC2Q6suS2GC1W9kmpS"  // Found in Project Settings > Service Accounts > Database Secrets

#define FIREBASE_AUTH "AIzaSyD...YOUR_API_KEY" // From Firebase config

// MPU6050 Settings
#define MPU_ADDR 0x68

FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

void setup() {
  Serial.begin(115200);
  
  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Connected! IP: ");
  Serial.println(WiFi.localIP());

  // Initialize Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Initialize MPU6050
  Wire.begin(21, 22); // SDA=21, SCL=22
  delay(1000);
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B); // Power management register
  Wire.write(0);    // Wake up!
  Wire.endTransmission(true);
  
  Serial.println("System Ready!");
}

void loop() {
  // Read sensor data
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B); // Start with register 0x3B
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 6, true);
  
  int16_t ax = Wire.read() << 8 | Wire.read();
  int16_t ay = Wire.read() << 8 | Wire.read();
  int16_t az = Wire.read() << 8 | Wire.read();
  
  float x = ax / 16384.0;
  float y = ay / 16384.0;
  float z = az / 16384.0;

  // Determine position
  String position;
  if (abs(z) > 0.8) {
    position = "VERTICAL";
  } else if (abs(y) > 0.8) {
    position = "ON_SIDE";
  } else if (abs(x) > 0.8) {
    position = "HORIZONTAL";
  } else {
    position = "UNKNOWN";
  }

  // Print to Serial
  Serial.print("Position: ");
  Serial.print(position);
  Serial.print(" | X: ");
  Serial.print(x);
  Serial.print(" Y: ");
  Serial.print(y);
  Serial.print(" Z: ");
  Serial.println(z);

  // Send to Firebase
  if (Firebase.setString(fbdo, "/backpack/position", position)) {
    Serial.println("Sent to Firebase!");
  } else {
    Serial.println("Firebase error: " + fbdo.errorReason());
  }

  // Store sensor values too
  Firebase.setFloat(fbdo, "/backpack/sensor/x", x);
  Firebase.setFloat(fbdo, "/backpack/sensor/y", y);
  Firebase.setFloat(fbdo, "/backpack/sensor/z", z);
  
  delay(1000); // Update every second
}