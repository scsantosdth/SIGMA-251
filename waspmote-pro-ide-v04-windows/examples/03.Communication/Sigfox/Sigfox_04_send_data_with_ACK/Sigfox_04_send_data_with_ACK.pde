/*  
 *  ------ Sigfox Code Example -------- 
 *  
 *  Explanation: This example shows how to send a Sigfox packet waiting 
 *  for a ACK (acknowledgement) to arrive.
 *  In this example, the message to be sent is defined as a string.
 *  This string defines the diferente HEX values of the bytes to be sent
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
#include <WaspSigfox.h>

//////////////////////////////////////////////
uint8_t socket = SOCKET0;
//////////////////////////////////////////////

uint8_t error;

void setup() 
{
  USB.ON(); 
  USB.println(F("Sigfox - Sending example\n"));     
}


void loop() 
{  
  //////////////////////////////////////////////
  // 1. switch on
  //////////////////////////////////////////////
  error = Sigfox.ON(socket);

  // Check sending status
  if( error == 0 ) 
  {
    USB.println(F("Switch ON OK"));     
  }
  else 
  {
    USB.println(F("Switch ON ERROR")); 
  }   


  //////////////////////////////////////////////
  // 2. send data
  //////////////////////////////////////////////

  USB.println(F("Sending a packet..."));     

  // Send 12 bytes at most
  error = Sigfox.sendACK("000102030405060708090A0B");

  // Check sending status
  if( error == 0 ) 
  {
    USB.println(F("Sigfox packet sent OK")); 

    USB.print(F("Back-End response:"));
    USB.println(Sigfox._buffer,Sigfox._length);    
  }
  else 
  {
    USB.println(F("Sigfox packet sent ERROR")); 
  } 


  //////////////////////////////////////////////
  // 3. sleep
  //////////////////////////////////////////////
  USB.println("\nEnter sleep");
  PWR.deepSleep("00:01:00:00",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
  USB.println("\n***************************************");
}

