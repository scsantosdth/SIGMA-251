/*   
 *  ------ [4-20mA_01] Current Loop Basic Example -------- 
 *   
 *  Explanation: This sketch shows how to use the most important 
 *  features of the 4-20mA current loop board in Waspmote. This 
 *  standard is used to transmit information of sensor over long
 *  distances. Waspmote uses analog inputs for reading the sensor 
 *  values. 
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
 *  Design:           David Gascon 
 *  Implementation:   Ahmad Saad
 */

// Include this library for using current loop functions
#include <currentLoop.h>

void setup()
{
  // Power on the USB for viewing data in the serial monitor
  USB.ON();
  delay(100);  

  // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  delay(1000);

  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  delay(1000); 
}

void loop()
{  
  // Get the sensor value in integer format (0-1023)
  int value = currentLoopBoard.readChannel(CHANNEL1); 
  USB.print("Int value read from channel 1: ");
  USB.println(value);

  // Get the sensor value as a voltage in Volts
  float voltage = currentLoopBoard.readVoltage(CHANNEL1); 
  USB.print("Voltage value rad from channel 1: ");
  USB.print(voltage);
  USB.println("V");

  // Get the sensor value as a current in mA
  float current = currentLoopBoard.readCurrent(CHANNEL1);
  USB.print("Current value read from channel 1: ");
  USB.print(current);
  USB.println("mA");

  USB.println("***************************************");
  USB.print("\n");

  delay(1000);  

}







