#include "Wasp3G.h"

int answer;

void setup(){
    _3G.OFF();
    PWR.setSensorPower(SENS_3V3, SENS_ON);
    pinMode(ANA6,OUTPUT); // Configures pins for IR cut filter and LED light
    pinMode(DIGITAL1,OUTPUT);
    pinMode(DIGITAL3,OUTPUT);
    pinMode(DIGITAL8,OUTPUT);
    pinMode(DIGITAL6,OUTPUT);
    digitalWrite(ANA6,HIGH);
    digitalWrite(DIGITAL1,HIGH);
    digitalWrite(DIGITAL3,HIGH);
    digitalWrite(DIGITAL8,LOW);
    digitalWrite(DIGITAL6,LOW);
    pinMode(GPS_PW,OUTPUT);
    digitalWrite(GPS_PW,LOW);
}


void loop(){


    while(USB.available() == 0);

    do{
        answer = USB.read();
        switch (answer)
        {
        case 'a':
            _3G.powerIRLED(0);
            break;
        case 's':
            _3G.powerIRLED(1);
            break;
        case 'd':
            _3G.powerIRLED(2);
            break;
        case 'f':
            _3G.powerIRLED(3);
            break;
        case 'q':
            _3G.selectFilter(0);
            break;
        case 'w':
            _3G.selectFilter(1);
            break;
        }
        delay(100);
    }while(USB.available() > 0);



}




