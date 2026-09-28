/*
 *  ------Waspmote WIFI_30c Example--------
 *
 *  Explanation: This example shows how to send UDP broadcast messages
 *  to comunicate with the Waspmote Wifi PC program. 
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
#define IP_ADDRESS "2.139.174.70"
#define REMOTE_PORT 3000
#define INTERVAL_TIME 0x7  //each 7 seconds
#define MESSAGE "Hi_from_Waspmote"
/////////////////////////////////


void setup()
{ 
  // Then switch on the WIFI module on the desired socket. 
  WIFI.ON(socket); 
   
  // 1. Configure the transport protocol (UDP, TCP, FTP,HTTP...) 
  WIFI.setConnectionOptions(UDP); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON); 
  // 3. Configure the Authentication Key
  WIFI.setAuthKey(WPA1,AUTHKEY);
  // 4. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);
  // 5. Store values
  WIFI.storeData(); 
  
  USB.println(F("WiFi setup done"));
  
} 
 
void loop()
{ 
 // 1. Switch ON the WiFi module
  WIFI.ON(socket);

  // 2. Join Network
  if (WIFI.join(ESSID)) 
  {    
    USB.println(F("Joined AP"));

    // 4. Call the function to create the broadcast UDP messages 
    WIFI.sendAutoBroadcast(IP_ADDRESS, REMOTE_PORT, INTERVAL_TIME, MESSAGE); 
    // 5. Now the waspmote will send udp broadcast messages each 7 seconds (3). 
    delay(21000); 
    // 6. Leaves AP
    WIFI.leave();  
  }
  else
  {
    USB.println(F("NOT Connected to AP"));
  }
  
  WIFI.OFF();  
  USB.println(F("****************************"));
  delay(3000);    
  
 
} 
