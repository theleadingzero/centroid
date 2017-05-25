/***************************************************************
 
 By Becky Stewart, 2017
 
 ****************************************************************/

import processing.serial.*;

int baudRate = 57600;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

boolean calibrateFlag = true;

int numSensors = 12;
float[] xValues;
float[] yValues;
float[] xMax;
float[] yMax;
float xPos = 0;
float yPos = 0;

PFont font;


/*********************************
 * setup
 *********************************/
void setup() {
  size( 700, 600 );

  // open port
  String portName = Serial.list()[1];
  //printArray(Serial.list()); // uncomment to list all ports
  myPort = new Serial(this, portName, baudRate);
  myPort.bufferUntil(10);


  // initialise the arrays of sensor values
  xValues = new float[numSensors/2];
  yValues = new float[numSensors/2];
  xMax = new float[numSensors/2];
  yMax = new float[numSensors/2];

  for (int i=0; i<numSensors/2; i++) {
    xValues[i] = 0;
    yValues[i] = 0;
    xMax[i] = 0;
    yMax[i] = 0;
  }

  // text settings
  font = loadFont("AndaleMono-20.vlw");
  textFont(font, 12);
}

/*********************************
 * draw
 *********************************/
void draw() {
  if ( calibrateFlag ) {
    calibrateSensors();
  } else {
    background(255);

    // show values above a threshold
    float xThreshold = 0.8;
    float yThreshold = 0.4;
    for (int i=0; i<numSensors/2; i++) {
      // show x values
      text(xValues[i], i*100+50, 30);
      // show y values
      text(yValues[i], 30, i*100+50);
    }

    fill(200, 0, 100);
    ellipse(xPos+50, yPos+50, 30, 30);

    textSize(32);
    fill(15);
  }
}


/*********************************
 * serialEvent
 *********************************/
void serialEvent(Serial p) {
  // read in raw string
  String inString = trim( p.readString() );

  // parse into ints
  int[] values = int(split( inString, ' '));
  parseInputs( values );
  // print  for debugging
  /*for ( int i=0; i<values.length; i++) {
   print( values[i] + " " );
   }*/
  println();

  if ( calibrateFlag ) {
    calibrateSensors();
  } else {
    normaliseSensors();
    //printValues();
    calculateCentroid();
  }
}

/*********************************
 * parseInputs
 *********************************/
void parseInputs(int[] inValues) {
  // read in x and y positions

  // x values
  int j=numSensors/2-1;
  for (int i=0; i<numSensors/2; i++) {
    xValues[i] = float(inValues[j--]);
  }

  // y values
  for (int i=0; i<numSensors/2; i++) {
    yValues[i] = float(inValues[i + numSensors/2]);
  }
}

/*********************************
 * printValues
 *********************************/
void printValues() {
  print("X: ");
  int j=numSensors/2;
  for (int i=0; i<numSensors/2; i++) {
    print(xValues[i] + " ");
  }
  println();

  print("Y: ");
  for (int i=0; i<numSensors/2; i++) {
    print(yValues[i] + " ");
  }
  println();
}

/*********************************
 * normaliseSensors
 *********************************/
void normaliseSensors() {
  // divide each sensor value by the maximum value
  // obtained during calibration
  for (int i=0; i<numSensors/2; i++) {
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
  for (int i=0; i<numSensors/2; i++) {
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
  for (int i=0; i<numSensors/2; i++) {
    // weighted product of each sensor
    num += yValues[i] * i * 100;
    // sum of sensor values
    dem += yValues[i];
  }
  // ratio of product and sum
  yPos = num/dem;
  // threshold to off screen if not sufficient levels from sensors
  if ( dem < 0.1)  yPos = -100;

  println("X: " + xPos + " Y: " + yPos);
}

/*********************************
 * calibrateSensors
 *********************************/
void calibrateSensors() {
  background(0);

  // if the current sensor value is higher than highest stored
  // update the max value to be current value
  for (int i=0; i<numSensors/2; i++) {
    if (xValues[i] > xMax[i]) xMax[i] = xValues[i];
    if (yValues[i] > yMax[i]) yMax[i] = yValues[i];
  }
}

/*********************************
 * keyPressed
 *********************************/
void keyPressed() {
  calibrateFlag = false;
}