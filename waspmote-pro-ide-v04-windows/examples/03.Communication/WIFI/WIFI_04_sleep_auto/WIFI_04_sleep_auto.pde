/*
 *  ------Waspmote WIFI_04 Example--------
 *
 *  Explanation: This example shows how to configure the Wifi module 
 *  to sleep and to wake up periodically. The socket used is SOCKET0.
 *  
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

// Server settings
/////////////////////////////////
#define IP_ADDRESS "???.???.???.???"
#define REMOTE_PORT 2000 
#define TIME_INTERVAL 0x7
#define MESSAGE "AWAKE!"  
/////////////////////////////////


void setup()
{
  // 1. Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {    
    USB.println(F("Wifi switched ON"));
  }
  else
  {
    USB.println(F("Wifi did not initialize correctly"));
  }
    
  // 2. Configure the way the modules will resolve the IP address
  WIFI.setDHCPoptions(DHCP_ON);

  // 3. Configure something default to do when waking up
  WIFI.setESSID(ESSID);   

  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  
  // 5. set auto Broadcast TCP packets when waking up
  WIFI.sendAutoBroadcast(IP_ADDRESS, REMOTE_PORT, TIME_INTERVAL, MESSAGE);   

  // 6. Configures the Wifi module to sleep 10 seconds and then wake up for 30 seconds
  WIFI.setSleep(10,30); 
  
  USB.println(F("End of WiFi setup"));
  
}



void loop()
{
  // Do nothing
  USB.println(F("New loop"));
  delay(10000);

}
