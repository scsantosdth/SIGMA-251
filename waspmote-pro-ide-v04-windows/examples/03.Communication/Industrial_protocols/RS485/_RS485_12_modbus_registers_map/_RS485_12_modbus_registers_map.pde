/*  
 *  ------ [RS-485_12] - Modbus Registers Map --------
 *  
 *  This sketch shows the use of the Modbus communication protocol over
 *  RS-485 standard, and the use of the main functions of the library.
 *  Modbus allows for communication between many devices connected
 *  to the same network. There are many variants of Modbus protocols,
 *  but Waspmote implements the RTU format. Modbus RTU is the most
 *  common implementation available for Modbus.
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
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <http://www.gnu.org/licenses/>.
 *  
 *  Version:           0.1
 *  Design:            David Gascón
 *  Implementation:    Ahmad Saad
 */

///////////////////////////////////////////////////////////////////////////////
// RS-485 Modbus parameters
///////////////////////////////////////////////////////////////////////////////

// Include these libraries for using the RS-485 and Modbus functions
#include <Wasp485.h>
#include <ModbusMaster485.h>

// TABLE contents
#define NAME 0
#define ADDRESS 1
#define BYTES 2
#define FCODE 3

// Define the size of the TABLE
#define NUM_REGISTERS 5
#define NUM_PARAMETERS 4

// Registers names
#define SERIALNUMBER 0
#define SOFTVERSION 1
#define MODBUSADDRESS 2
#define TEMPERATURE 3
#define HUMIDITY 4

// Function codes used
#define READ_HOLDING_REGISTERS 0x03


// Modbus Table Registers
static const int TABLE[NUM_REGISTERS][NUM_PARAMETERS] = 
{
  // NAME,         ADDRESS,  BYTES,   FCODE
  { SERIALNUMBER,     0,      4,    READ_HOLDING_REGISTERS } ,
  { SOFTVERSION,      4,      2,    READ_HOLDING_REGISTERS } ,
  { MODBUSADDRESS,    6,      2,    READ_HOLDING_REGISTERS } ,
  { TEMPERATURE,    101,      2,    READ_HOLDING_REGISTERS } ,
  { HUMIDITY,       304,      2,    READ_HOLDING_REGISTERS }  
};

// Default address of Modbus device
#define DEFAULTADDRESS 254

// Instantiate ModbusMaster object as slave ID 254
ModbusMaster485 node(DEFAULTADDRESS);

// Variable to store the results of Modbus communication
int result;

// Serial monitor messages
static const char* messages[] =
{
  "SERIAL NUMBER",
  "SOFTWARE VERSION",
  "MODBUS ADDRESS",
  "TEMPERATURE",
  "HUMIDITY",
};

void setup()
{
  // Initialize USB port for debugging
  USB.ON();
  USB.println(F("Modbus table registers example"));

  // Initialize Modbus communication baud rate
  node.begin(19200);
}


void loop()
{
  // Initial message
  USB.println(F("Reading Modbus device..."));
  USB.println(F("*****************************************"));

  // This loop will read all the registers
  // And prints in the serial monitor the results
  for ( int i = SERIALNUMBER ; i <= HUMIDITY; i++) {    
    // General function to read registers
    result = node.readRegiters(TABLE[i][ADDRESS] , TABLE[i][BYTES], TABLE[i][FCODE]);

    // result = 0: no errors
    // result != 0: error occurred
    if (result !=0) {
      // If no response from the slave, print an error message
      USB.print(F("Communication error while trying to read"));
      USB.println(messages[i]);
      USB.print(F("Result: "));
      USB.println(result);
      delay(100);
    } 
    else {
      USB.print(messages[i]);
      USB.print(F(" => "));
      
      // Some registers return more than one value
      for (int i = 0; i < node.available(); i++)
      {
        USB.print(node.getResponseBuffer(i) , DEC);
      }
    }
    USB.println();
  }

  USB.println(F("*****************************************"));
  USB.println();
  delay(10000);
}

