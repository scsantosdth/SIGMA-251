/*  
 *  ------ [DM_04b] - receive broadcast packets  -------- 
 *  
 *  Explanation: This program shows how to receive packets with 
 *  XBee-Digimesh modules. The packets received were broadcast
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

// define variable
uint8_t error;



void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("Receiving BROADCAST packets example"));

  // init XBee 
  xbeeDM.ON();  
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
    
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Source MAC Address: "));  
    USB.printHex( xbeeDM._srcMAC[0] );
    USB.printHex( xbeeDM._srcMAC[1] );
    USB.printHex( xbeeDM._srcMAC[2] );
    USB.printHex( xbeeDM._srcMAC[3] );
    USB.printHex( xbeeDM._srcMAC[4] );
    USB.printHex( xbeeDM._srcMAC[5] );
    USB.printHex( xbeeDM._srcMAC[6] );
    USB.printHex( xbeeDM._srcMAC[7] );
    USB.println();    
    USB.println(F("--------------------------------"));
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
    USB.println(F("--------------------------------"));
  }
} 

