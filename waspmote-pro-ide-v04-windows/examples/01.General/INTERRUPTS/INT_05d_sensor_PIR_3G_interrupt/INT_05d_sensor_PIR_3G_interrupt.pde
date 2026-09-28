/*
 *  ------ [INT_05d] Setting battery level interrupt example -------- 
 *
 *  Explanation: This example shows how to setup the PIR sensor 
 *  interruption from Video Camera Board
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L. 
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
 *  Version:                0.1
 *  Design:                 David Gascon
 *  Implementation:         Yuri Carmona
 */


// Inclusion of the 3G library
#include "Wasp3G.h"


void setup()
{
  USB.ON();
  USB.println(F("INT_09 example"));

  // Turn on the Events Sensor Board
  _3G.ON();
}



void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: interruptions from the Sensor Board
  ///////////////////////////////////////////////////////////////////////
   _3G.enablePIRInterrupt();


  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  //////////////////////////////////////////////////////////////////////
  USB.println(F("Enter sleep mode..."));  
  PWR.sleep( ALL_ON );

  // Interruption event happened

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption: from the board 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////////////////////////////
  _3G.disablePIRInterrupt(1);

  USB.ON();
  USB.println(F("Waspmote wakes up"));


  ///////////////////////////////////////////////////////////////////////
  // 4. Check the interruption source
  ///////////////////////////////////////////////////////////////////////
  if( intFlag & PIR_3G_INT )
  { 
    // print info
    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ PIR_3G_INT interruption captured!! ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++++++++")); 

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }


  } 

  ///////////////////////////////////////////////////////////////////////
  // 5. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 6. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();

}








