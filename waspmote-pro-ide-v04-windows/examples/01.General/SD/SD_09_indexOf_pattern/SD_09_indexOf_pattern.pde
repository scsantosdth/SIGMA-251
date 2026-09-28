/*  
 *  ------ [SD_09] - Index Of a pattern inside SD file -------- 
 *  
 *  Explanation: Turn on the SD card. Write a file with some lines.
 *  Then show how to find patterns inside the file.
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
 *  Version:           0.3
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

// define file name to be created: MUST be 8.3 SHORT FILE NAME
char file[]="FILE9.TXT";

uint8_t sd_answer;


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_09 example"));

  // Set SD ON
  SD.ON();
  
  // delete file
  sd_answer = SD.del(file);

  // create file
  sd_answer = SD.create(file);
  
  // Append data to file
  if(SD.appendln(file,"abcdefghijklmnopqrstuvwxyz0123456789")) USB.println("append ok");
  if(SD.appendln(file,"abcdefghijklmnopqrstuvwxyz0123456789")) USB.println("append ok");
  if(SD.appendln(file,"abcdefghijklmnopqrstuvwxyz0123456789")) USB.println("append ok");
  if(SD.appendln(file,"abcdefghijklmnopqrstuvwxyz0123456789")) USB.println("append ok");
  if(SD.appendln(file,"abcdefghijklmnopqrstuvwxyz0123456789")) USB.println("append ok");
  
  USB.println(F("-------------------"));
  USB.print(F("Show file:"));
  SD.showFile(file);
  delay(1000);

}


void loop()
{ 
  ///////////////////////////////////////////////    
  // 1 - index of 'abcdef' with offset=0 bytes
  ///////////////////////////////////////////////
  USB.print(F("indexOf 'abcdef' (offset=0): "));
  USB.println(SD.indexOf(file,"abcdef",0));  

  ///////////////////////////////////////////////  
  // 2 - index of 'abcedf' with offset=0 bytes
  ///////////////////////////////////////////////
  USB.print(F("indexOf 'abcedf' (offset=0): "));
  USB.println(SD.indexOf(file,"abcedf",0));

  ///////////////////////////////////////////////    
  // 3 - index of '0123' with offset=0 bytes 
  ///////////////////////////////////////////////
  USB.print(F("indexOf '0123' (offset=0): "));
  USB.println(SD.indexOf(file,"0123",0));

  ///////////////////////////////////////////////  
  // 4 - index of '999' with offset=0 bytes 
  ///////////////////////////////////////////////
  USB.print(F("indexOf '999' (offset=0): "));
  USB.println(SD.indexOf(file,"999",0));

  ///////////////////////////////////////////////  
  // 5 - index of 'abcd' with offset=1 byte 
  ///////////////////////////////////////////////
  USB.print(F("indexOf 'abcd'(offset=1): "));
  USB.println(SD.indexOf(file,"abcd",1));  

  ///////////////////////////////////////////////  
  // 6 - index of '0123' with offset=27 bytes   
  ///////////////////////////////////////////////
  USB.print(F("indexOf '0123' (offset=27): "));
  USB.println(SD.indexOf(file,"0123",27));

  ///////////////////////////////////////////////
  // 7 - index of 'bc' with offset=0 bytes   
  ///////////////////////////////////////////////
  USB.print(F("indexOf 'bc' (offset=0): "));
  USB.println(SD.indexOf(file,"bc",0));

  /////////////////////////////////////////////// 
  // 8 - index of 'cb' with offset=0 bytes    
  ///////////////////////////////////////////////
  USB.print(F("indexOf 'cb' (offset=0): "));
  USB.println(SD.indexOf(file,"cb",0));
 
  USB.println(F("-----------------------------"));
  delay(10000);
}


