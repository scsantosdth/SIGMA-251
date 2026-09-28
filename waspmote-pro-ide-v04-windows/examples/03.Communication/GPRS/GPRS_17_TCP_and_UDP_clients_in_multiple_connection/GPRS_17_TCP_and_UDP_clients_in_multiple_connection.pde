/*  
 *  ------  GPRS_17 - TCP and UDP clients in multiple connection  -------- 
 *  
 *  Explanation: This example shows how to create TCP and UDP clients 
 *  in multiple connection
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_Pro.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

char TCP_test_string[]="TCP test string from Waspmote!\n";
char UDP_test_string[]="UDP test string from Waspmote!\n";
int8_t answer;

void setup()
{   
    USB.println(F("**************************"));
    // 1. sets operator parameters
    GPRS_Pro.set_APN(apn, login, password);
    // And shows them
    GPRS_Pro.show_APN();
    USB.println(F("**************************"));
}

void loop()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));
    USB.println(F("**************************"));

    // 2. activates the GPRS_Pro module:
    answer = GPRS_Pro.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 3. sets pin code:
        USB.println(F("Setting PIN code..."));
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 4. waits for connection to the network:
        answer = GPRS_Pro.check(180);    
        if (answer == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // 5. configures IP connection
            USB.print(F("Setting connection..."));
            answer = GPRS_Pro.configureGPRS_TCP_UDP(MULTI_CONNECTION);
            if (answer == 1)
            {
                USB.println(F("Done"));

                // if configuration is success shows the IP address
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_Pro.IP_dir);
                USB.print(F("Opening TCP socket..."));  

                // 6a. creates a socket to the PC in connection 1
                // “IP” and “port” must be substituted by the IP address and the port
                answer = GPRS_Pro.createSocket(TCP_CLIENT, 1, "IP", "port");
                if (answer == 1)
                {
                    USB.println(F("Conected"));

                    // 6b. sending 'TCP_test_string' throught connection 1:
                    USB.print(F("Sending TCP test string..."));
                    if (GPRS_Pro.sendData(TCP_test_string,1) == 1) 
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    } 

                    // 6c. closes socket in connection 1:
                    USB.print(F("Closing TCP socket...")); 
                    if (GPRS_Pro.closeSocket(1) == 1) 
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
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Connection failed. Error code: "));
                    USB.println(answer, DEC);
                }        

                USB.print(F("Opening UDP socket...")); 
                // 7a. creates a socket to the PC in connection 2
                // “IP” and “port” must be substituted by the IP address and the port
                answer = GPRS_Pro.createSocket(UDP_CLIENT, 2, "IP", "port");
                if (answer == 1)
                {
                    USB.println(F("Conected"));

                    // 7b. sending 'UDP_test_string' throught connection 2:
                    USB.print(F("Sending UDP test string..."));
                    if (GPRS_Pro.sendData(UDP_test_string,2) == 1) 
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    } 

                    // 7c. closes socket in connection 2:
                    USB.print(F("Closing UDP socket...")); 
                    if (GPRS_Pro.closeSocket(2) == 1) 
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
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
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
                USB.println(GPRS_Pro.CME_CMS_code, DEC);
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
        USB.println(F("GPRS_Pro module not ready"));    
    }

    // 8. powers off the GPRS_Pro module:
    GPRS_Pro.OFF(); 

    USB.println(F("Sleeping..."));

    // 11. sleeps one hour:
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}


