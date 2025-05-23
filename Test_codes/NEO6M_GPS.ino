#include <WiFi.h>
#include <FirebaseESP32.h>
#include <TinyGPS++.h>

// WiFi credentials
#define WIFI_SSID "Dialog 4G 566"
#define WIFI_PASSWORD "c06855C1"

// Firebase credentials
#define FIREBASE_HOST "esp32-test-a1771-default-rtdb.asia-southeast1.firebasedatabase.app"
#define FIREBASE_AUTH "ysNQiwmicmtA3RAZ99fN65bC2Q6suS2GC1W9kmpS"

// Create Firebase and GPS objects
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;
TinyGPSPlus gps;

// Use HardwareSerial port for GPS
HardwareSerial gpsSerial(1); // Use UART1

// Define GPS RX/TX pins
#define GPS_RX_PIN 21  // ESP32 RX (connect to GPS TX)
#define GPS_TX_PIN 17  // TX is not needed for GPS but required in begin()

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Starting...");

  // Start the GPS serial connection
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX_PIN, GPS_TX_PIN);

  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected! IP: " + WiFi.localIP().toString());

  // Firebase config
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase initialized.");
}

void loop() {
  while (gpsSerial.available() > 0) {
    char c = gpsSerial.read();
    gps.encode(c);

    if (gps.location.isUpdated()) {
      if (gps.location.isValid()) {
        float lat = gps.location.lat();
        float lng = gps.location.lng();

        Serial.printf("Lat: %f, Lng: %f\n", lat, lng);

        // Send to Firebase
        if (Firebase.setFloat(fbdo, "/neo6m/latitude", lat) &&
            Firebase.setFloat(fbdo, "/neo6m/longitude", lng)) {
          Serial.println("Sent to Firebase!");
        } else {
          Serial.println("Firebase error: " + fbdo.errorReason());
        }
      } else {
        Serial.println("Waiting for valid GPS signal...");
      }
    }
  }

  delay(1000); // Slow down loop
}