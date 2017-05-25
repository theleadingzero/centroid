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
  // The font must be located in the sketch's 
  // "data" directory to load successfully
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
      for (int j=0; j<numSensors/2; j++) {
        if (xValues[i] > xThreshold && yValues[j] > yThreshold) {
          ellipse(i*100+60, j*100+50, 30, 30);
        }
        // show y values
        text(yValues[j], 30, j*100+50);
      }
      // show x values
      text(xValues[i], i*100+50, 30);
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
  for ( int i=0; i<values.length; i++) {
   print( values[i] + " " );
   }
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
  int j=numSensors/2-1;
  for (int i=0; i<numSensors/2; i++) {
    xValues[i] = float(inValues[j--]);
  }

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
  // x
  float num = 0;
  float dem = 0;
  for (int i=0; i<numSensors/2; i++) {
    num += xValues[i] * i * 100;
    dem += xValues[i];
  }
  xPos = num/dem;
  if ( dem < 1)  xPos = 0;

  // y
  num = 0;
  dem = 0;
  for (int i=0; i<numSensors/2; i++) {
    num += yValues[i] * i * 100;
    dem += yValues[i];
  }
  yPos = num/dem;
  if ( dem < 1)  yPos = 0;

  println("X: " + xPos + " Y: " + yPos);
}

/*********************************
 * calibrateSensors
 *********************************/
void calibrateSensors() {
  background(0);

  for (int i=0; i<numSensors/2; i++) {
    if (xValues[i] > xMax[i]) xMax[i] = xValues[i];
    if (yValues[i] > yMax[i]) yMax[i] = yValues[i];
  }

  print("X: ");
  int j=numSensors/2;
  for (int i=0; i<numSensors/2; i++) {
    print(xMax[i] + " ");
  }
  println();

  print("Y: ");
  for (int i=0; i<numSensors/2; i++) {
    print(yMax[i] + " ");
  }
  println();
}

/*********************************
 * keyPressed
 *********************************/
void keyPressed() {
  calibrateFlag = false;
}