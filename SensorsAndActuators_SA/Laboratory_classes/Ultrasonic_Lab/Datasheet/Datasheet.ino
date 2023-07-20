/*==========================================================================
// Author : Handson Technology
// Project : HC-SR04 Ultrasonic Sensor with Arduino Uno
// Description : HC-SR04 Distance Measure with Arduino and display
// on Serial Monitor.
// LiquidCrystal Library - Special Chars
// Source-Code : HC-SR04.ino
//==========================================================================
*/

int trig=9; // Attach pin D9 of Arduino to pin Trig of HC-SR04
int echo=8; // Attach pin D8 of Arduino to pin Echo of HC-SR04
int duration;//Or long?
float distance;//Or int?
float meter;

void setup() {
  Serial.begin(9600);
  pinMode(trig, OUTPUT); // Sets the trigPin as an OUTPUT
  digitalWrite(trig, LOW);
  delayMicroseconds(2);
  pinMode(echo, INPUT); // Sets the echoPin as an INPUT
  delay(6000);
  Serial.println("Distance:");
}

void loop() {
  // Clears the trigPin condition
  //digitalWrite(trigPin, LOW);
  //delayMicroseconds(2);

  // Sets the trigPin HIGH (ACTIVE) for 10 microseconds
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);

  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echo, HIGH);
  if(duration>=38000){
    Serial.print("Out range");
  }

  else{
    distance = duration/58;
    //OR
    //distance = duration * 0.034 / 2;
    Serial.print(distance);
    Serial.print("cm");
    meter=distance/100;
    Serial.print("\t");
    Serial.print(meter);
    Serial.println("m");
  }

 delay(1000);
 //delay(100);
}