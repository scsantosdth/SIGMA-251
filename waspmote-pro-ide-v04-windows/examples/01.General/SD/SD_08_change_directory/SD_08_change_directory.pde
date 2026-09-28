/*  
 *  ------ [SD_08] - Change current working directory -------- 
 *  
 *  Explanation: Turn on the SD card. Move from one to another directory
 *  in order to manage files directly in each folder instead of using
 *  complete paths.
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

// define folder and file names to be created: MUST be 8.3 SHORT FILE NAME
char path[]="/FOLD1/FOLD2/FOLD3";
char file1[]="FILE1";
char file2[]="FILE2";
char file3[]="FILE3";

uint8_t sd_answer;

void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_08 example"));

  // Set SD ON
  SD.ON();

  // delete all contained files in 'path'
  sd_answer = SD.rmRfDir("/FOLD1");
  
  if( sd_answer == true )
  {
    USB.println(F("Delete whole directory path"));
  }
  else
  { 
    USB.println(F("Delete Error"));
  }
  

  // create path
  sd_answer = SD.mkdir(path);
  
  if( sd_answer == true )
  {
    USB.print(F("Created directory system:"));
    USB.println(path);
  }
  else
  { 
    USB.println(F("mkdir Error"));
  }

}

void loop()
{ 
  // Starting current working directory is Root directory  

  /////////////////////////////////////////////////////////
  // 1. change directory to 'fold3'
  /////////////////////////////////////////////////////////
  if(SD.cd(path))
  { 
    USB.println(F("\ninside /FOLD1/FOLD2/FOLD3:"));
  }
  else
  { 
    USB.println("change to directory /FOLD1/FOLD2/FOLD3 FAILED");
  }

  /////////////////////////////////////////////////////////
  // 2. create a file inside /fold1/fold2/fold3/
  sd_answer = SD.create( file3 );  
  
  if( sd_answer == true )
  {
    USB.println(F("FILE3 created"));
  }
  else
  { 
    USB.println(F("FILE3 not created"));
  }
  /////////////////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////// 
  // 3. list current working directory: fold3
  /////////////////////////////////////////////////////////
  USB.println(F("-----------------------------"));  
  USB.println(F("\nlist /FOLD1/FOLD2/FOLD3 contents:"));
  USB.println(F("-----------------------------"));
  SD.ls( LS_SIZE | LS_DATE );  
  USB.println(F("-----------------------------"));
  delay(2000);

  /////////////////////////////////////////////////////////
  // 4. Go one directory up to /fold1/fold2/  
  /////////////////////////////////////////////////////////
  if(SD.cd(".."))
  {
    USB.println("\ninside /FOLD1/FOLD2:");
  }
  else
  { 
    USB.println("change to directory /FOLD1/FOLD2 FAILED"); 
  }

  /////////////////////////////////////////////////////////
  // 5. create a file inside /fold1/fold2/
  /////////////////////////////////////////////////////////
  sd_answer = SD.create(file2);
  
  if( sd_answer == true )
  {
    USB.println(F("FILE2 created"));
  }
  else
  { 
    USB.println(F("FILE2 not created"));
  }

  /////////////////////////////////////////////////////////
  // 6. list current working directory: fold2
  /////////////////////////////////////////////////////////  
  USB.println(F("\n-----------------------------"));  
  USB.println(F("list /FOLD1/FOLD2 contents:"));
  USB.println(F("-----------------------------"));
  SD.ls( LS_SIZE | LS_DATE );  
  USB.println(F("-----------------------------"));
  delay(2000);

  /////////////////////////////////////////////////////////
  // 7 - go one directory up to /fold1/
  /////////////////////////////////////////////////////////
  sd_answer = SD.cd("..");
  
  if( sd_answer == true )
  {
    USB.println("\ninside /FOLD1");
  }
  else
  { 
    USB.println("change to directory /FOLD1 FAILED");
  }

  /////////////////////////////////////////////////////////
  // 8. create a file inside /fold1/
  /////////////////////////////////////////////////////////
  sd_answer = SD.create(file1);
  
  if( sd_answer == true )
  {
    USB.println(F("FILE1 created"));
  }
  else
  { 
    USB.println(F("FILE1 not created"));
  }

  ///////////////////////////////////////////////////////// 
  // 9. list current working directory: fold1
  /////////////////////////////////////////////////////////
  USB.println(F("\n-----------------------------"));  
  USB.println(F("list /FOLD1 contents:"));
  USB.println(F("-----------------------------"));
  SD.ls( LS_SIZE | LS_DATE );  
  USB.println(F("-----------------------------"));
  delay(2000);
  
  
  /////////////////////////////////////////////////////////
  // 10. go one directory up to ROOT directory
  /////////////////////////////////////////////////////////
  sd_answer = SD.cd("..");
  
  if( sd_answer == true )
  {
    USB.println("\ninside ROOT directory:");
  }
  else
  {
    USB.println("change to ROOT directory FAILED"); 
  }

  /////////////////////////////////////////////////////////
  // 11. list Root directory
  /////////////////////////////////////////////////////////
  USB.println(F("###############################"));
  SD.ls( LS_R | LS_SIZE | LS_DATE );    
  USB.println(F("###############################"));
  
  
  delay(10000);
}


