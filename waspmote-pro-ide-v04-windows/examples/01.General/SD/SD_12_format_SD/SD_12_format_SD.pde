/*  
 *  ------ [SD_12] - Format SD file  -------- 
 *  
 *  Explanation: Turn on the SD card. Format SD card. erasing all data
 *  and formatting the SD card as FAT16. This example is based on the 
 *  William Greiman's SdFat library and examples:
 *    http://code.google.com/p/sdfatlib
  
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

// variable
boolean answer;

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE.TXT";

// All directory names MUST be defined 
// according to 8.3 SHORT FILE NAME
char foldername[]="FOLDER";

void setup()
{
  // Open USB port
  USB.ON();
  USB.println(F("SD_12 example"));
    
  USB.print(F("\n"
    "This sketch erases and formats SD/SDHC cards.\n"
    "\n"
    "Erase uses the card's fast flash erase command.\n"
    "Flash erase sets all data to 0X00 for most cards\n"
    "and 0XFF for a few vendor's cards.\n"
    "\nWarning, all data on the card will be erased.\n"));

}


void loop()
{
  /* First of all, teh user executes these functions 
  *  when the system is sure. The formatting process
  *  must be done securely
  */
  char c;  
  USB.print(F("Enter 'Y' to format the SD card: "));
  USB.flush();
  while (!USB.available()) {
  }
  delay(400);

  c = USB.read();
  USB.println(c);

  if (c != 'Y') 
  {
    USB.print(F("Quiting, you did not enter 'Y'.\n"));
    return;
  }
  

  // Set SD ON
  SD.ON();

  // 1. list Root directory
  USB.println(F("list Root directory:"));
  USB.println(F("---------------------------"));
  SD.ls(LS_R|LS_DATE|LS_SIZE);  
  USB.println(F("---------------------------\n"));

  // 1. create directory
  if(SD.mkdir(foldername)) 
  {
    USB.println(F("directory created"));
  }
  else
  {
    USB.println(F("mkdir failed"));
  }

  // 2. create file
  if(SD.create(filename))
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  }  

  // 3. list Root directory  
  USB.println(F("list Root directory:"));
  USB.println(F("---------------------------"));
  SD.ls(LS_R|LS_DATE|LS_SIZE);  
  USB.println(F("---------------------------\n"));

  // 4. format SD card
  USB.print(F("Formatting..."));
  answer = SD.format();  

  if( answer == true ) 
  {
    USB.println(F("SD format OK"));
  }
  else
  {
    USB.println(F("SD format failed"));
  }



  USB.println(F("\n\n**************************************************\n\n"));


  // Set SD ON
  SD.OFF();

  delay(5000);
}

