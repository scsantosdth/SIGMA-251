/*  
 *  ------   [DM_11b] - node search     -------- 
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
 
 #include <WaspXBeeDM.h>

// node ID
char nodeID[] = "node_RX";

// define variable
uint8_t error;



void setup()
{ 
  // init USB port
  USB.ON();
  USB.println(F("Node search example (RX node)"));

  //////////////////////////
  // 1. XBee set up
  //////////////////////////
  
  // 1.1. init XBee
  xbeeDM.ON();
      
  // 1.2. set NI (Node Identifier)
  xbeeDM.setNodeIdentifier( nodeID );
  
  // 1.3. save XBee values in memory
  xbeeDM.writeValues();
  
}



void loop()
{ 
  // receive XBee packet (wait for 10 seconds)
  error = xbeeDM.receivePacketTimeout( 10000 );

  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Data: "));  
    USB.println( xbeeDM._payload, xbeeDM._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Length: "));  
    USB.println( xbeeDM._length,DEC);
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct	  
     * '3' : Checksum byte is not available	
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    USB.print(F("Error receiving a packet:"));
    USB.println(error,DEC);     
  }

} 


