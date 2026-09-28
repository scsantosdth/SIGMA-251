/*  
 *  ------ [C_20] - Using GPRS with hibernate mode -------- 
 *  
 *  Explanation: This example sends a SMS with internal RTC
 *  temperature and then It goes to hibernate mode, during 
 *  specified time.
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
 *  Implementation:    Javier Siscart
 */

#include <WaspGPRS_Pro.h>
#include <WaspFrame.h>

// Variable to store sleeping period. Format DD:HH:MM:SS
char hibernateTime[] = "00:01:00:00";

//Variable to store SMS text
char SMSText [100];

void setup()
{
    ///////////////////////////////////////////////
    // 0. Initial configuration
    ////////////////////////////////////////////////

    // NOTE: 
    // Be sure hibernate switch is switched off correctly, just after 
    // turning ON Waspmote, while red LED is ON. Green LED must blink
    // just after that. If not, repeat the sequence.

    // 0.1 Checks if we come from a normal reset or an hibernate reset
    PWR.ifHibernate();

    // 0.2 Init USB port for debugging
    USB.ON();
    USB.println(F("C_20 Example"));

}

void loop()
{

    ///////////////////////////////////////////////
    // 1. Hibernate interruption
    ////////////////////////////////////////////////

    // 1.1 If Hibernate has been captured, execute the associated function
    if( intFlag & HIB_INT )
    {
        hibInterrupt();
    }

    ///////////////////////////////////////////////
    // 2. Message composition
    ////////////////////////////////////////////////

    // 2.2 Set mote Identifier (16-Byte max)
    frame.setID("WASPMOTE_001");	

    // 2.3 Create new frame
    frame.createFrame(ASCII);  

    // 2.4 Turn ON RTC to measure temperature
    RTC.ON();

    // 2.5 Add frame fields
    frame.addSensor(SENSOR_IN_TEMP, RTC.getTemperature());  

    // 2.6 Turn RTC OFF
    RTC.OFF();

    // 2.7 Print frame
    // Example: <=>#35689356#WASPMOTE_001#0#IN_TEMP:28.50#
    frame.showFrame();

    // Replace no printable chars '' in order to be able to send an SMS
    // This is not necessary for TCP or UDP. 
    // // Example: <=>###35689356#WASPMOTE_001#0#IN_TEMP:28.50#
    for(int i = 0; i < frame.length ; i++ )
    {
        switch (i)
        {
        case 3:       
            SMSText[i] = '#'; 
            break;
        case 4:       
            SMSText[i] = '#'; 
            break;
        default:      
            SMSText[i] = (char) frame.buffer[i];
        }
    }

    ////////////////////////////////////////////////
    // 3. Send message
    ////////////////////////////////////////////////

    USB.println(F("Sending data."));

    // 3.1 Activates the GPRS_Pro module:
    if (GPRS_Pro.ON() == 1)
    {
        USB.println(F("GPRS_Pro module ready..."));

        // 3.2 Sets pin code:
        // **** must be substituted by the SIM code
        if (GPRS_Pro.setPIN("****") == 1) 
        {
            USB.println(F("PIN code accepted"));
        }
        else
        {
            USB.println(F("PIN code incorrect"));
        }

        // 3.3 Waits for connection to the network:
        if (GPRS_Pro.check(60) == 1)
        {
            USB.println(F("GPRS_Pro module connected to the network..."));

            // ********* should be replaced by the desired tlfn number
            if (GPRS_Pro.sendSMS(SMSText, "*********") == 1) 
            {
                USB.println(F("SMS Sent OK")); 
            }
            else
            {
                USB.println(F("Error sending sms"));   
            }
        }
        else
        {
            USB.println(F("GPRS_Pro module NOT connected to the network..."));
        }
    }
    else
    {
        USB.println(F("GPRS_Pro module NOT started"));
    }

    // 3.4 Powers off the GPRS_Pro module   
    GPRS_Pro.OFF();


    ////////////////////////////////////////////////
    // 4. Entering Hibernate mode
    ////////////////////////////////////////////////
    USB.println(F("enter hibernate mode"));
    delay(5000);

    // Set Waspmote to Hibernate, waking up after "hibernateTime"
    PWR.hibernate(hibernateTime, RTC_OFFSET, RTC_ALM1_MODE2);

}

////////////////////////////////////////////////
// HIbernate Subroutine.
////////////////////////////////////////////////
void hibInterrupt()
{
    USB.println(F("---------------------"));
    USB.println(F("Hibernate Interruption captured"));
    USB.println(F("---------------------"));

    // Clear Flag 
    intFlag &= ~(HIB_INT);  
    delay(2000);
}


