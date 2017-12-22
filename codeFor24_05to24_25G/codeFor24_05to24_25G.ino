
#include <SPI.h>
//SPI params
const int DACPin = 9;
const int TurnOnPin = 10;
int dacVal = 0x3184;
bool reversedIndex = 0;
int adcCounter = 0;
//ADC params
const int pin =A0;
const unsigned long ADCinterval = 2; //interval in microsecs

unsigned long ADCtimer;
void setup()
{
  //initialize serial 
  Serial.begin(115200);
  ADCSRA &= ~(bit(ADPS0) | bit(ADPS1)| bit(ADPS2));
  ADCSRA |= bit(ADPS2); //16
  for(int i=0; i< 543; i++) analogRead(pin); // warming up
  //Serial.println(String("Sample ") + n + " times, pin=" + pin);
  Serial.flush( );
  delay(500);

  //initialize SPI
  pinMode(DACPin, OUTPUT);
  //pinMode(TurnOnPin, OUTPUT);
  digitalWrite(DACPin, HIGH);  // ensure SS stays high for now
  digitalWrite(TurnOnPin, HIGH);  // ensure SS stays high for now
  SPI.begin ();
  SPI.setBitOrder(MSBFIRST);
  SPI.setDataMode(SPI_MODE1);  //turn1T1R

  //turn 1T1R on
  digitalWrite(TurnOnPin, LOW);   
  SPI.transfer16(0x0018);
  // disable Slave Select
  digitalWrite(TurnOnPin, HIGH);
  SPI.setDataMode(SPI_MODE0);   //for DAC
  //handshake
  Serial.print('a');
  char a = 'b';
  while (a != 'a')
  {
    //wait for a specific character from the PC
    a = Serial.read();  
  }
}

void readingADC() {


   Serial.println(map(analogRead(pin), 0, 1023, 0, 255)); 
  
    // send test string
    adcCounter += 1;
    if (adcCounter >= 2) {
      adcCounter = 0;
      if (dacVal >= 0x320C) {
        reversedIndex = 1;
      } else if (dacVal <= 0x3184) {
        reversedIndex = 0;
      }
 
      digitalWrite(DACPin, LOW);    // SS is pin 10
      SPI.transfer16(dacVal);
      // disable Slave Select
      digitalWrite(DACPin, HIGH);

      if (reversedIndex) {
        dacVal -= 1;
      } else {
      dacVal += 1;
      }
    
    }
   ADCtimer = millis();

   
   
}

void loop() {
    
    Serial.flush(); 
    if ( (millis() - ADCtimer) >= ADCinterval) 
    readingADC();

  //Serial.println(runt);
   
}
