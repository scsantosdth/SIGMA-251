/*
 *  ------Waspmote WIFI_20b Example--------
 *
 *  Explanation: This example shows how to create a TCP client 
 *  connection using Waspmote Frames
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
// Include Frame library 
#include <WaspFrame.h>

// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket=SOCKET0;
///////////////////////////////////////

// TCP server settings
/////////////////////////////////
#define IP_ADDRESS "???.???.???.???"
#define REMOTE_PORT 3000
#define LOCAL_PORT 2000
/////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
/////////////////////////////////
#define ESSID "libelium_AP"
#define AUTHKEY "password"
/////////////////////////////////

void setup()
{
  wifi_setup();
}

void loop()
{
  // 1. Switch WiFi ON
  WIFI.ON(socket);

  // 2. Join AP
  if (WIFI.join(ESSID)) 
  {
    USB.println("Connected to AP");
    
    // 3. Call the function to create a TCP connection 
    if (WIFI.setTCPclient(IP_ADDRESS, REMOTE_PORT, LOCAL_PORT)) 
    {
      // 4. Now the connection is open, and we can use send and read functions 
      // to control the connection. 
      USB.println(F("TCP client set"));
      RTC.ON();
      RTC.getTime();
      
      // 5. Create new frame (ASCII)
      frame.createFrame(ASCII,"Waspmote_Pro"); 
      // set frame fields 
      frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() );
      frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );

      // 6. Sends to the TCP connection 
      WIFI.send(frame.buffer,frame.length);  
      
      // 7. Closes the TCP connection. 
      USB.println(F("Close TCP socket"));
      WIFI.close(); 
    }
    else
    {
      USB.println(F("TCP client NOT set"));
    } 
  }
  else
  {   
    USB.println(F("NOT Connected to AP"));
  }

  // Switch off the module
  WIFI.OFF();  
  USB.println(F("***************************"));
  delay(3000);  
}



/**********************************
 *
 *  wifi_setup - function used to 
 *  configure the WiFi parameters 
 *
 ************************************/
void wifi_setup()
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
  WIFI.setConnectionOptions(CLIENT); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(DHCP_ON);    

  // 3. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 

  // 4. Set Authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 

  // 5. Store values
  WIFI.storeData();

}

