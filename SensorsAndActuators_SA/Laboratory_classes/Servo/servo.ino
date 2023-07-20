#include <Servo.h>

Servo myservo;  // Create servo object to control a servo

int pos = 0;    // Variable to store the servo position

void setup() {
  Serial.begin(9600);
  myservo.attach(10);  // Attach the servo on pin 10 to the servo object
}

void loop() {
  myservo.writeMicroseconds(850); // 0º considered
  delay(2000);
  myservo.writeMicroseconds(1550); // 90º considered
  delay(2000);

  // Code part to rotate 6º per second (pulse Width=47us) from 0º to 90º
  for (pos = 850; pos <= 1550; pos += 47){ // Start at 0º and increment 6º at each second, rotate 15 positions
    myservo.writeMicroseconds(pos);        // Make servo rotate to the wanted position (6º, 12º, 18º, 24º, 30º, 36º, 42º, 48º, 54º, 60º, 66º, 72º, 78º, 84º, 90º)
    delay(1000);                           // Waits 1s for the servo to reach the position
  }
  
  // Code part to rotate 6º per second (pulse Width=47us) from 90º to 0º
  for (pos = 1550; pos >= 850; pos -= 47){  // Start at 90º and decrement 6º at each second
    myservo.writeMicroseconds(pos);         // Make servo rotate to the wanted position (90º, 84º, 78º, 72º, 66º, 60º, 54º, 48º, 42º, 36º, 30º, 24º, 18º, 12º, 6º)
    delay(1000);                            // Waits 1s for the servo to reach the position
  }

  // Code part to rotate as fast as possible 90º
  myservo.writeMicroseconds(1550);
  delay(2000);
}
