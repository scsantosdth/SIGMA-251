/*
 *  ------------------ [BLE_18] - Sleep mode ------------------- 
 *
 *  Explanation: This example shows how to manage BLE sleep mode.
 *  Do not confuse BLE sleep mode with Waspmote sleep modes.
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
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
 */

#include <WaspBLE.h>

void setup() 
{
  USB.println(F("BLE_18 Example")); 

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop()
{

  // 1. Put Bluetooth module into Sleep mode
  BLE.sleep();
  USB.println(F("Bluetooth module sleeping."));   
    
  // Now the Bluetooth module has the UART interface disabled 
  // and is not able to receive any command.
  USB.print(F("BLE MAC is: "));
  USB.println(BLE.getOwnMac());   
  
  // The power consumption is reduced to the minimum.
  delay(5000);

  // 2. Wake up Bluetooth module  
  USB.print(BLE.wakeUp(), DEC);
  USB.println(F("Bluetooth module alive.")); 
  
  // UART interface is now enabled again, 
  // the module is able to communicate with Waspmote.    
  USB.print(F("BLE MAC is: "));
  USB.println(BLE.getOwnMac()); 
  
  delay(5000);
}










