/*  
 *  ------  GPRS_SIM928A_06 - Making lost call  -------- 
 *  
 *  Explanation: This example shows how to make a lost call,
 *  with a duration of 30 seconds.
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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

#include "WaspGPRS_SIM928A.h"
int answer;

void setup()
{
  // setup for Serial port over USB:
  USB.ON();
  USB.println(F("USB port started..."));

  // 1. activates the GPRS_SIM928A module:
  answer = GPRS_SIM928A.ON(); 
  if ((answer == 1) || (answer == -3))
  {
    USB.println(F("GPRS_SIM928A module ready..."));

    // 2. sets pin code
    USB.println(F("Setting PIN code..."));
    // **** must be substituted by the SIM code
    if (GPRS_SIM928A.setPIN("****") == 1) 
    {
      USB.println(F("PIN code accepted"));
    }
    else
    {
      USB.println(F("PIN code incorrect"));
    }

    // 3. waits for connection to the network
    answer = GPRS_SIM928A.check(180);    
    if (answer == 1)
    {
      USB.println(F("GPRS_SIM928A module connected to the network..."));

      USB.println(F("Making lost call..."));

      // ********* must be substituted by the phone number
      // 4. makes a lost call
      answer = GPRS_SIM928A.makeLostCall("*********", 30); 

      if (answer == 1)
      {
        USB.println(F("Lost call done"));
      }
      else 
      {
        USB.println(F("Lost call error"));
      }

    }
    else
    {
      USB.println(F("GPRS_SIM928A module cannot connect to the network..."));
    }

  }
  else
  {
    USB.println(F("GPRS_SIM928A module NOT ready..."));
  }

  GPRS_SIM928A.OFF();
}

void loop()
{

}


