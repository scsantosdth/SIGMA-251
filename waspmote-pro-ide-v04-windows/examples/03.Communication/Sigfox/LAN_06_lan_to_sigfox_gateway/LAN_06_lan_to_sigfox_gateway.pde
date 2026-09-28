/*  
 *  ------ TD LAN Code Example -------- 
 *  
 *  Explanation: This example shows how to receive multiple packets
 *  from a LAN network. Then all packets received are sent to the
 *  Sigfox network. Thus, this node will act as gateway from a LAN
 *  network to the Sigfox infrastructure
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
 *  Version:           0.1
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona    
 */

// Put your libraries here (#include ...)

#include <WaspSigfox.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

// ADDRESS: Define the LAN network address. 
// Range: From 0x000000 to 0xFFFFFF. 
// Default: 0x000000
//////////////////////////////////////////////
uint32_t address   = 0x000001;
//////////////////////////////////////////////

uint8_t error;

// sigfox packet is 12-byte length (24 hexa)
char sigfox_packet[25];



void setup() 
{
  USB.ON();  

  //////////////////////////////////////////////
  // switch on
  //////////////////////////////////////////////
  error = Sigfox.ON(socket);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("Switch ON OK"));     
  }
  else 
  {
    USB.println(F("Switch ON ERROR")); 
  } 


  //////////////////////////////////////////////
  // Set LAN address
  //////////////////////////////////////////////
  error = Sigfox.setAddressLAN(address);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("Set LAN Address OK"));   
  }
  else 
  {
    USB.println(F("Set LAN Address ERROR")); 
  } 


  //////////////////////////////////////////////
  // Set Multi-packet reception  mode
  //////////////////////////////////////////////
  error = Sigfox.setMultiPacket();

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("Set Multi-packet mode OK"));   
  }
  else 
  {
    USB.println(F("Set Multi-packet mode ERROR")); 
  } 

  USB.println();
}



void loop()
{
  // Receive data
  USB.println(F("Waiting for LAN data..."));   

  // wait for a new packet (10 seconds)
  error = Sigfox.getMultiPacket(10);

  if (error == 0) 
  {
    USB.println(F("---------------------------------------"));
    USB.print(F("LAN Packet received: "));
    USB.println(Sigfox._packet);

    // copy first 12 bytes from received LAN packet
    snprintf( sigfox_packet, sizeof(sigfox_packet), "%s", Sigfox._packet);

    USB.println(F("Routing the packet to Sigfox network (only first 12 bytes)..."));    
    USB.print(F("Sigfox packet to send: "));
    USB.println(sigfox_packet); 

    // send Sigfox packet with received data (only first 12 bytes)  
    error = Sigfox.send(sigfox_packet);

    // Check sending status
    if( error == 0 ) 
    {
      USB.println(F("Sigfox packet sent OK"));     
    }
    else 
    {
      USB.println(F("Sigfox packet sent ERROR")); 
    } 
    USB.println(F("---------------------------------------"));
  }
  else
  {
    USB.println(F("Packet not received (timeout)"));  
  }


  USB.println();
}




