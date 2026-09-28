/*
 *  ------------------ [BLE_15] - Get Set own name ------------------- 
 *
 *  Explanation: This example shows how to read /write BLE friendly name
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

// Auxiliary variables
uint8_t aux = 0;
uint8_t handler = 0;
uint8_t flag = 0;

void setup() 
{  
  USB.println(F("BLE_15 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}
void loop() 
{

  // 1. Set the BLE device name by writting in the corresponding attribute.
  // Handler for name characteristic
  handler = 3;

  // Variable containing the device name as an array of char.
  char deviceName[20] = "Wasp BLE 01";

  USB.print(F("Setting device name as: "));
  USB.println(deviceName);

  // Write the local attribute containing the device name
  flag = BLE.writeLocalAttribute(handler, deviceName);

  if (flag == 0)
  {    
    USB.println("Name written");
  }
  else
  {
    USB.print("Error writing. flag =");
    USB.println(flag, DEC);
  }


  // 2. Get the BLE device name by reading the corresponding attribute.
  USB.println(F("Reading name..."));
  flag = BLE.readLocalAttribute(3);

  // Attribute value is stored in a global variable called attributeValue.
  // NOTE: according to the standard, first byte is field length.
  
  USB.print(F("Device name: "));
  for(uint8_t i = 0; i < BLE.attributeValue[0]; i++)
  {
    USB.print(BLE.attributeValue[i]);
  }
  USB.println();

  delay(10000);
}














