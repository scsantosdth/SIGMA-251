/*
 *  ------Waspmote WIFI_26b Example--------
 *
 *  Explanation: This example shows how to send a HTTP get request 
 *  message using the Waspmote Frame.
 *
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
 *  Version:                0.6
 *  Design:                 David Gascón
 *  Implementation:         Joaquin Ruiz, Yuri Carmona
 */

// Include WIFI library 
#include <WaspWIFI.h>
#include <WaspFrame.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
char ESSID[] = "libelium_AP";
char AUTHKEY[] = "password";
/////////////////////////////////

// WEB server settings and QUERY sentence for Waspmote Frame
///////////////////////////////////////////////////////////////
char ADDRESS[] = "pruebas.libelium.com";
char QUERY[]  =  "GET$/getpost_frame_parser.php?frame=";
///////////////////////////////////////////////////////////////


// define variable for communication status
uint8_t status;



void setup()
{
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(HTTP|CLIENT_SERVER);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);   
  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1, AUTHKEY); 
  // 5. Save Data to module's memory
  WIFI.storeData(); 

  USB.println(F("WiFi setup done"));

}



void loop()
{ 
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  } 

  // If it is manual, call join giving the name of the AP 
  if( WIFI.join(ESSID) ) 
  { 
    USB.println(F("Joined AP"));

    ///////////////////////////////////////////
    // Sensor measurements
    ///////////////////////////////////////////  
    RTC.ON();
    RTC.getTime();

    ///////////////////////////////////////////
    // Create ASCII frame
    ///////////////////////////////////////////  

    // create new frame
    frame.createFrame(ASCII, "WASPMOTE_PRO");  

    // add frame fields
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second ); 
    frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel()); 

    // show created frame
    frame.showFrame();    

    /////////////////////////////////////////// 
    // Send the HTTP query (specifying the url address)
    ///////////////////////////////////////////     
    status = WIFI.getURL(DNS, ADDRESS, QUERY, frame.buffer, frame.length);  

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


  WIFI.OFF();
  USB.println(F("\n******************************\n"));
  delay(1000);


} 


