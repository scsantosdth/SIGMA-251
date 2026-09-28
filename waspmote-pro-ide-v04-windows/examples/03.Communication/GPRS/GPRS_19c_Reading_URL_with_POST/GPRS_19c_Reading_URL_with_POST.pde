/*  
 *  ---------- GPRS_19c - Reading URL with POST  ---------- 
 *  
 *  Explanation: This example shows how to read an URL with a POST request
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
 *  Version:           0.7
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "WaspGPRS_Pro.h"

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

int answer;
char body[150];
unsigned int counter = 0;

////////////////////////////////////////////////////////////////////////
#define URL "http://pruebas.libelium.com/getpost_frame_parser.php?"
////////////////////////////////////////////////////////////////////////


void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    USB.println(F("---******************************************************************************---"));
    USB.println(F("POST request to the libelium's test url..."));
    USB.println(F("You can use this php to test the HTTP connection of the module."));
    USB.println(F("The php returns the same info the user sends with the POST query."));
    USB.println(F("In this case the loop counter and the RTC temperature."));
    USB.println(F("The url to use is: pruebas.libelium.com/getpost_frame_parser.php?"));
    USB.println(F("The syntax to add parameters to the POST data is below:"));
    USB.println(F("parameter1=value1&parameter2=value2&...&last_parameter=last_value"));
    USB.println(F("---******************************************************************************---"));

    // 1. sets operator parameters
    GPRS_Pro.set_APN(apn, login, password);
    // And shows them
    GPRS_Pro.show_APN();
    USB.println(F("---******************************************************************************---"));

}

void loop()
{
    // 2. activate the GPRS_Pro module:
    answer = GPRS_Pro.ON(); 
    if ((answer == 1) || (answer == -3))
    { 
        USB.println(F("GPRS_Pro module ready..."));

        // 3. set pin code:
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

        // 4. wait for connection to the network:
        answer = GPRS_Pro.check(180);    
        if (answer == 1)
        {

            USB.println(F("GPRS_Pro module connected to the network..."));

            // 5. configures GPRS connection for HTTP or FTP applications:
            answer = GPRS_Pro.configureGPRS_HTTP_FTP(1);
            if (answer == 1)
            {
                USB.print(F("Reading the URL with POST request..."));
                RTC.ON();                               

                // compose the POST body
                sprintf(body, "counter=%d&temp=%d", counter, (uint8_t)RTC.getTemperature() );

                // 6. get URL from the solicited URL
                answer = GPRS_Pro.readURL(URL, body, 1);
                
                // check answer
                if ( answer == 1)
                {
                    USB.println(F("Done")); 
                    USB.println(F("The server has replied with:"));   
                    USB.println(GPRS_Pro.buffer_GPRS);
                }
                else if (answer < -9)
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                    USB.print(F("CME error code: "));
                    USB.println(GPRS_Pro.CME_CMS_code, DEC);
                }
                else 
                {
                    USB.print(F("Failed. Error code: "));
                    USB.println(answer, DEC);
                }

            }
            else
            {
                USB.println(F("Configuration 1 failed. Error code: "));
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

    // 7. powers off the GPRS_Pro module
    GPRS_Pro.OFF(); 
    counter++;

    delay(5000);

}

