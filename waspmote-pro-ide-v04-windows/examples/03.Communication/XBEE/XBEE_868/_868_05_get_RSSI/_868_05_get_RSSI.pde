/*  
 *  ------ [868_05] - get RSSI from last received packet  -------- 
 *  
 *  Explanation: This program shows how to get RSSI value from the 
 *  last received packet. For this protocol, there is an API function which
 *  shows this information. Before running this example, make sure there 
 *  is another emitter sending packets to this XBee module in order to 
 *  receive information.
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

#include <WaspXBee868.h>

// define variable
uint8_t error;

// variable to store RSSI
int rssi;


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("Get RSSI example"));

  // init XBee 
  xbee868.ON(); 

}



void loop()
{ 
  // receive XBee packet (wait for 10 seconds)
  error = xbee868.receivePacketTimeout( 10000 );

  // check answer  
  if( error == 0 ) 
  {
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Data: "));  
    USB.println( xbee868._payload, xbee868._length);

    // Show data stored in '_payload' buffer indicated by '_length'
    USB.print(F("Length: "));  
    USB.println( xbee868._length,DEC);

    // Getting RSSI using the API function
    // This function returns the last received packet's RSSI
    xbee868.getRSSI();

    // check AT flag  
    if( xbee868.error_AT == 0 )
    {      
      USB.print(F("getRSSI(dBm): ")); 

      //get rssi from getRSSI function and make conversion
      rssi = xbee868.valueRSSI[0];
      rssi *= -1;  
      USB.println(rssi,DEC);
    }
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
}


