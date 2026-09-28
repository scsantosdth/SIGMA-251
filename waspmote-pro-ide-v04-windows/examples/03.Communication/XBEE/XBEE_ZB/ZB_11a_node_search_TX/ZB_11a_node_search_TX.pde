/*  
 *  ------   [ZB_11] - node search     -------- 
 *  
 *  Explanation: This program shows how to search for a specific 
 *  node inside the XBee's network. Once the node has been found a 
 *  packet is sent to this node.
 *  Keep in mind that there must be a node with the specific Node ID
 *  (NI parameter) so as to be scanned
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
 
 #include <WaspXBeeZB.h>

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
  
  USB.println(F("\n------------------------------------"));
  USB.print(F("Node ID to search:"));
  USB.println(nodeToSearch);
  USB.println(F("------------------------------------"));
  
  //////////////////////////
  // 1. XBee set up
  //////////////////////////

  // 1.1. init XBee
  xbeeZB.ON();

  // 1.2. set NI (Node Identifier)
  xbeeZB.setNodeIdentifier("node_TX");

  // 1.3. save XBee values in memory
  xbeeZB.writeValues();
  
  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  USB.println(F("Check Network parameters:"));  
  checkNetworkParams();

}



void loop()
{   
  ////////////////////////////////////////
  // 2. search node
  ////////////////////////////////////////

  error = xbeeZB.nodeSearch( nodeToSearch, mac);

  if( error == 0 )
  {
    USB.print(F("\nNode found!\nmac:"));
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
    error = xbeeZB.send( mac, "Message_from_TX_node" );   

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





/*******************************************
 *
 *  checkNetworkParams - Check operating
 *  network parameters in the XBee module
 *
 *******************************************/
void checkNetworkParams()
{
  // 1. get operating 64-b PAN ID
  xbeeZB.getOperating64PAN();

  // 2. wait for association indication
  xbeeZB.getAssociationIndication();
 
  while( xbeeZB.associationIndication != 0 )
  { 
    delay(2000);
    
    // get operating 64-b PAN ID
    xbeeZB.getOperating64PAN();

    USB.print(F("operating 64-b PAN ID: "));
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();     
    
    xbeeZB.getAssociationIndication();
  }

  USB.println(F("\nJoined a network!"));

  // 3. get network parameters 
  xbeeZB.getOperating16PAN();
  xbeeZB.getOperating64PAN();
  xbeeZB.getChannel();

  USB.print(F("operating 16-b PAN ID: "));
  USB.printHex(xbeeZB.operating16PAN[0]);
  USB.printHex(xbeeZB.operating16PAN[1]);
  USB.println();

  USB.print(F("operating 64-b PAN ID: "));
  USB.printHex(xbeeZB.operating64PAN[0]);
  USB.printHex(xbeeZB.operating64PAN[1]);
  USB.printHex(xbeeZB.operating64PAN[2]);
  USB.printHex(xbeeZB.operating64PAN[3]);
  USB.printHex(xbeeZB.operating64PAN[4]);
  USB.printHex(xbeeZB.operating64PAN[5]);
  USB.printHex(xbeeZB.operating64PAN[6]);
  USB.printHex(xbeeZB.operating64PAN[7]);
  USB.println();

  USB.print(F("channel: "));
  USB.printHex(xbeeZB.channel);
  USB.println();

}

