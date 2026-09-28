/*
 *  ------------------ [BLE_20] - sending custom commands --------------
 *
 *  Explanation: This example shows how to send custom commands to the 
 *  BLE module.
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

  USB.println("BLE_20 Example");  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop() 
{

  /* NOTE: This example requires to enable debug mode to be able 
   to see internal communication between Waspmote and BLE module.
   Please go to the library file WaspBLE.h and change the value 
   of the BLE_DEBUG constant to 2. 
   
   Possible values are:
   0 = no debug messages will be printed
   1 = some debug messages will be printed
   2 = All messages of internal communication will be printed
   */

  // Aux variable to store a custom command as an array of bytes
  uint8_t aux[5] = {
    0x04, 0x00, 0x00, 0x00, 0x01      };

  // 1. Sending a custom command defined as an array of bytes. 
  USB.println(F("Sending hello command as array of uint8_t"));  

  // Sending custom command to the BLE module.
  BLE.sendCommand(aux, 5);

  // Reading command module answer. It will be 00 00 00 01.
  BLE.readCommandAnswer(),

  // 2. Sending the same custom command as an array of char. 
  USB.println(F("Sending hello command as an array of char")); 

  // Aux variable to store the custom command as an aray of char
  char command[20] = "0400000001";
  BLE.sendCommand(command);

  // Reading command module answer.
  BLE.readCommandAnswer(),

  delay(10000);
  USB.println();

}














