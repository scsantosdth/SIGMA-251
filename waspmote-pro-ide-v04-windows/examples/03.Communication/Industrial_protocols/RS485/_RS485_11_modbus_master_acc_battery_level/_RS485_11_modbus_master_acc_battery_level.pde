/*   
 *  ------ [RS-485_11] Modbus Master ACC and Battery level -------- 
 *   
 *  This sketch shows the use of the Modbus communication protocol over 
 *  RS-485 standard, and the use of the main functions of the library.
 *. Modbus allows for communication between many devices connected
 *  to the same network. There are many variants of Modbus protocols, 
 *  but Waspmote implements the RTU format. Modbus RTU is the most 
 *  common implementation available for Modbus. 
 *  
 *  This example shows how to configure the Waspmote as a Modbus 
 *  master  device. The Waspmote read the ACC values and the battery
 *  level from a Modbus slave.
 *
 *  Note: See the example RS-485_10_modbus_slave_acc_battery_level
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


// Include these libraries for using the RS-485 and Modbus functions
#include <Wasp485.h>
#include <ModbusMaster485.h>

// Instantiate ModbusMaster object as slave ID 1
ModbusMaster485 slave(1); 

// Define addresses for reading
#define accX 0 
#define accY 1 
#define accZ 2
#define bateryLevel 3

// Define the number of bits to read
#define bytesQty 4

void setup()
{
  // Power on the USB for viewing data in the serial monitor
  USB.ON();

  // Initialize Modbus communication baud rate
  slave.begin(9600);

  // Print hello message
  USB.println("Modbus communication over RS-485");
  delay(100);
}


void loop()
{
  //              Reading from the temperature sensor 
  // *****************************************************************************************

  // This variable will store the result of the communication
  // Result = 0 : no errors
  // Result = 1 : error occurred 
  // Read 4 bytes
  int result =  slave.readHoldingRegisters(accX ,bytesQty);

  if (result != 0) {
    // If no response from the slave, print an error message
    USB.println("Communication error. Couldn't read from slave");
    delay(100);
  } 
  else { 
    USB.println("\n \t0X\t0Y\t0Z\tBatery %"); 
    USB.print(" ACC\t"); 
    USB.print(slave.getResponseBuffer(accX), DEC);
    USB.print(F("\t")); 
    USB.print(slave.getResponseBuffer(accY), DEC);
    USB.print(F("\t")); 
    USB.print(slave.getResponseBuffer(accZ), DEC);
    USB.print(F("\t")); 
    USB.println(slave.getResponseBuffer(bateryLevel), DEC);
  }

  USB.print("\n");
  delay(1000);

  // Clear the response buffer
  slave.clearResponseBuffer();

}


