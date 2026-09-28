/*  
 *  ------ [SD_11] - Create SD file according to RTC date or time-------- 
 *  
 *  Explanation: Turn on the SD card. Set time to RTC. Get date and time
 *  and use it to create SD files according to the date or the time it is 
 *  created.
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

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[13];


void setup()
{
  // Open USB port
  USB.ON();
  USB.println(F("SD_11 example"));

  // Set SD ON
  SD.ON();
  
  // Powers RTC up, init I2C bus and read initial values
  USB.println(F("Init RTC"));
  RTC.ON();  

}


void loop()
{ 
  delay(10000);
  
  /////////////////////////////////////////////////////////////  
  // 1. Reading time
  /////////////////////////////////////////////////////////////
  USB.print(F("Time [day of week, YY/MM/DD, HH:MM:SS]:"));
  USB.println(RTC.getTime());
  
  
  /////////////////////////////////////////////////////////////
  // 1. Create file according to DATE with the following format:
  // filename: [YYMMDD.TXT]
  /////////////////////////////////////////////////////////////
  sprintf(filename,"%02u%02u%02u.TXT",RTC.year, RTC.month, RTC.date);
  if(SD.create(filename))
  {
    USB.print(F("1 - file created:"));
    USB.println(filename);
  }
  else 
  {
    USB.println(F("1 - file NOT created")); // only one file per day
  } 
  
  
  /////////////////////////////////////////////////////////////
  // 2. Create file according to TIME with the following format:
  // filename: [HHMMSS.TXT]
  /////////////////////////////////////////////////////////////
  sprintf(filename,"%02u%02u%02u.TXT",RTC.hour, RTC.minute, RTC.second);
  if(SD.create(filename))
  {    
    USB.print(F("2 - file created:"));
    USB.println(filename);
  }
  else 
  {
    USB.println(F("2 - file NOT created")); // only one file per second
  } 
  
  
  
  /////////////////////////////////////////////////////////////
  // 3. Create file according to TIME mixed with letters:
  // filenames: [HHMMSS_A.TXT] [HHMMSS_B.TXT] [HHMMSS_C.TXT]
  /////////////////////////////////////////////////////////////
  sprintf(filename,"%02u%02u%02u_A.TXT",RTC.hour, RTC.minute, RTC.second);  
  if(SD.create(filename))
  {
    USB.print(F("3a - file created:"));
    USB.println(filename);
  }
  else 
  {
    USB.println(F("3a - file NOT created"));  
  } 
  
  sprintf(filename,"%02u%02u%02u_B.TXT",RTC.hour, RTC.minute, RTC.second);
  if(SD.create(filename))
  {
    USB.print(F("3b - file created:"));
    USB.println(filename);
  }
  else 
  {
    USB.println(F("3b - file NOT created"));  
  } 
  
  sprintf(filename,"%02u%02u%02u_C.TXT",RTC.hour, RTC.minute, RTC.second);
  if(SD.create(filename))
  {
    USB.print(F("3c - file created:"));
    USB.println(filename);
  }
  else 
  {
    USB.println(F("3c - file NOT created"));  
  } 
  
  USB.println(F("************************"));  

  delay(10000);
  
}
