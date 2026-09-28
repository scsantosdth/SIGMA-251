/*
 *  ------Waspmote WIFI_06 Example--------
 *
 *  Explanation: This example shows how to connect to an AP in manual mode.
 *  MANUAL MODE implies the user indicates the ESSID of the network when 
 *  joining without storing this ESSID in module's memory.
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L.
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


unsigned long previous;

void setup()
{
  // Switch on the WIFI module on the desired socket.
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP,HTTP...)
  WIFI.setConnectionOptions(UDP);
  // 2. Configure the way the modules will resolve the IP address.
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
  // switch WiFi ON 
  WIFI.ON(socket);

  // get actual time
  previous=millis();
  
  // If it is manual, call join giving the name of the AP
  if (WIFI.join(ESSID))
  {
    // Now you are connected to AP
    USB.print(F("Connected to AP."));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);
    delay(5000);
    // Leave Access Point
    WIFI.leave();
  }
  else
  {
    USB.print(F("ERROR Connecting to AP."));  
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
  // delay 2 seconds
  delay(2000);
}

