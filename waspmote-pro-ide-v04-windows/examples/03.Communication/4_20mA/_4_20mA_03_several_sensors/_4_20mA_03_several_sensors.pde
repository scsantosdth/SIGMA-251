/*
 *  ------ [4-20mA_03] Several Sensor --------
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

// Instantiate currentLoop object in channel 1.
#define TEMPERATURE CHANNEL3
#define HUMIDITY CHANNEL4

float current;

void setup()
{

  // Power on the USB for viewing data in the USB monitor
  USB.ON();
  delay(100);  

  // Sets the 5V switch ON
  currentLoopBoard.ON(SUPPLY5V);
  delay(100);
  
  // Sets the 12V switch ON
  currentLoopBoard.ON(SUPPLY12V); 
  delay(100); 

}

void loop()
{
  // Temperature sensor measure 
  //==================================================================

  if (currentLoopBoard.isConnected(TEMPERATURE))
  {
    // Get the sensor value as a current in mA.
    current = currentLoopBoard.readCurrent(TEMPERATURE);
    USB.print("Current value read from temperature sensor: ");
    USB.print(current);
    USB.println(" mA");
  }
  else {
    USB.println("Temperature sensor is not connected...");
  }

  USB.println("***************************************");
  USB.print("\n");

  // Humidity sensor measure 
  //==================================================================

  if (currentLoopBoard.isConnected(HUMIDITY))
  {
    // Get the sensor value as a current in mA.
    current = currentLoopBoard.readCurrent(HUMIDITY);
    USB.print("Current value read from humidity sensor: ");
    USB.print(current);
    USB.println(" mA");
  }
  else {
    USB.println("Humidity sensor is not connected...");
  }


  USB.println("***************************************");
  USB.print("\n");

  // Delay after reading.
  delay(5000);
}




