#include <Arduino.h>
#include <SD.h>
#include <ESP8266WiFi.h>
#include "pitches.h"

#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "Labs-LSD"
#define WIFI_PASSWORD "aulaslsd"

/** 2. Define the API key
 *
 * The API key can be obtained since you created the project and set up
 * the Authentication in Firebase console.
 *
 * You may need to enable the Identity provider at https://console.cloud.google.com/customer-identity/providers
 * Select your project, click at ENABLE IDENTITY PLATFORM button.
 * The API key also available by click at the link APPLICATION SETUP DETAILS.
 *
 */
#define API_KEY "AIzaSyAP2czwSBofWTe92A2Vkz6Z7XCG4Jr0kRM"

/* 3. If work with RTDB, define the RTDB URL */
#define DATABASE_URL "https://iot-alarm-app-group9-default-rtdb.europe-west1.firebasedatabase.app/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app


#define TRIG 0    //D3 -> GPIO0 
#define ECHO 14   //D5 -> GPIO14
#define LED 2     //NodeMCU's builtin LED
#define BUZZER 4
#define SPEED_OF_SOUND 0.0343 //in [cm/us]


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long dataMillis = 0;
int count = 0;
bool signupOK = false;

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
WiFiMulti multi;
#endif


// defines variables
long duration; 
float distance = 15; 
bool intruder_detected = false;
int intruder_counter = 0;
bool alarm_enable = true;


void setupFireBase();
float measureDistance();
void playAlarm();
bool getAlarmEnable();
int updateDatabase(bool alarm_status, int measurements);

void setup() {
  pinMode(TRIG, OUTPUT); 
  pinMode(ECHO, INPUT); 
  pinMode(LED, OUTPUT);
  Serial.begin(115200); 
//___________________________________________-

  setupFireBase();
  
}

void loop() {

  alarm_enable = getAlarmEnable();

  distance = measureDistance();
  // Displays the distance on the Serial Monitor

  if (distance < 20){
    digitalWrite(LED, LOW);
    if(!intruder_detected) {
      intruder_detected = true;
      intruder_counter++;
      if(alarm_enable) {playAlarm();}
    }
  }
  else {
    digitalWrite(LED, HIGH); 
    intruder_detected = false;
  }

  Serial.print("measurement -> ");
  Serial.println(intruder_counter);

  updateDatabase(intruder_detected, intruder_counter);

  delay(1000);
}


void setupFireBase(){
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to Wi-Fi");
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
    }
    
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

    /* Assign the API key (required) */
    config.api_key = API_KEY;

    /* Assign the RTDB URL */
    config.database_url = DATABASE_URL;

    Firebase.reconnectWiFi(true);

    Serial.print("Sign up new user... ");

    /* Sign up */
    if (Firebase.signUp(&config, &auth, "", ""))
    {
        Serial.println("ok");
        signupOK = true;

        /** if the database rules were set as in the example "EmailPassword.ino"
         * This new user can be access the following location.
         *
         * "/UserData/<user uid>"
         *
         * The new user UID or <user uid> can be taken from auth.token.uid
         */
    }
    else
        Serial.printf("%s\n", config.signer.signupError.message.c_str());

    // If the signupError.message showed "ADMIN_ONLY_OPERATION", you need to enable Anonymous provider in project's Authentication.

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    Firebase.begin(&config, &auth);
}

float measureDistance(){
  // Clears the TRIG condition
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  // Sets the TRIG HIGH (ACTIVE) for 10 microseconds
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);  
  digitalWrite(TRIG, LOW);
  // Reads the ECHO, returns the sound wave travel time in microseconds
  duration = pulseIn(ECHO, HIGH);
  
  // Calculating the distance
  return ((float)duration * SPEED_OF_SOUND / 2); // Speed of sound wave divided by 2 (go and back)
}


void playAlarm() {  
  int noteDuration = 500;
  int note = NOTE_C4;
  
  tone(BUZZER, note, noteDuration);
  delay(noteDuration);
  noTone(BUZZER);  
}


bool getAlarmEnable() {
  bool enable_state;
  if (signupOK && Firebase.ready()) {
    String path = "enable_alert_sound";
    
    
    Serial.printf("Get alarm_enable_state... %s\n", Firebase.RTDB.getBool(&fbdo, path, &enable_state) ? enable_state ? "true" : "false" : fbdo.errorReason().c_str());
    Serial.println(path);
  }
  
  return enable_state;
}

int updateDatabase(bool alarm_status, int measurements){

  // Firebase.ready() should be called repeatedly to handle authentication tasks.
  if (signupOK && Firebase.ready()) {
    String path = "alarm_status";
    Serial.printf("Set alarm_status... %s\n", Firebase.RTDB.setBool(&fbdo, path, alarm_status) ? "ok" : fbdo.errorReason().c_str());

    path = "measurement";
    Serial.printf("Set measurement... %s\n", Firebase.RTDB.setInt(&fbdo, path, measurements) ? "ok" : fbdo.errorReason().c_str());
  }

  return 0;
}