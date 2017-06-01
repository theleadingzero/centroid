/*******************************************************************************

  By Becky Stewart, 2017

  Based on DataStream.ino by Bare Conductive.

*******************************************************************************/

// serial rate
#define BAUDRATE 57600
#define NUM_SENSORS 6

#include <MPR121.h>
#include <Wire.h>

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;


float xValues[NUM_SENSORS];
float yValues[NUM_SENSORS];
float xMax[NUM_SENSORS];
float yMax[NUM_SENSORS];
float xPos = 0;
float yPos = 0;

/**********************************************************
   setup()
 * ********************************************************/
void setup() {
  Serial.begin(BAUDRATE);
  while (!Serial); // only needed for Arduino Leonardo or Bare Touch Board
  Serial.println("*****GO!****");
  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  if (!MPR121.begin(0x5C)) {
    Serial.println("error setting up MPR121");
    switch (MPR121.getError()) {
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
    while (1);
  }

  // the trigger and threshold values refer to the difference between
  // the filtered data and the running baseline - see p13 of
  // http://www.freescale.com/files/sensors/doc/data_sheet/MPR121.pdf
  MPR121.setTouchThreshold(touchThreshold);
  MPR121.setReleaseThreshold(releaseThreshold);

  // initialise arrays
  for (int i = 0; i < NUM_SENSORS; i++) {
    xValues[i] = 0;
    yValues[i] = 0;
    xMax[i] = 0;
    yMax[i] = 0;
  }

}


/**********************************************************
   loop()
 * ********************************************************/
void loop() {
  readInputs();
  //if (millis() < 6000) {
    //calibrateSensors();
  //} else {
    calibrateSensors();
    normaliseSensors();
    calculateCentroid();
    Serial.print(xPos);
    Serial.print(" ");
    Serial.println(yPos);
  //}
}

/**********************************************************
   readInputs()

   Read through each sensor channel and print the value.
 * ********************************************************/
void readInputs() {
  int i;

  // update all values
  if (MPR121.touchStatusChanged()) MPR121.updateTouchData();
  MPR121.updateBaselineData();
  MPR121.updateFilteredData();

  // this for loop is only for debugging in Processing
  /*for (i = 0; i < NUM_SENSORS * 2; i++) {  // 12 value pairs

    Serial.print(MPR121.getBaselineData(i)-MPR121.getFilteredData(i), DEC);
    if(i<12) Serial.print(" ");
    }*/
    
  // x values (sensors 5 through 0 from MPR121)
  int j = NUM_SENSORS - 1;
  for (int i = 0; i <  NUM_SENSORS; i++) {
    xValues[i] = MPR121.getBaselineData(j) - MPR121.getFilteredData(j);
    j--;
  }

  // y values (sensors 6 through 11 from MPR121)
  for (int i = 0; i < NUM_SENSORS; i++) {
    yValues[i] = MPR121.getBaselineData(i+NUM_SENSORS) - MPR121.getFilteredData(i+NUM_SENSORS);
  }
}


/*********************************
   calibrateSensors
 *********************************/
void calibrateSensors() {
  // if the current sensor value is higher than highest stored
  // update the max value to be current value
  for (int i = 0; i < NUM_SENSORS; i++) {
    if (xValues[i] > xMax[i]) xMax[i] = xValues[i];
    if (yValues[i] > yMax[i]) yMax[i] = yValues[i];

    // if below zero, set to arbitrary small number
    // to avoid dividing by zero during normalisation
    if (xMax[i] <= 0) xMax[i] = 0.0000001;
    if (yMax[i] <= 0) yMax[i] = 0.0000001;
  }
}

/*********************************
 * normaliseSensors
 *********************************/
void normaliseSensors() {
  // divide each sensor value by the maximum value
  // obtained during calibration
  for (int i=0; i<NUM_SENSORS; i++) {
    xValues[i] = xValues[i]/xMax[i];
    yValues[i] = yValues[i]/yMax[i];

    // limit sensors to not go below 0
    if ( xValues[i] < 0 ) xValues[i] = 0;
    if ( yValues[i] < 0 ) yValues[i] = 0;
  }
}

/*********************************
 * calculateCentroid
 *********************************/
void calculateCentroid() {
  // x values
  float num = 0;
  float dem = 0;

  for (int i=0; i<NUM_SENSORS; i++) {
    // weighted product of each sensor
    num += xValues[i] * i * 100; 
    // sum of sensor values
    dem += xValues[i];
  }
  
  // ratio of product and sum
  xPos = num/dem; 
  // threshold to off screen if not sufficient levels from sensors
  if ( dem < 0.1)  xPos = -100; 

  // y
  num = 0;
  dem = 0;
  for (int i=0; i<NUM_SENSORS; i++) {
    // weighted product of each sensor
    num += yValues[i] * i * 100;
    // sum of sensor values
    dem += yValues[i];
  }
  // ratio of product and sum
  yPos = num/dem;
  //threshold to off screen if not sufficient levels from sensors
  if ( dem < 0.1)  yPos = -100;
}
