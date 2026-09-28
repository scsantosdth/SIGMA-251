/*
 *  ------Waspmote WIFI_20a Example--------
 *
 *  Explanation: This example shows how to create a TCP client 
 *  connection. Remember to set the correct AP and TCP server settings
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

// define timeout for listening to messages
#define TIMEOUT 10000

// variable to measure time
unsigned long previous;


void setup()
{
    // setup WiFi configuration
    wifi_setup();
}

void loop()
{  
    // 1. Switch ON the WiFi module
    WIFI.ON(socket);

    // 2. Join Network
    if (WIFI.join(ESSID))  
    {
        USB.println(F("Joined AP"));

        // 3. Call the function to create a TCP connection 
        if (WIFI.setTCPclient(IP_ADDRESS, REMOTE_PORT, LOCAL_PORT)) 
        { 
            USB.println(F("TCP client set"));

            // 4. Now the connection is open, and we can use send and read functions 
            // to control the connection. Send message to the TCP connection 
            WIFI.send("TCP - Hi from Waspmote through Wifi!\r\n"); 

            // 5. Reads an answer from the TCP connection (NOBLO means NOT BLOCKING)
            USB.println(F("Listen to TCP socket:"));
            previous=millis();
            while(millis()-previous<TIMEOUT)
            {
                if(WIFI.read(NOBLO)>0)
                {
                    for(int j=0; j<WIFI.length; j++)
                    {
                        USB.print(WIFI.answer[j],BYTE);
                    }
                    USB.println();
                }

                // Condition to avoid an overflow (DO NOT REMOVE)
                if (millis() < previous)
                {
                    previous = millis();	
                }
            }

            // 6. Closes the TCP connection. 
            USB.println(F("Close TCP socket"));
            WIFI.close(); 
        } 
        else
        {
            USB.println(F("TCP client NOT set"));
        }
        // 7. Leaves AP
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





/**********************************
 *
 *  wifi_setup - function used to 
 *  configure the WIFI parameters 
 *
 ************************************/
void wifi_setup()
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

    // 3. Configure how to connect the AP 
    WIFI.setJoinMode(MANUAL); 
    // 4. Set Authentication key
    WIFI.setAuthKey(WPA1,AUTHKEY); 

    // 5. Store changes  
    WIFI.storeData();

}




