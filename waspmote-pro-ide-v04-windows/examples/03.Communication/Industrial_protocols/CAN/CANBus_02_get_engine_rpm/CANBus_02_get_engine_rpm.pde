/*  
 *  ------ [CAN_Bus_02] CAN Bus Get Engine RPM -------- 
 *  
 *  This sketch shows how to get the engine RPM using the standard OBD-II 
 *  PIDs codes. This codes are used to request data from a vehicle, used 
 *  as a diagnostic tool.
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
 *  Version:          0.1 
 *  Implementation:   Luis Antonio Martin & Ahmad Saad
 */

// Include always these libraries before using the CAN Bus functions
#include <WaspCAN.h>

void setup()
{ 	
  // Turn on the USB 
  USB.ON();
  delay(100);

  // Print initial message 
  USB.println("Initializing CAN Bus...");	

  // Configuring the BUS at 500 Kbit/s
  CAN.ON(500);   
  USB.println("CAN Bus initialized at 500 KBits/s");  
}

void loop()
{	
  // Read the value of RPM if the engine 
  int engineRpm = CAN.getEngineRPM();     
  
  // Print received data in the serial monitor
  USB.print("RPM of engine: "); 
  USB.println(engineRpm);
  delay(1000); 

}





