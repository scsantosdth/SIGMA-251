/*  
 *  ------ [SD_04] - Read data from SD file -------- 
 *  
 *  Explanation: Turn on the SD card. Append data at the end of
 *  the SD file and then show how to read it.
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
 *  Version:           0.5
 *  Design:            David Gascón 
 *  Implementation:    Yuri Carmona
 */

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE4.TXT";

// array in order to read data
char output[101];

// define variable
uint8_t sd_answer;


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_4 example"));
  
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
  
  // Append data to file
  SD.appendln(filename,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
  SD.appendln(filename,"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
  SD.appendln(filename,"cccccccccccccccccccccccccccccc");
  SD.appendln(filename,"dddddddddddddddddddddddddddddd");
  SD.appendln(filename,"eeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
  SD.appendln(filename,"ffffffffffffffffffffffffffffff");
  SD.appendln(filename,"gggggggggggggggggggggggggggggg");
  SD.appendln(filename,"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhh");
  SD.appendln(filename,"iiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
  
  USB.println(F("\n-------------------"));
  USB.print(F("SHOW THE FILE CONTENTS"));
  SD.showFile(filename);
  
  delay(3000);  
  
}


void loop()
{ 
  
  // 1 - SD.cat
  // Read file bytes using different values of 
  // offset (first position to be read) and 
  // scope (number of bytes to be read)
  USB.println(F("\n\n-----------------------------"));
  USB.println(F("1 - Use of SD.cat function"));
  USB.println(F("-----------------------------"));
  USB.println(F("Read file in bytes (offset:0; scope:10):"));
  SD.cat(filename,0,10);   
  USB.println(SD.buffer);
  USB.println(F("-----------------------------"));
  delay(1000);
  
  USB.println(F("Read file in bytes (offset:25; scope:10):"));
  SD.cat( filename, 25, 10); 
  USB.println( SD.buffer );    
  USB.println(F("-----------------------------"));
  delay(1000);
  
  USB.println(F("Read file in bytes (offset:0; scope:1000) [256 bytes max]:"));
  SD.cat( filename, 0, 1000);   
  USB.println( SD.buffer);
  USB.println(F("-----------------------------"));
  delay(3000); 
 
  
  // 2 - SD.catBin
  // Read file hexadecimal data using different values of 
  // offset (first position to be read) and 
  // scope (number of bytes to be read)
  USB.println(F("\n\n-----------------------------"));
  USB.println(F("2 - Use of SD.catBin function"));
  USB.println(F("-----------------------------"));
  USB.println(F("Read binary data (offset:0; scope:10):")); 
  SD.catBin(filename,0,10);
  Utils.hex2str( SD.bufferBin, output, 10);
  USB.println( output );  
  USB.println(F("-----------------------------"));
  delay(1000);
  
  USB.println(F("Read binary data (offset:25; scope:10):"));
  SD.catBin(filename,25,10);
  Utils.hex2str( SD.bufferBin, output, 10);
  USB.println( output );    
  USB.println(F("-----------------------------"));
  delay(1000);
  
  USB.println(F("Read binary data (offset:0; scope:50):"));
  SD.catBin( filename, 0, 50);
  Utils.hex2str( SD.bufferBin, output, 50);
  USB.println( output );    
  USB.println(F("-----------------------------"));
  delay(3000);
   
     
  // 3 - SD.catln
  // Read file lines using different values of 
  // offset (first line to be read) and 
  // scope (number of lines to be read)
  USB.println(F("\n\n-----------------------------"));
  USB.println(F("3 - Use of SD.catln function"));
  USB.println(F("-----------------------------"));
  USB.println(F("Read file lines (offset:0; scope:1):"));
  SD.catln(filename,0,1);   
  USB.println( SD.buffer );
  USB.println(F("-----------------------------"));
  delay(1000);  
  
  USB.println(F("Read file lines (offset:1; scope:1):"));
  SD.catln(filename,1,1);  
  USB.println( SD.buffer );
  USB.println(F("-----------------------------"));
  delay(1000);  
  
  USB.println(F("Read file lines (offset:2; scope:1):"));
  SD.catln(filename,2,1);   
  USB.println( SD.buffer );
  USB.println(F("-----------------------------"));
  delay(1000);  
  
  USB.println(F("Read file lines (offset:0; scope:5):"));
  SD.catln(filename,0,5);   
  USB.println( SD.buffer );
  USB.println(F("-----------------------------"));
  delay(1000);  
  
  USB.println(F("Read file lines (offset:0; scope:25) [256 bytes max]:"));
  SD.catln(filename,0,25);  
  USB.println( SD.buffer );  
  USB.println(F("-----------------------------"));
  
  USB.println(F("*****************************"));
 
  delay(10000); 
 
}


