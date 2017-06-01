/***************************************************************
 
 By Becky Stewart, 2017
 
 ****************************************************************/

import processing.serial.*;

int baudRate = 57600;

Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port

boolean calibrateFlag = true;

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

  // text settings
  font = loadFont("AndaleMono-20.vlw");
  textFont(font, 12);
  
  
  noStroke();
  fill(200, 0, 100);
}

/*********************************
 * draw
 *********************************/
void draw() {
  background(255);

  ellipse(xPos+50, yPos+50, 30, 30);
}


/*********************************
 * serialEvent
 *********************************/
void serialEvent(Serial p) {
  // read in raw string
  String inString = trim( p.readString() );

  // parse into ints
  float[] values = float(split( inString, ' '));
  parseInputs( values );

  printValues();
}

/*********************************
 * parseInputs
 *********************************/
void parseInputs(float[] inValues) {
  // read in x and y positions

  // x position
  xPos  = inValues[0];
  
  // y position
  yPos  = inValues[1];
}

/*********************************
 * printValues
 *********************************/
void printValues() {
  println("X: " + xPos + " Y: " + yPos);
}