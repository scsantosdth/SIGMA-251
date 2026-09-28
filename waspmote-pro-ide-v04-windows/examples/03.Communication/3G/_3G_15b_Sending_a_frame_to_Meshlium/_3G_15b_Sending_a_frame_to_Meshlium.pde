/*  
 *  --------------- 3G_15b - Sending a frame to Meshlium  --------------- 
 *  
 *  Explanation: This example shows how to send frame to Meshlium
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

#include <WaspFrame.h>
#include "Wasp3G.h"

char url[] = "pruebas.libelium.com";
int port = 80;

char apn[] = "apn";
char login[] = "login";
char password[] = "password";

int8_t answer;

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
    _3G.set_APN(apn, login, password);
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

        // 4. wait for connection to the network:
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));            

            // switch on RTC
            RTC.ON();
            // Create new frame (ASCII)
            frame.createFrame(ASCII,"Waspmote_PRO"); 
            // set frame fields (Time from RTC)
            frame.addSensor(SENSOR_TIME, RTC.getTime());
            // set frame fields (Temperature in Celsius sensor - float)
            frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());
            // show Frame
            frame.showFrame();            
            // switch off RTC
            RTC.OFF();            

            // 5. Sends the frame to Meshlium with GET
            USB.print(F("Sending the frame to Meshlium with GET method..."));

            answer = _3G.sendHTTPframe( url, port, frame.buffer, frame.length, GET);

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

            // switch on RTC
            RTC.ON();
            // Create new frame (ASCII)
            frame.createFrame(ASCII,"Waspmote_PRO"); 
            // set frame fields (Time from RTC)
            frame.addSensor(SENSOR_TIME, RTC.getTime());
            // set frame fields (Temperature in Celsius sensor - float)
            frame.addSensor(SENSOR_IN_TEMP, (float) RTC.getTemperature());
            // show Frame
            frame.showFrame();            
            // switch off RTC
            RTC.OFF();    

            // 6. Sends the frame to Meshlium with POST
            USB.print(F("Sending the frame to Meshlium with POST method..."));

            answer = _3G.sendHTTPframe( url, port, frame.buffer, frame.length, POST);

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

    // 7. powers off the 3G module
    _3G.OFF(); 

    USB.println(F("Sleeping..."));

    // 8. sleeps one hour
    PWR.deepSleep("00:00:01:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}








