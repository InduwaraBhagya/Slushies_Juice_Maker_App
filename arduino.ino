#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>
#include <time.h> 


#define WIFI_SSID "BhagyaM14"
#define WIFI_PASSWORD "akee1012"


const char* FIREBASE_HOST = "firestore.googleapis.com";
const int HTTPS_PORT = 443;
const char* PROJECT_ID = "slushies-7eaf7";
const char* API_KEY = "AIzaSyAjWiZiBcyUiE799UH9eTEOKdxzZAhIMrc";

#define ORANGE_RELAY D1
#define MANGO_RELAY  D5
#define SUGAR_RELAY  D3
#define WATER_RELAY  D8

const int JUICE_DURATION = 5000;
const int SUGAR_DURATION = 1500;
const int WATER_DURATION = 8000;


const long CHECK_INTERVAL = 15000; 
unsigned long previousCheckTime = 0;
String lastProcessedDocumentId = "pBOqYDriFZO7iMhakqcL"; 

const long  GMT_OFFSET_SEC = 19800;  
const int   DAYLIGHT_OFFSET_SEC = 0;


String getPinName(int pin) {
  switch(pin) {
    case D1: return "D1 (ORANGE_RELAY)";
    case D5: return "D5 (MANGO_RELAY)";
    case D3: return "D3 (SUGAR_RELAY)";
    case D8: return "D8 (WATER_RELAY)";
    default: return "PIN_" + String(pin);
  }
}

void setupPins() {
  int pins[] = {ORANGE_RELAY, MANGO_RELAY, SUGAR_RELAY, WATER_RELAY};
  Serial.println(" Setting up relay pins...");
  for (int i = 0; i < 4; i++) {
    pinMode(pins[i], OUTPUT);
    digitalWrite(pins[i], HIGH); 
    Serial.println("  " + getPinName(pins[i]) + " -> OUTPUT, Initial: HIGH (OFF)");
  }
  Serial.println(" All pins configured!");
}

void activatePin(int pin, int duration) {
  Serial.println(" ACTIVATING PIN: " + getPinName(pin));
  Serial.println("  Duration: " + String(duration) + "ms");
  Serial.println("   Setting pin LOW (Relay ON)");
  
  digitalWrite(pin, LOW); 
  Serial.println("  Pin " + getPinName(pin) + " is now ACTIVE (LOW)");
  
  
  if (duration > 2000) {
    unsigned long startTime = millis();
    int lastSecond = -1;
    while (millis() - startTime < duration) {
      int currentSecond = (millis() - startTime) / 1000;
      if (currentSecond != lastSecond) {
        int remaining = (duration - (millis() - startTime)) / 1000;
        Serial.println("  " + getPinName(pin) + " active for " + String(remaining) + " more seconds...");
        lastSecond = currentSecond;
      }
      delay(100);
    }
  } else {
    delay(duration);
  }
  
  digitalWrite(pin, HIGH); 
  Serial.println("  Pin " + getPinName(pin) + " is now INACTIVE (HIGH)");
  Serial.println(" PIN DEACTIVATED: " + getPinName(pin) + "\n");
}

void makeSlushie(JsonObject fields) {
  String juiceType = fields["juice_type"]["stringValue"];
  JsonArray ingredients = fields["ingredient_list"]["arrayValue"]["values"];
  
  Serial.println("\n MAKING SLUSHIE: " + juiceType + " ");
  Serial.println("═══════════════════════════════════════════════");
  
  // Show the recipe first
  Serial.println(" RECIPE:");
  Serial.println("    Juice: " + juiceType);
  Serial.print("   Ingredients: ");
  for (JsonVariant ingredient : ingredients) {
    Serial.print(ingredient["stringValue"].as<String>() + " ");
  }
  Serial.println("\n");
  
  Serial.println(" STARTING JUICE PREPARATION...");
  Serial.println("═══════════════════════════════════════════════");
  
  // Juice dispensing
  if (juiceType == "Orange") {
    Serial.println(" DISPENSING ORANGE JUICE");
    activatePin(ORANGE_RELAY, JUICE_DURATION);
  } else if (juiceType == "Mango") {
    Serial.println(" DISPENSING MANGO JUICE");
    activatePin(MANGO_RELAY, JUICE_DURATION);
  } else if (juiceType == "Strawberry") {
    Serial.println(" DISPENSING STRAWBERRY JUICE (using Mango relay)");
    activatePin(MANGO_RELAY, JUICE_DURATION);
  }
  
  // Ingredients dispensing
  for (JsonVariant ingredient : ingredients) {
    String ing = ingredient["stringValue"];
    if (ing == "Sugar") {
      Serial.println(" ADDING SUGAR");
      activatePin(SUGAR_RELAY, SUGAR_DURATION);
    } else if (ing == "Water") {
      Serial.println(" ADDING WATER");
      activatePin(WATER_RELAY, WATER_DURATION);
    }
  }
  
  Serial.println("═══════════════════════════════════════════════");
  Serial.println("SLUSHIE PREPARATION COMPLETE! ");
  Serial.println("═══════════════════════════════════════════════\n");
}


String extractDocumentId(String documentName) {
  int lastSlash = documentName.lastIndexOf('/');
  if (lastSlash != -1) {
    return documentName.substring(lastSlash + 1);
  }
  return documentName;
}


String readCompleteResponse(WiFiClientSecure& client) {
  String response = "";
  String headers = "";
  bool inHeaders = true;
  bool isChunked = false;
  unsigned long startTime = millis();
  const unsigned long TOTAL_TIMEOUT = 20000; 
  
  Serial.println(" Reading complete response...");
  
  while ((client.connected() || client.available()) && (millis() - startTime < TOTAL_TIMEOUT)) {
    if (client.available()) {
      String line = client.readStringUntil('\n');
      line.trim();
      
      if (inHeaders) {
        headers += line + "\n";
        if (line.indexOf("Transfer-Encoding: chunked") != -1) {
          isChunked = true;
          Serial.println(" Chunked encoding detected");
        }
        if (line.length() == 0) {
          inHeaders = false;
          Serial.println("Headers complete, reading body...");
          if (headers.indexOf("HTTP/1.1 200") == -1) {
            Serial.println(" HTTP Error in headers:");
            Serial.println(headers.substring(0, 300));
            return "";
          }
        }
      } else {
        
        if (isChunked) {
         
          response += line;
          
          
          if (response.indexOf('{') != -1) {
            int openBraces = 0;
            int closeBraces = 0;
            for (int i = 0; i < response.length(); i++) {
              if (response[i] == '{') openBraces++;
              if (response[i] == '}') closeBraces++;
            }
            
            
            if (openBraces > 0 && openBraces == closeBraces) {
              Serial.println(" Complete JSON detected");
              break;
            }
          }
        } else {
          response += line + "\n";
        }
      }
    } else {
      delay(10); 
    }
  }
  
  Serial.println(" Response length: " + String(response.length()));
  
  
  int jsonStart = response.indexOf('{');
  if (jsonStart != -1) {
    response = response.substring(jsonStart);

    response.replace("0\r\n\r\n", "");
    response.replace("\r\n", "");
    response.replace("\r", "");
    response.replace("\n", "");
  }
  
  return response;
}

void checkForLatestPaidOrder() {
  Serial.println("\n GETTING LATEST DOCUMENT (TIMESTAMP DESC) ");
  Serial.println(" Last processed: " + lastProcessedDocumentId);
  
  WiFiClientSecure client;
  client.setInsecure();
  
  if (!client.connect(FIREBASE_HOST, HTTPS_PORT)) {
    Serial.println(" Failed to connect to Firestore");
    return;
  }
  

  String url = "/v1/projects/";
  url += PROJECT_ID;
  url += "/databases/(default)/documents/orders";
  url += "?orderBy=timestamp%20desc&pageSize=1&key=";
  url += API_KEY;
  
  Serial.println(" Requesting latest document...");
  client.println("GET " + url + " HTTP/1.1");
  client.println("Host: " + String(FIREBASE_HOST));
  client.println("User-Agent: ESP8266");
  client.println("Connection: close");
  client.println();
  
  unsigned long timeout = millis();
  while (!client.available() && millis() - timeout < 10000) {
    delay(10);
  }
  
  if (!client.available()) {
    Serial.println(" Timeout - No response from Firestore");
    client.stop();
    return;
  }
  
 
  String jsonResponse = readCompleteResponse(client);
  client.stop();
  
  if (jsonResponse.length() == 0) {
    Serial.println(" Empty JSON response");
    return;
  }
  
  Serial.println(" JSON length: " + String(jsonResponse.length()));
  
  
  DynamicJsonDocument doc(16384);
  DeserializationError error = deserializeJson(doc, jsonResponse);
  
  if (error) {
    Serial.print(" JSON parsing failed: ");
    Serial.println(error.c_str());
    Serial.println(" JSON preview (first 500 chars):");
    Serial.println(jsonResponse.substring(0, 500));
    Serial.println(" JSON preview (last 200 chars):");
    int start = max(0, (int)jsonResponse.length() - 200);
    Serial.println(jsonResponse.substring(start));
    return;
  }
  
  Serial.println("JSON parsed successfully!");
  
  if (!doc.containsKey("documents") || doc["documents"].size() == 0) {
    Serial.println(" No documents found");
    return;
  }
  
  
  JsonObject document = doc["documents"][0];
  JsonObject fields = document["fields"];
  
  String documentName = document["name"].as<String>();
  String documentId = extractDocumentId(documentName);
  String status = fields.containsKey("status") ? fields["status"]["stringValue"].as<String>() : "unknown";
  String timestamp = fields.containsKey("timestamp") ? fields["timestamp"]["timestampValue"].as<String>() : "no-timestamp";
  
  Serial.println(" LATEST DOCUMENT:");
  Serial.println("    Document ID: " + documentId);
  Serial.println("    Status: " + status);
  Serial.println("   Timestamp: " + timestamp);
  
  if (status == "paid") {
    Serial.println("Latest document status is PAID!");
    
    if (documentId == lastProcessedDocumentId) {
      Serial.println(" Already processed this document: " + documentId);
      Serial.println(" Waiting for new orders...");
      return;
    }
    
    Serial.println("\n NEW PAID ORDER DOCUMENT! PROCESSING NOW! ");
    Serial.println(" Document ID: " + documentId);
    
    Serial.println("--- Order Details ---");
    serializeJsonPretty(fields, Serial);
    Serial.println("-------------------");
    
    makeSlushie(fields);
    
    lastProcessedDocumentId = documentId;
    Serial.println(" SUCCESS! Document " + documentId + " processed! ");
  } else {
    Serial.println("  Latest document status is '" + status + "' - not paid yet");
  }
}

void setup() {
  Serial.begin(9600);
  Serial.println("\n SLUSHIE MACHINE v7.0 - PIN MONITORING ");
  
  setupPins();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print(" Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n WiFi connected!");
  Serial.println(" IP: " + WiFi.localIP().toString());
  Serial.println(" Signal: " + String(WiFi.RSSI()) + " dBm");

  Serial.println("\n PIN CONFIGURATION:");
  Serial.println("   Orange Juice -> " + getPinName(ORANGE_RELAY));
  Serial.println("   Mango/Strawberry -> " + getPinName(MANGO_RELAY));
  Serial.println("   Sugar -> " + getPinName(SUGAR_RELAY));
  Serial.println("   Water -> " + getPinName(WATER_RELAY));

  Serial.println("\n Machine ready! Will check for NEW documents every 15 seconds...");
  Serial.println("Already processed: " + lastProcessedDocumentId);
  Serial.println(" Waiting for new paid orders...");
  Serial.println(" Pin activity will be shown in detail during juice preparation!");
}

void loop() {
  unsigned long currentTime = millis();
  if (currentTime - previousCheckTime >= CHECK_INTERVAL) {
    previousCheckTime = currentTime;
    checkForLatestPaidOrder();
  }
  
  
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println(" WiFi disconnected, reconnecting...");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
    Serial.println("\n WiFi reconnected!");
  }
}