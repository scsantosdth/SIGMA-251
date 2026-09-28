/*  
 *  ------ [DM_09] - set low power state in XBee module  -------- 
 *  
 *  Explanation: This program shows how to set the cyclic sleep mode
 *  in XBee-Digimesh modules. In order to coordinate a whole sleeping 
 *  network it is mandatory to switch on a network coordinator which
 *  SM must be set to '7' and its SO parameter must be set to '1' so 
 *  as to be a coordinator.     
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
 *  Version:           0.2
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

#include <WaspXBeeDM.h>

// SP parameter: Time to be asleep -> 5 seconds: 0x0001F4 (hex format, time in units of 10ms)
// Other possible values: 
//   0x0003E8 (10 seconds)
//   0x0000C8 (2 seconds)
//   0x0005DC (15 seconds)
//   0x001770 (60 seconds)
uint8_t asleep[3]={ 0x00,0x01,0xF4};

// ST parameter: Time to be awake -> 5 seconds: 0x001388 (hex format, time in units of 1ms)
// Other possible values: 
//   0x002710 (10 seconds)
//   0x0007D0 (2 seconds)
//   0x003A98 (15 seconds)
//   0x00EA60 (60 seconds)
uint8_t awake[3]={ 0x00,0x13,0x88};

// deifne variable to get running time
unsigned long startTime;


void setup()
{
  // Init USB port
  USB.ON();
  USB.println(F("Cyclic sleep example"));

  // init RTC 
  RTC.ON();

  //////////////////////////
  // 1. XBee setup
  //////////////////////////

  // 1.1. init XBee
  xbeeDM.ON();
  

  // 1.2. set time the module remains awake (ST parameter)
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

  // 1.3. set Sleep period (SP parameter)
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

  // 1.4. set sleep mode for cyclic sleep mode
  xbeeDM.setSleepMode(8);  

}


void loop()
{  
  ///////////////////////////////////////////////
  // 2. Waspmote sleeps while XBee sleeps
  ///////////////////////////////////////////////

  // Waspmote enters to sleep until XBee module wakes it up
  // It is important not to switch off the XBee module when
  // entering sleep mode calling PWR.sleep function
  // It is necessary to enable the XBee interrupt

  // get starting time
  startTime = RTC.getEpochTime();

  USB.println(F("Enter deep sleep..."));
  
  // 2.1. enables XBEE Interrupt
  enableInterrupts(XBEE_INT);

  // 2.2. Waspmote enters sleep mode
  PWR.sleep( SENS_OFF );


  ///////////////////////////////////////////////
  // 3. Waspmote wakes up and check intFlag
  ///////////////////////////////////////////////

  USB.println(F("...wake up!"));

  // init RTC 
  RTC.ON();
  
  USB.print(F("Sleeping time (seconds):"));
  USB.println( RTC.getEpochTime() - startTime );
 
  
  // After waking up check the XBee interrupt
  if( intFlag & XBEE_INT )
  {
    // blink the red LED
    Utils.blinkRedLED();

    USB.println(F("--------------------"));
    USB.println(F("XBee interruption captured!!"));
    USB.println(F("--------------------"));
    
    intFlag &= ~(XBEE_INT); // Clear flag
  }

  /* Application transmissions should be done here when XBee
   module is awake for the defined awake time. All operations
   must be done during this period before teh XBee modules enters
   a sleep period again*/

  // do nothing while XBee module remains awake before 
  // return to sleep agains after 'awake' seconds
  delay(1000);
}




