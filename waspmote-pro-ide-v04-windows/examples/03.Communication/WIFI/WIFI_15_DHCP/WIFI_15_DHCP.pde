/*
 *  ------Waspmote WIFI_15--------
 *
 *  Explanation: This example shows the way to use DHCP protocol
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
  WIFI.setConnectionOptions(UDP);
  
  // 2. Configure the way the modules will resolve the IP address.
  /*** DHCP MODES ***
  * DHCP_OFF   (0): Use stored static IP address
  * DHCP_ON    (1): Get IP address and gateway from AP
  * AUTO_IP    (2): Generally used with Ad-hoc networks
  * DHCP_CACHE (3): Uses previous IP address if lease is not expired
  */  
  WIFI.setDHCPoptions(DHCP_ON);
  
  // 3. Set WiFi Authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY);   
  // 4. Configure how to connect the AP
  WIFI.setJoinMode(MANUAL);
  // 5. Store Values
  WIFI.storeData();
}

void loop()
{
  // Switch WiFi ON 
  WIFI.ON(socket);
  
  // Join AP
  if(WIFI.join(ESSID))
  {        
    USB.println(F("joined AP"));
    
    USB.println(F("-----------------------"));    
    USB.println(F("get IP"));
    USB.println(F("-----------------------"));
    WIFI.getIP();
    USB.println();
  }
  else
  {    
    USB.println(F("NOT joined"));
  }
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
  USB.println(F("*************************"));
  
  // delay 2 seconds
  delay(2000);
}

