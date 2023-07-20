#include <Arduino.h>

/*
 *  Copyright (C) 2018  Digital Incubation & Growth GmbH
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *  This software is dual-licensed. For commercial licensing options, please
 *  contact the authors (see README).
 */

/****************************************************************************/
/* Includes                                                                 */
/****************************************************************************/
// NB IoT library
#include <commandadapter.h>
#include <narrowband.h>
#include <narrowbandcore.h>
#include <nbdbg.h>
#include <nbutils.h>
#include <serialcmds.h>
#include "pitches.h"

//#define NBIOT_DEBUG1

#define SEND_INTERVAL 3000           // milliseconds

//Pin D13 (Arduino built-in LED) cannot be used because the Quectel BC66 board connects it to the RESET-N function. An external LED must be used, for example through D5.
#define LED_PIN 5 
//#define LED_PIN LED_BUILTIN

#define BUZZER_PIN 12

#define D5 11 //ECHO
#define D3 10 // trigger

char serverIP[] = "193.136.128.108";  // IP of the server
int serverPort = 5509;              // Port of the server


// NB IoT module
Narrowband::ArduinoSerialCommandAdapter ca(Serial); // Instantiate command adapter as the connection via serial
Narrowband::NarrowbandCore nbc(ca);                 // Driver class
Narrowband::FunctionConfig cfg;
Narrowband::Narrowband nb(nbc, cfg);                // instantiate NB object. 


int alarm_count = 0;
int proximity = HIGH, tx_proximity = 0;
int buzzer_enable = false;

static uint8_t mydata[4];
uint8_t rcv_buffer[12];



void setup() {
  pinMode(D3, OUTPUT); // D3 TRIGGER
  pinMode(D5, INPUT); // D5 ECHO
  pinMode(LED_PIN, OUTPUT);
     
    // connection speed to your terminal (e.g. via USB)
    //Serial.begin(115200);
    Serial.begin(9600);

    //Serial1.begin(9600);

//    Serial.print("Hit [ENTER] or wait 10s ");
//    Serial.setTimeout(10000);
//    Serial.readStringUntil('\n');


    // begin session
    nb.begin();

    digitalWrite(LED_PIN, HIGH); 
    delay(1000);
    digitalWrite(LED_PIN, LOW); 
    delay(1000);
 

    if (!nb) {
          
//        Serial.println("Error initializing NB module.");

        return;
    } else {
//        Serial.println("NB module Initialized.");
    digitalWrite(LED_PIN, HIGH); 
    delay(4000);
    digitalWrite(LED_PIN, LOW); 
    delay(4000);

    }

//    nb.getCore().setReportError(true);

    // try to attach within 15 secs
    while (!nb.isAttached()) {
        if (nb.attach(20000, 500)) {
                digitalWrite(LED_PIN, HIGH); 
//            Serial.println("Attached.");
//            delay(5*1000);
            delay(10*1000);

//            String ip;
//            if (nb.getCore().getPDPAddress(ip)) {
//                Serial.println(ip);
//            }     
        
        digitalWrite(LED_PIN, LOW); 
        
//            break;
        } else {
//            Serial.println("unable to attach to NB network.");
        }
    }
}

int getdistancelvl(){
  int duration, distance;
  // Clears the D3 condition
  digitalWrite(D3, LOW);
  delayMicroseconds(2);
  // Sets the D3 HIGH (ACTIVE) for 10 microseconds
  digitalWrite(D3, HIGH);
  delayMicroseconds(10);
  digitalWrite(D3, LOW);
  // Reads the D5, returns the sound wave travel time in microseconds
  duration = pulseIn(D5, HIGH);
  // Calculating the distance
  distance = duration * 0.034 / 2; // Speed of sound wave divided by 2 (go and back)
  delay(1000);
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");
  if(distance < 20) { 
    return LOW;
  }

  return HIGH;

}

void check_sensor(){
    int prev_proximity = proximity;
    proximity = getdistancelvl(); 
    if ( proximity == LOW ) // If the sensor's output goes low, motion is detected
    {
       buzzer_enable = rcv_buffer[0];
       if ( buzzer_enable == 1 ) 
       {
          tone(BUZZER_PIN, NOTE_A4, 1000);


       }
    
//       Serial.println("Motion detected!");
//       Serial.println(buzzer_enable);


       tx_proximity = 1;

//       if ( prev_proximity == HIGH )
//       {
          alarm_count++;
          do_send();
//       }
    }
    else
    {
//       digitalWrite(LED_PIN, LOW); 
       tx_proximity = 0;
       noTone(BUZZER_PIN);
       do_send();
//       Serial.println("No motion...");
    }     
}

void do_send(){
    bool res;
    int res_len;
    
    mydata[0] = tx_proximity;
    mydata[1] = alarm_count >> 8;
    mydata[2] = alarm_count & 0x00FF;
    mydata[3] = buzzer_enable;

//      digitalWrite(LED_PIN, HIGH);
//       delay(3000);
//       digitalWrite(LED_PIN, LOW);
//       delay(3000);

    // request something. Put in your IP address and 
    // request data.
    if ( nb.sendReceiveUDP(serverIP, serverPort, mydata, 4, rcv_buffer, 3, 15000)) {


      
        tx_proximity = 0;
      
//        Serial.print("Message sent: ");
//        Serial.print(String(mydata[0], HEX));
//        Serial.print(String(mydata[1], HEX));
//        Serial.print(String(mydata[2], HEX));
//        Serial.print(String(mydata[3], HEX));

//        Serial.print(" Received length:");
//        Serial.println(String(res_len, HEX));
        
        
        if ( res_len > 0 ) {

//           Serial.print("Message received: ");
//           Serial.println(String(respdata[0], HEX));
        }
    }
    else {
//      Serial.println("Error sending or receiving message");
    }        
}

void loop() {
//digitalWrite(LED_PIN, HIGH);
    check_sensor();
    
    //do_send();

    //delay(SEND_INTERVAL);

//    digitalWrite(LED_PIN, LOW);
//    delay(3000);


}