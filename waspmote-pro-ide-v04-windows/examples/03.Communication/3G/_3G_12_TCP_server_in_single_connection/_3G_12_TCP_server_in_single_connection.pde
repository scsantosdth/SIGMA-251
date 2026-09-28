/*  
 *  ----- 3G_12 - TCP server in single connection ------- 
 *  
 *  Explanation: This example shows how to create a non-transparent TCP
 *  server in single connection and manage strings
 *  
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 3 of the License, or 
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
 *  Version:           1.2
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "Wasp3G.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

uint16_t server_port = 80;

char test_string[]="Hello Waspmote!\n";
char test_string2[]="Go to sleep Waspmote\n";
int ok, answer, counter, total_clients;
unsigned long time;

void setup()
{
    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN(apn, login, password);
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************"));
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));
    USB.println(F("**************************"));

    // 2. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("3G module ready..."));

        // 3. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (_3G.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 4. waits for connection to the network:
        answer = _3G.check(180);    
        if (answer == 1)
        {
            USB.println(F("3G module connected to the network..."));

            // 5. configures TCP connection
            USB.print(F("Setting connection..."));
            answer = _3G.configureTCP_UDP();
            if (answer == 1)
            {
                USB.println(F("Done"));

                // 6. creates a TCP server
                USB.print(F("Creating TCP server..."));  
                answer=_3G.createSocket(TCP_SERVER, server_port);
                if (answer == 1)
                {
                    USB.println(F("Done"));

                    if(_3G.getIP() == 1)
                    {
                        // if configuration is success shows the IP address
                        USB.print(F("IP address: ")); 
                        USB.println(_3G.buffer_3G);
                    }

                    // 7. waits for clients
                    time = millis();
                    do{
                        _3G.listClients();
                        delay(1000);

                        // Condition to avoid an overflow (DO NOT REMOVE)
                        if (millis() < time)
                        {
                            time = millis();	
                        }
                    }
                    while ((_3G.buffer_3G[0] == '\0') && ((millis() - time) < 300000));

                    if ((millis() - time) < 300000)
                    {  
                        counter=0;
                        total_clients=0;

                        do{
                            if( _3G.buffer_3G[counter] == '\r')
                            {
                                total_clients++;
                            }
                            counter++;                
                        }
                        while (_3G.buffer_3G[counter] != '\0');


                        USB.println(F("Clients: "));
                        USB.println(total_clients, DEC);
                        ok = 0;

                        // 8. opens a client connection
                        answer = _3G.openClient(total_clients-1);
                        if (answer == 1)
                        {
                            while (ok == 0) 
                            {
                                time = millis();

                                do{
                                    // Condition to avoid an overflow (DO NOT REMOVE)
                                    if (millis() < time)
                                    {
                                        time = millis();	
                                    }
                                    delay(10);
                                    // waits for TCP client data:
                                }
                                while((_3G.manageIncomingData() != 3) && ((millis() - time) < 300000));

                                if ((millis() - time) < 300000)
                                {                
                                    // checks the received string and compares:
                                    if (strcmp(_3G.buffer_3G, test_string) == 0)
                                    {
                                        _3G.sendData("=>Hello developer!\n\r");
                                        time = millis();
                                    }
                                    if (strcmp(_3G.buffer_3G, test_string2) == 0)
                                    {
                                        _3G.sendData("=>Bye developer\n\r");
                                        ok = 1;
                                        time = millis();
                                    }
                                }
                                else
                                {
                                    ok = 1;     
                                }
                            }

                            // 9. closes the client:
                            USB.print(F("Closing client...")); 
                            if (_3G.closeClient(total_clients-1) == 1)
                            {
                                USB.println(F("Done"));
                            }
                            else
                            {
                                USB.println(F("Fail"));
                            }
                        }
                        else
                        {
                            USB.println(F("Error opening the client")); 
                        }
                    }
                    else
                    {
                        USB.println(F("No clients connected"));
                    }

                    // 10.  closes the TCP server:
                    USB.print(F("Closing server TCP...")); 
                    if (_3G.closeSocket() == 1)
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }
                }
                else if (answer == -2)
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(_3G.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                }           
            }
            else if (answer < -14)
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
                USB.print(F("CME error code: "));
                USB.println(_3G.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module cannot connect to the network"));     
        }
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

    // 11. powers off the 3G module:
    _3G.OFF();

    USB.println(F("Sleeping..."));

    // 12. sleeps one hour:
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);


}











