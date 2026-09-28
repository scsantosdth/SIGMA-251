/*  
 *  --[Pa_1] - Reading the sensors on Smart Parking board-- 
 *  
 *  Explanation: The Smart Parking board is turned on and calibrated,
 *               then a measurement taken every second approximately
 *               printing the result through the USB.
 *  
 *  Copyright (C) 2012 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Design:            David Gascón 
 
 *  Implementation:    Manuel Calahorra
 */

// Inclusion of the Smart Parking Sensor Board v20 library
#include <WaspSensorParking.h>

// Variable to store temperature
int temperature;

// Variable to store status
boolean status;

void setup()
{

  // Turn on the USB and print a start message
  USB.ON();
  USB.println(F("start"));
  delay(5000);

  // Once "calibration start" command is received, calibration starts. 
  USB.println(F("calibration start"));

  // The reference coefficients are loaded
  SensorParking.loadReference();
  
  // Turn on the board
  SensorParking.ON();
  delay(100);
  
  // Proceed to calibrate
  SensorParking.calibration();  

  // Print the initial values
  USB.print("Initial Values: ");
  USB.print(F("X-Field: "));
  USB.print(SensorParking.initialX);
  USB.print(F(" Y-Field: "));
  USB.print(SensorParking.initialY);
  USB.print(F(" Z-Field: "));
  USB.println(SensorParking.initialZ);
  USB.println(F("calibration finished"));
  
 
}

void loop()
{
  
  //Part 1: Reading the parking board sensors
  // Read the sensors
  SensorParking.readParkingSetReset();
  temperature = SensorParking.readTemperature();
  
  // Estimate the state and turn off the board
  SensorParking.calculateReference(temperature);
  status = SensorParking.estimateState();

  // Part 2: USB printing
  // Print the current value through the USB
  USB.print(F("X-Field: "));
  USB.print(SensorParking.valueX);
  USB.print(F(" Y-Field: "));
  USB.print(SensorParking.valueY);
  USB.print(F(" Z-Field: "));
  USB.print(SensorParking.valueZ);
  if(status == PARKING_OCCUPIED)
  {
    USB.println(" OCCUPIED");
  } else
  {
    USB.println(" EMPTY");
  }
  
  delay(1000);

}
