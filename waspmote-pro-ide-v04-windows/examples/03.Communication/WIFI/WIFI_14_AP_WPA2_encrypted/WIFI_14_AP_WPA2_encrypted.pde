/*
 *  ------Waspmote WIFI_14 Example--------
 *
 *  Explanation: This example shows how to join to a WPA2 encrypted AP
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
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(CLIENT);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  
  // *** Wifi Protected Access 2 (WPA 2) ***   
  // 3. Sets WPA2-PSK encryptation // 1-64 Character 
  WIFI.setAuthKey(WPA2, AUTHKEY); 
  
  // 4. Configure how to connect the AP
  WIFI.setJoinMode(MANUAL);
  // 5. Store Values
  WIFI.storeData();
}


void loop()
{  
  // Call join the AP 
  if (WIFI.join(ESSID)) 
  { 
    USB.println(F("joined AP"));

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
  
  // Switch WiFi OFF
  WIFI.OFF();  
  
  USB.println(F("************************"));
  
  // delay 2 seconds
  delay(2000);  

}

