/*
 *  ------ [ACC_8] Waspmote Accelerometer sleep to wake Example--------
 *
 *  Explanation: This example shows how to manage the sleep to wake
 *  mode
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

long previous = 0;

void setup()
{
  ACC.ON();
  USB.ON(); // starts using the serial port
  USB.println(F("ACC_08 example"));
}


void loop()
{
  ACC.ON();
  USB.println(F("\r\nAccelerometer ON"));
  ACC.setMode(ACC_LOW_POWER_5);
  ACC.setFF();
  USB.println("Free Fall interrupt configured");
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_5"));

  // Sleep to Wake activation
  ACC.setSleepToWake();
  USB.println("Sleep to Wake mode configured");
  
  PWR.sleep(ALL_OFF);
   
  if( intFlag & ACC_INT )
  {
    // unset the Sleep to Wake
    ACC.unSetSleepToWake();
    // clear the accelerometer interrupt flag on the general interrupt vector
    intFlag &= ~(ACC_INT);
    // read the acceleration source register
    delay(200);
    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ Free Fall interrupt detected ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++"));    
  }
  delay(2000);
}
