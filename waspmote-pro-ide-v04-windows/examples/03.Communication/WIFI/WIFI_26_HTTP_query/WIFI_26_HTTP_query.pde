/*
 *  ------Waspmote WIFI_26 Example--------
 *
 *  Explanation: This example shows how to send a HTTP get request 
 *  message. 
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
 *  Version:                0.4
 *  Design:                 David Gascón
 *  Implementation:         Joaquin Ruiz, Yuri Carmona
 */

// Include WIFI library 
#include <WaspWIFI.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
char ESSID[] = "libelium_AP";
char AUTHKEY[] = "password";
/////////////////////////////////

// WEB server settings 
/////////////////////////////////
char HOST[] = "pruebas.libelium.com";
char URL[]  = "GET$/getpost_frame_parser.php?";
/////////////////////////////////


// define variable for communication status
uint8_t status;
uint8_t counter=0;
char body[100];
unsigned long previous;


void setup()
{
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }

  // reset to avoid previous configuration stored in the module
  //WIFI.resetValues();

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(HTTP|CLIENT_SERVER);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);   
  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 5. Save Data to module's memory
  WIFI.storeData();
  
  
  USB.println(F("Set up done"));
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
    USB.println(F("Joined"));

    /////////////////////////////////////////// 
    // Create the HTTP body with sensor data
    ///////////////////////////////////////////  
    RTC.ON();
    RTC.getTime();
    counter++;
    snprintf( body, sizeof(body), "counter=%u&hour=%02u&minute=%02u&second=%02u", counter, RTC.hour,  RTC.minute,  RTC.second );

    USB.print(F("body:"));
    USB.println(body);

    /////////////////////////////////////////// 
    // Send the HTTP get/post query (specifying the WEB server so DNS is used)
    /////////////////////////////////////////// 
    status = WIFI.getURL(DNS, HOST, URL, body);

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
      USB.println(F("\nHTTP query ERROR"));
      counter--; 
    }
  } 
  else
  {
    USB.println(F("NOT joined"));
  }
  
  
  // switch off module 
  WIFI.OFF();  
  USB.println(F("***************************"));  
  delay(1000);
} 


