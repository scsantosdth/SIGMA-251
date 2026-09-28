/*
 *  ------------------ [BLE_14] - managing whitelist ------------------- 
 *
 *  Explanation: This example show how to manage users inside the
 *  whitelist of the BLE module,
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

// Aux variable
uint16_t aux = 0;

// MAC address of a BLE module
char BleMacAddress[13] = "001122334455";


void setup() 
{  
  USB.println(F("BLE_14 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop() 
{

  // 1. Add new member. 
  aux = BLE.whiteListAppend(BleMacAddress);
  if (aux == 0)
  {
    USB.print(BleMacAddress);
    USB.println(" member added");
  }
  else
  {
    USB.println(F(" Append failed"));
  }

  // 2. Remove new member
  aux = BLE.whiteListRemove(BleMacAddress);
  if (aux == 0)
  {
    USB.print(BleMacAddress);
    USB.println(" member removed");
  }
  else
  {
    USB.println(F(" Remove failed"));
  }

  // 3. add new member
  aux = BLE.whiteListAppend(BleMacAddress);
  if (aux == 0)
  {
    USB.print(BleMacAddress);
    USB.println(" member added");
  }
  else
  {
    USB.println(F(" Append failed"));
  }

  // 4. clear all members
  if (BLE.whiteListClear() == 1)
  {
    USB.println(F("Whitelist is empty"));
  }
  else
  {
    USB.println(F("clear failed"));
  }

  USB.println();
  delay(10000);


  /* NOTE 1: Do not use this command while advertising, scanning, 
   or while being connected. The current list is discarded upon 
   reset or power-cycle.
   */

  /* NOTE 2: There is no function to show the current members of 
   the whitelist.
   */

}














