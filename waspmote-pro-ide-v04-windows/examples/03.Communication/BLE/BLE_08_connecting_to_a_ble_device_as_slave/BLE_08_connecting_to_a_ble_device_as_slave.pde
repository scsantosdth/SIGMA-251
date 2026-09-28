/*
 *  ------------------ [BLE_08] - Connecting to a BLE device as slave --------
 *
 *  Explanation: this code set discoverable/connectable mode on Waspmote to 
 *  allow connections from other BLE devices. Then wait during 30 seconds for 
 *  incoming connections. If a connection is established, then Waspmote keeps 
 *  connected till the master ends the connection.
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

// Variable to store function returning values
uint8_t flag = 0;


void setup() 
{
  USB.println(F("BLE_08 Example"));  

  // 0. Turn BLE module ON
  BLE.ON(SOCKET0);

}

void loop() 
{
  // 1. make Waspmote visible to other BLE modules
  BLE.setDiscoverableMode(BLE_GAP_GENERAL_DISCOVERABLE);

  // 2. make Waspmote connectable to any other BLE device
  BLE.setConnectableMode(BLE_GAP_UNDIRECTED_CONNECTABLE);
  USB.println(F("Waiting for incoming connections..."));

  /* 3. wait for connection status event during 30 seconds. connection status event structure:
   Field:   | Message type | Payload| Msg Class	| Msg ID | Connection | Flags |...
   Length:  |       1      |    1   |     1     |    1   |      1     |    1  |...
   Example: |      80      |   10   |     03    |   00   |      00    |   05  |...
   
   ...|   address    | address type | con interval | timeout | latency | bonding |
   ...|     6        |      1       |   2          |    2    |    2    |   1     |
   ...| bf9e78800700 |      00      |  3c00F       |  6400   |   0000  |   00    |
   */
  flag = BLE.waitEvent(30000);
  if (flag == BLE_EVENT_CONNECTION_STATUS)
  {
    USB.println(F("Connected!"));
    USB.println(F("Now Waspmote is connected as slave.")); 

    // 3.1 Parse the status event to find MAC of master device who initiated the connection.
    // NOTE: The event captured is stored in BLE.event array.
    uint8_t b = 5;
    for(uint8_t a = 0; a < 6 ; a++)
    {
      BLE.BLEDev.mac[a] = BLE.event[b+6];
      b--;
    }

    // 3.2 Print MAC of the Master device.
    USB.print(F("MASTER MAC Address: "));
    for(uint8_t i =0; i<6; i++)
    {
      USB.printHex(BLE.BLEDev.mac[i]);
    }
    USB.println();

    // 3.3 now wait to other events forever. If disconnection is detected, exit loop.
    flag = 0;
    while(flag != BLE_EVENT_CONNECTION_DISCONNECTED)
    {

      // if disconnected event, then exist the loop and start again.
      // Possible disconnection event: 80 03 03 04 00 13 02
      flag = BLE.waitEvent(1000);

      if (flag != 0)
      {
        USB.println(F("Event found"));
        USB.print("flag = ");
        USB.println(flag, DEC);


        //
        // NOTE: here the user can add custom actions depending on the received envent.
        //

      }
    }

    // 4. if here, disconnected.
    USB.println(F("Disconnected"));    

  }
  else 
  {
    if (flag == 0)
    {
      // If there are no events, then no one tried to connect Waspmote
      USB.println(F("No events found. No devices tried to connect Waspmote."));
    }
    else
    {
      // Other event received from BLE module
      USB.print(F("Other event found. "));
      USB.print("flag = ");
      USB.println(flag, DEC);
    }
  }

  USB.println(); 
}
















