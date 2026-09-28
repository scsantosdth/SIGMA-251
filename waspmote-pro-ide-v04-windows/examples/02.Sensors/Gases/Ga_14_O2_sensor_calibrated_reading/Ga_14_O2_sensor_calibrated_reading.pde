/*  
 *  ------ [Ga_13] - Oxygen Calibrated sensor Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and reads the O2 sensor
 *  every second, printing the result through the USB
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.1 
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspSensorGas_v20.h>

#define GAIN_O2  1000  //GAIN of the sensor stage

// CONCENTRATION VALUES: OXYGEN HAS A MANDATORY ZERO-ARRAY
int calibrationConcentration[3] = {0,0,0};

// INTRODUCE IN THE NEXT ARRAY THE CALIBRATION OUTPUT OF THE SENSORS
float calibrationOutput[3] = { 0.3354, 0, 0};

//Variable to store the read O2 value
float o2Val;
float percentageVal;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorGasv20.ON();

  // Turn on the RTC
  RTC.ON();

  // Configure the O2 sensor socket
  SensorGasv20.configureSensor(SENS_O2, GAIN_O2);

  // Turn on the O2 sensor and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_O2);
  delay(1000);
  
}
 
void loop()
{  
  // 1. Read mean voltage value 
  o2Val = 0;  
  for(int i=0; i<5; i++)
  {  
    o2Val = o2Val + SensorGasv20.readValue(SENS_O2);  
    delay(100);  
  }  
  o2Val = o2Val/5;
  
  // 2. Print mean voltage value 
  USB.print(o2Val);
  USB.print(F("volts - "));
  
  // 3. Conversion from output voltage to oxygen percentage level
  percentageVal = SensorGasv20.calculateConcentration(calibrationConcentration,calibrationOutput,o2Val);
  USB.print(percentageVal);
  USB.println(F("%"));
  
  delay(1000);

}
