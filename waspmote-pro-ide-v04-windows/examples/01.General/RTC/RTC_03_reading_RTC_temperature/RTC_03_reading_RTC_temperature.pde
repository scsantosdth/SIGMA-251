/*  
 *  ------ [RTC_1] Reading RTC temperature example -------- 
 *  
 *  Explanation: This example shows how to read the temperature of the 
 *  Waspmote RTC, using its temperature sensor
 *  
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Marcos Yarza
 */

// define variable
float temperature;


void setup()
{
  
  // Open the USB connection
  USB.ON();
  USB.println(F("RTC_3 example"));

  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();
}

void loop()
{    
  // Getting Temperature
  temperature = RTC.getTemperature();
  
  // print value
  USB.print(F("Temperature: "));
  USB.println(temperature);
    
  delay(5000);  
  
}

