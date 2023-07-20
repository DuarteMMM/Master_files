#include <DS18B20.h>

DS18B20 ds(2);

float WarmSideTemp = 0;
float ColdSideTemp = 0;
bool sensor = false;

long last_millis = 0;
long measure_time_cold = 0;
long measure_time_warm = 0;

int i = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  if (Serial.available())
  {
    char data[20];
    byte m = Serial.readBytesUntil('\n', data, 20);
    if ( data[0] == 'M')
    {
      sensor = true;
    } else {
      sensor = false;
    }
  }
  if (sensor) {
    while (ds.selectNext()) {
        switch(i) {
          case 0:
            last_millis = millis();
            ColdSideTemp = ds.getTempC();
            measure_time_cold = millis() - last_millis;
            break;
            
          case 1:
            last_millis = millis();
            WarmSideTemp = ds.getTempC();
            measure_time_warm = millis() - last_millis;
            break;
        }
        i = (i+1)%2;
    }
    
    Serial.println(String(WarmSideTemp) + "," + String(measure_time_warm) + "," + String(ColdSideTemp) + "," + String(measure_time_cold));

  }
  
  delay(1000);
}
