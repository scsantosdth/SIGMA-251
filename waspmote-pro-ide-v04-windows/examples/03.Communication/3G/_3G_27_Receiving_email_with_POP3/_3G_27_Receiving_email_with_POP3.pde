/*  
 *  --------------- 3G_27 - Receiving email with POP3 ----------------- 
 *  
 *  Explanation: This example shows how to receive an email with POP3
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

int total_email;
int answer=0;


void setup()
{
    USB.println(F("**************************"));
    // 1. sets operator parameters
    _3G.set_APN(apn, login, password);
    // And shows them
    _3G.show_APN();
    USB.println(F("**************************"));
}


void loop(){ 

    USB.ON();
    USB.println(F("Starting"));

    // 2. activates the 3G module:
    answer = _3G.ON();
    if ((answer == 1) || (answer == -3))
    {
        USB.println(F("3G module ready..."));

        _3G.setTime();
        // 3. sets pin code
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

        USB.print(F("Connecting to the network..."));    

        // 4. waits for connection to the network
        answer = _3G.check(180);    
        if (answer == 1)
        { 
            USB.println(F("connected"));        

            // 5. Sets SMTP parameters
            USB.print(F("Setting POP3 server parameters..."));
            answer = _3G.setPOP3server("SMTP server", server_port, "STMP_account", "password");
            if (answer == 1)
            {
                USB.println(F("done"));

                // 6. Gets the number of emails
                USB.print(F("Getting number of emails..."));
                total_email = _3G.getPOP3list();
                if (total_email >= 0)
                {
                    USB.print(total_email, DEC);
                    USB.println(F(" emails"));
                }
                else
                {
                    USB.print(F("fail. Error code:"));
                    USB.println(total_email, DEC);
                }  


                // 7. Reads the first email
                USB.print(F("Getting the first email..."));
                _3G.selectStorage(1);
                answer = _3G.getPOP3mail(1);
                if (answer == 1)
                {
                    USB.println(F(" done"));
                    USB.println(_3G.buffer_3G);
                }
                else
                {
                    USB.print(F("fail. Error code:"));
                    USB.println(answer, DEC);
                }     
            }
            else
            {
                USB.print(F("fail. Error code:"));
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

    // 8. Powers off the 3G module
    _3G.OFF();

    USB.println(F("Sleeping..."));

    // 9. sleeps one hour:
    PWR.deepSleep("00:01:00:00", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);

}






