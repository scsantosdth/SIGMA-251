/*  
 *  ------ [C_11] - Sending GPS values to Meshlium -------- 
 *  
 *  Explanation:  THis example shows how to obtain GPS data and 
 *  send it via WIFI POST
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Javier Siscart
 */

#include <WaspFrame.h>
#include <WaspGPS.h>
#include <WaspWIFI.h>

// Define GPS timeout when connecting to satellites
// this time is defined in seconds (240sec = 4minutes)
#define TIMEOUT 240

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
char ESSID[] = "libelium_AP";
char AUTHKEY[] = "password";
/////////////////////////////////

// MESHLIUM settings
///////////////////////////////////////////////////////////////
char ADDRESS[] = "10.10.10.1";
int REMOTE_PORT = 80;
///////////////////////////////////////////////////////////////

// Define status variable for GPS connection
bool status;

// Variable to store sleeping period. Format DD:HH:MM:SS
char sleepTime[] = "00:00:00:10"; 

// Variable to store data to be sent
char data[200];


void setup()
{
  // 0. Init USB port for debugging
  USB.ON();
  USB.println(F("C_11 Example"));


  ////////////////////////////////////////////////
  // 1. Initial message composition
  ////////////////////////////////////////////////

  // 1.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 1.2 Create new ASCII frame
  frame.createFrame(ASCII);  

  // 1.3 Set frame fields (String - char*)
  frame.addSensor(SENSOR_STR, (char*) "C_11 Example");

  // 1.4 Print frame
  frame.showFrame();


  ////////////////////////////////////////////////
  // 2. Send initial message
  ////////////////////////////////////////////////
  USB.println(F("Turning WIFI module ON"));

  // 2.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);

  // 2.2 Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(HTTP|CLIENT_SERVER);
  
  // 2.3 Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  
  // 2.4 Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);   
  
  // 2.5 Set the AP authentication key
  WIFI.setAuthKey(WPA1, AUTHKEY); 
  
  // 2.6 Save current configuration
  WIFI.storeData();
  
  // 2.7 Power off WIFI module
  WIFI.OFF();
}

void loop()
{
  ////////////////////////////////////////////////
  // 3. Measure corresponding values
  ////////////////////////////////////////////////
  USB.println(F("Obtaining GPS data..."));

  // 3.1 Set GPS ON  
  GPS.ON();  

  ///////////////////////////////////////////////
  // 3.2 Wait for GPS signal
  ///////////////////////////////////////////////
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


  ///////////////////////////////////////////////
  // 4. Message composition
  ////////////////////////////////////////////////

  // 4.1 Set mote Identifier (16-Byte max)
  frame.setID("WASPMOTE_001");	

  // 4.2 Create new frame
  frame.createFrame(ASCII);  

  // 4.3 if GPS is connected then get position
  if( status == true )
  {
    // getPosition function gets all basic data 
    GPS.getPosition();   

    USB.print("Latitude (degrees):");
    USB.println(GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator));
    USB.print("Longitude (degrees):");
    USB.println(GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator));

    // add frame fields
    frame.addSensor(SENSOR_GPS, 
    GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator),
    GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator) );
  }
  else
  {    
    // add frame fields
    frame.addSensor(SENSOR_STR,"GPS not connected");
  }

  // 4.4 Print frame
  // Example: <=>\0x80\0x03#35689884#WASPMOTE_001#...
  frame.showFrame();


  ////////////////////////////////////////////////
  // 5. Send message
  ////////////////////////////////////////////////
  USB.println(F("Turning WIFI module ON"));

  // 5.1 Switch on the WIFI module on the desired socket.
  WIFI.ON(SOCKET0);

  if (WIFI.join(ESSID)) 
  {
    USB.println(F("Joined AP"));
    
    status = WIFI.sendHTTPframe(IP,ADDRESS, REMOTE_PORT, frame.buffer, frame.length);  

    if( status == 1)
    {
      USB.println(F("\nHTTP query OK."));
      USB.print(F("WIFI.answer:"));
      USB.println(WIFI.answer);  

      /*
      * At this point, it could be possible
       * to parse the web server information
       */
    }
    else
    {
      USB.println(F("HTTP query ERROR"));
    }     
  } 
  else
  {
    USB.println(F("NOT joined"));
  }

  // 5.2 Power off WIFI module
  WIFI.OFF();


  ////////////////////////////////////////////////
  // 6. Entering Deep Sleep mode
  ////////////////////////////////////////////////
  USB.println(F("Going to sleep..."));
  USB.println();
  PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

  USB.ON();
  USB.println(F("wake"));
}



