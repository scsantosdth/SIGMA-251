/*
 *  ------ Waspmote WIFI_08 Example --------
 *
 *  Explanation: This example shows how to join to an AP in AUTO STORE mode.
 *  In this mode the module tries to join the access point that matches the 
 *  stored SSID, passkey and channel. 
 *  In this particular example, the module tries to match a known network 
 *  with static IP so as to improve the timing of the joining process. However,
 *  it could be possible to join via DHCP protocol (non-static ip)
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
uint8_t socket = SOCKET0;
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

// define variable for time
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
    
  // 1. Configure the transport protocol:
  /* 
  *  CLIENT_SERVER (TCP)
  *  CLIENT        (TCP)
  *  HTTP          (HTTP)
  *  UDP           (UDP)
  *  SECURE        (UDP)
  */
  WIFI.setConnectionOptions(UDP);
  
  // *** STATIC IP *** 
  // 2.1. Configure the way the modules will resolve the IP address
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
  
  // *** AUTO-STORE *** 
  // 3.1. Configure the Authentication mode of the auto-join. 
  WIFI.setAutojoinAuth(WPA1); 
  // 3.2. set ESSID 
  WIFI.setESSID(ESSID);
  // 3.3. set Auth key 
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 3.4. set auto-store mode 
  WIFI.setJoinMode(AUTO_STOR);
  
  // 4. Save Data to module's memory
  WIFI.storeData();  
  
  USB.println(F("WiFi setup done"));
}

void loop()
{
  // Switch on the WiFi module
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("WiFi switched ON"));
  }
  else
  {
    USB.println(F("WiFi did not initialize correctly"));
  }
  
  // get actual time
  previous = millis();
  
  // Check connectivity for several seconds
  if( WIFI.isConnected(5000) == true ) 
  {
    // Now you are connected to AP
    USB.print(F("Connected to AP."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);

    // Displays Access Point status.
    USB.println(F("\n----------------------"));
    USB.println(F("AP Status:"));
    USB.println(F("----------------------"));
    WIFI.getAPstatus();

    // Displays IP settings.
    USB.println(F("\n----------------------"));
    USB.println(F("IP Settings:"));
    USB.println(F("----------------------"));
    WIFI.getIP();
    USB.println();
    
    // Call the function that needs a connection. 
    WIFI.resolve("www.libelium.com"); 
  }
  else
  {
    USB.println(F("not joined"));
  }
  
  // Switch off the WiFi module
  WIFI.OFF();
  USB.println(F("\n\n******************************************************\n\n"));
  delay(5000);
}


