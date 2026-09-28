/*  
 *  ------ TD LAN Code Example -------- 
 *  
 *  Explanation: This example shows how to transmit packets through the 
 *  LAN network created with other TD module
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

// define buffer for data transmission
uint8_t data[17];
uint8_t length;

uint8_t error;
uint32_t counter = 0;

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
  

  USB.println();
}


void loop()
{
  
  //////////////////////////////////////////////
  // Create array of bytes to send
  //////////////////////////////////////////////  
  
  length = 0;
  data[length++] = 0x00;
  data[length++] = 0x01;
  data[length++] = 0x02;
  data[length++] = 0x03;
  data[length++] = 0x04;
  data[length++] = 0x05;
  data[length++] = 0x06;
  data[length++] = 0x07;
  data[length++] = 0x08;
  data[length++] = 0x09;
  data[length++] = 0x00;
  data[length++] = 0x00;
  data[length++] = 0x00;
  data[length++] = 0x00;
  data[length++] = 0x00;
  data[length++] = 0x00;
  data[length++] = counter++;
  
  USB.print(F("Data to send:"));
  USB.printHexln(data, length);
  
  //////////////////////////////////////////////
  // Send command
  //////////////////////////////////////////////  
   
  error = Sigfox.sendLAN(data, length);

  // Check status
  if( error == 0 ) 
  {
    USB.println(F("Send packet OK"));     
  }
  else 
  {
    USB.println(F("Send packet ERROR")); 
  }
  
  
  USB.println();  
  delay(5000);
}

