/*  
 *  ------ [SD_01] - Create/delete SD file -------- 
 *  
 *  Explanation: Turn on the SD card. Delete specified filename
 *  in the case it exists. The first loop creates the file, but 
 *  the following loops will not because the file already exists. 
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

// define file name: MUST be 8.3 SHORT FILE NAME
char filename[]="FILE1.TXT";


void setup()
{
  // Open USB port
  USB.ON();
  USB.println(F("SD_1 example"));

  // Set SD ON
  SD.ON();

  // Delete file
  if(SD.del(filename)) 
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }

}


void loop()
{  
  // Create file1
  if(SD.create(filename))
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  }  
    
  delay(5000);


}


