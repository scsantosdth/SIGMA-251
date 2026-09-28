/*  
 *  ------ [Ga_9] - Socket3B Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and reads the sensor
 *  placed on socket 3B every second, printing the result
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
#define RESISTOR 3   // LOAD RESISTOR of the sensor stage

// Variable to store the read value
float socket3BVal;

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

  // Configure the 3B sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET3B, GAIN, RESISTOR);

  
  // Turn on the sensor on socket 3B and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET3B);
  delay(40000);
 
}
 
void loop()
{
  
  // Read the sensor 
  socket3BVal = SensorGasv20.readValue(SENS_SOCKET3B);
  
  // Print the result through the USB
  USB.print(F("SOCKET3B: "));
  USB.print(socket3BVal);
  USB.print(F("V - "));
  
  // Conversion from voltage into kiloohms
  socket3BVal = SensorGasv20.calculateResistance(SENS_SOCKET3B, socket3BVal, GAIN, RESISTOR);
  USB.print(socket3BVal);
  USB.println("kohms");
  
  
  delay(1000);
}
