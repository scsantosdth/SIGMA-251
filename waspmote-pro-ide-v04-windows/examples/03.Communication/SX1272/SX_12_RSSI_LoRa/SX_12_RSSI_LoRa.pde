/*  
 *  ------ [SX_12] - RX LoRa getting RSSI -------- 
 *
 *  Explanation: This example shows how to configure the semtech 
 *  module in LoRa mode and then receive packets. When a new packet 
 *  is received the SNR, channel RSSI and last received packet RSSI 
 *  are measured from the module
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

// Put your libraries here (#include ...)
#include <WaspSX1272.h>

// status variable
int8_t e;


void setup() 
{
  // init USB port
  USB.ON();
  USB.println(F("SX_12 example"));
  USB.println(F("Semtech SX1272 module RX in LoRa getting RSSI and SNR"));

  USB.println(F("----------------------------------------"));
  USB.println(F("Setting configuration:")); 
  USB.println(F("----------------------------------------"));

  // init SX1272 module
  sx1272.ON();

  // Select frequency channel
  e = sx1272.setChannel(CH_16_868);  
  USB.print(F("Setting Channel CH_16_868.\t state "));  
  USB.println(e);  

  // Select implicit (off) or explicit (on) header mode
  e = sx1272.setHeaderON();
  USB.print(F("Setting Header ON.\t\t state "));  
  USB.println(e); 

  // Select mode: from 1 to 10
  e = sx1272.setMode(3);
  USB.print(F("Setting Mode '3'.\t\t state ")); 
  USB.println(e);  

  // Select CRC on or off
  e = sx1272.setCRC_ON();
  USB.print(F("Setting CRC ON.\t\t\t state "));
  USB.println(e); 

  // Select output power (Max, High or Low)
  e = sx1272.setPower('H');
  USB.print(F("Setting Power to 'H'.\t\t state "));  
  USB.println(e);  

  // Select the node address value: from 2 to 255
  e = sx1272.setNodeAddress(8);
  USB.print(F("Setting Node Address to '8'.\t state "));
  USB.println(e); 
  USB.println();

  delay(1000);  

  USB.println(F("----------------------------------------"));
  USB.println(F("Receiving:")); 
  USB.println(F("----------------------------------------"));
}


void loop()
{
  // receive packet
  e = sx1272.receivePacketTimeout(10000);

  // check rx status
  if( e == 0 )
  {
    USB.println(F("\nShow packet received: "));

    // show packet received
    sx1272.showReceivedPacket();
  }
  else
  {
    USB.print(F("\nReceiving packet TIMEOUT, state "));
    USB.println(e, DEC);  
  }

  ///////////////////////////////
  // 1. Get SNR
  ///////////////////////////////  
  e = sx1272.getSNR();

  // check status
  if( e == 0 ) 
  {
    USB.print(F("Getting SNR \t\t--> OK. "));
    USB.print(F("SNR current value is: "));
    USB.println(sx1272._SNR);
  }
  else 
  {
    USB.println(F("Getting SNR --> ERROR"));
  } 

  ///////////////////////////////
  // 2. Get channel RSSI
  ///////////////////////////////
  e = sx1272.getRSSI();

  // check status
  if( e == 0 ) 
  {
    USB.print(F("Getting RSSI \t\t--> OK. "));
    USB.print(F("RSSI current value is: "));
    USB.println(sx1272._RSSI);

  }
  else 
  {
    USB.println(F("Getting RSSI --> ERROR"));
  } 

  ///////////////////////////////
  // 3. Get last packet received RSSI
  ///////////////////////////////
  e = sx1272.getRSSIpacket();

  // check status
  if( e == 0 ) 
  {
    USB.print(F("Getting RSSI packet \t--> OK. "));
    USB.print(F("Last packet RSSI value is: "));    
    USB.println(sx1272._RSSIpacket);
  }
  else 
  {
    USB.println(F("Getting RSSI packet --> ERROR"));
  } 
  
  USB.println();
}




