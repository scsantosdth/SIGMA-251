/*  
 *  ------ [GPS_02] - Using ephemeris  -------- 
 *  
 *  Explanation: Set GPS module ON. Wait until it is connected to
 *  the satellites. Then ephemeris are requested and stored in SD
 *  card. Secondly, ephemeris are loaded to the GPS module from
 *  the SD card
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

  // setup the GPS module
  USB.println("GPS_02 example");

  // Init SD
  SD.ON();

  // Turn GPS on
  GPS.ON(); 
}



void loop()
{
  ////////////////////////////////////////////////////////
  // 1. wait for GPS signal for specific time
  ////////////////////////////////////////////////////////
  status = GPS.waitForSignal(TIMEOUT);
  
  if( status == true )
  {
    USB.println(F("\n----------------------"));
    USB.println(F("Connected"));
    USB.println(F("----------------------"));
  }
  else
  {
    USB.println(F("\n----------------------"));
    USB.println(F("GPS TIMEOUT. NOT connected"));
    USB.println(F("----------------------"));
  }

  ////////////////////////////////////////////////////////
  // 2. if connected, store & load ephemeris
  ////////////////////////////////////////////////////////
  if( status == true )
  {
    // store ephemeris to SD card
    USB.print("Save Ephemeris (ok=1; error=0):");
    USB.println(GPS.saveEphems(),DEC);

    delay(5000);

    // load ephemeris from SD card
    USB.print("Load Ephemeris (ok=1; error=0):");
    USB.println(GPS.loadEphems(),DEC);
  }

}

