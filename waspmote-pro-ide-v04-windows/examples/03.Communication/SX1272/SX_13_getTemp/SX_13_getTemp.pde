/*  
 *  ------ [SX_13] - Get Temperature -------- 
 *
 *  Explanation: This example shows how to get the temperature value
 *  that this module provides.
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
 *  Implementation:    Covadonga Albiñana, Yuri Carmona
 */

// Put your libraries here (#include ...)
#include <WaspSX1272.h>

// status variable
int8_t e;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_13 example"));
  USB.println(F("Semtech SX1272 module. Get Temperature"));

  // Init SX1272 module  
  sx1272.ON();

  delay(1000);
  USB.println(F("Configuration finished"));  

}


void loop()
{
  // Getting temperature
  e = sx1272.getTemp();

  // Check status
  if( e == 0 ) 
  { 
    USB.print("Getting Temperature --> OK.  ");  

    USB.print(F("Temperature(celsius): "));
    USB.println(sx1272._temp);     
  }
  else 
  {
    USB.println(F("ERROR getting temperature"));
  } 
  
  delay(1000);
}


