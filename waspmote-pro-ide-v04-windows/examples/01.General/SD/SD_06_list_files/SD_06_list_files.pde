/*  
 *  ------ [SD_06] - List files inside the SD card -------- 
 *  
 *  Explanation: Turn on the SD card. Firstly, delete all folder and
 *  all contained files. Secondly, create all directories specified in
 *  path. Finally, create files inside each subfolder and show the created 
 *  directories and files. 
 *  The rest of the program shows how to list the directories in several ways.
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
 *  Version:           0.4
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
  USB.println(F("SD_06 example"));
 
  ///////////////////////////////////////////
  // 1. Set SD ON
  ///////////////////////////////////////////
  SD.ON();
  
  ///////////////////////////////////////////
  // 2. delete all directories at the beginning of execution
  ///////////////////////////////////////////
  sd_answer = SD.rmRfDir("FOLDER1");
  
  if( sd_answer == 1 )
  { 
    USB.println(F("deleted folders and all contained files"));
  }
  else
  {
    USB.println(F("rmdir failed"));
  }
  
  ///////////////////////////////////////////  
  // 3. create directories
  ///////////////////////////////////////////  
  sd_answer = SD.mkdir(path);  
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/FOLDER2/FOLDER3/ created"));
  }
  else 
  {
    USB.println(F("path NOT created"));
  }
    
  ///////////////////////////////////////////    
  // 4. create a file inside FOLDER1/
  ///////////////////////////////////////////  
  sd_answer = SD.create("FOLDER1/file1");
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/file1 created"));
  }
  else
  {
    USB.println(F("/FOLDER1/file1 not created"));
  }
    
  ///////////////////////////////////////////    
  // 5. create a file inside FOLDER1/FOLDER2/
  ///////////////////////////////////////////  
  sd_answer = SD.create("FOLDER1/FOLDER2/file2");
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/FOLDER2/file2 created"));
  }
  else 
  {
    USB.println(F("/FOLDER1/FOLDER2/file2 not created"));
  }
    
  ///////////////////////////////////////////    
  // 6. create a file inside FOLDER1/FOLDER2/FOLDER3
  ///////////////////////////////////////////  
  sd_answer = SD.create("FOLDER1/FOLDER2/FOLDER3/file3");
  
  if( sd_answer == 1 )
  {
    USB.println(F("/FOLDER1/FOLDER2/FOLDER3/file3 created"));
  }
  else 
  {
    USB.println(F("/FOLDER1/FOLDER2/FOLDER3/file3 not created"));
  }
     
}


void loop()
{     
  ////////////////////////////////////////////////////////  
  // 7 - list root directory: file size details by default
  ////////////////////////////////////////////////////////
  USB.println(F("\n---------------------------"));
  USB.println(F("list (file size details by default):"));
  USB.println(F("---------------------------"));
  SD.ls();  
  USB.println(F("---------------------------"));
  
  delay(1000);
  
  ////////////////////////////////////////////////////////  
  // 8 - list root directory recursively
  ////////////////////////////////////////////////////////
  USB.println(F("\n---------------------------"));
  USB.println(F("list recursively:"));
  USB.println(F("---------------------------"));
  SD.ls( LS_R );  
  USB.println(F("---------------------------"));  
  
  delay(1000);  
  
  ////////////////////////////////////////////////////////
  // 9 - list root directory recursively showing file size
  ////////////////////////////////////////////////////////
  USB.println(F("\n---------------------------"));
  USB.println(F("list recursively showing file size:"));
  USB.println(F("---------------------------"));
  SD.ls( LS_R | LS_SIZE );  
  USB.println(F("---------------------------"));
    
  delay(1000);  
  
  ////////////////////////////////////////////////////////  
  // 10 - list root directory recursively showing date and file size
  ////////////////////////////////////////////////////////
  USB.println(F("\n---------------------------"));
  USB.println(F("list recursively showing date and file size:"));
  USB.println(F("---------------------------"));
  SD.ls( LS_R | LS_DATE | LS_SIZE );   
  USB.println(F("---------------------------"));
  
  
  delay(5000);
}



