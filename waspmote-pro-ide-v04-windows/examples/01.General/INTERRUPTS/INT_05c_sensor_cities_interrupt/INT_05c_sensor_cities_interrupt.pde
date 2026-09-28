/*
 *  ------ [INT_05c] Setting battery level interrupt example -------- 
 *
 *  Explanation: This example shows how to setup a threshold to the 
 *  Smart Cities Board and enter sleep mode until an LDR sensor
 *  interruption occurs. Then show the value returned by the sensor 
 *  board and print it.
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
 *  (at your option) any later version. 
 *  
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *  
 *  You should have received a copy of the GNU General Public License 
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>. 
 *
 *  Version:                0.1
 *  Design:                 David Gascon
 *  Implementation:         Yuri Carmona
 */


// Inclusion of the Smart Cities Sensor Board library
#include <WaspSensorCities.h>

// Variable to store the sensor read value
float value = 0;



void setup()
{
  USB.ON();
  USB.println(F("INT_05c example"));

  // Turn on the Events Sensor Board
  SensorCities.ON();

  // Init the RTC
  RTC.ON();

  // Configure sensors supply
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_AUDIO);  
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_TEMPERATURE);
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_AUDIO);
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_LD);
  delay(5000);

  // Configure the sensor threshold voltages
  SensorCities.setThreshold(SENS_CITIES_TEMPERATURE, 1.8);
  SensorCities.setThreshold(SENS_CITIES_LD, 1.5);
  SensorCities.setThreshold(SENS_CITIES_AUDIO, 1.0);
  SensorCities.setThreshold(SENS_CITIES_HUMIDITY, 0.8);
  SensorCities.setThreshold(SENS_CITIES_DUST, 1.0);
  SensorCities.setThreshold(SENS_CITIES_LDR, 2.8);
}



void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: interruptions from the Sensor Board
  ///////////////////////////////////////////////////////////////////////
  SensorCities.attachInt();

  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  //////////////////////////////////////////////////////////////////////
  // Sensor board power supply is kept. Note the input argument for 
  // sleep function is: SOCKET0_OFF. But SENS_OFF has 
  // been omitted so as to keep the Board powered on
  USB.println(F("Enter sleep mode..."));  
  PWR.sleep( SOCKET0_OFF );

  // Interruption event happened

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption: from the board 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////////////////////////////
  SensorCities.detachInt();  

  USB.ON();
  USB.println(F("Waspmote wakes up"));


  ///////////////////////////////////////////////////////////////////////
  // 4. Load the interruption register
  ///////////////////////////////////////////////////////////////////////
  // This is donde to load the shift register which permits to know which 
  // of the sensors in the board generated the interruption
  SensorCities.loadInt();


  ///////////////////////////////////////////////////////////////////////
  // 5. Check the interruption source
  ///////////////////////////////////////////////////////////////////////

  if( SensorCities.intFlag & SENS_CITIES_LDR )
  {  
    // print info
    USB.ON();
    USB.println(F("+++++++++++++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ SENS_CITIES_LDR interruption captured!! ++"));
    USB.println(F("+++++++++++++++++++++++++++++++++++++++++++++")); 
    USB.println();     

    float ldr_value;
    ldr_value = SensorCities.readValue(SENS_CITIES_LDR);

    USB.print(F("ldr_value="));
    USB.println(ldr_value);

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }
  }

  ///////////////////////////////////////////////////////////////////////
  // 6. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 7. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();

}













