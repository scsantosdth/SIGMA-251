/*
 *  ------ [ACC_4] Waspmote Accelerometer Power Modes --------
 *
 *  Explanation: This example shows how to get the acceleration on the
 *  different axis using the power modes of the accelerometer
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


void setup()
{
  ACC.ON();
  USB.ON(); // starts using the serial port
  USB.println(F("ACC_4 example"));
}

int x_acc = 0;
int y_acc = 0;
int z_acc = 0;

void loop()
{
  USB.println(F("\r\n+++++++++++++++++++++++++++++++++++++++"));
  
  // Normal mode
  ACC.setMode(ACC_ON);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("Accelerometer mode: ACC_ON"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000);
  
  // LOW POWER 1
  ACC.setMode(ACC_LOW_POWER_1);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_1"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000);

  // LOW POWER 2
  ACC.setMode(ACC_LOW_POWER_2);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_2"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000);
  
  // LOW POWER 3
  ACC.setMode(ACC_LOW_POWER_3);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_3"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000); 
  
  // LOW POWER 4
  ACC.setMode(ACC_LOW_POWER_4);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_4"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000); 
  
  // LOW POWER 5
  ACC.setMode(ACC_LOW_POWER_5);
  x_acc = ACC.getX();    // reading X value
  y_acc = ACC.getY();    // reading Y value
  z_acc = ACC.getZ();    // reading Z value
 
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_LOW_POWER_5"));
  USB.print(F("Acceleration: X= ")); 
  USB.print(x_acc, DEC);
  USB.print(F(" | Y= ")); 
  USB.print(y_acc, DEC);
  USB.print(F(" |Z= ")); 
  USB.println(z_acc, DEC);

  delay(1000); 
  
  // ACC POWER DOWN
  ACC.setMode(ACC_POWER_DOWN);
  
  ACC.OFF();  
   
  USB.println(F("------------------------------"));
  USB.println(F("Accelerometer mode: ACC_POWER_DOWN"));
    
  delay(5000);
  
}



