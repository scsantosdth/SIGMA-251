/*
 *  ------Waspmote WIFI_21 Example--------
 *
 *  Explanation: This example shows how to create a TCP server 
 *  connection. 
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L.
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
 *  Version:                0.2
 *  Design:                 David Gascón
 *  Implementation:         Joaquin Ruiz
 */

// Include WIFI library 
#include <WaspWIFI.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

// TCP server settings
/////////////////////////////////
#define LOCAL_PORT 2000
/////////////////////////////////

// define time to be listening
#define TIMEOUT 60000
unsigned long previous;


void setup()
{
  wifi_setup();  
}

void loop()
{
  // switch Wifi module ON
  WIFI.ON(socket);

  // join Access Point
  if (WIFI.join(ESSID)) 
  {   
    USB.println(F("-----------------------"));    
    USB.println(F("get IP"));
    USB.println(F("-----------------------"));
    WIFI.getIP();
    USB.println();


    // Call the function to create a TCP connection on port 2000 
    if (WIFI.setTCPserver(LOCAL_PORT)) 
    { 
      USB.println(F("TCP server set"));

      // Listen for a while
      USB.print(F("Listening for incoming data during "));
      USB.print(TIMEOUT);
      USB.println(F(" milliseconds"));

      previous=millis();
      while( millis()-previous<TIMEOUT ) 
      {
        // Reads from the TCP connection 
        WIFI.read(NOBLO); 
        if(WIFI.length>0)
        {
          USB.print(F("RX: "));
          for( int k=0; k<WIFI.length; k++)
          {
            USB.print(WIFI.answer[k],BYTE);
          }
          USB.println(); 
        }
        // Condition to avoid an overflow (DO NOT REMOVE)
        if (millis() < previous)
        {
          previous = millis();	
        }
      }
      // Closes the TCP connection.
      USB.println(F("Close the TCP connection")); 
      WIFI.close(); 
    } 
    else
    {
      USB.println(F("TCP server NOT set"));
    }
  }
  else
  {
    USB.println(F("NOT Connected to AP"));
  }

  // Switch Wifi module off
  WIFI.OFF();
  USB.println(F("*************************"));
  delay(3000);  
} 




/**********************************
 *
 *  wifi_setup - function used to 
 *  configure the WIFI parameters 
 *
 ************************************/
void wifi_setup()
{  
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT_SERVER); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON);    

  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 4. Set Authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 

  // 5. Store values
  WIFI.storeData();

}






