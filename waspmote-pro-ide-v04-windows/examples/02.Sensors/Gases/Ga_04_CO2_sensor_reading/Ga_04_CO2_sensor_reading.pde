/*  
 *  ------ [Ga_4] - CO2 Sensor for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and read the CO2
 *  sensor every second, printing the result through the USB
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

#define GAIN  7  //GAIN of the sensor stage

// Variable to store the read CO2 value
float co2Val;

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

  // Configure the CO2 sensor socket
  SensorGasv20.configureSensor(SENS_CO2, GAIN);

  
  // Turn on the CO2 sensor and wait for stabilization and
  // sensor response time
  SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);
  delay(40000); 
 
  
}
 
void loop()
{
  
  // Read the sensor 
  co2Val = SensorGasv20.readValue(SENS_CO2);
  
  // Print the result through the USB
  USB.print(F("CO2: "));
  USB.print(co2Val);
  USB.println(F("V"));
  
  delay(1000);
}
