/*  
 *  ------ [802_04a] - send packets using a unicast 16-bit address -------- 
 *  
 *  Explanation: This program shows how to send packets with 
 *  XBee-802.15.4 modules. The destination address is set as a
 *  16-bit network address 
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */
 
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "1234";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";

// define the network address for the Xbee module
char OWN_NETADDRESS[] = "1212";

// define variable
uint8_t error;


void setup()
{  
  // init USB port
  USB.ON();
  USB.println(F("Sending packets example - TX NODE (16-bit addressing)"));

  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee 
  xbee802.ON();
  
  // set 0x1212 as this XBee's Network Address (MY address)
  xbee802.setOwnNetAddress( OWN_NETADDRESS );
  
  // write values to XBee module memory
  xbee802.writeValues(); 
    
}



void loop()
{  
  ///////////////////////////////////////
  // 1. Create Data Frame
  ///////////////////////////////////////

  // 1.1 create new frame
  frame.createFrame( ASCII );  
  
  // 1.2 add frame fields
  frame.addSensor(SENSOR_STR, "This_is_a_message");  
  
    
  ///////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////

  // send XBee packet
  error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
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
