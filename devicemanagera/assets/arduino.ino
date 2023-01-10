/*
   IoT SMART FARM_V2
*/

#include <DHT_U.h>
// #include <VitconBrokerComm.h>
#include <ArduinoJson.h>
#include <SoftPWM.h>
#include <U8g2lib.h>  //U8g2 by oliver 라이브러리 설치 필요
U8G2_SH1106_128X64_NONAME_F_SW_I2C u8g2(U8G2_R0, SCL, SDA, U8X8_PIN_NONE);

// using namespace vitcon;
#define DHTPIN A1
#define DHTTYPE DHT22
#define LAMP 17
#define PUMP 16
#define SOILHUMI A6

DHT_Unified dht(DHTPIN, DHTTYPE);
SOFTPWM_DEFINE_CHANNEL(A3);  // Arduino pin A3

int Soilhumi = 0;
float Temp = 0;
float Humi = 0;
int fanVal = 0;

int mode = 0;

bool fan_out_status;
bool pump_out_status;
bool lamp_out_status;

uint8_t controlMessage[100];
int controlMessageLength = 0;
uint8_t latestControlMessageToken = 0;
uint8_t processedControlMessageToken = 0;
uint8_t controlMessageSequence = 0;
uint8_t processedControlMessageSequence = 0;

/* A set of definition for IOT items */
#define ITEM_COUNT 18

void drawLogo() {
  u8g2.clearBuffer();

  u8g2.setFont(u8g2_font_ncenB08_te);
  u8g2.drawStr(1, 15, " ETRI - SMART FARM");

  u8g2.drawStr(15, 36, "Temp.");
  u8g2.setCursor(85, 36);
  u8g2.print(Temp);
  u8g2.drawStr(114, 36, "\xb0");
  u8g2.drawStr(119, 36, "C");

  u8g2.drawStr(15, 47, "Humidity");
  u8g2.setCursor(85, 47);
  u8g2.print(Humi);
  u8g2.drawStr(116, 47, "%");

  u8g2.drawStr(15, 58, "Soil Humi.");
  u8g2.setCursor(85, 58);
  u8g2.print(Soilhumi);
  u8g2.drawStr(116, 58, "%");

  u8g2.sendBuffer();
}
StaticJsonDocument<1000> makeStatusJson();
StaticJsonDocument<1000> makeAckJson(char *tkn);

StaticJsonDocument<100> INFO;
String sname = "devicemanagera";
String uuid = "etri-ZXRyaQ==";

void setup() {
  Serial.begin(57600);
  //   comm.SetInterval(200);

  mode = 0;

  INFO["uuid"] = uuid;
  INFO["sname"] = sname;

  pinMode(LAMP, OUTPUT);
  pinMode(PUMP, OUTPUT);
  pinMode(SOILHUMI, INPUT);

  // 초기설정
  digitalWrite(LAMP, LOW);
  digitalWrite(PUMP, LOW);

  u8g2.begin();
  dht.begin();

  // begin with 60hz pwm frequency
  SoftPWM.begin(490);
}

bool readControlMessage() {
  uint8_t recvValue = 0;

  controlMessageLength = 0;

  while (true) {
    recvValue = Serial.read();
    if (recvValue == 255) {
      break;
    }

    controlMessage[controlMessageLength] = recvValue;
    controlMessageLength++;
  }

  if (controlMessage[2] != controlMessageLength) {
    return false;
  }

  if (controlMessageLength < 3) {
    return false;
  }

  latestControlMessageToken = controlMessage[1];
  controlMessageSequence = (controlMessageSequence + 1) % 256;
  return true;
}

void processControlMessage() {
  if (processedControlMessageToken == latestControlMessageToken) {
    processedControlMessageSequence = controlMessageSequence;
    sendMessage(200);
    return;
  }

  // code check
  if (controlMessage[0] == 11 && mode == 0) {
    // process init control message
    mode = 1;
  } else if (controlMessage[0] == 10 && mode == 1) {
    mode = 0;
  } else if (controlMessage[0] == 2 && mode == 1) {
    fan_out_status = controlMessage[3] == 't';
    lamp_out_status = controlMessage[4] == 't';
    pump_out_status = controlMessage[5] == 'f';

    if (fan_out_status) {
      SoftPWM.set(65);
    } else {
      SoftPWM.set(0);
    }
    digitalWrite(LAMP, lamp_out_status);
  }

  processedControlMessageSequence = controlMessageSequence;
  processedControlMessageToken = latestControlMessageToken;
  sendMessage(200);
}

void sendMessage(uint8_t code) {
  Serial.write(code);
  if (code == 200) {
    Serial.write(processedControlMessageToken);
  } else {
    serializeJson(makeStatusJson(), Serial);
  }

  Serial.write(255);
}

StaticJsonDocument<1000> makeStatusJson() {
  // return status report message
  StaticJsonDocument<1000> body;
  body["Temp"] = Temp;
  body["Humidity"] = Humi;
  body["SoilHumi"] = Soilhumi;
  body["lamp"] = lamp_out_status;
  body["fan"] = fan_out_status;

  StaticJsonDocument<1000> msg;
  msg["code"] = 1;
  msg["body"] = body;

  return msg;
}


void broadcastUUID() {
  Serial.write(199);
  serializeJson(INFO, Serial);
  Serial.write(255);
}

void operate() {
  char cmd[1000];
  int idx = 0;

  /* DHT22 data acquisition */
  sensors_event_t event1;
  sensors_event_t event2;

  dht.temperature().getEvent(&event1);  // DHT22_Temperature
  Temp = event1.temperature;

  dht.humidity().getEvent(&event2);  // DHT22_Humidity
  Humi = event2.relative_humidity;

  Soilhumi = map(analogRead(SOILHUMI), 0, 1023, 100, 0);  // soil humiditiy

  drawLogo();
  sendMessage(201);
}

void loop() {
  if (Serial.available()) {
    readControlMessage();
  }

  if (controlMessageSequence != processedControlMessageSequence) {
    processControlMessage();
    return;
  }

  if (mode == 0) {
    broadcastUUID();
  } else {
    operate();
  }

  delay(1000);
}