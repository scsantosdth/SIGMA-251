/*  
 *  ------   [868_10] - node search     -------- 
 *  
 *  Explanation: This program shows how to search for a specific 
 *  node inside the XBee's network. Once the node has been found a 
 *  packet is sent to this node.
 *
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Yuri Carmona
 */
 
 #include <WaspXBee868.h>

// node Id to be searched
char nodeToSearch[] = "node_RX";

// variable to store searched Destination MAC Address
uint8_t mac[8]; 

// define variable
uint8_t error;



void setup()
{ 
  // init USB port
  USB.ON();
  USB.println(F("Node search example (TX node)"));

  //////////////////////////
  // 1. XBee set up
  //////////////////////////

  // 1.1. init XBee
  xbee868.ON();

  // 1.2. set NI (Node Identifier)
  xbee868.setNodeIdentifier("node_TX");

  // 1.3. save XBee values in memory
  xbee868.writeValues();

}



void loop()
{   
  ////////////////////////////////////////
  // 2. search node
  ////////////////////////////////////////

  error = xbee868.nodeSearch( nodeToSearch, mac);

  if( error == 0 )
  {
    USB.print(F("\nmac:"));
    USB.printHex( mac[0] );
    USB.printHex( mac[1] );
    USB.printHex( mac[2] );
    USB.printHex( mac[3] );
    USB.printHex( mac[4] );
    USB.printHex( mac[5] );
    USB.printHex( mac[6] );
    USB.printHex( mac[7] );
  }
  else 
  {
    USB.print(F("nodeSearch() did not find any node")); 
  }
  USB.println();


  ////////////////////////////////////////
  // 3. send a packet to the searched node
  ////////////////////////////////////////

  if( error == 0 )
  {
    // send XBee packet
    error = xbee868.send( mac, "Message_from_TX_node" );   

    // check TX flag
    if( error == 0 )
    {
      USB.println(F("send ok"));

      // blink green LED
      Utils.blinkGreenLED();
    }
    else 
    {
      USB.println(F("send error"));

      // blink red LED
      Utils.blinkRedLED();
    }
  }

  // wait   
  delay(3000);  

}  

