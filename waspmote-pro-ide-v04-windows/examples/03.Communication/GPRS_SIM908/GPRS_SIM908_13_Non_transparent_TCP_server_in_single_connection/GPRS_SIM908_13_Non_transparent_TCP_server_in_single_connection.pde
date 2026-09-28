/*  
 *  ----- GPRS_SIM908_13 - Non transparent TCP server in single connection ------- 
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
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_SIM908.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

char test_string[]="Hello Waspmote!\n";
char test_string2[]="Go to sleep Waspmote\n";
int ok;
int answer;
unsigned long time;

void setup()
{   
    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_SIM908.set_APN(apn, login, password);
    // And shows them
    GPRS_SIM908.show_APN();
    USB.println(F("**************************"));
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 2. activates the GPRS_SIM908 module:
    answer = GPRS_SIM908.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_SIM908 module ready..."));

        // 3. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (GPRS_SIM908.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 4. waits for connection to the network:
        answer = GPRS_SIM908.check(180);    
        if (answer == 1)
        { 
            USB.println(F("GPRS_SIM908 module connected to the network..."));

            // 5. configures IP connection
            USB.print(F("Setting connection..."));
            answer = GPRS_SIM908.configureGPRS_TCP_UDP(SINGLE_CONNECTION, NON_TRANSPARENT);
            if (answer == 1)
            {
                USB.println(F("Done"));

                // if configuration is success shows the IP address
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_SIM908.IP_dir); 

                // 6. create a TCP server
                //  “server_port” must be substituted by the desired port
                USB.print(F("Creating TCP server..."));  
                answer=GPRS_SIM908.createSocket(TCP_SERVER,"server_port");
                if (answer == 1)
                {
                    USB.println(F("Done"));

                    ok = 0;
                    while (ok == 0) 
                    {
                        time = millis();
                        // 7. waits for TCP client data:
                        while ((GPRS_SIM908.manageIncomingData() != 3) && ((millis() - time) < 300000))
                        {
                            // Condition to avoid an overflow (DO NOT REMOVE)
                            if (millis() < time)
                            {
                                time = millis();	
                            }
                        }

                        if ((millis() - time) < 300000)
                        {
                            // checks the received string and compares:
                            if (strcmp(GPRS_SIM908.buffer_GPRS, test_string) == 0)
                            {
                                GPRS_SIM908.sendData("=>Hello developer!\n\r");
                                time = millis();
                            }
                            if (strcmp(GPRS_SIM908.buffer_GPRS, test_string2) == 0)
                            {
                                GPRS_SIM908.sendData("=>Bye developer\n\r");
                                ok = 1;
                                time = millis();
                            }
                        }
                        else
                        {
                            ok = 1;     
                        }
                    }

                    // 8. closes the client:
                    USB.print(F("Closing client...")); 
                    if (GPRS_SIM908.closeSocket() == 1)
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }

                    // 9. closes the TCP server:
                    USB.print(F("Closing server TCP...")); 
                    if (GPRS_SIM908.closeSocket(8) == 1)
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
                    USB.println(GPRS_SIM908.CME_CMS_code, DEC);
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
                USB.println(GPRS_SIM908.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Configuration failed. Error code: "));
                USB.println(answer, DEC);
            }
        }
        else
        {
            USB.println(F("GPRS_SIM908 module cannot connect to the network"));     
        }
    }
    else
    {
        USB.println(F("GPRS_SIM908 module not ready"));    
    }

    // 10. powers off the GPRS_SIM908 module:
    GPRS_SIM908.OFF();

    USB.println(F("Sleeping..."));

    // 11. sleeps one hour:
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

