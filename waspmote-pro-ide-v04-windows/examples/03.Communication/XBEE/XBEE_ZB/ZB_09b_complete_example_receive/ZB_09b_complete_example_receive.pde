/*  
 *  ------ [ZB_09b] - complete example receive  ------
 *  
 *  Explanation: This is a complete example for XBee-ZigBee.
 *  This example shows how to reeive a packet. When the source 
 *  address is the expected one, an answer is sent back to the
 *  emitter Waspmote
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
#include <WaspFrame.h>

// define variable
uint8_t error;
uint8_t destination[8];


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Complete example (RX node)"));

  //////////////////////////
  // 1. init XBee
  //////////////////////////
  xbeeZB.ON();  

  delay(3000);

  //////////////////////////
  // 2. check XBee's network parameters
  //////////////////////////
  checkNetworkParams();
}


void loop()
{

  // receive XBee packet (wait message for 20 seconds)
  error = xbeeZB.receivePacketTimeout( 20000 );

  // check answer  
  if( error == 0 ) 
  {    
    USB.println(F("\n1. New packet received"));
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));  
    USB.println( xbeeZB._payload, xbeeZB._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));  
    USB.println( xbeeZB._length,DEC);


    /*** Available info in library structure ***/

    // get Source's MAC address
    destination[0] = xbeeZB._srcMAC[0]; 
    destination[1] = xbeeZB._srcMAC[1]; 
    destination[2] = xbeeZB._srcMAC[2]; 
    destination[3] = xbeeZB._srcMAC[3]; 
    destination[4] = xbeeZB._srcMAC[4]; 
    destination[5] = xbeeZB._srcMAC[5]; 
    destination[6] = xbeeZB._srcMAC[6]; 
    destination[7] = xbeeZB._srcMAC[7]; 
    
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Source MAC address: "));      
    USB.printHex( destination[0] );    
    USB.printHex( destination[1] );    
    USB.printHex( destination[2] );    
    USB.printHex( destination[3] );    
    USB.printHex( destination[4] );    
    USB.printHex( destination[5] );    
    USB.printHex( destination[6] );    
    USB.printHex( destination[7] );    
    USB.println();
    
    // insert small delay to wait TX node 
    // to prepare to receive messages
    delay(1000);
    

    /*** Send message to TX node ***/
    
    USB.println(F("\n2. Send a response to the TX node: ")); 
    
    // send XBee packet
    error = xbeeZB.send( destination, "Message_from_RX_node" );       

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
  
  
  USB.println(F("\n----------------------------------"));
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

  USB.println(F("Wait for association"));
  while( xbeeZB.associationIndication != 0 )
  {   
    delay(2000);
    
    printAssociationState();

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




/*******************************************
 *
 *  printAssociationState - Print the state 
 *  of the association flag
 *
 *******************************************/
void printAssociationState()
{
  switch(xbeeZB.associationIndication)
  {
  case 0x00  :  
    USB.println(F("Successfully formed or joined a network"));
    break;
  case 0x21  :  
    USB.println(F("Scan found no PANs"));
    break;    
  case 0x22  :  
    USB.println(F("Scan found no valid PANs based on current SC and ID settings"));
    break;    
  case 0x23  :  
    USB.println(F("Valid Coordinator or Routers found, but they are not allowing joining (NJ expired)"));
    break;    
  case 0x24  :  
    USB.println(F("No joinable beacons were found"));
    break;    
  case 0x25  :  
    USB.println(F("Unexpected state, node should not be attempting to join at this time"));
    break;
  case 0x27  :  
    USB.println(F("Node Joining attempt failed"));
    break;
  case 0x2A  :  
    USB.println(F("Coordinator Start attempt failed"));
    break;
  case 0x2B  :  
    USB.println(F("Checking for an existing coordinator"));
    break;
  case 0x2C  :  
    USB.println(F("Attempt to leave the network failed"));
    break;
  case 0xAB  :  
    USB.println(F("Attempted to join a device that did not respond."));
    break;
  case 0xAC  :  
    USB.println(F("Secure join error: network security key received unsecured"));
    break;
  case 0xAD  :  
    USB.println(F("Secure join error: network security key not received"));
    break;
  case 0xAF  :  
    USB.println(F("Secure join error: joining device does not have the right preconfigured link key"));
    break;
  case 0xFF  :  
    USB.println(F("Scanning for a ZigBee network (routers and end devices)"));
    break;
  default    :  
    USB.println(F("Unkown associationIndication"));
    break;  
  }
}


