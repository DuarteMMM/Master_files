// Pins
#define xPin A0
#define yPin A1
#define zPin A2

// Constants
int xMin = 404;       // Experimental values obtained by meausuring the voltage for each axis (+-)1g
int xMax = 270;

int yMin = 403;
int yMax = 267;

int zMin = 415;
int zMax = 280;

long last_millis = 0;

void setup() {
  Serial.begin(9600);
  pinMode(13,OUTPUT);
  digitalWrite(13,LOW);
}

void loop() {
  int xRaw=0,yRaw=0,zRaw=0;
  for(int i=0;i<11;i++)  //Read raw values 11 times
  {
    xRaw+=analogRead(xPin);
    yRaw+=analogRead(yPin);
    zRaw+=analogRead(zPin);
  }

  //Convert raw values to 'Gs'
  float xG = map(xRaw/11, xMin, xMax, -1000, 1000) / 1000.0;
  float yG = map(yRaw/11, yMin, yMax, -1000, 1000) / 1000.0;
  float zG = map(zRaw/11, zMin, zMax, -1000, 1000) / 1000.0;

  Serial.print(xG,2);
  Serial.print("g");
  Serial.print("\t");
  
  Serial.print(yG,2);
  Serial.print("g");
  Serial.print("\t");

  Serial.print(zG,2);
  Serial.print("g");
  Serial.println();

  // Code part to detect a crash, when the acceleration is higher than (+-2g) the Arduino LED turns on for 3s

  if((abs(xG)>2.0) || (abs(yG)>2.0) || (abs(zG)>2.0)){  
    digitalWrite(13, HIGH);
    last_millis = millis();
  }

  if((millis()-last_millis) >= 3000){
    digitalWrite(13, LOW);
  }
  
  delay(200);
}