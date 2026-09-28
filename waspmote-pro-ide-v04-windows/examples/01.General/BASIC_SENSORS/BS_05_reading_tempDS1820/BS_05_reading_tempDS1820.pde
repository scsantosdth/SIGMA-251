/*
 *  ------ [BS_05] Waspmote reading DS1820 temperature sensor --------
 *
 *  Explanation: This example shows how to read the DS1820 temperature sensor
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
 *  Implementation:    Marcos Yarza
 */

// Variables

float temp = 0;
 
 
void setup()
{
  // Init USB
  USB.ON();
  
}

void loop()
{
  // Reading the DS1820 temperature sensor connected to DIGITAL8
  temp = Utils.readTempDS1820(DIGITAL8);
  USB.print(F("DS1820 Temperature: "));
  USB.print(temp);
  USB.println(F(" degrees"));
  delay(1000);
}

