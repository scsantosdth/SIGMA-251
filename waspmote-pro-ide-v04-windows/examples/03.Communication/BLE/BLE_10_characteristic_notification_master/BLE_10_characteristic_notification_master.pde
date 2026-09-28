/*
 *  ------------------ [BLE_10] - Characteristic notification - Master -------
 *  Explanation: This example shows how notifying processes works.
 *  The program first look for a certain BLE device and connects to it.
 *  Then, it subscribes to notifications of a certain characteristic and wait
 *  for notifications from the slave. Once 5 notifications are received 
 *  (or timeout is reached) the Master terminates the connection and starts again.
 *  This example is though to be used together with example BLE_11.
 * 
 *  NOTE: the master can be replaced by a smartphone with a BLE app.
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

// MAC address of BLE device to find and connect.
char MAC[14] = "000780789eeb";

// Aux variable
uint16_t flag = 0;

// Variable to count notify events
uint8_t eventCounter = 0;

void setup() 
{  
  USB.println(F("BLE_10 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop() 
{

  flag = 0;

  // 1. Look for a specific device
  USB.println(F("First scan for device"));  
  USB.print("Look for device: ");
  USB.println(MAC);
  if (BLE.scanDevice(MAC) == 1)
  {
    // 2. Now try to connect with the defined parameters.
    USB.println(F("Device found. Connecting... "));
    flag = BLE.connectDirect(MAC);

    if (flag == 1) 
    {
      USB.print("Connected. connection_handle: ");
      USB.println(BLE.connection_handle, DEC);

      // 3. get RSSI of the link
      USB.print("RSSI:");
      USB.println(BLE.getRSSI(BLE.connection_handle), DEC);


      /* 4. Subscribe to notifications of one characteristic. 
       In this case an attribute with handler 44.
       
       NOTE 1: the client characteristic configuration attribute of 
       this characteristic has the handler 46.
       
       NOTE 2: To subscribe notifications it is necessary to write a '1'
       */
      char notify[2] = "1";
      flag = BLE.attributeWrite(BLE.connection_handle, 46, notify);

      if (flag == 0)
      {
        /* 5. Notify subscription successful. Now start a loop till 
         receive 5 notification or timeout is reached (30 seconds). If disconnected, 
         then exit while loop.
         
         NOTE 3: 5 notifications are done by the example BLE_11.
         */
        eventCounter = 0;
        unsigned long previous = millis();
        while (( eventCounter < 5 ) && ( (millis() - previous) < 30000))
        {
          // 5.1 Wait for indicate event. 
          USB.println(F("Waiting events..."));
          flag = BLE.waitEvent(5000);

          if (flag == BLE_EVENT_ATTCLIENT_ATTRIBUTE_VALUE)
          {
            USB.println(F("Notification received."));

            /* attribute value event structure:
             Field:   | Message type | Payload| Msg Class | Method |  Connection |...
             Length:  |       1      |    1   |     1     |    1   |      1      |...
             Example: |      80      |   05   |     04    |   05   |     00      |...
             
             ...| att handle | att type | value |
             ...|     2      |     8    |   n   |
             ...|   2c 00    |     x    |   n   |
             */

            // 5.2 Extract the handler from the received event saved on the buffer BLE.event
            uint16_t handler = ((uint16_t)BLE.event[6] << 8) | BLE.event[5];
            USB.print("attribute with handler ");
            USB.print(handler, DEC);
            USB.println(" has changed. ");
            USB.print("Attribute value: ");

            // 5.3 Print attribute value
            for(uint8_t i = 0; i < BLE.event[8]; i++)
            {
              USB.printHex(BLE.event[i+9]);        
            }
            USB.println();

            eventCounter++;
            flag = 0;
          }
          else
          {
            // 5.4 If disconnection event is received, then exit the while loop.
            if (flag == BLE_EVENT_CONNECTION_DISCONNECTED)
            {
              break;
            }
          }

          // Condition to avoid an overflow (DO NOT REMOVE)
          if( millis() < previous ) previous=millis();

        } // end while loop

        delay(3000);

        // 6. Disconnect. Remember that after a disconnection, 
        // the slave becomes invisible automatically.
        if (BLE.getStatus(BLE.connection_handle) == 1)
        {
          flag = BLE.disconnect(BLE.connection_handle);
          if (flag != 0) 
          {
            // Error trying to disconnect
            USB.print(F("disconnect fail. flag = "));
            USB.println(flag, DEC);
            USB.println();
          }
          else
          {
            USB.println(F("Disconnected."));
            USB.println();
          } 
        }
        else
        {
          // Already disconnected
          USB.println(F("Disconnected.."));
          USB.println();
        } 
      }
      else
      {
        // 4.1 Failed to subscribe.
        USB.println(F("Failed subscribing."));
        USB.println();
      }
    }
    else
    {
      // 2.1 Failed to connect
      USB.println(F("NOT Connected"));
      USB.println();  
    }
  }
  else
  {
    // 1.1 Scan failed.
    USB.println(F("Device not found: "));
    USB.println();
  }
}




















