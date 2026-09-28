/*
 *  ------------------ [BLE_7] - Connecting to a BLE device as Master -------
 *
 *  Explanation: This examples shows how to connect to other BLE device, using default 
 *  connecting parameters. This device will be the master and the remote device 
 *  will be the slave. A remote attribute is read / written on the slave.
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

// MAC address of BLE device to find and connect.
char MAC[14] = "000780789eeb";

char attributeData[20] = "att 1.0 written"; 

void setup() 
{  
  USB.println(F("BLE_07 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);
}

void loop() 
{

  // 1. Look for a specific device
  USB.println(F("First scan for device"));  
  USB.print("Look for device: ");
  USB.println(MAC);
  if (BLE.scanDevice(MAC) == 1)
  {
    //2. now try to connect with the defined parameters.
    USB.println(F("Device found. Connecting... "));
    aux = BLE.connectDirect(MAC);

    if (aux == 1) 
    {
      USB.print("Connected. connection_handle: ");
      USB.println(BLE.connection_handle, DEC);

      // 3. get RSSI of the link
      USB.print("RSSI:");
      USB.println(BLE.getRSSI(BLE.connection_handle), DEC);


      // 4. Now try to read a remote attribute. 
      // Note 1: Maximum allowed bytes to read from one attempt are 22 bytes, 
      // but the attribute chosen is 20 bytes length.
      // Note 2: On default profile of Waspmote BLE module, handler 32 matches
      // with the characteristic 1.0 of user service 1.
      USB.println(F("Reading attribute.. "));
      BLE.attributeRead(BLE.connection_handle,  32); 


      // 4.1 Print attribute value. First byte of BLE.attributeValue is the length of the value.
      USB.print(F("Attribute Value: "));
      for(uint8_t i = 0; i < BLE.attributeValue[0]; i++)
      {
        USB.printHex(BLE.attributeValue[i+1]);        
      }
      USB.println();
      // Print attribute in ASCII
      USB.print(F("Attribute Value (ASCII): "));
      for(uint8_t i = 0; i < BLE.attributeValue[0]; i++)
      {
        USB.print(BLE.attributeValue[i+1]);        
      }
      USB.println();


      // 5 Now remotely write an attribute with the data defined at the beginning.
      USB.println(F("Writing attribute.. "));
      if (BLE.attributeWrite(BLE.connection_handle,  32, attributeData) == 0)
      {
        USB.println(F("Write OK."));
      }   


      // 6 Read attribute again to demonstrate write operation.
      USB.println(F("Reading attribute.. "));
      BLE.attributeRead(BLE.connection_handle,  32); 


      // 6.1 Print attribute value. First byte of BLE.attributeValue is the length of the value.
      USB.print(F("Attribute Value: "));
      for(uint8_t i = 0; i < BLE.attributeValue[0]; i++)
      {
        USB.printHex(BLE.attributeValue[i+1]);        
      }
      USB.println();

      // Print attribute in ASCII
      USB.print(F("Attribute Value (ASCII): "));
      for(uint8_t i = 0; i < BLE.attributeValue[0]; i++)
      {
        USB.print(BLE.attributeValue[i+1]);        
      }
      USB.println();

      delay(1000);


      // 7. disconnect. Remember that after a disconnection, the slave becomes invisible automatically.
      BLE.disconnect(BLE.connection_handle);
      if (BLE.errorCode != 0) 
      {
        USB.println(F("Disconnect fail"));
      }
      else
      {
        USB.println(F("Disconnected."));
      } 
    }
    else
    {
      USB.println(F("NOT Connected"));  
    }
  }
  else
  {
    USB.println(F("Device not found: "));
  }

  USB.println();
  delay(5000);

  /* Note 3: On the slave node, next events will arise: 
   
   - Status event:     80 10 03 00 00 05 bf 9e 78 80 07 00 00 3c 00 64 00 00 00 ff
   - Value event:      80 17 02 00 00 00 20 00 00 00 + data written  
   - Disconnect event: 80 03 03 04 00 13 02 
   
   */
}














