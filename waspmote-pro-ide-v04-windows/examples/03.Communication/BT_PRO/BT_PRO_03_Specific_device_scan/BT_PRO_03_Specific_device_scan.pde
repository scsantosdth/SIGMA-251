/*
 *  ------------------ [BT PRO_03] - Scan specific device ------------------- 
 *
 *  Explanation: This example shows how to look for an specific device 
 *  using its MAC address using Bluetooth module Pro.
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
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Javier Siscart
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

  // Mac for searched module must be defined as follows
  char mac[18] = "00:1a:70:90:b3:28";

  // 1 Looking specific device 
  USB.print(F("specific device: "));
  USB.println(mac);

  if (BT_Pro.scanDevice(mac, 5, TX_POWER_6) == 1 )
	{
		USB.println(F("Found"));
	}
  else 
	{
		USB.println(F("Not found"));
	}

}
