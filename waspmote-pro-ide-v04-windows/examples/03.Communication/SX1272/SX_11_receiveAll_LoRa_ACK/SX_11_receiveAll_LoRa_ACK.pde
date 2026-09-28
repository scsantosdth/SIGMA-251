/*  
 *  ------ [SX_10] - RX LoRa from all Nodes with ACK -------- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then receive packets from any node. When a
 *  packet is received, an ACK is sent back to the sender. This
 *  code works as a network sniffer because independently the packet is
 *  sent to, this module gets it and shows it.
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
 */

// Put your libraries here (#include ...)
#include <WaspSX1272.h>

// status variable
int8_t e;


void setup() 
{
  // init USB port
  USB.ON();
  USB.println(F("Semtech SX1272 module RX in LoRa, complete example"));

  // init SX1272 module
  sx1272.ON();

  // select frequency channel
  e = sx1272.setChannel(CH_14_868);  
  USB.print(F("Setting Channel CH_14_868.\t state ")); 
  USB.println(e);

  // select implicit or explicit header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select mode: from 1 to 10
  e = sx1272.setMode(10);
  USB.print(F("Setting Mode '10'.\t\t state ")); 
  USB.println(e);  

  // Select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e);

  // Select output power (Max, High or Low)
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state "));  
  USB.println(e); 

  // select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(53);
  USB.print(F("Setting Node Address to '53'.\t state "));
  USB.println(e); 
  USB.println();

  delay(1000);  

  USB.println(F("--------------------------------------------------"));
  USB.println(F("Receiving from All Nodes (with ACK response):")); 
  USB.println(F("--------------------------------------------------"));
}


void loop()
{
  // Receive from all Nodes
  e = sx1272.receiveAll(10000);
  
  // check RX status
  if( e == 0 )
  {
    // if packet received then send ACK
    e = sx1272.setACK();
    if( e == 0 )
    {
      e = sx1272.sendWithTimeout();
      USB.print(F("ACK sent, state "));
      USB.println(e, DEC);
    }
    else
    {
      USB.println(F("There has been any error while setting ACK"));
    }
  }
  else
  {
    USB.println(F("There has been any error while receiving packet"));
  }
}


