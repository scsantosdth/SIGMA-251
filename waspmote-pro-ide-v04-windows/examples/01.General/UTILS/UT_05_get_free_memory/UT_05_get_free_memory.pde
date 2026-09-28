/*
 *  ------ [Ut_05] Get Free Memory  --------
 *
 *  Explanation: This example shows how to get the actual free memory
 *  in RAM memory.
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

char* pointer;

void setup()
{
  // Init USB
  USB.ON();
  USB.println(F("UT_05 example"));
  
  USB.print(F("Initial free Memory (Bytes):"));
  USB.println(freeMemory());  
  USB.print(F("-----------------------------"));

}

void loop()
{
  // See how dynamic memory consumes RAM memory during code
  pointer = (char*)calloc(1,100); 
  
  USB.print(F("\nfree Memory:"));
  USB.println(freeMemory());
  
  // free memory
  free(pointer);
  pointer=NULL;
  
  delay(3000);
}


