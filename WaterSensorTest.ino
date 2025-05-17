#include <WiFi.h>
#include <FirebaseESP32.h>

// WiFi Configuration
#define WIFI_SSID "Dialog 4G 566"
#define WIFI_PASSWORD "c06855C1"

// Firebase Configuration
#define FIREBASE_HOST "esp32-test-a1771-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "ysNQiwmicmtA3RAZ99fN65bC2Q6suS2GC1W9kmpS"

// Hardware
#define WATER_SENSOR_PIN 36
#define THRESHOLD 1500

FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

void connectToWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    Serial.print(".");
    delay(500);
    attempts++;
  }
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nFailed to connect!");
    ESP.restart();
  }
  Serial.println("\nConnected!");
}

void setup() {
  Serial.begin(115200);
  delay(1000); // Give serial monitor time to connect
  
  Serial.println("\nStarting System...");
  Serial.printf("Free Heap: %d\n", ESP.getFreeHeap());
  
  connectToWiFi();
  
  // Initialize Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  Serial.println("System initialized");
}

void loop() {
  static bool lastState = false;
  
  if (!Firebase.ready()) {
    Serial.println("Firebase not ready!");
    delay(1000);
    return;
  }

  int sensorValue = analogRead(WATER_SENSOR_PIN);
  bool waterDetected = sensorValue > THRESHOLD;
  
  Serial.printf("Sensor: %d, State: %s, Heap: %d\n", 
               sensorValue, 
               waterDetected ? "WET" : "DRY",
               ESP.getFreeHeap());

  if (waterDetected != lastState) {
    if (Firebase.setBool(fbdo, "/water-leak-detection/water-leak", waterDetected)) {
      Serial.println("Firebase update successful");
      lastState = waterDetected;
    } else {
      Serial.println("Firebase error: " + fbdo.errorReason());
    }
  }
  
  delay(2000);
}