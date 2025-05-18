#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// Your WiFi information (like your home address)
#define WIFI_SSID "Dialog 4G 566"       // Put your WiFi name here
#define WIFI_PASSWORD "c06855C1" // Put your WiFi password here

// Your Firebase information (from the config you copied)
#define FIREBASE_HOST "esp32-test-a1771-default-rtdb.asia-southeast1.firebasedatabase.app" // Without "https://" or "/"
#define FIREBASE_AUTH "ysNQiwmicmtA3RAZ99fN65bC2Q6suS2GC1W9kmpS"  // Found in Project Settings > Service Accounts > Database Secrets

#define FIREBASE_AUTH "AIzaSyD...YOUR_API_KEY" // From Firebase config


// RFID Pins
#define RST_PIN 4
#define SS_PIN 5
#define SCK 18
#define MISO 19
#define MOSI 23

// Create objects
MFRC522 mfrc522(SS_PIN, RST_PIN);
FirebaseData fbdo;
FirebaseConfig config;
FirebaseAuth auth;

void setup() {
  Serial.begin(115200);
  
  // Initialize SPI with explicit pins
  SPI.begin(SCK, MISO, MOSI, SS_PIN);
  mfrc522.PCD_Init();
  Serial.println("RFID Reader Ready");

  // Connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected! IP: ");
  Serial.println(WiFi.localIP());

  // Configure Firebase
  config.host = FIREBASE_HOST;
  config.signer.tokens.legacy_token = FIREBASE_AUTH;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // Look for cards
  if (!mfrc522.PICC_IsNewCardPresent()) {
    delay(50);
    return;
  }
  
  if (!mfrc522.PICC_ReadCardSerial()) {
    delay(50);
    return;
  }

  // Get card UID
  String uid = "";
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    if (mfrc522.uid.uidByte[i] < 0x10) uid += "0";
    uid += String(mfrc522.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  
  Serial.print("Card UID: ");
  Serial.println(uid);

  // CORRECT Firebase saving method for FirebaseESP32 library
  if (Firebase.setString(fbdo, "/cards/" + uid, "scanned")) {
    Serial.println("✅ Saved to Firebase!");
  } else {
    Serial.println("❌ Error: " + fbdo.errorReason());
  }

  // Proper reset
  mfrc522.PICC_HaltA();
  mfrc522.PCD_StopCrypto1();
  delay(1000);
}