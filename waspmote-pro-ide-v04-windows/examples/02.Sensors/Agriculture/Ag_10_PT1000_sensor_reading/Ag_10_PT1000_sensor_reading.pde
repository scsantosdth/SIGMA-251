/*  
 *  --[Ag_10] - Reading the PT1000 sensor at Agriculture v20 board-- 
 *  
 *  Explanation: Turn on the Agriculture v20 board and read the 
 *  PT1000 sensor on it once every second
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
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorAgr_v20.h>

// Variable to store the read value
float value;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorAgrv20.ON();
  
  // Turn on the RTC
  RTC.ON();
  
}
 
void loop()
{
  // Part 1: Sensor reading
  // Turn on the sensor and wait for stabilization and response time
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_PT1000);
  delay(10);
  
  // Read the PT1000 sensor 
  value = SensorAgrv20.readValue(SENS_AGR_PT1000);
  
  // Turn off the sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_PT1000);
  
  // Part 2: USB printing
  // Print the PT1000 temperature value through the USB
  USB.print(F("PT1000: "));
  USB.print(value);
  USB.println(F("ºC"));
  
  delay(1000);
}
