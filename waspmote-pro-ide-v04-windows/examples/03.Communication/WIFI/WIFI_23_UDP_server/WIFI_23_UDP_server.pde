/*
 *  ------Waspmote WIFI_23 Example--------
 *
 *  Explanation: This example shows how to create an UDP Server 
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

// UDP server settings
/////////////////////////////////
#define LOCAL_PORT 2000
/////////////////////////////////

// define time to be listening
#define TIMEOUT 60000
unsigned long previous;

void setup()
{
  // Switch on the WIFI module on the desired socket.
  WIFI.ON(socket);

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(UDP); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 
  // 3. Configure the Authentication Key
  WIFI.setAuthKey(WPA1,AUTHKEY);
  // 4. Set local port
  WIFI.setLocalPort(LOCAL_PORT);
  // 5. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);  
  // 6. Store values
  WIFI.storeData();
}

void loop()
{ 
  // 1. Switch ON the WiFi module
  WIFI.ON(socket);

  // 2. Join Network
  if (WIFI.join(ESSID)) 
  {  
    USB.println(F("Joined AP"));   

    // 3. Get IP address
    USB.println(F("-----------------------"));    
    USB.println(F("get IP"));
    USB.println(F("-----------------------"));
    WIFI.getIP();
    USB.println();

    // 4. Call the function to create UDP connection in LOCAL_PORT 
    if( WIFI.setUDPserver(LOCAL_PORT) ) 
    { 
      USB.println(F("UDP server set"));

      // Listen for a while
      USB.print(F("Listening for incoming data during "));
      USB.print(TIMEOUT);
      USB.println(F(" milliseconds"));

      previous=millis();
      while( millis()-previous<TIMEOUT ) 
      {
        // Reads from the UDP connection 
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

      // Exits from UDP sending data mode. 
      USB.println(F("Close UDP socket"));
      WIFI.close(); 
    }
    else
    {
      USB.println(F("UDP server NOT set"));
    } 
  }
  else
  {
    USB.println(F("NOT Connected to AP"));
  } 

  WIFI.OFF();  
  USB.println(F("****************************"));
  delay(3000);  
}





