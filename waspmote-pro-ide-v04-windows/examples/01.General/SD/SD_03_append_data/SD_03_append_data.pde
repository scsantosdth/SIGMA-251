/*  
 *  ------ [SD_03] - Append data to SD file -------- 
 *  
 *  Explanation: Turn on the SD card. Append data t the end of
 *  the SD file. 
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

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE3.TXT";

// define an example string
char data[]="hello"; 

// define variable
uint8_t sd_answer;


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_3 example"));
  
  // Set SD ON
  SD.ON();
    
  // Delete file
  sd_answer = SD.del(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }
    
  // Create file
  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 
}


void loop()
{ 
  
  // 1 - It appends “he” in file indicating 2-byte length
  sd_answer = SD.append(filename, data, 2);
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n1 - append \"he\" in file indicating 2-byte length"));
  }
  else
  {
    USB.println(F("\n1 - append error"));
  }
  
  // show file
  SD.showFile(filename);
  delay(1000);
  
  
  // 2 - It appends “hello” at the end of the file
  sd_answer = SD.append(filename, data);
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n2 - appends \"hello\" at the end of the file"));
  }
  else 
  {
    USB.println(F("\n2 - append error"));
  }
  
  // show file
  SD.showFile(filename);
  delay(1000);
  
  
  // 3 - It appends data to file adding an End Of Line at the end of the string
  sd_answer = SD.appendln(filename,"goodbye");
  
  if( sd_answer == 1 )
  {
    USB.println(F("\n3 - append \"goodbye\" in file adding an EOL"));
  }
  else 
  {
    USB.println(F("\n3 - append error"));
  }
  
  // show file
  SD.showFile(filename);
  delay(5000); 
 
}



