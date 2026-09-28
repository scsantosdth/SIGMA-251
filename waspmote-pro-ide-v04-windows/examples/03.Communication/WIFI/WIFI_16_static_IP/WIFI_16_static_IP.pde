/*
 *  ------Waspmote WIFI_16 Example--------
 *
 *  Explanation: This example shows the way the way to use a static 
 *  IP address
 *
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L.
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
 *  Version:                0.3
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
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

// Define static IP Address to set to WiFi module
/////////////////////////////////
#define STATIC_IP "10.10.10.20"
#define NETMASK   "255.255.255.0"
#define GATEWAY   "10.10.10.1"
/////////////////////////////////

// variable
unsigned long previous;


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
  
  // 2.1. Configure the way the modules will resolve the IP address.
  /*** DHCP MODES ***
  * DHCP_OFF   (0): Use stored static IP address
  * DHCP_ON    (1): Get IP address and gateway from AP
  * AUTO_IP    (2): Generally used with Ad-hoc networks
  * DHCP_CACHE (3): Uses previous IP address if lease is not expired
  */  
  WIFI.setDHCPoptions(DHCP_OFF);
  
  // 2.2. Configure the static IP address
  // Beware of the AP address and network mask you try to connect to
  WIFI.setIp(STATIC_IP); 
  // 2.3. set Netmask
  WIFI.setNetmask(NETMASK); 
  // 2.4. set DNS address
  WIFI.setDNS(MAIN,"8.8.8.8","www.google.com");
  // 2.5. set gateway address
  WIFI.setGW(GATEWAY);
  
  // 3. set Auth key 
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  
  // 4. Configure how to connect the AP
  WIFI.setJoinMode(MANUAL);
  // 5. Store Values
  WIFI.storeData();
}

void loop()
{
  // switch WiFi ON 
  WIFI.ON(socket);
  
  // get actual time
  previous=millis();
  
  // Join AP
  if(WIFI.join(ESSID))
  {    
    // Now you are connected to AP
    USB.print(F("Connected to AP."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
    
    USB.println(F("-----------------------"));    
    USB.println(F("get IP"));
    USB.println(F("-----------------------"));
    WIFI.getIP();
    USB.println();
    
    WIFI.resolve("www.libelium.com");
  }
  else
  {    
    USB.print(F("ERROR Connecting to AP."));  
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }  
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
  USB.println(F("\n\n******************************************************\n\n"));
  
  // delay 2 seconds
  delay(2000);
  
}
