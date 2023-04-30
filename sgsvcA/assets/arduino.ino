/*
   IoT SMART FARM_V2
*/

#include <DHT_U.h>
// #include <VitconBrokerComm.h>
#include <ArduinoJson.h>
#include <SoftPWM.h>
#include <U8g2lib.h> //U8g2 by oliver 라이브러리 설치 필요
U8G2_SH1106_128X64_NONAME_F_SW_I2C u8g2(U8G2_R0, SCL, SDA, U8X8_PIN_NONE);

// using namespace vitcon;
#define DHTPIN A1
#define DHTTYPE DHT22
#define LAMP 17
#define PUMP 16
#define SOILHUMI A6

#define GET 1
#define POST 2
#define PUT 3
#define DELETE 4

DHT_Unified dht(DHTPIN, DHTTYPE);
SOFTPWM_DEFINE_CHANNEL(A3); // Arduino pin A3

const char *firmware_version = "v0.3";
const String sname = "SG-Service (Type A)";
const String uuid = "etri-KYxUyaQ==";
const long interval = 2000;

typedef struct _sensor {
  float temp;
  float humi;
  float soilHumi;
} Sensor;

typedef struct _actuator {
  bool led;
  bool fan;
  bool pump;
} Actuator;

byte requestMessage[100];
int requestMessageLength = 0;

Sensor sensor;
Actuator actuator;
Actuator actuatorToSync;

StaticJsonDocument<100> INFO;

void drawLogo() {
  u8g2.clearBuffer();

  u8g2.setFont(u8g2_font_ncenB08_te);
  u8g2.drawStr(1, 15, "SF (etri-ZXRyaQ==)");

  u8g2.drawStr(15, 36, "Temp.");
  u8g2.setCursor(85, 36);
  u8g2.print(sensor.temp);
  u8g2.drawStr(114, 36, "\xb0");
  u8g2.drawStr(119, 36, "C");

  u8g2.drawStr(15, 47, "Humidity");
  u8g2.setCursor(85, 47);
  u8g2.print(sensor.humi);
  u8g2.drawStr(116, 47, "%");

  u8g2.drawStr(15, 58, "Soil Humi.");
  u8g2.setCursor(85, 58);
  u8g2.print(sensor.soilHumi);
  u8g2.drawStr(116, 58, "%");

  u8g2.sendBuffer();
}

void setup() {
  Serial.begin(57600);
  //   comm.SetInterval(200);

  INFO["uuid"] = uuid;
  INFO["sname"] = sname;

  pinMode(LAMP, OUTPUT);
  pinMode(PUMP, OUTPUT);
  pinMode(SOILHUMI, INPUT);
  u8g2.begin();
  dht.begin();
  // begin with 60hz pwm frequency
  SoftPWM.begin(490);

  // 초기설정
  digitalWrite(LAMP, LOW);
  digitalWrite(PUMP, LOW);
}

// [0] -> code / [1] -> Token / [2] -> Length / [3~] -> Payload
bool readRequestMessage() {
  uint8_t recvValue = 0;
  int messageLength = 0;
  requestMessageLength = 0;

  // read request message
  while (Serial.available()) {
    recvValue = Serial.read();
    if (recvValue == 255) {
      break;
    }

    requestMessage[requestMessageLength] = recvValue;
    requestMessageLength++;
  }

  requestMessage[requestMessageLength] = 0;

  // error handling
  if (requestMessageLength == 0) {
    return false;
  }

  if (requestMessageLength < 3) {
    return false;
  }

  if (requestMessageLength != requestMessage[2]) {
    return false;
  }

  return true;
}

void handleQueryMessage() {
  uint8_t tkn = (uint8_t)requestMessage[1];
  String query = String((char *)(requestMessage + 3));

  if (query == "init") {
    sendMessageWithJson(205, tkn, INFO);
  } else if (query == "sensor") {
    StaticJsonDocument<100> js_sensor;
    js_sensor["temp"] = sensor.temp;
    js_sensor["humi"] = sensor.humi;
    js_sensor["soilHumi"] = sensor.soilHumi;
    sendMessageWithJson(205, tkn, js_sensor);
  } else if (query == "actuator") {
    StaticJsonDocument<100> js_actuator;
    js_actuator["led"] = actuator.led;
    js_actuator["fan"] = actuator.fan;
    js_actuator["pump"] = actuator.pump;
    sendMessageWithJson(205, tkn, js_actuator);
  }
}

void handleControlMessage() {
  // Deserialize the JSON document
  uint8_t tkn = (uint8_t)requestMessage[1];
  StaticJsonDocument<200> doc;

  DeserializationError error = deserializeJson(doc, requestMessage + 3);
  if (error) {
    sendMessageWithString(404, requestMessage[1], "json deserialization error");
    return;
  }

  if (strcmp("led", doc["path"]) == 0) {
    if (doc["value"] != true && doc["value"] != false) {
      sendMessageWithString(404, requestMessage[1], "invalid value error");
      return;
    }

    actuatorToSync.led = doc["value"];
  } else if (strcmp("fan", doc["path"]) == 0) {
    if (doc["value"] != true && doc["value"] != false) {
      sendMessageWithString(404, requestMessage[1], "invalid value error");
      return;
    }

    actuatorToSync.fan = doc["value"];
  } else if (strcmp("pump", doc["path"]) == 0) {
    if (doc["value"] != true && doc["value"] != false) {
      sendMessageWithString(404, requestMessage[1], "invalid value error");
      return;
    }

    actuatorToSync.pump = doc["value"];
  } else {
    sendMessageWithString(404, requestMessage[1], "invalid path error");
    return;
  }

  sendMessageWithString(204, requestMessage[1], "changed");
}

void handleRequestMessage() {
  // code check
  if (requestMessage[0] == 0) {
    // handle init information request
    sendMessageWithJson(205, requestMessage[1], INFO);
  } else if (requestMessage[0] == GET) {
    // handle query request
    handleQueryMessage();
    // sendMessage(205, requestMessage[1], makeStatusJson());
  } else if (requestMessage[0] == POST) {
    // handle control message
    handleControlMessage();
  }
}

void sendMessageWithJson(uint8_t code, uint8_t token,
                         JsonVariantConst payload) {
  Serial.write(code);
  Serial.write(token);
  serializeJson(payload, Serial);
  Serial.write(255);
}

void sendMessageWithString(uint8_t code, uint8_t token, char *payload) {
  Serial.write(code);
  Serial.write(token);
  Serial.write(payload);
  Serial.write(255);
}

void syncActuatorStatus() {
  if (actuator.led != actuatorToSync.led) {
    actuator.led = actuatorToSync.led;
    digitalWrite(LAMP, actuator.led);
  }

  if (actuator.fan != actuatorToSync.fan) {
    actuator.fan = actuatorToSync.fan;
    SoftPWM.set(actuator.fan ? 65 : 0);
  }

  if (actuator.pump != actuatorToSync.pump) {
    actuator.pump = actuatorToSync.pump;
    digitalWrite(PUMP, actuator.pump);
  }
}

void sensing() {
  /* DHT22 data acquisition */
  sensors_event_t event1;
  sensors_event_t event2;

  dht.temperature().getEvent(&event1); // DHT22_Temperature
  sensor.temp = event1.temperature;

  dht.humidity().getEvent(&event2); // DHT22_Humidity
  sensor.humi = event2.relative_humidity;

  sensor.soilHumi =
      map(analogRead(SOILHUMI), 0, 1023, 100, 0); // soil humiditiy

  drawLogo();
}

unsigned long previousMillis = 0;
void loop() {
  bool isRead = false;

  if (millis() - previousMillis >= interval) {
    sensing();
  }

  if (readRequestMessage()) {
    handleRequestMessage();
  }

  syncActuatorStatus();
}
