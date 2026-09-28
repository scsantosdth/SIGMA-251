/*  
 *  ------ [SW_03] - DI sensor Reading for Smart Water-------- 
 *  
 *  Explanation: Turn on the Smart Water Board and reads the DI sensor
 *  printing the result through the USB
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
 *  
 *  Version:           2.1
 *  Design:            David Gascón 
 *  Implementation:    Ahmad Saad
 */

#include <WaspSensorSW.h>

float value_di;
float value_calculated;

DIClass DISensor;

void setup()
{
  // Turn ON the Smart Water sensor board and start the USB
  SensorSW.ON();
  USB.ON();  
}

void loop()
{
  // Reading of the DI sensor
  value_di = DISensor.readDI();

  // Print of the results
  USB.print(F(" DI Output Voltage: "));
  USB.println(value_di);
  
  delay(500);  
}


