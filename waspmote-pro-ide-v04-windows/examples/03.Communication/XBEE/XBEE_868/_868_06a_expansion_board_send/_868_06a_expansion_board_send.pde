/*  
 *  ------   [868_06a] - Use of Expansion board     -------- 
 *  
 *  Explanation: This example shows how to use the XBee 868
 *  which is connected to the Expansion board (SOCKET1)
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

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20040479B70";
//////////////////////////////////////////

// create data fields for each packet
char data[] = "this_is_a_message";

// define variable
uint8_t error;



void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("Send messages via Expansion Board"));

  //////////////////////////
  // 1. init XBees
  //////////////////////////
  
  // 1.2. initiliaze object in SOCKET1
  xbee868.ON( SOCKET1 );  

}

void loop()
{ 
  
  //////////////////////////////////////
  // 2. send packet via SOCKET1 
  //////////////////////////////////////

  // send XBee packet
  error = xbee868.send( RX_ADDRESS, data );   
  
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
  
  // wait for five seconds
  delay(5000);


}




