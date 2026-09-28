/*  
 *  -------------------------- RB.1 - Reading Radiation in CPM ------------------- 
 *  
 *  Explanation: This example shows how to read radiation in CPM (counts per minute)
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
 *  Implementation:    Javier Siscart 
 */

#include "WaspSensorRadiation.h"

void setup()
{

  // Starting USB
  USB.ON();
  USB.println(F("Starting Waspmote..."));

  // Starting Radiation Board
  RadiationBoard.ON();

}

void loop()
{

  // Variable to store measured radiation
  float radiation;

  // Measure radiation in cpm, during 5s
  USB.println(F("Measuring during 5s cpm"));
  radiation = RadiationBoard.getCPM(5000);
  USB.print(F("radiation[cpm]: "));
  USB.println(radiation);
  USB.println();
  delay(2000);

}



