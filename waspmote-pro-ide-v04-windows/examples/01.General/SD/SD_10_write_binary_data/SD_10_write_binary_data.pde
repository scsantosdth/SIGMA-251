/*  
 *  ------ [SD_10] - Write data to a SD file -------- 
 *  
 *  Explanation: Turn on the SD card. Write binary data in SD file
 *  indicating the position to write.
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
char filename[]="FILE10";

// define hexadecimal data
uint8_t data1[10]={ 0x30,0x31,0x32,0x33,0x00,0x35,0x36,0x37,0x38,0x39};
uint8_t data2[10]={ 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09};

void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_10 example"));

  // Set SD ON
  SD.ON();

  // Delete file if exists
  if(SD.del(filename)) 
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }

  // Create file
  if(SD.create(filename))
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

  ///////////////////////////////////////////////////
  // 1. write hexadecimal data1 (offset=0; length:10)
  ///////////////////////////////////////////////////
  if(SD.writeSD(filename, data1, 0, 10)) 
  {
    USB.println(F("write OK"));
  }
  else 
  {
    USB.println(F("write failed")); 
  }
  
   /////////////////////////////////////////////////// 
  // 2. append hexadecimal data2 (length:10)
  ///////////////////////////////////////////////////
  if(SD.append(filename, data2, 10))
  {
    USB.println(F("append OK"));
  }
  else 
  {
    USB.println(F("append failed"));
  }

  ///////////////////////////////////////////////////
  // 3. show binary file
  ///////////////////////////////////////////////////
  showBinaryFile();
  delay(5000);

}




/*****************************************************
 * Local Function in order to show the file contents
 *
 *****************************************************/
void showBinaryFile()
{
  // show file
  USB.println(F("Show file:"));      
  USB.println(F("-------------------"));
  SD.catBin(filename, 0, SD.getFileSize(filename));
  for(int i=0; i<SD.getFileSize(filename); i++)
  {
    USB.printHex(SD.bufferBin[i]);
    if( i >= sizeof(SD.bufferBin) )
    {
      break;
    }
  }
  USB.println(F("\n-------------------"));
}


