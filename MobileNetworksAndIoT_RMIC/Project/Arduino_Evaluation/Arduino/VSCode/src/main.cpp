#include <Arduino.h>  
#include <string.h>
#include <WiFiNINA.h>
#include <Firebase_Arduino_WiFiNINA.h>
#include<Servo.h>

#define FIREBASE_HOST "iot-alarm-app-group9-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "haj3a1PHqkTowcwQCQHa0M1zu8LgySR2iY6zbjTI"

// WiFi SSID and password used while testing project (change later to classroom WiFi network)
#define WIFI_SSID "N3E Robotics"
#define WIFI_PASSWORD "Inferno69."

// Parameters for rotation, LDR values and panel voltage, respectively
#define step 3
#define tol 50
#define N_samples 5

// Functions
void auto_mode();
void manual_mode();
void smooth_operator_vertical(int prev_val, int new_val);
void smooth_operator_horizontal(int prev_val, int new_val);

// Parameters for panel voltage
int volt_cnt=0;
float voltage_sum;

// Bottom servo motor (horizontal)
Servo horizontal;
int servoh;
int prev_servoh;
int servohLimitHigh = 180;
int servohLimitLow = 0;

// Upper servo motor (vertical) 
Servo vertical;
int servov;
int prev_servov;
int servovLimitHigh = 180;
int servovLimitLow = 0;

int lt, rt, ld, rd; // LDR values

FirebaseData firebaseData;
String path = "/angles";
char voltJSON[20];

// To run once
void setup() {

  Serial.begin(9600);

  // Pins for servo motors
  horizontal.attach(9);
  vertical.attach(10);
 
  // WiFi and Firebase
  Serial.print("Connecting to WiFi...");
  int status = WL_IDLE_STATUS;
  while (status != WL_CONNECTED) {
    status = WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print(".");
    delay(300);
  }
  Serial.print(" IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH, WIFI_SSID, WIFI_PASSWORD);
  Firebase.reconnectWiFi(true);

  delay(3000);

  // Get angles from Firebase
  // Important: in Firebase, from -90º to 90º; in servos, from 0º to 180º (and inverted)
  Firebase.getInt(firebaseData, "angles/azimuth");
  servoh = -firebaseData.intData()+90;
  Firebase.getInt(firebaseData, "angles/elevation");
  servov = -firebaseData.intData()+90;

  prev_servoh = servoh;
  prev_servov = servov;
}

// To run repeatedly
void loop() {

  int dtime = 10;

  // LDR values
  lt = analogRead(0); // top left
  rt = analogRead(1); // top right
  ld = analogRead(2); // down left
  rd = analogRead(3); // down right

  // Auto or Manual mode
  if(!Firebase.getBool(firebaseData, "auto_mode")){
    auto_mode();
  } else {
    manual_mode();
  }
  
  Serial.println("====================================================");

  // Panel voltage
  float voltage = (float)analogRead(A5)*15/1023;
  Serial.print("Solar Panel: "); Serial.println(voltage);
  
  Serial.println("====================================================");

  // Print values in serial monitor
  Firebase.getInt(firebaseData, "angles/azimuth");
  Serial.print("Az: "); Serial.println(firebaseData.intData());
  Firebase.getInt(firebaseData, "angles/elevation");
  Serial.print("El: "); Serial.println(firebaseData.intData());
  Serial.println(!Firebase.getBool(firebaseData, "auto_mode")?"auto":"manual");
  Serial.println(!Firebase.getBool(firebaseData, "tracking")?"TRACKING":"NOT TRACKING");

  // Calculate average panel voltage (N samples) and send to Firebase (to plot)
  if (volt_cnt >= N_samples){
    volt_cnt = 0;
    voltage = (float)voltage_sum/N_samples;
    Serial.println("......................................");
    char volt_float[5];
    dtostrf(voltage, 4, 2, volt_float); 
    sprintf(voltJSON, "{\"voltage\": %s}", volt_float);
    Serial.println(Firebase.pushJSON(firebaseData, "voltage_values", voltJSON));
    Serial.println(voltJSON);  
    Serial.println("......................................");
    voltage_sum = 0;
  }else{
    voltage_sum += voltage;
    volt_cnt++;
  }
}

void auto_mode() {

  // Tracking or Not Tracking
  if(!Firebase.getBool(firebaseData, "tracking")==false){return;}

  // Average LDR values
  int avt = (lt + rt) / 2; // average value top
  int avd = (ld + rd) / 2; // average value down
  int avl = (lt + ld) / 2; // average value left
  int avr = (rt + rd) / 2; // average value right

  int dvert = avt - avd; // check the difference of up and down
  int dhoriz = avl - avr; // check the difference of left and right
  
  // Conditions for rotations and write angles in servo motors
  // Important: in Firebase, angles from -90º to 90º;
  // in servos, from 0º to 180º (and inverted), thus +step decreases angle in Firebase
  if (-1*tol > dvert || dvert > tol){
    if (avt<avd){
      servov = servov + step;
      if (servov > servovLimitHigh){
        servov = servovLimitHigh;      
      }
      vertical.write(servov);
      delay(20);
    }
    else if(avt>avd){
      servov = servov - step;
      if (servov < servovLimitLow){
        servov = servovLimitLow;
      }
      vertical.write(servov);
      delay(20);
    }
  }

  if (-1*tol > dhoriz || dhoriz > tol){
    if(avl>avr){
      servoh = servoh - step;
      if (servoh > servohLimitHigh){
        servoh = servohLimitHigh;    
      }
      horizontal.write(servoh);
      delay(20);
    }
    else if(avl<avr){
      servoh = servoh + step;
      if (servoh < servohLimitLow){
        servoh = servohLimitLow;        
      }
      horizontal.write(servoh);
      delay(20);      
    }
  }

  Serial.print("Servo Horizontal: "); Serial.println(servoh);
  Serial.print("Servo Vertical: "); Serial.println(servov);

  // Set angles in Firebase
  Firebase.setInt(firebaseData,"angles/azimuth", -servoh + 90);
  Firebase.setInt(firebaseData,"angles/elevation", -servov + 90);
}

void manual_mode(){

  // Get angles from Firebase
  prev_servov = servov;
  prev_servoh = servoh;

  Firebase.getInt(firebaseData, "angles/azimuth");
  servoh = -firebaseData.intData()+90;
  Serial.print("Az: "); Serial.println(servoh);

  Firebase.getInt(firebaseData, "angles/elevation");
  servov = -firebaseData.intData()+90;
  Serial.print("El: "); Serial.println(servov);

  // Write angles in servo motors (functions for smooth rotation)
  smooth_operator_vertical(prev_servov, servov);
  smooth_operator_horizontal(prev_servoh, servoh);
}

void smooth_operator_vertical(int prev_val, int new_val) {
  int dir = (new_val>prev_val)? 1 : -1;
  for(int i = prev_val; i != new_val; i+=dir){
    vertical.write(i);
    delay(10);
  }
}

void smooth_operator_horizontal(int prev_val, int new_val) {
  int dir = (new_val>prev_val)? 1 : -1;
  for(int i = prev_val; i != new_val; i+=dir){
    horizontal.write(i);
    delay(20);
  }
}

