/*  
 *  ------ [INT_01] Waspmote watchdog timer interrupt example -------- 
 *  
 *  Explanation: This example shows how to set the watchdog timer interrupt
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
 *  Version:           0.2
 *  Design:            Marcos Yarza
 *  Implementation:    Marcos Yarza, Yuri Carmona
 */

void setup()
{  
  // open serial port
  USB.ON();
  USB.println(F("INT_01 example"));

}


void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: Watchdog interruption after 8 seconds
  ///////////////////////////////////////////////////////////////////////
  PWR.setWatchdog( WTD_ON, WTD_8S);


  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  ///////////////////////////////////////////////////////////////////////
  USB.println(F("enter sleep mode..."));
  PWR.sleep(ALL_OFF);

  // Interruption event happened  

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption:
  //    Before doing anything else to avoid new interruption 
  ///////////////////////////////////////////////////////////////////////
  PWR.setWatchdog( WTD_OFF, WTD_8S);  

  USB.ON();
  USB.println(F("Waspmote wakes up"));

  ///////////////////////////////////////////////////////////////////////
  // 4. Check the interruption source
  ///////////////////////////////////////////////////////////////////////
  if( intFlag & WTD_INT )
  {

    // print info
    USB.ON();
    USB.println(F("+++++++++++++++++++++++++++++++++"));
    USB.println(F("++ Watchdog interrupt detected ++"));
    USB.println(F("+++++++++++++++++++++++++++++++++")); 
    USB.println(); 

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }
    
    /* 
     *  Insert your code here if more things needed
     */
    
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


