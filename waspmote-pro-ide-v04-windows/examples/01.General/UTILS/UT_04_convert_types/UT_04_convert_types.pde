/*
 *  ------ [Ut_04] Convert types --------
 *
 *  Explanation: This example shows how to convert variable types
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
 *  Implementation:    Yuri Carmona
 */


void setup()
{
  // Init USB
  USB.ON();

}

void loop()
{
  /////////////////////////////////////////////////
  // 1. Convert from long int to string
  /////////////////////////////////////////////////
  char number2[20];
  Utils.long2array(1356, number2); // Gets the number ‘1356’ into the string  
  USB.println(number2);


  /////////////////////////////////////////////////
  // 2. Convert from float to string  (3 decimals)
  /////////////////////////////////////////////////
  char number3[20];
  Utils.float2String (134.54342, number3, 3);
  USB.println(number3);
  
 
  /////////////////////////////////////////////////
  // 3. Convert from string to int
  /////////////////////////////////////////////////
  int number4 = atoi("2341");
  USB.println(number4);
  
 
  /////////////////////////////////////////////////
  // 4. Convert from string to long int
  /////////////////////////////////////////////////
  long int number5 = atol("143413");
  USB.println(number5);
  
  USB.println(F("------------------------------------"));
  
  delay(3000);
}


