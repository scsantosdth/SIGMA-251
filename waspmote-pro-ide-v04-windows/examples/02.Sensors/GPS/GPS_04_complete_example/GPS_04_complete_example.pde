/*  
 *  ------ [GPS_04] - Complete example  -------- 
 *  
 *  Explanation: This example shows how to use the different functions
 *  of the Waspmote GPS API. Basic data is requested using specific 
 *  functions for each parameter. Finally, ephemeris are used in order 
 *  to connect easily to satellites.
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

long time=0;



void setup()
{

  // open USB port
  USB.ON();

  // setup the GPS module
  USB.println(F("GPS_04 example"));

  // Inits SD pins
  SD.ON();

  // set GPS on
  GPS.ON();

  // Gets Power Mode  
  USB.print(F("Power Mode: "));
  switch( GPS.getMode() )
  {
  case GPS_ON:   
    USB.println(F("GPS_ON"));
    break;
  case GPS_OFF:  
    USB.println(F("GPS_OFF"));
    break;
  }

  USB.println(F("--------------------------------"));


}



void loop()
{  
  // set GPS on
  GPS.ON();

  ///////////////////////////////////////////////////
  // 1. wait for GPS signal for specific time
  ///////////////////////////////////////////////////
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

  ///////////////////////////////////////////////////
  // 2. get parameters from GPS module (parameter-dedicated functions)
  ///////////////////////////////////////////////////  
  if( status == true)
  {
    // Getting Time
    GPS.getTime();  
    USB.print(F("Time [hhmmss.sss]: "));
    USB.println(GPS.timeGPS);

    // Getting Date  
    GPS.getDate();
    USB.print(F("Date [ddmmyy]: "));
    USB.println(GPS.dateGPS);

    // Getting Latitude  
    GPS.getLatitude();
    USB.print(F("Latitude [ddmm.mmmm]: "));
    USB.println(GPS.latitude);
    USB.print(F("North/South indicator: "));
    USB.println(GPS.NS_indicator);
    USB.print("Latitude (degrees):");
    USB.println(GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator));

    // Getting Longitude
    GPS.getLongitude();
    USB.print(F("Longitude [dddmm.mmmm]: "));
    USB.println(GPS.longitude);
    USB.print(F("East/West indicator: "));
    USB.println(GPS.EW_indicator);
    USB.print("Longitude (degrees):");
    USB.println(GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator));

    // Getting Altitude
    GPS.getAltitude();
    USB.print(F("Altitude [m]: "));
    USB.println(GPS.altitude);

    // Getting Speed
    GPS.getSpeed();
    USB.print(F("Speed [km/h]: "));
    USB.println(GPS.speed);

    // Getting Course  
    GPS.getCourse();
    USB.print(F("Course [degrees]: "));
    USB.println(GPS.course);  
    USB.println(F("--------------------------------"));
  }  

  ///////////////////////////////////////////////////
  // 3. store/load ephemeris
  ///////////////////////////////////////////////////  
  if( status == true )
  {
    // Save ephemeris in the default file: EPHEM.TXT  
    USB.print(F("Store ephemeris in EPHEM.TXT. (ok=1; error=0): "));
    USB.println(GPS.saveEphems(),DEC);

    // Save ephemeris in the selected file: "FILE" 
    USB.print(F("Store ephemeris in the selected file:'FILE'. (ok=1; error=0): "));
    USB.println(GPS.saveEphems("FILE"),DEC);

    delay(5000);

    // Load ephemeris from the default file: EPHEM.TXT 
    USB.print(F("Load ephemeris from EPHEM.TXT. (ok=1; error=0): "));
    USB.println(GPS.loadEphems(),DEC);

    // Load ephemeris from the selected file: "FILE"
    USB.print(F("Load ephemeris from selected file:'FILE'. (ok=1; error=0): "));
    USB.println(GPS.loadEphems("FILE"),DEC);
    USB.println(F("--------------------------------"));

  }    

  // switch GPS off
  GPS.OFF();
  delay(1000);
}


