/*
 *  ------Waspmote WIFI_29b Example--------
 *
 *  Explanation: This example shows the way to communicate with 
 *  the Waspmote Wifi Demo Android app.
 *    Step1: Create a WiFi AP in your smart phone with the ESSID and 
 *           password described in this example
 *    Step2: Open the WiFi app
 *    Step3: Run this Waspmote code
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
#define ESSID   "ANDROID"
#define AUTHKEY "password"
/////////////////////////////////

// Specifies the message that is sent to the WiFi module.
char tosend[128];

// answer parser
char buffer[100];
uint8_t field1;
uint8_t field2;
uint8_t field3;
uint8_t field4;

void setup()
{
  // Initialize the accelerometer
  ACC.ON();

  // Switch on the WIFI module on the desired socket.
  WIFI.ON(socket);

  // 1. Configure the transport protocol (UDP, TCP, FTP, HTTP...)
  WIFI.setConnectionOptions(UDP);
  // 2. Configure the way the modules will resolve the IP address.
  WIFI.setDHCPoptions(DHCP_ON);
  // 3. Configure how to connect the AP.
  WIFI.setJoinMode(MANUAL);
  // 4. Set the AP authentication key
  WIFI.setAuthKey(WPA1,AUTHKEY); 
  // 5. Save Data to module's memory
  WIFI.storeData();
}

void loop()
{
  // Switch ON the WiFi module on the desired socket
  if( WIFI.ON(socket) == 1 )
  {   
    USB.println(F("Switched on"));

    // If it is manual, call join giving the name of the AP 
    if(WIFI.join(ESSID)) 
    { 
      // Switches on green led to show us it's connected.
      Utils.setLED(LED1, LED_ON);

      // 4. Creates UDP connection.
      if (WIFI.setUDPclient("255.255.255.255",12345,2000))
      {
        // 5. Now we can use send and read functions to send and
        // receive UDP messages.
        while(1)
        {
          // 6. Send data to the IOS smartphone
          sprintf(tosend,"Wasp-1;19;20;21;22;23;24;%d;%d;%d;",
          ACC.getY(),ACC.getX(),ACC.getZ());
          WIFI.send(tosend);
          // Reads data to the IOS smartphone
          if( WIFI.read(NOBLO) > 0 )
          {          
            // get answers
            field1 = WIFI.answer[0] - 48;
            field2 = WIFI.answer[2] - 48;
            field3 = WIFI.answer[4] - 48;
                     
            // manage green LED with switch1
            if( field1 == 0 )
            {
              Utils.setLED( LED1, LED_ON );
            }
            else
            {
              Utils.setLED( LED1, LED_OFF );              
            }
            
            // manage red LED with switch2
            if( field2 == 0 )
            {
              Utils.setLED( LED0, LED_ON );
            }
            else
            {
              Utils.setLED( LED0, LED_OFF );              
            }       
               
          }
        }
      }
      else
      {
        USB.println(F("ERROR setting UDP client"));
      }
    }
    else
    {
      USB.println(F("ERROR joining"));
    }
  }
  else
  {
    USB.println(F("ERROR switching on"));
  }

}







