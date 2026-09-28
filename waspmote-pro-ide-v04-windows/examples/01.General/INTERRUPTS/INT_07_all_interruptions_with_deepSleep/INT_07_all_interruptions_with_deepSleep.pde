/*
 *  ------ INT_08 All interruptions with deep Sleep mdoe --------
 *
 *  Explanation: This example shows how set up all interruptions
 *  in the same code. Waspmote goes to deep sleep expecting some
 *  interruption source: 
 *    - RTC
 *    - ACC
 *    - Pluviometer sensor
 *    - XBee Digimesh module
 *
 *  Copyright (C) 2013 Libelium Comunicaciones Distribuidas S.L.
 *  http://www.libelium.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
 *  Version:		0.1
 *  Design:		David Gascón
 *  Implementation:	Yuri Carmona
 */

// include libraries
#include <WaspSensorAgr_v20.h>
#include <WaspXBeeDM.h>

///////////////////////////////////////////////////////////////////////////
// XBee settings
// Time to be ASLEEP: 10 seconds: 0x0003E8 (hex format, time in units of 10ms)
// Other possible values: 0x0001F4 (5 seconds), 0x0000C8 (2 seconds), 0x0005DC (15 seconds)
uint8_t asleep[3]={ 0x00,0x03,0xE8};

// Time to be AWAKE: 5 seconds: 0x001388 (hex format, time in units of 1ms)
// Other possible values: 0x002710 (10 seconds), 0x0007D0 (2 seconds), 0x003A98 (15 seconds)
uint8_t awake[3]={ 0x00,0x13,0x88};
///////////////////////////////////////////////////////////////////////////

char* filename="INT_FILE.TXT";
char command[100];



void setup()
{
  // start using the serial port
  USB.ON();  

  ////////////////////////////////////////////////
  // 1. Switch on the Agriculture Sensor Board
  ////////////////////////////////////////////////
  SensorAgrv20.ON();

  ////////////////////////////////////////////////
  // 2. Switch on the XBee module
  ////////////////////////////////////////////////
  // 2.1. Init XBee
  xbeeDM.ON();

  // 2.2. Set time the module remains awake (ST parameter)
  xbeeDM.setAwakeTime(awake);

  // 2.3. Check AT command flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("ST parameter set ok"));
  }
  else 
  {
    USB.println(F("error setting ST parameter")); 
  }

  // 2.4. Set Sleep period (SP parameter)
  xbeeDM.setSleepTime(asleep);

  // 2.5. Check AT command flag
  if( xbeeDM.error_AT == 0 ) 
  {
    USB.println(F("SP parameter set ok"));
  }
  else 
  {
    USB.println(F("error setting SP parameter")); 
  }

  // 2.6. Set sleep mode
  xbeeDM.setSleepMode(8);
  

  ///////////////////////////////////////////////
  // 3. Switch on the ACC 
  ///////////////////////////////////////////////
  ACC.ON();


  ///////////////////////////////////////////////
  // 4. SD card
  ///////////////////////////////////////////////

  // 4.1. Init SD Card
  SD.ON();

  // 4.2. Delete file
  if( !SD.del(filename) )
  {
    USB.println(F("Error while deleting file"));
  }
  else
  {
    USB.println(F("file deleted"));
  }

  // 4.3. Creating the file to store the info
  if( !SD.create(filename) )
  {
    USB.println(F("Error while creating file"));
  }
  else
  {
    USB.println(F("file created"));
  }

  // 4.4. List directory
  SD.ls();


}




void loop()
{
  
  ///////////////////////////////////////////////////////////////////////
  // 1. Enable interruptions: 
  //       + ACC Free Fall interruption 
  //       + Pluviometer interruption 
  //       + XBee interruption 
  ///////////////////////////////////////////////////////////////////////
  ACC.ON();
  ACC.setFF(); 
  SensorAgrv20.attachPluvioInt();
  enableInterrupts(XBEE_INT);
  
  
  ///////////////////////////////////////////////////////////////////////
  // 2. Enter sleep mode calling the "SensorAgrv20.sleepAgr" function 
  /////////////////////////////////////////////////////////////////////// 
  // Both XBee module and Sensor Board power supply is kept. 
  // Note that the only input argument for sleepAgr function is: ALL_ON. 
  // Both SOCKET0_OFF and SENS_OFF have been omitted
  USB.println("enter sleep mode");
  SensorAgrv20.sleepAgr("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_ON, SENS_AGR_PLUVIOMETER);

  // Interruption event happened

  ///////////////////////////////////////////////////////////////////////
  // 3. Disable interruptions before doing anything else to avoid new 
  //    interruptions:
  //       + ACC Free Fall interruption 
  //       + Pluviometer interruption 
  //       + XBee interruption 
  ///////////////////////////////////////////////////////////////////////
  ACC.ON();
  ACC.unsetFF(); 
  disableInterrupts(XBEE_INT);
  SensorAgrv20.detachPluvioInt();
  
  USB.ON();
  USB.println(F("Waspmote wakes up"));

  ///////////////////////////////////////////////////////////////////////
  // 4. Print 'intFlag'
  ///////////////////////////////////////////////////////////////////////
  USB.println(F("\nintFlag:"));
  PWR.printIntFlag();


  ///////////////////////////////////////////////////////////////////////
  // 5. Check the interruption source
  ///////////////////////////////////////////////////////////////////////

  // check RTC 
  if( intFlag & RTC_INT )
  {
    RTC_alarm();
  } 

  // check ACC
  if( intFlag & ACC_INT )
  {
    ACC_alarm();
  }  

  // check PLV
  if( intFlag & PLV_INT ) 
  {
    PLV_alarm();
  }  

  // check XBEE
  if( intFlag & XBEE_INT ) 
  {
    XBEE_alarm();  
  }


  ///////////////////////////////////////////////////////////////////////
  // 6. Show file
  ///////////////////////////////////////////////////////////////////////
  showFile();

  ///////////////////////////////////////////////////////////////////////
  // 7. Clear 'intFlag' 
  ///////////////////////////////////////////////////////////////////////
  // This is mandatory, if not this interruption will not be deleted and 
  // Waspmote could think in the future that a not existing interruption arrived
  clearIntFlag(); 

  ///////////////////////////////////////////////////////////////////////
  // 8. Clear interruption pin   
  ///////////////////////////////////////////////////////////////////////
  // This function is used to make sure the interruption pin is cleared
  // if a non-captured interruption has been produced
  PWR.clearInterruptionPin();
}







/////////////////////////////////////////////////////////////////////////
//// FUNCTIONS //////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////



/**************************************************************
 * RTC_alarm(void) - writes to the SD an alarm due to an 
 *                  interruption captured
 **************************************************************/
void RTC_alarm()
{  
  USB.println(F("++++++++++++++++++++++++++++++++"));
  USB.println(F("++   RTC interrupt detected   ++"));
  USB.println(F("++++++++++++++++++++++++++++++++"));  
  
  // check how the flags are filled:
  USB.print(F("intArray[RTC_POS]:"));
  USB.println(intArray[RTC_POS],DEC);
  USB.print(F("intCounter:"));
  USB.println(intCounter,DEC);

  // clear flags (this is optional; do not clear those if you need a global interrupt counter)    
  intCounter--;
  intArray[RTC_POS]--;  

  // mandatory to switch on the RTC after sleep 
  // mode in order to communicate with this chip
  RTC.ON();
  RTC.getTime();

  // create command to write into SD file
  sprintf(command,"++ RTC  interrupt detected ++ || Time: %02u:%02u:%02u || BAT: %u", RTC.hour, RTC.minute, RTC.second, PWR.getBatteryLevel());

  // call the local function to write the message
  writeCommand(command);

}


/***********************************************************************
 * ACC_alarm(void) - writes to the SD an alarm due to the interruption 
 *                   captured
 ***********************************************************************/
void ACC_alarm()
{     
  USB.println(F("++++++++++++++++++++++++++++++++++"));
  USB.println(F("++ Free Fall interrupt detected ++"));
  USB.println(F("++++++++++++++++++++++++++++++++++"));  
  
  // check how the flags are filled:
  USB.print(F("intArray[ACC_POS]:"));
  USB.println(intArray[ACC_POS],DEC);
  USB.print(F("intCounter:"));
  USB.println(intCounter,DEC);

  // clear flags (this is optional; do not clear those if you need a global interrupt counter)    
  intCounter--;
  intArray[ACC_POS]--;
  
  // mandatory to switch on the RTC after sleep 
  // mode in order to communicate with this chip
  RTC.ON();
  RTC.getTime();

  // create command to write into SD file
  sprintf(command,"++ ACC  interrupt detected ++ || Time: %02u:%02u:%02u", RTC.hour, RTC.minute, RTC.second);

  // call the local function to write the message
  writeCommand(command);
}




/**************************************************************
 * PLV_alarm() - 
 **************************************************************/
void PLV_alarm()
{    
  // Unset the interrupt again
  SensorAgrv20.detachPluvioInt();


  USB.println(F("++++++++++++++++++++++++++++++++"));
  USB.println(F("++   PLV interrupt detected   ++"));
  USB.println(F("++++++++++++++++++++++++++++++++"));
  
  // check how the flags are filled:
  USB.print(F("intArray[PLV_POS]:"));
  USB.println(intArray[PLV_POS],DEC);
  USB.print(F("intCounter:"));
  USB.println(intCounter,DEC);
  
    // clear flags (this is optional; do not clear those if you need a global interrupt counter)    
  intCounter--;
  intArray[PLV_POS]--;
  
  // mandatory to switch on the RTC after sleep 
  // mode in order to communicate with this chip
  RTC.ON();
  RTC.getTime();

  // create command to write into SD file
  sprintf(command,"++ PLV  interrupt detected ++ || Time: %02u:%02u:%02u", RTC.hour, RTC.minute, RTC.second);  

  // call the local function to write the message
  writeCommand(command);

}



/**************************************************************
 * XBEE_alarm() - 
 **************************************************************/
void XBEE_alarm()
{     
  USB.println(F("+++++++++++++++++++++++++++++++++"));
  USB.println(F("++   XBEE interrupt detected   ++"));
  USB.println(F("+++++++++++++++++++++++++++++++++"));
  
  // check how the flags are filled:
  USB.print(F("intArray[XBEE_POS]:"));
  USB.println(intArray[XBEE_POS],DEC);
  USB.print(F("intCounter:"));
  USB.println(intCounter,DEC);

  // clear flags (this is optional; do not clear those if you need a global interrupt counter)    
  intCounter--;
  intArray[XBEE_POS]--;
  
  // mandatory to switch on the RTC after sleep 
  // mode in order to communicate with this chip
  RTC.ON();
  RTC.getTime();

  // create command to write into SD file
  sprintf(command,"++ XBEE interrupt detected ++ || Time: %02u:%02u:%02u", RTC.hour, RTC.minute, RTC.second);  

  // call the local function to write the message
  writeCommand(command);
}




/**************************************************************
 * writeCommand(char* cmd) - This function write the command 
 *                           specified as input 
 **************************************************************/
uint8_t writeCommand(char* cmd)
{   
  uint8_t done;
  
  // set SD on
  SD.ON();

  // write message to SD file
  if( !SD.appendln(filename,cmd) ) 
  {
    USB.println(F("Error writing on SD"));
    done = false;
  }
  else
  {
    USB.println(F("Writing done"));
    done = true;
  }
  
  // set SD off
  SD.OFF();
  
  return done;
  
}




/**************************************************************
 * showFile() - This function shows all the information 
 *              contained in the SD file
 **************************************************************/
void showFile()
{  
  // mandatory to set SD on after sleep mode in 
  // order to communicate with it
  SD.ON();
  USB.println(F("#########   SHOW THE FILE CONTENTS   #########"));
  for(int i=SD.numln(filename)-1; i<SD.numln(filename); i++)
  {
    USB.print(SD.catln( filename, i, 1) );   
  }
  USB.println(F("##############################################\n\n"));

  SD.OFF();
}








