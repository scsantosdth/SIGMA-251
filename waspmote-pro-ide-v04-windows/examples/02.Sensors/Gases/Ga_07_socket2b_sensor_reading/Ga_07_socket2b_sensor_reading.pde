/*  
 *  ------ [Ga_7] - Socket2B Reading for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and reads the sensor
 *  placed on socket 2B sensor every second, printing the result
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

#define GAIN  1      //GAIN of the sensor stage
#define RESISTOR 20  //LOAD RESISTOR of the sensor stage

// Variable to store the read value
float socket2BVal;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorGasv20.ON();

  // Configure the 2B sensor socket
  SensorGasv20.configureSensor(SENS_SOCKET2B, GAIN, RESISTOR);

  // Turn on the RTC
  RTC.ON();
  
  // Turn on the sensor on socket 2B and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_SOCKET2B);
  delay(40000);
 
  
}
 
void loop()
{
  
  // Read the sensor 
  socket2BVal = SensorGasv20.readValue(SENS_SOCKET2B);
  
  // Print the result through the USB
  USB.print(F("SOCKET2B: "));
  USB.print(socket2BVal);
  USB.print(F("V - "));
  
  // Conversion from voltage into kiloohms
  socket2BVal = SensorGasv20.calculateResistance(SENS_SOCKET2B, socket2BVal, GAIN, RESISTOR);
  USB.print(socket2BVal);
  USB.println(" kohms");
  
  delay(1000);
}
