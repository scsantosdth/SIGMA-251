/*  
 *  ------ [SW_07] - Turbidity Sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Turbidity sensor and reads the turbidity 
 *  value. The turbidity sensor uses the RS-485 module and the Modbus 
 *  library, so is necessary to include these libraries in the code. 
 *  
 *  Copyright (C) 2015 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:           0.3 
 *  Design:            David Gascón 
 *  Implementation:    Ahmad Saad
 */

// Put your libraries here (#include ...)
#include <TurbiditySensor.h>
#include <ModbusMaster485.h>
#include <Wasp485.h>

turbiditySensorClass turbiditySensor;

void setup() {
  // Turn on the Turbidity sensor board and start the USB
  USB.ON();     
  turbiditySensor.ON();
}


void loop() {

  // Result of the communication
  int result = -1;
  int retries = 0;

  ///////////////////////////////////////////////////////////
  // Get Turbidity Measure
  ///////////////////////////////////////////////////////////

  // Initializes the retries counter
  retries = 0;

  // This variable will store the result of the communication
  // result = 0 : no errors 
  // result = 1 : error occurred
  result = -1;

  while ((result !=0) & (retries < 5)) 
  {  
    retries ++;
    result = turbiditySensor.readTurbidity();
    delay(10);
  }

  ///////////////////////////////////////////////////////////
  // Print Turbidity Value
  ///////////////////////////////////////////////////////////
  if (result == 0) {
    float turbidity = turbiditySensor.getTurbidity();
    USB.print(F("Turbidity value: "));
    USB.print(turbidity);    
    USB.println(F(" NTU"));
  } else {
    USB.println(F("Error while reading turbidity sensor"));
  }
  
  delay(500);  
}
