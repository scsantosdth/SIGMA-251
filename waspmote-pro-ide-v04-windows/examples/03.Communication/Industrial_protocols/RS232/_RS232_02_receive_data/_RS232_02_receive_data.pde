/*   
 *  ------ [RS-232_02] RS-232 Receive Data -------- 
 *   
 *  This sketch shows how to receive data through RS-232 standard. 
 *  This standard defines the electrical characteristics of drivers
 *  and receivers for use in digital systems. It does not specify
 *  or recommend any communications protocol. For a complete 
 *  communication protocol, please see the Modbus examples. 
 *   
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *   
 *  This program is free software: you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation, either version 2 of the License, or 
 *  (at your option) any later version. 
 *   
 *  This program is distributed in the hope that it will be useful, 
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of 
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
 *  GNU General Public License for more details. 
 *   
 *  You should have received a copy of the GNU General Public License 
 *  along with this program. If not, see <http://www.gnu.org/licenses/>. 
 *   
 *  Version:          0.2
 *  Design:           David Gascon 
 *  Implementation:   Ahmad Saad
 */

//Include always this library when you are using the Wasp232 functions  
#include <Wasp232.h>

uint8_t error;

void setup() {

  // Power on the USB for viewing data in the serial monitor.  
  // Note : if you are using the socket 0 for communication, 
  // for viewing data in the serial monitor, you should open
  // the USB at the same speed. 
  USB.ON();
  delay(100);


  // Powers on the module and assigns the UART in socket0
  W232.ON(SOCKET0);

  // Configure the baud rate of the module
  W232.baudRateConfig(115200);

  // Configure the parity bit as disabled 
  W232.parityBit(NONE);

  // Use one stop bit configuration
  W232.stopBitConfig(1);

  // Print hello message
  USB.println("Hello, this is RS-232 communication receive data example.");

}



void loop() 
{  
  if(W232.receive() > 0)
  { 
    USB.println(W232._buffer, W232._length);
  }

  delay(100);
}

