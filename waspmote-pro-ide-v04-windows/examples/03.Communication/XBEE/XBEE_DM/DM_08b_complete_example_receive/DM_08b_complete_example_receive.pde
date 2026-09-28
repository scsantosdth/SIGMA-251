/*  
 *  ------ [DM_08b] - complete example receive  ------
 *  
 *  Explanation: This is a complete example for XBee-DigiMesh
 *  This example shows how to receive a packet. When the source 
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

#include <WaspXBeeDM.h>
#include <WaspFrame.h>


// define variable
uint8_t error;
uint8_t destination[8];


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Complete example (RX node)"));

  // init XBee 
  xbeeDM.ON();
}


void loop()
{

  // receive XBee packet (wait message for 20 seconds)
  error = xbeeDM.receivePacketTimeout( 20000 );

  // check answer  
  if( error == 0 ) 
  {    
    USB.println(F("\n1. New packet received"));
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));  
    USB.println( xbeeDM._payload, xbeeDM._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));  
    USB.println( xbeeDM._length,DEC);


    /*** Available info in library structure ***/

    // get Source's MAC address
    destination[0] = xbeeDM._srcMAC[0]; 
    destination[1] = xbeeDM._srcMAC[1]; 
    destination[2] = xbeeDM._srcMAC[2]; 
    destination[3] = xbeeDM._srcMAC[3]; 
    destination[4] = xbeeDM._srcMAC[4]; 
    destination[5] = xbeeDM._srcMAC[5]; 
    destination[6] = xbeeDM._srcMAC[6]; 
    destination[7] = xbeeDM._srcMAC[7]; 
    
    
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
    error = xbeeDM.send( destination, "Message_from_RX_node" );       

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









