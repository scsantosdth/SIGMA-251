/*  
 *  --[SC_7] - Reading the Crack Detection Sensor on Smart Cities board-- 
 *  
 *  Explanation: Turn on the sensor every second, taking a measurement and
 *               printing its result through the USB port.
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

#include <WaspSensorCities.h>

// Variable to store the read value
float value;

void setup()
{
  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  // Turn on the sensor board
  SensorCities.ON();
  
  // Turn on the RTC
  RTC.ON();
  
}
 
void loop()
{
  // Part 1: Sensor reading
  // Turn on the sensor and wait for stabilization and response time
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_CD);
  delay(10);
  
  // Read the crack detection sensor and print a message if a crack is detected
  if( SensorCities.readValue(SENS_CITIES_CD) )
  {
    USB.println(F("No Crack"));
  } else
  {
    USB.println(F("New Crack Detected!"));
  }
    
  // Turn off the sensor
  SensorCities.setSensorMode(SENS_OFF, SENS_CITIES_CD);
  
  delay(1000);
}
