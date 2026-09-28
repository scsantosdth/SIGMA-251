/*  
 *  --------------- [BT PRO_05] - Reading own Mac-------- 
 *  
 *  Explanation: Reading Bluetooth module Mac address. 
 *  It is a read only value.
 *    
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Javier Siscart 
 */

#include "WaspBT_Pro.h"

void setup()
{

  // Setup for Serial port over USB
  USB.ON();
  USB.println(F("USB port started...")); 

  // Turn On Bluetooth module
  BT_Pro.ON(SOCKET1);

}

void loop()
{

  // 1. Read Bluetooth module Mac address 
  USB.print(F("Mac:"));
  USB.println(BT_Pro.getOwnMac());

  delay(2000);

}



