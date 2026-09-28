/*  
 *  ------------------ BT PRO_08 - Get/Set nodeID ------------------------ 
 *  
 *  Explanation: Read and write nodeID (node identifier). 
 *  It is saved into EEPROM memory into a reserved space.
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

  // 1. Set new node ID. Must have 8 digit length. 
  BT_Pro.setNodeID("BT000001");

  // 2. Print node identifier
  USB.print("nodeID: ");
  USB.println(BT_Pro.getNodeID());

  // This parameter can be used to identify a node into a network.
  // The paramenter is also saved into SD card with each scan. 
  
  delay(5000);

}


