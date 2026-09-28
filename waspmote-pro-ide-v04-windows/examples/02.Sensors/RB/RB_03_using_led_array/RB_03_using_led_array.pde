// revisar

/*  
 *  -------------------------- RB.3 - Using led array ------------------- 
 *  
 *  Explanation: This example shows how to manage radiation board led array.
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

  // This example uses default values defined in WaspSensorRadiation.h
  // The user can define its own thresholds and use led array freely
  
  // 1. Set all leds OFF.
  RadiationBoard.ledBar(0);
  USB.println(F("Now leds are OFF"));
  delay(2000);
  
  // 2. Seting level one
  RadiationBoard.ledBar(TH1);
  delay(500);
  
  // 3. Seting level two
  RadiationBoard.ledBar(TH2);
  delay(500);

  // 4. Seting level three
  RadiationBoard.ledBar(TH3);
  delay(500);

  // 5. Seting level four
  RadiationBoard.ledBar(TH4);
  delay(500);
  
  // 6. Seting level five
  RadiationBoard.ledBar(TH5);
  USB.println(F("Now all leds are ON"));
  delay(2000);

}
