#define ITEM_COUNT 12
#include <ArduinoJson.h>
#include <GyverNTC.h>
#include <Servo.h>
Servo myservo;

#include <U8g2lib.h>
U8G2_SH1106_128X64_NONAME_F_SW_I2C u8g2(U8G2_R0, SCL, SDA, U8X8_PIN_NONE);

#define NTC A1
#define MagnetSW A2
#define BUZZER 18
#define PERSON A6
#define LAMP_PWM 6
#define LAMP_POWER 5
#define SERVO 14

#define GET 1
#define POST 2
#define PUT 3
#define DELETE 4

const char *firmware_version = "v0.1";
const String sname = "SG-Service (Type B)";
const String sid = "sgsvc_b";
const String uuid = "etri-ZTxkAuQ1";
const long interval = 2000;

// Variable for servo motor
int pos;           // 서보모터 위치
int openPos = 180; // 현관문을 열기 위한 서보모터의 각도 지정
int closePos = 0;  // 현관문을 닫기 위한 서보모터의 각도 지정

// Variable for lamp
int light_level; // 트랙바에서 받는 LAMP 밝기 단계
int pwm_real;    // LED 램프로 출력하는 PWM값

// Variable for environmental value
GyverNTC therm(1, 10000, 3435);
float temp; // NTC 온도

uint32_t OLEDOutputDelay = 3000; // ms
uint32_t OLEDOutput_ST = 0;      // start time

typedef struct _sensor {
  float temp;
} Sensor;

typedef struct _actuator {
  bool led;
  bool door;
  bool buzzer;
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
  u8g2.drawStr(1, 15, "SF (etri-ZTxkAuQ1)");

  u8g2.drawStr(15, 47, "Temp.");
  u8g2.setCursor(85, 47);
  u8g2.print(sensor.temp);
  u8g2.drawStr(114, 47, "\xb0");
  u8g2.drawStr(119, 47, "C");

  u8g2.sendBuffer();
}

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
    sendMessageWithJson(205, tkn, js_sensor);
  } else if (query == "actuator") {
    StaticJsonDocument<100> js_actuator;
    js_actuator["led"] = actuator.led;
    js_actuator["door"] = actuator.door;
    js_actuator["buzzer"] = actuator.buzzer;
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
  } else if (strcmp("door", doc["path"]) == 0) {
    if (doc["value"] != true && doc["value"] != false) {
      sendMessageWithString(404, requestMessage[1], "invalid value error");
      return;
    }

    actuatorToSync.door = doc["value"];
  } else if (strcmp("buzzer", doc["path"]) == 0) {
    if (doc["value"] != true && doc["value"] != false) {
      sendMessageWithString(404, requestMessage[1], "invalid value error");
      return;
    }

    actuatorToSync.buzzer = doc["value"];
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
    if (actuator.led)
      analogWrite(LAMP_PWM, 0);
    else
      analogWrite(LAMP_PWM, 255);
  }

  if (actuator.door != actuatorToSync.door) {
    actuator.door = actuatorToSync.door;

    if (actuator.door) {
      pos = openPos;
    } else {
      pos = closePos;
    }

    myservo.write(pos);
  }

  if (actuator.buzzer != actuatorToSync.buzzer) {
    actuator.buzzer = actuatorToSync.buzzer;
    if (actuator.buzzer) {
      digitalWrite(BUZZER, HIGH);
    } else {
      digitalWrite(BUZZER, LOW);
    }
  }
}

void sensing() {
  sensor.temp = therm.getTempAverage();
  drawLogo();
}

void setup() {
  Serial.begin(57600);

  INFO["uuid"] = uuid;
  INFO["sname"] = sname;
  INFO["sid"] = sid;

  u8g2.begin(); // oled가 연결되지 않으면 comm.Run()실행 에러

  myservo.attach(SERVO); // 서보모터가 사용할 핀 설정(자동 pinMode설정포함)
  pinMode(MagnetSW, INPUT_PULLUP);
  pinMode(BUZZER, OUTPUT);
  pinMode(LAMP_POWER, OUTPUT);
  pinMode(LAMP_PWM, OUTPUT);

  // 초기 설정
  digitalWrite(LAMP_POWER, HIGH);
  OLEDOutput_ST = millis();
  pos = closePos;
  myservo.write(pos);
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