/*
 *  ------ [INT_09] Accelerometer interrupt with No Sleep mode example -------- 
 *
 *  Explanation: This example shows how to manage Accelerometer 
 *  Interruption without setting any low-power consumption state
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
 *  Design:                 David Gascón
 *  Implementation:         Yuri Carmona
 */


void setup()
{

  USB.ON();
  USB.println(F("INT_09 example"));

  ///////////////////////////////////////////////
  // 1. Starts accelerometer
  ///////////////////////////////////////////////
  ACC.ON();

  ///////////////////////////////////////////////
  // 2. Enable interruption: ACC Free Fall interruption 
  ///////////////////////////////////////////////
  ACC.setFF(); 
}


void loop()
{
  ///////////////////////////////////////////////
  // 3. Check the interruption flag 
  ///////////////////////////////////////////////
  if( intFlag & ACC_INT ) 
  { 
    // Disable interruption: ACC Free Fall interrupt 
    ACC.unsetFF(); 

    USB.ON();
    USB.println(F("++++++++++++++++++++++++++++++++++"));
    USB.println(F("++ Free Fall interrupt detected ++"));
    USB.println(F("++++++++++++++++++++++++++++++++++")); 
    USB.println();
    
    // Enable interruption: ACC Free Fall interruption    
    ACC.setFF(); 
  }

  ///////////////////////////////////////////////////////////////////////
  // 4. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 5. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();

}




