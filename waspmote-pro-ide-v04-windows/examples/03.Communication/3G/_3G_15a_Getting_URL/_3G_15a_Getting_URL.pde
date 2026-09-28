/*  
 *  --------------- 3G_15a - Getting URL  --------------- 
 *  
 *  Explanation: This example shows how to get an URL
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

int8_t answer;
char aux_str[200];
char aux_str2[20];
int counter;
float temp;
int d1;      
float f2;
int d2;  

void setup()
{    
    USB.println(F("USB port started..."));

    USB.println(F("---******************************************************************************---"));
    USB.println(F("GET method to the libelium's test url with frame..."));
    USB.println(F("You can use this php to test the HTTP connection of the module."));
    USB.println(F("The php returns the parameters that the user sends with the URL."));
    USB.println(F("In this case the RTC time and the RTC temperature."));
    USB.println(F("---******************************************************************************---"));

    // 1. sets operator parameters
    _3G.set_APN("apn", "login", "password");
    // And shows them
    _3G.show_APN();
    USB.println(F("---******************************************************************************---"));

}

void loop()
{

    // 2. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 3. set pin code:
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

        // 4. Waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));

            USB.print(F("Getting URL with GET method..."));
            RTC.ON();
            temp = RTC.getTemperature();
            RTC.OFF();
            d1 = temp;            
            f2 = temp - d1;   
            d2 = f2 * 100;   
            sprintf(aux_str, "GET /test-get-post.php?counter=%d&temp=%d.%02d HTTP/1.1\r\nHost: pruebas.libelium.com\r\nContent-Length: 0\r\n\r\n", counter,  d1,d2);

            // 5. gets URL from the solicited URL
            answer = _3G.readURL("pruebas.libelium.com", 80, aux_str);

            // Checks the answer
            if ( answer == 1)
            {
                USB.println(F("Done"));  
                USB.println(_3G.buffer_3G);
            }
            else if (answer < -14)
            {
                USB.print(F("Failed. Error code: "));
                USB.println(answer, DEC);
                USB.print(F("CME error code: "));
                USB.println(_3G.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Failed. Error code: "));
                USB.println(answer, DEC);
            } 

            USB.print(F("Getting URL with POST method..."));
            RTC.ON();
            temp = RTC.getTemperature();
            RTC.OFF();
            d1 = temp;            
            f2 = temp - d1;   
            d2 = f2 * 100;   
            sprintf(aux_str2, "counter=%d&temp=%d.%02d", counter,  d1,d2);
            sprintf(aux_str, "POST /test-get-post.php HTTP/1.1\r\nHost: pruebas.libelium.com\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: %d\r\n\r\n%s", strlen(aux_str2), aux_str2);

            // 6. gets URL from the solicited URL
            answer = _3G.readURL("pruebas.libelium.com", 80, aux_str);

            // Checks the answer
            if ( answer == 1)
            {
                USB.println(F("Done"));  
                USB.println(_3G.buffer_3G);
            }
            else if (answer < -14)
            {
                USB.print(F("Failed. Error code: "));
                USB.println(answer, DEC);
                USB.print(F("CME error code: "));
                USB.println(_3G.CME_CMS_code, DEC);
            }
            else 
            {
                USB.print(F("Failed. Error code: "));
                USB.println(answer, DEC);
            } 
        }
        else
        {
            USB.println(F("3G module cannot connect to the network..."));
        }  
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }

    // 7. Powers off the 3G module
    _3G.OFF();

    USB.println(F("Sleeping..."));
    counter++;

    // 8. sleeps one hour
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}






