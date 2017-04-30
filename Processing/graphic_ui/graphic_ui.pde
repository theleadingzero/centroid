/***************************************************************
 
 By Becky Stewart, 2017
 
 ****************************************************************/

import processing.serial.*;

int baudRate = 57600;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

int numSensors = 12;
float[] xValues;
float[] yValues;


void setup() {
  size( 600, 600 );

  // open port
  String portName = Serial.list()[1];
  //printArray(Serial.list()); // uncomment to list all ports
  myPort = new Serial(this, portName, baudRate);
  myPort.bufferUntil(10);
  
  
  // initialise the arrays of sensor values
  xValues = new float[numSensors/2];
  yValues = new float[numSensors/2];
  for(int i=0; i<numSensors/2; i++) {
     xValues[i] = 0;
     yValues[i] = 0;
  }

  fill(200, 0, 100);

}

void draw() {
  background(255);
  
  // show values above a threshold
  float xThreshold = 0.8;
  float yThreshold = 0.4;
  for(int i=0; i<numSensors/2; i++){
    for(int j=0; j<numSensors/2; j++) {
      if(xValues[i] > xThreshold && yValues[j] > yThreshold){
        ellipse(i*100+50, j*100+50, 30, 30);
      }
    }
  }
}






void serialEvent(Serial p) {
  // read in raw string
  String inString = trim( p.readString() );
  
  // parse into ints
  int[] values = int(split( inString, ' '));
  parseInputs( values );
  // print  for debugging
  /*for ( int i=0; i<values.length; i++) {
    print( values[i] + " " );
  }
  println();*/
  
  normaliseSensors();
  printValues();
}


void parseInputs(int[] inValues) {
  // read in x and y positions
  int j=numSensors/2;
  for(int i=0; i<numSensors/2; i++) {
     xValues[i] = float(inValues[j--]);
  }
  
  for(int i=0; i<numSensors/2; i++) {
     yValues[i] = float(inValues[i + numSensors/2]);
  }
}

void printValues() {
    print("X: ");
  int j=numSensors/2;
  for(int i=0; i<numSensors/2; i++) {
     print(xValues[i] + " ");  
  }
  println();
  
  print("Y: ");
  for(int i=0; i<numSensors/2; i++) {
     print(yValues[i] + " "); 
  }
  println();
}

void normaliseSensors() {
  int xMax = 50;
  int yMax = 10;
 for(int i=0; i<numSensors/2; i++) {
   xValues[i] = xValues[i]/xMax;
   yValues[i] = yValues[i]/yMax;  
 }
}