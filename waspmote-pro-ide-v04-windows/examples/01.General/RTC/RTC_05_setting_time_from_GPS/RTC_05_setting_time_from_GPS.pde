/*  
 *  ------ [RTC_3] Setting time in RTC from GPS example -------- 
 *  
 *  Explanation: This example shows how to set the Time of the RTC
 *  using the Waspmote GPS
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
 *  Implementation:    Marcos Yarza
 */

#include <WaspGPS.h>

void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("RTC_5 example"));

  // Powers RTC up, init I2C bus and read initial values
  RTC.ON();
  USB.println(F("Init RTC"));
  
  // setup the GPS module
  USB.println(F("Setting up GPS..."));
  GPS.ON();
  while(!GPS.check()) delay(1000);  
  
  // GPS is connected OK
  USB.println(F("GPS connected"));
  
  // set time in RTC from GPS time (GMT time)
  GPS.setTimeFromGPS();

}

void loop()
{
  // Reading time
  USB.print(F("Time: "));
  USB.println(RTC.getTime());
  
  delay(1000); 
}
