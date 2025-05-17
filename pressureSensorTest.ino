#include <WiFi.h>
#include <FirebaseESP32.h>

// WiFi Configuration
#define WIFI_SSID "Dialog 4G 566"
#define WIFI_PASSWORD "c06855C1"

// Firebase Configuration
#define FIREBASE_HOST "esp32-test-a1771-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "ysNQiwmicmtA3RAZ99fN65bC2Q6suS2GC1W9kmpS"

// Sensor Configuration
#define PRESSURE_PIN 36  // VP (GPIO36)
#define MAX_KG 10.0      // 10kg max capacity (DF9-40 rating)

// Calibration Values - YOU MUST SET THESE!
#define NO_PRESSURE_RAW 4095  // Raw value when no pressure
#define MAX_PRESSURE_RAW 100   // Raw value at MAX_KG pressure

FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

void setup() {
  Serial.begin(115200);
  
  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected");

  // Initialize Firebase with new syntax
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  
  // Optional: Reduce buffer sizes for stability
  fbdo.setBSSLBufferSize(1024, 1024);
  fbdo.setResponseSize(1024);
}

float readPressureKg() {
  // Read and invert the value
  int rawValue = analogRead(PRESSURE_PIN);
  int effectiveValue = NO_PRESSURE_RAW - rawValue;
  
  // Convert to kilograms
  float kg = map(effectiveValue, 
                0, 
                NO_PRESSURE_RAW - MAX_PRESSURE_RAW, 
                0, 
                MAX_KG * 100) / 100.0;
  
  return kg;
}

void loop() {
  float pressure_kg = readPressureKg();
  
  // Send to Firebase
  if (Firebase.ready()) {
    if (Firebase.setFloat(fbdo, "/pressure/kg", pressure_kg)) {
      Serial.print("Pressure: ");
      Serial.print(pressure_kg, 2);
      Serial.println(" kg");
    } else {
      Serial.println("Firebase error: " + fbdo.errorReason());
    }
  }

  delay(2000); // Update every 2 seconds
}