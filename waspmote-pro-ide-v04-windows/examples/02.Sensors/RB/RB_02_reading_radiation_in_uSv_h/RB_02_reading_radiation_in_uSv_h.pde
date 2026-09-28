/*  
 *  -------------------------- RB.2 - Reading radiation in uSv/h ------------------- 
 *  
 *  Explanation: This example shows how to measure radiation in uSv/h 
 *  during a specific time.
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
  
  // 1. Measure radiation during default time (10 s)
  USB.println(F("Measuring radiation levels."));
  radiation = RadiationBoard.getRadiation();
  USB.print(F("radiation[uSv/h]: "));
  USB.println(radiation);
  USB.println();
  delay(2000);

  // 2. Measure radiation during 25 s
  USB.println(F("Measuring during 25s."));
  radiation = RadiationBoard.getRadiationInt(25000);
  USB.print(F("radiation[uSv/h]: "));
  USB.println(radiation);
  USB.println();
  delay(2000);

}



