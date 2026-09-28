/*  
 *  --[Pr_1] - Reading the Analog-to-Digital converter at Prototyping v20 board-- 
 *  
 *  Explanation: Turn on the Prototyping v20 board and read the 
 *  analog-to-digital converter on it once every second
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

#include <WaspSensorPrototyping_v20.h>

//Variable to store the read value
float value;

void setup()
{
  //Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(100);

  //Turn on the sensor board
  SensorProtov20.ON();
  
  //Turn on the RTC
  RTC.ON();
  
}
 
void loop()
{
  
  //Read the ADC 
  value = SensorProtov20.readADC();
  
  //Print the result through the USB
  USB.print(F("Value: "));
  USB.print(value);
  USB.println(F("V"));
  
  delay(1000);
}
