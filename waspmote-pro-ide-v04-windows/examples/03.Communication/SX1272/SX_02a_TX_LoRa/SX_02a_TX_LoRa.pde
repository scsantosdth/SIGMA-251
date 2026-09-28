/*
 *  ------ [SX_02a] - TX LoRa -------- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then send packets with plain-text payloads
 *
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Implementation:    Covadonga Albiñana, Yuri Carmona
 */


// Include this library to transmit with sx1272
#include <WaspSX1272.h>

// define the destination address to send packets
uint8_t rx_address = 8;

// status variable
int8_t e;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_02a example"));
  USB.println(F("Semtech SX1272 module TX in LoRa"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // Init sx1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_10_868);
  USB.print(F("Setting Channel CH_10_868.\t state ")); 
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select mode: from 1 to 10
  e = sx1272.setMode(1);  
  USB.print(F("Setting Mode '1'.\t\t state "));
  USB.println(e);  

  // Select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e);  

  // Select output power (Max, High or Low)
  e = sx1272.setPower('L');
  USB.print(F("Setting Power to 'L'.\t\t state "));  
  USB.println(e); 

  // Select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(2);
  USB.print(F("Setting Node Address to '2'.\t state "));
  USB.println(e);
  USB.println();
  
  delay(1000);  
  
  USB.println(F("----------------------------------------"));
  USB.println(F("Sending:")); 
  USB.println(F("----------------------------------------"));
}


void loop()
{
  // Sending packet before ending a timeout
  e = sx1272.sendPacketTimeout( rx_address, "This_is_a_new_message");

  // Check sending status
  if( e == 0 ) 
  {
    USB.println(F("Packet sent OK"));     
  }
  else 
  {
    USB.println(F("Error sending the packet"));  
    USB.print(F("state: "));
    USB.println(e, DEC);
  } 

  delay(2500); 
}


