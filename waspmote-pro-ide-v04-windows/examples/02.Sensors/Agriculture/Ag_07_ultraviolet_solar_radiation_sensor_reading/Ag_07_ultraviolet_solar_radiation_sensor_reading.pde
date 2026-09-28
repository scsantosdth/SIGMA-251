/*  
 *  --[Ag_7] - Reading the Ultraviolet Radiation sensor at Agriculture v20 board-- 
 *  
 *  Explanation: Turn on the Agriculture v20 board and read the 
 *  Ultraviolet Radiation sensor on it once every second
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Manuel Calahorra
 */

#include <WaspSensorAgr_v20.h>

// Variable to store the read value
float value;

// Variable to store the radiation conversion value
float radiation;

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
  SensorAgrv20.setSensorMode(SENS_ON, SENS_AGR_RADIATION);
  delay(100);
  
  // Read the ultraviolet radiation sensor 
  value = SensorAgrv20.readValue(SENS_AGR_RADIATION);
  
  // Conversion from voltage into umol·m-2·s-1
  // The 2012 sensor version has a different sensitivity
  radiation = value / 0.0002;
    
  // Turn off the sensor
  SensorAgrv20.setSensorMode(SENS_OFF, SENS_AGR_RADIATION);
  
  // Part 2: USB printing
  // Print the radiation value through the USB
  USB.print(F("Radiation: "));
  USB.print(radiation);
  USB.println(F("umol*m-2*s-1"));
  
  delay(1000);
}
