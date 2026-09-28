/*  
 *  ------ [GPS_07] - Setting RTC Time and Date from GPS module -------- 
 *  
 *  Explanation: This example show how to set the Time and Date 
 *  from the GPS data.
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
 *  Implementation:    Yuri Carmona
 */
#include <WaspGPS.h>

// define GPS timeout when connecting to satellites
// this time is defined in seconds (240sec = 4minutes)
#define TIMEOUT 240

// define status variable for GPS connection
bool status;


void setup()
{  
  // open USB port
  USB.ON();
  USB.println(F("GPS_07 example"));

  // set GPS ON  
  GPS.ON(); 

  // set RTC ON
  RTC.ON();

  //////////////////////////////////////////////////////
  // 1. wait for GPS signal for specific time
  //////////////////////////////////////////////////////
  status = GPS.waitForSignal(TIMEOUT);

  //////////////////////////////////////////////////////
  // 2. if GPS is connected then set Time and Date to RTC
  //////////////////////////////////////////////////////
  if( status == true )
  {    
    // set time in RTC from GPS time (GMT time)
    GPS.setTimeFromGPS();
    Utils.blinkLEDs(1000);
  }

}


void loop()
{
  //////////////////////////////////////////////////////
  // 3. Print time from RTC
  //////////////////////////////////////////////////////  
  USB.print(F("Time: "));
  USB.println(RTC.getTime());

  delay(5000);

  USB.println(F("----------------------"));
}


