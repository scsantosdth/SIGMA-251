/*
 *  ------------------ [BLE_21] - Software reset ------------------- 
 *
 *  Explanation: This example shows how to make a software reset 
 *  of the BLE module
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
 *  MERCHANTABILITY or FITNESS ARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
 */

#include <WaspBLE.h>

// Auxiliary variable
uint8_t aux = 0;

void setup() 
{  
  USB.println("BLE_21 Example");  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}

void loop() 
{

  // Send the reset command to the module.
  aux = BLE.reset();
  if(aux == 1 )
  {
    // reset event found.
    USB.println("Module has been reset");  
  }
  else 
  {
    USB.println("Reset failed");  
  }

  delay(5000);

}














