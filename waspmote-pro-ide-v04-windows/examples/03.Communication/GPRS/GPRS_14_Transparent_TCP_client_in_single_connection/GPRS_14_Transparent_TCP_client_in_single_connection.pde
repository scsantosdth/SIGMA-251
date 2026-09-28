/*  
 *  ------  GPRS_14 - Transparent TCP client in single connection  -------- 
 *  
 *  Explanation: This example shows how to create a transparent TCP client 
 *  in single connection
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
 *  Version:           0.5
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_Pro.h"
#include <WaspFrame.h>

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

char test_string[]="Test string from Waspmote!\r\n";
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
            answer = GPRS_Pro.configureGPRS_TCP_UDP(SINGLE_CONNECTION, TRANSPARENT);
            if (answer == 1)
            {
                USB.println(F("Done"));

                // if configuration is success shows the IP address
                USB.print(F("Configuration success. IP address: ")); 
                USB.println(GPRS_Pro.IP_dir);
                USB.print(F("Opening TCP socket..."));  

                // 6. create a TCP socket
                // “IP” and “port” must be substituted by the IP address and the port
                answer = GPRS_Pro.createSocket(TCP_CLIENT, "IP", "port");
                if (answer == 1)
                {
                    USB.println(F("Conected"));

                    delay(1000);
                    //************************************************
                    //             Send a string of text
                    //************************************************

                    USB.print(F("Sending test string..."));
                    // 7. sending 'test_string'
                    if (GPRS_Pro.sendData(test_string) == 1) 
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }


                    //************************************************
                    //             Send a ASCII frame
                    //************************************************

                    // create new frame (ASCII)
                    frame.createFrame(ASCII,"Waspmote_Pro"); 
                    // add frame fields
                    frame.addSensor(SENSOR_STR, test_string); 
                    frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
                    RTC.ON();
                    frame.addSensor(SENSOR_TCA, (float) RTC.getTemperature());
                    RTC.OFF();

                    USB.print(F("Sending a frame...")); 
                    // 8. sending a frame
                    if (GPRS_Pro.sendData(frame.buffer, frame.length) == 1) 
                    {
                        USB.println(F("Done"));
                    }
                    else
                    {
                        USB.println(F("Fail"));
                    }

                    // 9. changes from data mode to command mode:
                    GPRS_Pro.switchtoCommandMode();

                    USB.print(F("Closing TCP socket..."));  
                    // 10. closes socket
                    if (GPRS_Pro.closeSocket() == 1) // Closes socket
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

    // 11. powers off the GPRS_Pro module
    GPRS_Pro.OFF(); 

    USB.println(F("Sleeping..."));

    // 12. sleeps one hour
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}

