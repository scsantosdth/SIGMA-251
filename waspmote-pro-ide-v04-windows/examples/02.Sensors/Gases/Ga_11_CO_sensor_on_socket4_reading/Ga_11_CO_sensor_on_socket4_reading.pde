/*  
 *  ------ [Ga_11] - CO sensor Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and reads the CO sensor
 *  placed on socket 4 every second, printing the result
 *  through the USB
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    
 */

#include <WaspSensorGas_v20.h>

#define GAIN  1      // GAIN of the sensor stage
#define RESISTOR 100  // LOAD RESISTOR of the sensor stage

// Variable to store the read CO value
float coVal;

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

  // Configure the CO sensor on socket 4
  SensorGasv20.configureSensor(SENS_SOCKET4CO, GAIN, RESISTOR);
  
}
 
void loop()
{
  
  // Read the sensor 
  coVal = SensorGasv20.readValue(SENS_SOCKET4CO);
  
  // Print the result through the USB
  USB.print(F("CO: "));
  USB.print(coVal);
  USB.print(F("V - "));

  // Conversion from voltage into kiloohms  
  coVal = SensorGasv20.calculateResistance(SENS_SOCKET4CO, coVal, GAIN, RESISTOR);
  USB.print(coVal);
  USB.println(F("kohms"));
  
  delay(1000);
}
