/*
 *  ------ [4-20mA_02] Current Loop Connection State --------
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
  // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  delay(100);
  
  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  delay(100); 
}

void loop()
{
  if (currentLoopBoard.isConnected(CHANNEL1))
  {
    // Get the sensor value in int format (0-1023)
    int value = 0;    
    // Voltage and current conversion variables
    float voltage = 0;
    float current = 0;
    
    // Read from the ADC
    value = currentLoopBoard.readChannel(CHANNEL1);

    USB.print("Int value read from channel 1: ");
    USB.println(value);

    // Get the sensor value as a voltage in Volts
    voltage = currentLoopBoard.readVoltage(CHANNEL1);


    USB.print("Voltage value read from channel 1: ");
    USB.print(voltage , 3);
    USB.println(" V");

    // Get the sensor value as a curren in mA
    current = currentLoopBoard.readCurrent(CHANNEL1);
    USB.print("Current value read from channel 1: ");
    USB.print(current , 3);
    USB.println(" mA");


    USB.println("***************************************");
    USB.print("\n");

  }
  else {

    USB.println("The sensor is not connected...");

  }

  // Delay after reading
  delay(1000);

}



