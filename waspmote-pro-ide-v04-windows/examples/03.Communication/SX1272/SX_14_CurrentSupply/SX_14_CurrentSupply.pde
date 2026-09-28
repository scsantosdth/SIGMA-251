/*  
 *  ------ [SX_14] - Get Current -------- 
 *
 *  Explanation: This example shows how to set the maximum Over Current 
 *  Protection (OCP) level. By default, the OCP is disabled. This example 
 *  also permits to get the OCP current value in mA units.
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
  // init USB port
  USB.ON();
  USB.println(F("SX_14 example"));
  USB.println(F("Semtech SX1272 module. Current supply configuration"));

  // init SX1272 module  
  sx1272.ON();
  
  /* DEFAULT:
   * By default, after switching ON the module, it works  
   * with NO Over Current Protection to ensure better work
   */

  // Set Maximum allowed Current Supply: from 0x00 (45 mA) to 0x1B (240 mA)
  e = sx1272.setMaxCurrent(0x17);
  USB.print(F("Setting Maximum Current Supply: state ")); 
  USB.println(e);

  delay(1000);
  USB.println(F("Configuration finished"));  

}


void loop()
{
  // put your main code here, to run repeatedly:
  e = sx1272.getMaxCurrent();

  // Check status
  if( e == 0 ) 
  { 
    USB.print("Getting Maximum Current Supply --> OK.  ");  

    USB.print(F("Maximum current supply (mA)= "));
    USB.println(sx1272._maxCurrent,DEC); 
  }
  else 
  {
    USB.println(F("ERROR getting Maximum Current Supply"));
  } 

  delay(1000);
}



