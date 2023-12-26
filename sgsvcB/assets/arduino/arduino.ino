/*
   IoT SMART FARM_V2
*/
#include <ArduinoJson.h>
#include <Servo.h>
#include <DHT.h>
// #include <Wire.h>
#include <LiquidCrystal_I2C.h>

#define LIGHTPIN 4
#define SERVOPIN 9
#define DHTTYPE DHT11
#define DHTPIN 12
#define WATER_PUMP_PIN 31
#define FAN_PIN 32

int RBG_R = 23;
int RBG_G = 35;
int RBG_B = 36;

int light = 0;
int fan = 0;
int servo_angle = 0;

DHT dht(DHTPIN, DHTTYPE);
LiquidCrystal_I2C lcd(0x27, 16, 2);
Servo servo;

StaticJsonDocument<1000>  makeStatusJson();
StaticJsonDocument<1000>  makeAckJson(char* tkn);

StaticJsonDocument<100> INFO;
String sname = "devicemanagerb";
String uuid = "DEVICE-B-UUID";

int mode = 0;

void printLCD(int col, int row, char *str)
{
    for (int i = 0; i < strlen(str); i++)
    {
        lcd.setCursor(col + i, row);
        lcd.print(str[i]);
    }
}

void initSensorAndActuator()
{
    analogWrite(LIGHTPIN, light);
    digitalWrite(FAN_PIN, fan);
    servo.attach(SERVOPIN);
    servo.write(servo_angle);
    delay(500);
    servo.detach();
}

int Soilhumi = 0;
float Temp = 0;
float Humi = 0;
int fanVal = 0;
bool fan_out_status;
bool lamp_out_status;
// function for loop
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

void setup() {
  printLCD(0, 0, "ETRI Smart Farm ");
  printLCD(0, 1, "Are You Ready? ");
  Serial.begin(115200); // Serial Monitor for Debug
    while (!Serial)
        ;

  mode = 0;

  INFO["uuid"] = uuid;
  INFO["sname"] = sname;
  INFO["code"] = 0;

  initSensorAndActuator();

  dht.begin();
}

void operate(){

}

void loop(){
  if(mode == 0){
    initialize();
  }else{
    operate();
  }
}
