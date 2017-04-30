/***************************************************************
 
 By Becky Stewart, 2017
 
 ****************************************************************/

import processing.serial.*;

int baudRate = 57600;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

int numSensors = 12;
int[] xValues;
int[] yValues;

void setup() {
  size( 600, 600 );

  // open port
  String portName = Serial.list()[1];
  //printArray(Serial.list()); // uncomment to list all ports
  myPort = new Serial(this, portName, baudRate);
  myPort.bufferUntil(10);
  
  
  // initialise the arrays of sensor values
  xValues = new int[numSensors/2];
  yValues = new int[numSensors/2];
  for(int i=0; i<numSensors/2; i++) {
     xValues[i] = 0;
     yValues[i] = 0;
  }

  fill(200, 0, 100);

}

void draw() {
  background(255);
  
  // show values above a threshold
  for(int i=0; i<numSensors/2; i++){
    for(int j=0; j<numSensors/2; j++) {
      if(xValues[i] > 20 && yValues[j] > 5){
        ellipse(i*100+10, j*100+10, 30, 30);
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
}


void parseInputs(int[] inValues) {
  // read in x and y positions
  print("X: ");
  int j=numSensors/2;
  for(int i=0; i<numSensors/2; i++) {
     xValues[i] = inValues[j--];
     print(xValues[i] + " ");  
  }
  println();
  
  print("Y: ");
  for(int i=0; i<numSensors/2; i++) {
     yValues[i] = inValues[i + numSensors/2];
     print(yValues[i] + " "); 
  }
  println();
}