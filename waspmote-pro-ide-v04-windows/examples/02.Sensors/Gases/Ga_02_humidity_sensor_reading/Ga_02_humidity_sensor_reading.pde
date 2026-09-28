/*  
 *  ------ [Ga_2] - Humidity Sensor for Gases v20-------- 
 *  
 *  Explanation: Turn on the Gases Board v20 and read the humidity
 *  sensor every sixteen seconds, printing the result through the USB
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

// Variable to store the read humidity value
float humidityVal;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);
}
 
void loop()
{
  // Turn on the sensor board and wait for stabilization and sensor response time
  SensorGasv20.ON();
  delay(15000); 
 
  // Read the sensor 
  humidityVal = SensorGasv20.readValue(SENS_HUMIDITY);
  
  // Turn off the sensor board
  SensorGasv20.OFF();
  
  // Print the result through the USB
  USB.print(F("Humidity: "));
  USB.print(humidityVal);
  USB.println(F("%RH"));
  
  delay(1000);
}
