/*   
 *  ------ [RS-485_02] Receive Data -------- 
 *   
 *  This sketch shows how to receive data through RS-485 standard. 
 *  This standard defines the electrical characteristics of drivers
 *  and receivers for use in digital systems. It does not specify
 *  or recommend any communications protocol. For a complete 
 *  communication protocol, please see the Modbus examples. 
 *   
 *  Copyright (C) 2014 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:          0.1 
 *  Implementation:   Ahmad Saad
 */

// Include always this library when you are using the Wasp485 functions  
#include <Wasp485.h>

void setup() {

  // Power on the USB for viewing data in the serial monitor
  USB.ON();
  delay(100);

  // Powers on the module and assigns the SPI in socket0
  if ( W485.ON() == 0) {
     USB.println("RS-485 module started successfully");
  } else {
     USB.println("RS-485 did not initialize correctly");
  }
  delay(100);

  // Configure the baud rate of the module
  W485.baudRateConfig(115200);
  // Configure the parity bit as disabled 
  W485.parityBit(DISABLE);
  // Use one stop bit configuration 
  W485.stopBitConfig(1);  
  // Print hello message
  USB.println("This is RS-485 communication receive data example");
}



void loop() {     
  
  // If data in response buffer 
  if (W485.available()) 
  {
    while (W485.available()) {
      // Read one byte from the buffer
      char data = W485.read();
      // Print data received in the serial monitor
      USB.print(data);
    }
  }   
  
  delay(1);
}
