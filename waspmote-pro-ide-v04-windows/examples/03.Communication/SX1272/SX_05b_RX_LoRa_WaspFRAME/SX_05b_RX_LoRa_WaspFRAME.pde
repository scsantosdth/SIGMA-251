/*  
 *  ------ [SX_05b] - RX LoRa with Waspmote Frame -------- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then receive packets with Waspmote Frames
 *  within the payload
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

// Include these libraries to transmit frames with sx1272
#include <WaspSX1272.h>
#include <WaspFrame.h>

// status variable
int8_t e;


void setup() 
{
  // Init USB port
  USB.ON();
  USB.println(F("SX_05b example"));
  USB.println(F("Semtech SX1272 module. RX LoRa with Waspmote Frame"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // Init SX1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_11_868);
  USB.print(F("Setting Channel CH_11_868.\t state ")); 
  USB.println(e);

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select mode: from 1 to 10
  e = sx1272.setMode(1);  
  USB.print(F("Setting Mode '1'.\t\t state "));
  USB.println(e);  

  // select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e);  

  // Select output power (Max, High or Low)
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state "));  
  USB.println(e); 

  // Select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(5);
  USB.print(F("Setting Node Address to '5'.\t state "));
  USB.println(e); 
  USB.println();

  delay(1000);  

  USB.println(F("----------------------------------------"));
  USB.println(F("Receiving:")); 
  USB.println(F("----------------------------------------"));
}

void loop()
{
  // Receiving a packet
  e = sx1272.receivePacketTimeout(10000);

  // check status
  if( e == 0 )
  {
    USB.println(F("\nShow packet received: "));
    
    // show frame received
    sx1272.showFramefromPacket();
  }
  else
  {
    USB.print(F("\nReceiving packet TIMEOUT, state "));
    USB.println(e, DEC);  
  }    
}


