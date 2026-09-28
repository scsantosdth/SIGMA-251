/*  
 *  ------  GPRS_SIM908_09 - Receiving SMS  -------- 
 *  
 *  Explanation: This example shows how to receive and show a SMS.
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

int answer;
unsigned long time;

void setup()
{
    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the GPRS_SIM908 module:
    answer = GPRS_SIM908.ON(); 
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("GPRS_SIM908 module ready..."));

        // 2. sets pin code
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

        // 3. waits for connection to the network
        answer = GPRS_SIM908.check(180);    
        if (answer == 1)
        {
            USB.println(F("GPRS_SIM908 module connected to the network..."));

            // 5. configures info from incoming SMS
            GPRS_SIM908.setInfoIncomingSMS();

            // 6. waits 60 seconds for receive a SMS
            time = millis();
            answer = 0;
            while ((answer != 2) && ((millis() - time) < 60000))
            {
                answer = GPRS_SIM908.manageIncomingData();

                // Condition to avoid an overflow (DO NOT REMOVE)
                if (millis() < time)
                {
                    time = millis();	
                }
            }

            if (answer == 2)
            {
                // 7. then shows the text of the message
                USB.print(F("Text of the SMS: "));
                USB.println(GPRS_SIM908.buffer_GPRS);
            }
            else
            {                
                USB.println(F("No SMS received"));    
            }
        }
        else
        {
            USB.println(F("GPRS_SIM908 module cannot connect to the network..."));
        }

    }
    else
    {
        USB.println(F("GPRS_SIM908 module NOT ready..."));
    }

    GPRS_SIM908.OFF();


}

void loop()
{


}






