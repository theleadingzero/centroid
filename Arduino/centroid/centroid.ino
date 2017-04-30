/*******************************************************************************

  By Becky Stewart, 2017
  
  Based on DataStream.ino by Bare Conductive.

*******************************************************************************/

// serial rate
#define BAUDRATE 57600

#include <MPR121.h>
#include <Wire.h>

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;

/**********************************************************
 * setup()
 * ********************************************************/
void setup(){  
  Serial.begin(BAUDRATE);
  while(!Serial); // only needed for Arduino Leonardo or Bare Touch Board 

  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  if(!MPR121.begin(0x5C)){ 
    Serial.println("error setting up MPR121");  
    switch(MPR121.getError()){
      case NO_ERROR:
        Serial.println("no error");
        break;  
      case ADDRESS_UNKNOWN:
        Serial.println("incorrect address");
        break;
      case READBACK_FAIL:
        Serial.println("readback failure");
        break;
      case OVERCURRENT_FLAG:
        Serial.println("overcurrent on REXT pin");
        break;      
      case OUT_OF_RANGE:
        Serial.println("electrode out of range");
        break;
      case NOT_INITED:
        Serial.println("not initialised");
        break;
      default:
        Serial.println("unknown error");
        break;      
    }
    while(1);
  }


  MPR121.setTouchThreshold(touchThreshold);
  MPR121.setReleaseThreshold(releaseThreshold);  
}


/**********************************************************
 * loop()
 * ********************************************************/
void loop(){
   readPrintInputs();  
}

/**********************************************************
 * readPrintInputs()
 * 
 * Read through each sensor channel and print the value.
 * ********************************************************/
void readPrintInputs(){
    int i;

    // update all values
    if(MPR121.touchStatusChanged()) MPR121.updateTouchData();
    MPR121.updateBaselineData();
    MPR121.updateFilteredData();
    
    
    // the trigger and threshold values refer to the difference between
    // the filtered data and the running baseline - see p13 of 
    // http://www.freescale.com/files/sensors/doc/data_sheet/MPR121.pdf

    for(i=0; i<13; i++){          // 13 value pairs
      Serial.print(MPR121.getBaselineData(i)-MPR121.getFilteredData(i), DEC);
      if(i<12) Serial.print(" ");
    }           
    Serial.println();

}
