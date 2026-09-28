/*  
 *  ------ BT PRO_07 - Get/Set Friendly name -------- 
 *  
 *  Explanation: Read and write bluetooth module friendly name (visible 
 *  name). Name is software limited to 20 characters. 
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
     
  // 1. Set a friendly name of less than 20 characters
  BT_Pro.setOwnName("My Bluetooth Pro");
  
  // 2. Read firendly name
  USB.print(F("Name: "));
  USB.println(BT_Pro.getOwnName());
  
  // 3. Set new friendly name
  BT_Pro.setOwnName("Bluetooth module");
  
  // 4. Read new firendly name
  USB.print(F("New Name: "));
  USB.println(BT_Pro.getOwnName());
  
  delay(5000);
  
}

