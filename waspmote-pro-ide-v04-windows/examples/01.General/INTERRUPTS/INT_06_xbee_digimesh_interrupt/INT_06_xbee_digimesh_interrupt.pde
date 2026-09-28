/*  
 *  ------ [INT_06] - XBee DigiMesh interrupts  -------- 
 *  
 *  Explanation: This program shows how to set the cyclic sleep mode
 *  in XBee-Digimesh modules. In order to coordinate a whole sleeping 
 *  network it is mandatory to switch on a network coordinator which
 *  SM must be set to '7' and its SO parameter must be set to '1' so 
 *  as to be a coordinator.     
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
 *  Version:           0.1
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeDM.h>

// Time to be ASLEEP: 5 seconds: 0x0001F4 (hex format, time in units of 10ms)
// Other possible values: 0x0003E8 (10 seconds), 0x0000C8 (2 seconds), 0x0005DC (15 seconds)
uint8_t asleep[3]={ 0x00,0x01,0xF4};

// Time to be AWAKE: 5 seconds: 0x001388 (hex format, time in units of 1ms)
// Other possible values: 0x002710 (10 seconds), 0x0007D0 (2 seconds), 0x003A98 (15 seconds)
uint8_t awake[3]={ 0x00,0x13,0x88};


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("INT_06 example"));
  
   
  // init XBee
  xbeeDM.ON();
  delay(1000);


  ///////////////////////////////////////////////////////////////////////
  // XBee sleeping setup
  ///////////////////////////////////////////////////////////////////////

  // set time the module remains awake (ST parameter)
  xbeeDM.setAwakeTime(awake);

  // check AT command flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("ST parameter set ok"));
  }
  else 
  {
    USB.println(F("error setting ST parameter")); 
  }

  // set Sleep period (SP parameter)
  xbeeDM.setSleepTime(asleep);

  // check AT command flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("SP parameter set ok"));
  }
  else 
  {
    USB.println(F("error setting SP parameter")); 
  }


  // set cyclic sleep mode in XBee module
  xbeeDM.setSleepMode(8);


}


void loop()
{
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruption: XBEE interruption in RXD1 pin
  ///////////////////////////////////////////////////////////////////////
  enableInterrupts(XBEE_INT);


  ///////////////////////////////////////////////////////////////////////
  // 2. Set low-power consumption state
  ///////////////////////////////////////////////////////////////////////
  // XBee module power supply is kept. Note the input argument for 
  // sleep function is: SENS_OFF. But SOCKET0_OFF has 
  // been omitted so as to keep the XBee powered on
  USB.println(F("Enter deep sleep..."));
  PWR.sleep( SENS_OFF );

  // Interruption event happened
 
  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruption before doing anything else: XBee interrupt 
  //    This is done to avoid new interruptions
  ///////////////////////////////////////////////////////////////////////
  disableInterrupts(XBEE_INT);
 
  USB.ON();
  USB.println(F("Waspmote wakes up"));
  
  
  ///////////////////////////////////////////////////////////////////////
  // 4. Check the interruption source
  ///////////////////////////////////////////////////////////////////////
  if( intFlag & XBEE_INT )
  {
    // print info
    USB.ON();
    USB.println(F("+++++++++++++++++++++++++++++"));
    USB.println(F("++ XBEE interrupt detected ++"));
    USB.println(F("+++++++++++++++++++++++++++++")); 
    USB.println(); 

    // blink LEDs
    for(int i=0; i<10; i++)
    {
      Utils.blinkLEDs(50);
    }
    
    /* 
     *  Insert your code here if more things needed
     *********************  NOTE  ********************************
     * Application transmissions should be done here when XBee
     * module is awake for the defined awake time. All operations
     * must be done during this period before the XBee module
     * enters a sleep period again
      ************************************************************
     */
  }
  
  ///////////////////////////////////////////////////////////////////////
  // 6. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 7. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();

}






