/*  
 *  ------ [DM_08a] - complete example send  ------
 *  
 *  Explanation: This is a complete example for XBee Digimesh.
 *  This example shows how to send a packet using unicast 64-bit
 *  destination address. After sending the packet, Waspmote waits
 *  for the response of the receiver and prints all available 
 *  information  
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


// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A200402C02E3";
//////////////////////////////////////////

// define variable
uint8_t error;



void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Complete example (TX node)"));

  // set Waspmote identifier
  frame.setID("node_TX");

  // init XBee
  xbeeDM.ON();

}


void loop()
{ 
  //////////////////////////
  // 1. create frame
  //////////////////////////  

  // 1.1. create new frame
  frame.createFrame(ASCII);  

  // 1.2. add frame fields
  frame.addSensor(SENSOR_STR, "Complete example message"); 
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel() ); 
  
  USB.println(F("\n1. Created frame to be sent"));
  frame.showFrame();

  //////////////////////////
  // 2. send packet
  //////////////////////////  

  // send XBee packet
  error = xbeeDM.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  USB.println(F("\n2. Send a packet to the RX node: "));
  
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


  //////////////////////////
  // 3. receive answer
  //////////////////////////  
  
  USB.println(F("\n3. Wait for an incoming message"));
  
  // receive XBee packet
  error = xbeeDM.receivePacketTimeout( 10000 );

  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Data: "));  
    USB.println( xbeeDM._payload, xbeeDM._length);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Length: "));  
    USB.println( xbeeDM._length,DEC);
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("--> Source MAC address: "));      
    USB.printHex( xbeeDM._srcMAC[0] );    
    USB.printHex( xbeeDM._srcMAC[1] );    
    USB.printHex( xbeeDM._srcMAC[2] );    
    USB.printHex( xbeeDM._srcMAC[3] );    
    USB.printHex( xbeeDM._srcMAC[4] );    
    USB.printHex( xbeeDM._srcMAC[5] );    
    USB.printHex( xbeeDM._srcMAC[6] );    
    USB.printHex( xbeeDM._srcMAC[7] );    
    USB.println();
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
  
  // wait for 5 seconds
  USB.println(F("\n----------------------------------"));
  delay(5000);

}




