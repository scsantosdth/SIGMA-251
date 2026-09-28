/*  
 *  ------ [CAN_Bus_04] CAN Bus Dash Board -------- 
 *  
 *  This sketch shows how to get the most important parameters from 
 *  a vehicle using the standard OBD-II PIDs codes. This codes are 
 *  used to request data from a vehicle, used as a diagnostic tool. 
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
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
 */

// Include always these libraries before using the CAN Bus functions
#include <WaspCAN.h>


void setup() {
  // Turn on the USB 
  USB.ON();
  delay(100);

  // Print initial message 
  USB.println("Initializing CAN Bus...");	

  // Configuring the Bus at 500 Kbit/s
  CAN.ON(500);   

  USB.println("CAN Bus initialized at 500 KBits/s");  
  USB.println();
}


void loop() {

  // Read the value of the Vehicle Speed 
  int vehicleSpeed = CAN.getVehicleSpeed(); 

  // Read the value of RPM of the engine
  int engineRPM = CAN.getEngineRPM(); 

  // Read the engine fuel rate
  int engineFuelRate = CAN.getEngineFuelRate();

  // Get the fuel level
  int fuelLevel = CAN.getFuelLevel();

  // Get the throttle position
  int throttlePosition = CAN.getThrottlePosition();

  //Get the fuel pressure value 
  int fuelPressure = CAN.getFuelPressure(); 


  USB.println(F("<============================================>"));
  USB.print(F("\tVehicle Speed =>  ")); 
  USB.print(vehicleSpeed);
  USB.println("  Km / h");

  USB.print(F("\tEngine RPM =>  ")); 
  USB.print(engineRPM);
  USB.println("  RPM");

  USB.print(F("\tEngine Fuel Rate =>  ")); 
  USB.print(engineFuelRate);
  USB.println("  L/h");

  USB.print(F("\tFuel Level :=>  ")); 
  USB.print(fuelLevel);
  USB.println("  %");

  USB.print(F("\tThrottle Position =>  ")); 
  USB.print(throttlePosition);
  USB.println(" % ");

  USB.print(F("\tFuel Pressure =>  ")); 
  USB.print(fuelPressure);
  USB.println("  KPa");

  USB.println(F("<============================================>"));

  USB.println();

  delay(1000); 
}


