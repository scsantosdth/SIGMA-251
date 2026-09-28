/*  
 *  -----------  3G_08 - Receiving SMS  ------------ 
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
 *  Version:           1.1
 *  Design:            David Gascón 
 *  Implementation:    Alejandro Gállego
 */

#include "Wasp3G.h"

int8_t answer;

void setup()
{

    // setup for Serial port over USB:
    USB.ON();
    USB.println(F("USB port started..."));

    // 1. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        // 2. sets pin code:
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

        // 3. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("3G module connected to the network..."));

        }
        else
        {
            USB.println(F("3G module cannot connect to the network..."));
        }

        // 4. configures info from incoming SMS
        answer = _3G.setInfoIncomingSMS();
        if ( answer == 1)
        {
            USB.println(F("Info Incoming SMS OK"));
        }
        else
        {
            USB.println(F("Info Incoming SMS NOT OK"));
        }
    }
    else
    {
        // Problem with the communication with the 3G module
        USB.println(F("3G module not started"));
    }    






}

void loop()
{
    // 5. waits for receive a SMS
    while (_3G.manageIncomingData() != 2);

    // 6. then shows the text of the message    
    USB.print(F("SMS from: "));
    USB.println(_3G.tlfNumber);
    USB.print(F("Text of the SMS: "));
    USB.println(_3G.buffer_3G);

}


