/*  
 *  ------ [SD_07] - Datalogger to store info in SD file -------- 
 *  
 *  Explanation: This example shows how to store formatted frames in 
 *  SD file using the Data Frame class. Besides, it shows how to get
 *  these frames from the file and get them ready to be sent.
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
#include <WaspFrame.h>

// define folder and file to store data
char path[]="/data";
char filename[]="/data/log";

// buffer to write into Sd File
char toWrite[200];

// define variables to read stored frames 
uint8_t frameSD[MAX_FRAME+1];
uint16_t lengthSD;
int32_t numLines;

// variables to define the file lines to be read
int startLine;
int endLine;

// define variable
uint8_t sd_answer;



void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_07 example"));

  // Set SD ON
  SD.ON();

  // create path
  sd_answer = SD.mkdir(path);
  
  if( sd_answer == 1 )
  { 
    USB.println(F("path created"));
  }
  else
  {
    USB.println(F("mkdir failed"));
  }
  

  // Create file for Waspmote Frames
  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  { 
    USB.println(F("/data/log created"));
  }
  else
  {
    USB.println(F("/data/log not created"));
  }
  

  // init Accelerometer
  ACC.ON();

}

void loop()
{    
  /////////////////////////////////////////////////////
  // 1. Create Data frame using the Waspmote Frame class
  /////////////////////////////////////////////////////

  // Create new frame (ASCII)
  frame.createFrame(ASCII,"Waspmote_Pro"); 

  // add frame field (String message)
  frame.addSensor(SENSOR_STR, (char*) "data frame");
  // add frame field (Battery level)
  frame.addSensor(SENSOR_BAT, (uint8_t) PWR.getBatteryLevel());
  // add frame field (Accelerometer axis)
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ() );
  //show actual Frame 
  frame.showFrame(); 

  memset(toWrite, 0x00, sizeof(toWrite) ); 

  // Conversion from Binary to ASCII
  Utils.hex2str( frame.buffer, toWrite, frame.length);

  USB.print("Frame to be stored:");
  USB.println(toWrite);


  /////////////////////////////////////////////////////   
  // 2. Append data into file
  /////////////////////////////////////////////////////  
  sd_answer = SD.appendln(filename, toWrite);
  
  if( sd_answer == 1 )
  {
    USB.println(F("Frame appended to file"));
  }
  else 
  {
    USB.println(F("Append failed"));
  }

  /////////////////////////////////////////////////////
  // 3. Get information from File
  /////////////////////////////////////////////////////  

  // get number of lines in file
  numLines = SD.numln(filename);
  
  // get specified lines from file
  // get only the last file line
  startLine = numLines-1; 
  endLine = numLines;
  
  // iterate to get the File lines specified
  for( int i=startLine; i<endLine ; i++ )
  {  
    // Get 'i' line -> SD.buffer
    SD.catln( filename, i, 1); 
    
    // initialize frameSD
    memset(frameSD, 0x00, sizeof(frameSD) ); 
    
    // conversion from ASCII to Binary 
    lengthSD = Utils.str2hex(SD.buffer, frameSD );

    // Conversion from ASCII to Binary 
    USB.print(F("Get previously stored frame:"));
    for(int j=0; j<lengthSD; j++)
    {    
      USB.print(frameSD[j],BYTE);
    }
    USB.println();
    
    /************************************************
    * At this point 'frameSD' and 'lengthSD' can be 
    * used as 'frame.buffer' and 'frame.length' to 
    * send information via some communication module 
    *************************************************/
  }

  USB.println();
  USB.println();
  delay(2000);
}


