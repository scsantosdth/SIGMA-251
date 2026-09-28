/*
 *  ------Waspmote WIFI_27 Example--------
 *
 *  Explanation: This example shows how to send a ping to a remote
 *  specified host
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

// define IP address to ping to
#define IP_ADDRESS "10.10.10.1"


void setup()
{
  // Switch on the WIFI module on the desired socket.
  if(WIFI.ON(socket))
  {
    USB.println(F("Switched on"));
  }
  else
  {
    USB.println(F("ERROR switching on"));
  }
  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(UDP);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);  
  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 
  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 5. Save Data to module's memory
  WIFI.storeData();
}


void loop()
{ 
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {   
    USB.println(F("Switched on"));
    
    // If it is manual, call join giving the name of the AP 
    if(WIFI.join(ESSID)) 
    { 
      USB.println(F("Joined network"));
      
      // send PING 
      WIFI.sendPing(IP_ADDRESS);
    }
    else
    {
      USB.println(F("ERROR joining"));
    }
  }
  else
  {
    USB.println(F("ERROR switching on"));
  }
  
  // switch off the module
  WIFI.OFF();
  USB.println(F("*********************"));
  delay(1000);
  
}





