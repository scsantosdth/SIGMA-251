/*
 *  ------------------ [BLE_19] - Get own mac ------------------- 
 *
 *  Explanation: This example shows how to know the BLE module MAC address
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
  USB.println(F("BLE_19 Example"));

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
 
  // 2. Print MAC address
  USB.print("BLE MAC is: ");
  USB.println(BLE.getOwnMac()); 

}

void loop() 
{
  delay(1000);
}










