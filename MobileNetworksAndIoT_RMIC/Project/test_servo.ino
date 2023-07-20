#include<Servo.h>
// 180 horizontal MAX
Servo horizontal; // horizontal servo
int servoh = 90; // 90; // stand horizontal servo
int servohLimitHigh = 180;
int servohLimitLow = 0;
// 65 degrees MAX
Servo vertical; // vertical servo
int servov = 45; // 90; // stand vertical servo
int servovLimitHigh = 180;
int servovLimitLow = 0;
void setup() {
  // put your setup code here, to run once:
  horizontal.attach(9);
  vertical.attach(10);
  horizontal.write(90);
  vertical.write(45);

  delay(3000);
}

void loop() {
  // put your main code here, to tun repeatedly:

  int dtime = 10; int tol = 50;
  int lt = analogRead(0); // top left
  int rt = analogRead(1); // top right
  int ld = analogRead(2); // down left
  int rd = analogRead(3); // down right

  int avt = (lt + rt) / 2; // average value top
  int avd = (ld + rd) / 2; // average value down
  int avl = (lt + ld) / 2; // average value left
  int avr = (rt + rd) / 2; // average value right

  int dvert = avt - avd; // check the difference of up and down
  int dhoriz = avl - avr;
  
  //==============================================
  if (-1*tol > dvert || dvert > tol){
    if (avt<avd){
      servov = servov + 1;
      if (servov > servovLimitHigh){
        servov = servovLimitHigh;      
      }
      vertical.write(servov);
      delay(20);
    }
    else if(avt>avd){
      servov = servov - 1;
      if (servov < servovLimitLow){
        servov = servovLimitLow;
      }
      vertical.write(servov);
      delay(20);
    }
    else if(avt==avd){
      //nothing
    }
  }

  //==============================================
  if (-1*tol > dhoriz || dhoriz > tol){
    if(avl>avr){
      servoh = servoh - 1;
      if (servoh > servohLimitHigh){
        servoh = servohLimitHigh;    
      }
      horizontal.write(servoh);
      delay(20);
    }
    else if(avl<avr){
      servoh = servoh + 1;
      if (servoh < servohLimitLow){
        servoh = servohLimitLow;        
      }
      horizontal.write(servoh);
      delay(20);      
    }
    else if(avl==avr){
      //nothing
    }
  }

  //==============================================
  
  delay(100);
  
}