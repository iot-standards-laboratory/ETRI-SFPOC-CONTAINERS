/*
   IoT SMART FARM_V2
*/

#include <DHT_U.h>
// #include <VitconBrokerComm.h>
#include <SoftPWM.h>
#include <ArduinoJson.h>
#include <U8g2lib.h>  //U8g2 by oliver 라이브러리 설치 필요
U8G2_SH1106_128X64_NONAME_F_SW_I2C u8g2(U8G2_R0, SCL, SDA, U8X8_PIN_NONE);

// using namespace vitcon;
#define DHTPIN A1
#define DHTTYPE DHT22
#define LAMP 17
#define PUMP 16
#define SOILHUMI A6

DHT_Unified dht(DHTPIN, DHTTYPE);
SOFTPWM_DEFINE_CHANNEL(A3);  //Arduino pin A3

int Soilhumi = 0;
float Temp = 0;
float Humi = 0;
int fanVal = 0;

// mode = 0 -> initial mode
// mode = 1 -> operating mode
int mode = 0;

bool timeset = false;
bool soilstatus = true;
bool tempstatus = false;
bool lampflag = true;
bool auto_1_execute = false;
bool manu_1_execute = false;

bool fan_out_status;
bool pump_out_status;
bool lamp_out_status;
bool Interval_Minute_Up_status;
bool Interval_Hour_Up_status;



uint32_t Hour = 0;
uint32_t Minute = 1;
uint32_t TimeSum = 0;
uint32_t TimeStatus;

/* A set of definition for IOT items */
#define ITEM_COUNT 18

//Interval 설정 모드로 들어가기 위한 함수
void timeset_out(bool val) {
  timeset = val;
}

//Interval 시간 단위를 설정하는 함수
void Interval_Hup(bool val) {
  Interval_Hour_Up_status = val;
}

//Interval 분 단위를 설정하는 함수
void Interval_Mup(bool val) {
  Interval_Minute_Up_status = val;
}

//manual mode일 때 FAN을 제어하는 함수
void fan_out(bool val) {
  fan_out_status = val;
}

//manual mode일 때 PUMP를 제어하는 함수
void pump_out(bool val) {
  pump_out_status = val;
}

//manual mode일 때 LAMP를 제어하는 함수
void lamp_out(bool val) {
  lamp_out_status = val;
}

//Interval을 0시 0분으로 리셋하는 함수
void IntervalReset(bool val) {
  if (!timeset && val) {
    Hour = 0;
    Minute = 0;
  }
}

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
StaticJsonDocument<1000>  makeStatusJson();
StaticJsonDocument<1000>  makeAckJson(char* tkn);

StaticJsonDocument<100> INFO;
String sname = "devicemanagera";
String uuid = "DEVICE-A-UUID";

void setup() {
  Serial.begin(115200);
  //   comm.SetInterval(200);

  mode = 0;

  INFO["uuid"] = uuid;
  INFO["sname"] = sname;
  INFO["code"] = 0;

  pinMode(LAMP, OUTPUT);
  pinMode(PUMP, OUTPUT);
  pinMode(SOILHUMI, INPUT);

  //초기설정
  digitalWrite(LAMP, LOW);
  digitalWrite(PUMP, LOW);

  u8g2.begin();
  dht.begin();

  
  // begin with 60hz pwm frequency
  SoftPWM.begin(490);
}

char latestToken[9] = "Temporary"; 

void operate();
void initialize();

void loop(){
  if(mode == 0){
    initialize();
  }else{
    operate();
  }
}
 

void broadcastUUID()
{
    serializeJson(INFO, Serial);
    Serial.println();

}

void initialize(){
  bool rcvCmd = false;
  char cmd[200];
  int idx = 0;

  rcvCmd = Serial.available();
  while(Serial.available()){
    char ch = Serial.read();
    cmd[idx] = ch;
    idx = idx+1;
    if(ch == '\n'){
      break;
    }
  }
  cmd[idx] = 0;

  if(!rcvCmd){
    broadcastUUID();
  }else{
    // when retrieve command msg
    // deserialize json
    StaticJsonDocument<1000> cmdJson;
    
    DeserializationError err = deserializeJson(cmdJson, cmd);
    if(!err && cmdJson["token"] != NULL){
      mode = cmdJson["mode"];
      serializeJson(makeAckJson(cmdJson["token"]), Serial);
    }else{
      Serial.print(cmd);
      Serial.println();
      // Serial.print("{\"code\": 400}");
    }
  }

  rcvCmd = false;
  idx = 0;
  delay(2000);
}

void operate() {
  bool rcvCmd = false;
  char cmd[1000];
  int idx = 0;

  /* DHT22 data acquisition */
  sensors_event_t event1;
  sensors_event_t event2;

  dht.temperature().getEvent(&event1);  //DHT22_Temperature
  Temp = event1.temperature;

  dht.humidity().getEvent(&event2);  //DHT22_Humidity
  Humi = event2.relative_humidity;

  Soilhumi = map(analogRead(SOILHUMI), 0, 1023, 100, 0);  //soil humiditiy

  drawLogo();

  rcvCmd = Serial.available();
  
  while(Serial.available()){
    char ch = Serial.read();
    cmd[idx] = ch;
    idx = idx+1;
    if(ch == '\n'){
      break;
    }
  }
  
  cmd[idx] = 0;

  if(!rcvCmd){
    serializeJson(makeStatusJson(), Serial);
    Serial.println();
  }else{
    // when retrieve command msg
    // deserialize json
    StaticJsonDocument<1000> cmdJson;
    
    DeserializationError err = deserializeJson(cmdJson, cmd);
    if(!err){
      if(cmdJson["code"] == 255) {
        mode = 0;
        return;
      }else if(cmdJson["code"] == 1){
        serializeJson(makeAckJson(cmdJson["token"]), Serial);
        lamp_out_status = cmdJson["body"]["lamp"];
        fan_out_status = cmdJson["body"]["fan"];
        ManualMode();
      }
      
    }else{
      Serial.print("{\"code\": 400}");
    }
    // send ack message
    
    Serial.println();
  }
  
  rcvCmd = false;
  idx = 0;
  SoftPWM.set(fanVal);
  delay(500);
}

StaticJsonDocument<1000>  makeStatusJson(){
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

StaticJsonDocument<1000>  makeAckJson(char* tkn){
  // return ack message 
  StaticJsonDocument<1000> doc;
  doc["code"] = 2;
  doc["token"] = tkn;
  return doc;
}

void ManualMode() {
  if (fan_out_status == true) {
    fanVal = 65;
  } else {
    fanVal = 0;
  }
  digitalWrite(PUMP, pump_out_status);
  digitalWrite(LAMP, lamp_out_status);
}