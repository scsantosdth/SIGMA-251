/* 
 *  ------ [CAN_Bus_01] CAN Bus Basic Example -------- 
 * 
 *  This sketch shows how to send data through CAN Bus standard. 
 *  CAN Bus (for controller area network) is a vehicle bus standard 
 *  designed to allow micro controllers and devices to communicate 
 *  with each other within a vehicle without a host compute.
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
 *  Implementation:   Luis Antonio Martin  & Ahmad Saad
 */

// Include always these libraries before using the CAN Bus functions
#include <WaspCAN.h>

// ID numbers
#define IDWAITED 200
#define OWNID 100


// Setting up our devices and I/Os 
void setup() {
  
  // Inits the USB
  USB.ON();
  delay(100);

  // Let's open the bus. Remember the input parameter:
  // 1000: 1Mbps
  // 500: 500Kbps  <--- Most frequently used
  // 250: 250Kbp
  // 125: 125Kbps
  CAN.ON(500);
}

void loop() {

  //****************************************
  // 1. Receive data
  //****************************************

  if (CAN.messageAvailable() == 1) {
    // Read the last message received
    CAN.getMessage(&CAN.messageRx);
    // Print in the serial monitor the received message
    CAN.printMessage(&CAN.messageRx);
  }
  

  //****************************************
  // 2. Send data
  //****************************************

  // Insert the ID in the data structure
  CAN.messageTx.id = OWNID;
  // These fields include the data to send
  CAN.messageTx.data[0] = 0;
  CAN.messageTx.data[1] += 1;
  CAN.messageTx.data[2] = 2;
  CAN.messageTx.data[3] = 3;
  CAN.messageTx.data[4] = 4;
  CAN.messageTx.data[5] = 5;
  CAN.messageTx.data[6] = 6;
  CAN.messageTx.data[7] = 7;

  // The length of the data structure
  CAN.messageTx.header.length = 8;
  // Send data
  CAN.sendMessage(&CAN.messageTx);  
  // A time delay
  delay(1000);
}




