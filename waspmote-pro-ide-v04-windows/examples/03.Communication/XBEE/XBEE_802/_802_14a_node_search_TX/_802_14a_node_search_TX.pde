/*  
 *  ------   [802_14a] - node search     -------- 
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */
 
 #include <WaspXBee802.h>

// node Id to be searched
char nodeToSearch[] = "node_RX";

// variable to store searched Destination 16-b Network Address
uint8_t networkAddress[2]; 

// define variable
uint8_t error;


void setup()
{ 
  // Init USB port
  USB.ON();
  USB.println(F("Node search example (TX node)"));

  // init XBee
  xbee802.ON();
  
  // set NI (Node Identifier)
  xbee802.setNodeIdentifier("node_TX");  
  
  // check at commmand execution flag
  if( xbee802.error_AT == 0 ) 
  {
    USB.println(F("Node ID set OK"));
  }
  else 
  {
    USB.println(F("Error setting Node ID"));
  }
  
  // save XBee values in memory
  xbee802.writeValues();
  
}

void loop()
{  
 
  /////////////////////////////////////
  // 1. Search node 
  /////////////////////////////////////
  
  error = xbee802.nodeSearch( nodeToSearch, networkAddress);
 
  if( error == 0 )
  {
    USB.print(F("\nnaD:"));
    USB.printHex( networkAddress[0] );
    USB.printHex( networkAddress[1] );
    USB.println();
  }
  else 
  {
    USB.println(F("nodeSearch() did not find any node"));
  }
  
  
  /////////////////////////////////////  
  //  2. Send a packet to the searched node
  ////////////////////////////////////////

  if( error == 0 )
  {
    // convert network address from binary to ASCII
    char na_str[5];
    Utils.hex2str( networkAddress, na_str, 2);
    
    // send XBee packet
    error = xbee802.send( na_str, "Message_from_TX_node" );   

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




