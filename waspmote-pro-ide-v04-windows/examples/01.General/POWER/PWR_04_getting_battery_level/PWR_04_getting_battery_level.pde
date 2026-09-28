/*  
 *  ------ [PWR_4] Getting Battery Level Example -------- 
 *  
 *  Explanation: This example shows how to get the remaining battery 
 *  level.
 *
 *  WARNING: This example is suitable for rechargeable batteries only. 
 *  Non-rechargeable batteries always show a plain discharge curve, 
 *  so it is not possible to know how much power is left.
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Marcos Yarza
 */

char WARNING_MESSAGE[] =\
"\n-------------------------------------------------------------------\n"\
"WARNING: This example is suitable for rechargeable batteries only.\n"\
"Non-rechargeable batteries always show a plain discharge curve,\n"\
"so it is not possible to know how much power is left.\n"
"-------------------------------------------------------------------\n";
 
 
void setup()
{
  // Open the USB connection
  USB.ON();
  USB.println(F("PWR_4 example"));
  
  // show warning
  USB.println( WARNING_MESSAGE );
}



void loop()
{
  // Show the remaining battery level
  USB.print(F("Battery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.print(F(" %"));
  
  // Show the battery Volts
  USB.print(F(" | Battery (Volts): "));
  USB.print(PWR.getBatteryVolts());
  USB.println(F(" V"));
  
  delay(5000);
}
