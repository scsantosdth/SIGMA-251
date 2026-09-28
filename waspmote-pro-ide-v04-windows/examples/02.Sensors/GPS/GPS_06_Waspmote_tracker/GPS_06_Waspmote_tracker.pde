/*  
 *  ------ [GPS_06] - Waspmote tracker  -------- 
 *  
 *  Explanation: This example creates a KML file for Google Earth tracking
 *  When GPS module connects to satellites, Waspmtoe starts appending data 
 *  to the KML file. When writing the SD file, the red LED lets the user 
 *  know that Waspmote shouldn't be switched off.
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
#define GPS_TIMEOUT 240

// define status variable for GPS connection
bool status;


// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="track.kml";

// ending string for KML file
char ENDING[]="</gx:Track></Placemark></kml>";



void setup()
{
  // Open USB port
  USB.ON();
  USB.println(F("Waspmote Tracker"));

  // Set GPS ON  
  GPS.ON();   

  // wait for GPS signal for specific time
  status = GPS.waitForSignal(GPS_TIMEOUT);
  
  if( status == true )
  {    
    USB.println(F("Connected"));
    Utils.blinkLEDs(3000);
  }
  else
  {
    USB.println(F("GPS TIMEOUT. NOT connected"));
  }


  // Set SD ON
  SD.ON(); 

  // Create file
  if(SD.create(filename))
  {
    USB.println(F("file created"));
    SD.appendln(filename,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    SD.appendln(filename,"<kml xmlns=\"http://www.opengis.net/kml/2.2\"");
    SD.appendln(filename," xmlns:gx=\"http://www.google.com/kml/ext/2.2\">");
    SD.appendln(filename,"<Placemark>");
    SD.appendln(filename,"\t<gx:Track>"); 
    SD.appendln(filename,ENDING); 
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 

}




void loop()
{

  // wait for GPS signal for specific time
  status = GPS.waitForSignal(GPS_TIMEOUT);

  if( status == true )
  {
    USB.println(F("Connected"));

    // getPosition function gets all basic data );
    GPS.getPosition(); 

    // Write log to SD card while Red LED is ON
    Utils.setLED(LED0,LED_ON);
    deleteEnding();
    appendTime();
    appendCoord();   
    SD.appendln(filename,ENDING);     
    Utils.setLED(LED0,LED_OFF);
  }
  else
  {
    USB.println(F("GPS TIMEOUT. NOT connected"));
  }

  delay(1000);

}

/*
 *  deleteEnding - Deletes the last KML file line
 *  in order to write new Data instead of the ending line
 */
void deleteEnding()
{  
  char empty[]="                             ";
  SD.writeSD(filename, empty, SD.getFileSize(filename)-strlen(ENDING)-1);
}


/*
 *  appendTime - append Timestamp to KML file
 */
void appendTime()
{
  char time[100];

  // create timestamp for KML format: <when>yyyy-mm-ddThh:mm:ssZ</when>
  sprintf(time,"<when>20%c%c-%c%c-%c%cT%c%c:%c%c:%c%cZ</when>",  
   GPS.dateGPS[4],
   GPS.dateGPS[5],
   GPS.dateGPS[2],
   GPS.dateGPS[3],
   GPS.dateGPS[0],
   GPS.dateGPS[1],
   GPS.timeGPS[0],
   GPS.timeGPS[1],
   GPS.timeGPS[2],
   GPS.timeGPS[3],
   GPS.timeGPS[4],
   GPS.timeGPS[5]);
  SD.appendln(filename, time);    

}


/*
*  appendCoord - appends coordinates and altitude to KML file
 */
void appendCoord()
{

  char coord[100];
  char latitude_str[30];
  char longitude_str[30];

  float latitude=GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator);
  float longitude=GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator);

  Utils.float2String(latitude, latitude_str, 6);
  Utils.float2String(longitude, longitude_str, 6);  

  sprintf(coord,"<gx:coord>%s %s %s</gx:coord>", longitude_str, latitude_str, GPS.altitude);

  SD.appendln(filename, coord); 

}


