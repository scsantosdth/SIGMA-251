/*
 *  ------Waspmote WIFI_29a Example--------
 *
 *  Explanation: This example shows the way to communicate with  
 *  the Waspmote Wifi Demo iPhone app. 
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
#define ESSID "iPHONE_ADHOC"
#define AUTHKEY "password"
/////////////////////////////////

// Specifies the message that is sent to the WiFi module. 
char tosend[128]; 

void setup()
{ 
  // Initialize the accelerometer 
  ACC.ON(); 
  
  // Then switch on the WIFI module on the desired socket. 
  WIFI.ON(socket); 

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...) 
  WIFI.setConnectionOptions(CLIENT_SERVER|UDP); 
  // 2. Configure the way the modules will resolve the IP address. 
  WIFI.setDHCPoptions(AUTO_IP); 
  // 3. Configure how to connect the AP. 
  WIFI.setAutojoinAuth(ADHOC); 
  // 3.1 Sets the name of the ADhoc network. 
  WIFI.setESSID(ESSID); 
  // 3.2 Sets the channel of the ADhoc network 
  WIFI.setChannel(6); 
  // 4. Configure how to connect the AP 
  WIFI.setJoinMode(MANUAL); 
  // 5. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 6. Save Data to module's memory
  WIFI.storeData();
} 

void loop()
{ 
  // Call function to create/join the Adhoc network. 
  if(WIFI.setJoinMode(CREATE_ADHOC))
  { 
    // Switches on green led. 
    Utils.setLED(LED1, LED_ON); 
    
    // Creates UDP connection. 
    if (WIFI.setUDPclient("255.255.255.255",12345,2000))
    { 
      // Now we can use send and read functions to send and 
      // receive UDP messages. 
      while(1)
      { 
        // Sends data to the IOS smartphone 
        sprintf(tosend,"Wasp-1;19;24;70;20;383;0;%d;%d;%d", 
        ACC.getX(),ACC.getY(),ACC.getZ()); 
        WIFI.send(tosend); 
        // Reads data to the IOS smartphone 
        WIFI.read(NOBLO); 
        // Waspmote acts depending on the answer. 
        uint8_t period = (WIFI.answer[6] - 48) * 10 + (WIFI.answer[7] - 48); 
        if (period<11)
        { 
          // Switches on a lamp with intensity= period % (...) 
        } 
        delay(100); 
      } 
    }
    else
    {
      USB.println(F("UDP client NOT set"));
    } 
  }
  else
  {
    USB.println(F("Error joining"));
  } 
} 



