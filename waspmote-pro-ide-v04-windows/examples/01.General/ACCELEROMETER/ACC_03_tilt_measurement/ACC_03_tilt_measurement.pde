/*
 *  ------ [ACC_3] Waspmote Accelerometer tilt measurement --------
 *
 *  Explanation: This example shows how to get the acceleration on the
 *  different axis and calculate the tilt of Waspmote
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
  ACC.ON(FS_2G);
  USB.ON(); // starts using the serial port
  USB.println(F("ACC_03 example"));
}

void loop()
{

  
  float x_acc = ACC.getX();
  if (x_acc > 1000) x_acc = 1000;
  if (x_acc < -1000) x_acc = -1000;
  float angle_x = (180 / PI) * asin(x_acc/1000);
  
  float y_acc = ACC.getY();
  if (y_acc > 1000) y_acc = 1000;
  if (y_acc < -1000) y_acc = -1000;
  float angle_y = (180 / PI) * asin(y_acc/1000);
  
  float z_acc = ACC.getZ();
  if (z_acc > 1000) z_acc = 1000;
  if (z_acc < -1000) z_acc = -1000;
  float angle_z = (180 / PI) * asin(z_acc/1000);
  
  USB.println(F("+++++++++++++++++++++++++++++++++"));
  USB.print(F("Acceleration X: "));
  USB.print(x_acc,DEC);
  USB.print(F(" | X angle: "));
  USB.println(angle_x);
  
  USB.print(F("Acceleration Y: "));
  USB.print(y_acc,DEC);
  USB.print(F(" | Y angle: "));
  USB.println(angle_y);
  
  USB.print(F("Acceleration Z: "));
  USB.print(z_acc,DEC);
  USB.print(F(" | Z angle: "));
  USB.println(angle_z);
 
  delay(500);
  
}



