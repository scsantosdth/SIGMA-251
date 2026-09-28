/*
 *  ------Waspmote WIFI_19 --------
 *
 *  Explanation: This example shows how to create a broadcast UDP 
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

// WiFi AP settings 
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

// UDP server settings
/////////////////////////////////
#define IP_ADDRESS     "???.???.???.???"
#define REMOTE_PORT    3000
#define LOCAL_PORT     2000
#define TIME_INTERVAL  0x7
#define MESSAGE        "BROADCAST_TEST"
/////////////////////////////////


void setup()
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
  WIFI.setConnectionOptions(UDP);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);  
  // 3. set Auth key 
  WIFI.setAuthKey(WPA1,AUTHKEY);
  // 4. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL);
  // 5. Store values
  WIFI.storeData();
  
  
}

void loop()
{
  // switch WiFi ON 
  WIFI.ON(socket); 
  
  // Join AP
  if( WIFI.join(ESSID) )
  {
    USB.println(F("joined!"));
    
    // Call the function to create the broadcast UDP messages 
    WIFI.sendAutoBroadcast(IP_ADDRESS, REMOTE_PORT, TIME_INTERVAL, MESSAGE);
    
    // Now the waspmote will send udp broadcast messages each 7 seconds 
    delay(20000);
    
    // leave AP
    WIFI.leave();
  }
  else
  {
    USB.println(F("NOT joined"));
  }
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
  USB.println(F("*****************************"));
  
  // delay 2 seconds
  delay(2000); 
}
