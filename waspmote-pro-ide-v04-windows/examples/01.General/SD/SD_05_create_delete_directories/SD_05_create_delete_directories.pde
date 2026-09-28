/*  
 *  ------ [SD_5] - Create and delete directories in SD card -------- 
 *  
 *  Explanation: Turn on the SD card. Firstly, delete all folder and
 *  all contained files. Secondly, create all directories specified in
 *  path. Finally, create files inside each subfolder and show the created 
 *  directories and files. The rest of the program is an infinite loop which
 *  does nothing
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


// Define folder path
// All directory names MUST be defined 
// according to 8.3 SHORT FILE NAME
char path[]="FOLDER1/FOLDER2/FOLDER3/";

// define variable
uint8_t sd_answer;


void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_5 example"));
  
  //////////////////////////////////////
  // 1. Set SD ON
  SD.ON();
  //////////////////////////////////////  
  
  //////////////////////////////////////
  // 2. Delete all directories at the beginning of execution
  //////////////////////////////////////
  sd_answer = SD.rmRfDir("FOLDER1");
  
  if( sd_answer == 1 )
  {
    USB.println(F("deleted FOLDER1 and all contained files"));
  }
  else
  {
    USB.println(F("rmdir failed"));
  }
  
  //////////////////////////////////////
  // 3. List root directory recursively
  //////////////////////////////////////
  USB.println(F("list Root directory:"));
  USB.println(F("---------------------------"));
  SD.ls(LS_R|LS_DATE|LS_SIZE);  
  USB.println(F("---------------------------"));
  
  //////////////////////////////////////
  // 4. create directories
  //////////////////////////////////////
  sd_answer = SD.mkdir(path);
    
  if( sd_answer == 1 )
  {
    USB.println(F("directories created OK"));
  }
  else
  {
    USB.println(F("mkdir failed"));
  }
    
  //////////////////////////////////////
  // 5. create a file inside FOLDER1/
  //////////////////////////////////////
  sd_answer = SD.create("FOLDER1/file1");
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/file1 created"));
  }
  else
  {
    USB.println(F("/FOLDER1/file1 not created"));
  }
    
  //////////////////////////////////////
  // 6. create a file inside FOLDER1/FOLDER2/
  //////////////////////////////////////
  sd_answer = SD.create("FOLDER1/FOLDER2/file2"); 
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/FOLDER2/file2 created"));
  }
  else 
  {
    USB.println(F("/FOLDER1/FOLDER2/file2 not created"));
  }
   
  ////////////////////////////////////// 
  // 7. create a file inside FOLDER1/FOLDER2/FOLDER3
  //////////////////////////////////////
  sd_answer = SD.create("FOLDER1/FOLDER2/FOLDER3/file3");
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/FOLDER2/FOLDER3/file3 created"));
  }
  else 
  {
    USB.println(F("/FOLDER1/FOLDER2/FOLDER3/file3 not created"));
  }
  
  //////////////////////////////////////
  // 8. list root directory recursively
  //////////////////////////////////////  
  USB.println(F("list Root directory:"));
  USB.println(F("---------------------------"));
  SD.ls(LS_R|LS_DATE|LS_SIZE);  
  USB.println(F("---------------------------"));
   
}


void loop()
{     
  // Do nothing
  delay(5000);
}



