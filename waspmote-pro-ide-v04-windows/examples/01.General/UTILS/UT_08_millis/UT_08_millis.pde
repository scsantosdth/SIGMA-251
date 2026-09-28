/*
 *  ------   [UT_08] - millis() function   -------- 
 *
 *  Explanation: This example shows how to use the millis() function
 *  to perform time-controlled loops
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
 *  Version:           0.1 
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona
 */

// define variable to store number of milliseconds
unsigned long previous;

// define timeout: 10 seconds
unsigned long TIMEOUT = 10000; // ms units


void setup() 
{ 
  USB.ON();
  USB.println(F("UT_08 example - millis function\n"));

  // get millis() value
  previous = millis();

  USB.print(F("millis() function returns the execution time (ms units):"));
  USB.println(previous);
  USB.println();
}



void loop() 
{
  // 1. get actual time
  previous = millis();
  
  USB.print(F("1. Enter while loop with previous = "));
  USB.println(previous);


  // 2. enter while loop for specified TIMEOUT
  while( (millis() - previous) < TIMEOUT )
  {
    // Do whatever...
    USB.print(F("2. Inside while loop until timeout. millis() = "));
    USB.println(millis());
    delay(1000);

    // Check overflow (mandatory sentence)
    if( millis()<previous )  previous = millis();
  }


  // 3. exit while loop
  USB.println(F("3. Exit while loop"));
  USB.println();
  
  
  delay(5000);
}







