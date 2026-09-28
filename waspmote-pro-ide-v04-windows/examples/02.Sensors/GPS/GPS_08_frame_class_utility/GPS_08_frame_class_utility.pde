/*  
 *  ------------  [GPS_08] - Frame Class Utility  -------------- 
 *  
 *  Explanation: This is the basic code to create a frame with GPS
 * 	basic data
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
 *  Version:		    0.1
 *  Design:             David Gascón
 *  Implementation:     Luis Miguel Marti
 */

#include <WaspGPS.h>
#include <WaspFrame.h>

#define TIMEOUT 240

// define status variable for GPS connection
bool status;

char node_ID[] = "Node_01";


void setup()
{
  USB.ON();
  USB.println(F("Frame Utility Example for GPS"));

  // Set the Waspmote ID
  frame.setID(node_ID);
  
  // Set GPS ON  
  GPS.ON(); 
}

void loop()
{
  ///////////////////////////////////////////
  // 1. Turn on board and wait for GPS signal
  ///////////////////////////////////////////
  GPS.ON(); 
  status = GPS.waitForSignal(TIMEOUT);
  delay(100);


  ///////////////////////////////////////////
  // 2. Read data if GPS is connected
  ///////////////////////////////////////////  
  if( status == true )
  {
    // getPosition function gets all basic data 
    status = GPS.getPosition();   
  }
  else
  {
    USB.println("Could not connect GPS");
  }

  ///////////////////////////////////////////
  // 3. Create ASCII frame
  /////////////////////////////////////////// 

  // Create new frame (ASCII)
  frame.createFrame(ASCII);
  if( status == true )
  {
    //Add global position [degrees]
    frame.addSensor(SENSOR_GPS, 
                    GPS.convert2Degrees(GPS.latitude, GPS.NS_indicator),
                    GPS.convert2Degrees(GPS.longitude, GPS.EW_indicator) );
	
    //Add altitude [m]
    frame.addSensor(SENSOR_ALTITUDE,GPS.altitude);
    
    //Add speed [km/h]
    frame.addSensor(SENSOR_SPEED,GPS.speed);
    
    //Add course [degrees]
    frame.addSensor(SENSOR_COURSE,GPS.course);    
    
    //Add time
    frame.addSensor(SENSOR_TIME,GPS.timeGPS);
    
    //Add date
    frame.addSensor(SENSOR_DATE,GPS.dateGPS);
  
  }
  



  // Show the frame
  frame.showFrame();


  
  ///////////////////////////////////////////
  // 4. Turn off the board
  /////////////////////////////////////////// 
  GPS.OFF();
  
  //wait 2 seconds
  delay(2000);
}
