/**
 * KinectMultiColorTrack
 * by Ellen Lo
 *
 * Track swipe gesture for work scene (#7).
 */

import gab.opencv.*;
import java.awt.Rectangle;
import SimpleOpenNI.*;
import signal.library.*;

// opencv variables
OpenCV opencv;
PImage src;
ArrayList<Contour> contours;
//ArrayList<Integer> colors;
int maxColors = 4;
int[] hues;
int[] colors;
int rangeWidth = 10;
PImage[] outputs;
int colorToChange = -1;

// output image variables
int numPixels;
int[] prevPixels;
PImage[] prevOutputs;
PImage[] motions;
float[] movePercents;
float[] movingAvgsPrev;
float[] movingAvgs;
float[] motionSpikes;
float alpha;
float motionThreshold;

// kinect variables
SimpleOpenNI kinect;
int kinectWidth = 640;
int kinectHeight = 480;

// filter
//SignalFilter myFilter;
//float srcSignal, srcSignalPrev;
//float filteredSignal, filteredSignalPrev;
//float minCutoff = 0.05; // decrease this to get rid of slow speed jitter
//float beta      = 4.0;  // increase this to get rid of high speed lag
//float xPos = 0;

void setup() {
  // opencv config
  opencv = new OpenCV(this, kinectWidth, kinectHeight);
  contours = new ArrayList<Contour>();
  size(960, 480, P2D);
  colors = new int[maxColors];
  hues = new int[maxColors];
  outputs = new PImage[maxColors];
  
  // output image config
  numPixels = kinectWidth * kinectHeight;
  prevPixels = new int[numPixels];
  prevOutputs = new PImage[maxColors];
  motions = new PImage[maxColors];
  movePercents = new float[maxColors];
  movingAvgs = new float[maxColors];
  movingAvgsPrev = new float[maxColors];
  motionSpikes = new float[maxColors];
  alpha = 0.4;
  motionThreshold = 20;
  for(int i = 0; i < maxColors; i++) {
    prevOutputs[i] = createImage(kinectWidth, kinectHeight, ALPHA);
    motions[i] = createImage(kinectWidth, kinectHeight, ALPHA); 
    movePercents[i] = 0;
    movingAvgs[i] = 0;
    movingAvgsPrev[i] = 0;
    motionSpikes[i] = 0;
  }
  
  // kinect config
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  
  // filter config
  //myFilter = new SignalFilter(this);
}

void draw() {
  
  background(150);
  
  // kinect update
  kinect.update();
  opencv.loadImage(kinect.userImage());
  
  // filter update
  //myFilter.setMinCutoff(minCutoff);
  //myFilter.setBeta(beta);
  //srcSignalPrev = srcSignal;
  //filteredSignalPrev = filteredSignal;
  //filteredSignal = myFilter.filterUnitFloat(movePercent);
  
  // Tell OpenCV to use color information
  opencv.useColor();
  src = opencv.getSnapshot();
  opencv.useColor(HSB);
  detectColors();
  detectMotion();
  
  // Show images
  image(src, 0, 0);
  for (int i=0; i<outputs.length; i++) {
    if (outputs[i] != null) {
      image(outputs[i], 640, i*src.height/4, src.width/4, src.height/4);
      image(motions[i], width-src.width/4, i*src.height/4, src.width/4, src.height/4);
      
      noStroke();
      fill(colors[i]);
      rect(src.width, i*src.height/4, 30, src.height/4);
    }
  }
  
  
  // Print text if new color expected
  textSize(20);
  stroke(255);
  fill(255);
  
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-4] to select color", 10, 25);
  }
  
  //displayContoursBoundingBoxes();
  
  println(frameRate);
}

//////////////////////
// Detect Functions
//////////////////////

void detectMotion() {
  for(int j = 0; j < maxColors; j++) {
    if(outputs[j] != null) {
      outputs[j].loadPixels();
      motions[j].loadPixels();
      prevOutputs[j].loadPixels();
      
      int movementSum = 0;
      int areaSum = 0;
      for(int i = 0; i < numPixels; i++) {
        color currColor = outputs[j].pixels[i];
        color prevColor = prevOutputs[j].pixels[i];
        int currGray = currColor & 0xFF;
        int prevGray = prevColor & 0xFF;
        int diff = abs(currGray - prevGray);
        if(currGray == 255) areaSum++;
        if(diff > 0) movementSum++; 
        motions[j].pixels[i] = color(diff);
      }
      
      prevOutputs[j].copy(outputs[j], 0, 0, kinectWidth, kinectHeight, 0, 0, kinectWidth, kinectHeight);
      prevOutputs[j].updatePixels();
      outputs[j].updatePixels();
      motions[j].updatePixels();
      movePercents[j] = float(movementSum) / float(areaSum);
      movingAvgsPrev[j] = movingAvgs[j];
      movingAvgs[j] = (1-alpha)*movingAvgsPrev[j] + alpha*movePercents[j];
      motionSpikes[j] = floor((movePercents[j] - movingAvgs[j])/movingAvgs[j]*100);
      
      // drawing texts
      fill(255);
      //text(movementSum, 800, 20+j*120);
      //text(areaSum, 800, 60+j*120);
      //text(movePercents[j], 800, 100+j*120);
      
      text(movePercents[j], 800, 20+j*120);
      text(motionSpikes[j], 800, 60+j*120);
      if(motionSpikes[j] > motionThreshold) text("Moved!", 800, 100+j*120);
    }
  }
}

void detectColors() {
    
  for (int i=0; i<hues.length; i++) {
    
    if (hues[i] <= 0) continue;
    
    opencv.loadImage(src);
    opencv.useColor(HSB);
    
    // <4> Copy the Hue channel of our image into 
    //     the gray channel, which we process.
    opencv.setGray(opencv.getH().clone());
    
    int hueToDetect = hues[i];
    //println("index " + i + " - hue to detect: " + hueToDetect);
    
    // <5> Filter the image based on the range of 
    //     hue values that match the object we want to track.
    opencv.inRange(hueToDetect-rangeWidth/2, hueToDetect+rangeWidth/2);
    
    //opencv.dilate();
    opencv.erode();
    
    // TO DO:
    // Add here some image filtering to detect blobs better
    
    // <6> Save the processed image for reference.
    outputs[i] = opencv.getSnapshot();
  }
  
  // <7> Find contours in our range image.
  //     Passing 'true' sorts them by descending area.
  if (outputs[0] != null) {
    
    opencv.loadImage(outputs[0]);
    contours = opencv.findContours(true,true);
  }
}

void displayContoursBoundingBoxes() {
  
  for (int i=0; i<contours.size(); i++) {
    
    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if (r.width < 20 || r.height < 20)
      continue;
    
    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    rect(r.x, r.y, r.width, r.height);
  }
}

//////////////////////
// Keyboard / Mouse
//////////////////////

void mousePressed() {
    
  if (colorToChange > -1) {
    
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 0, 180));
    
    colors[colorToChange-1] = c;
    hues[colorToChange-1] = hue;
    
    println("color index " + (colorToChange-1) + ", value: " + hue);
  }
}

void keyPressed() {
  
  if (key == '1') {
    colorToChange = 1;
    
  } else if (key == '2') {
    colorToChange = 2;
    
  } else if (key == '3') {
    colorToChange = 3;
    
  } else if (key == '4') {
    colorToChange = 4;
  }
}

void keyReleased() {
  colorToChange = -1; 
}


void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}