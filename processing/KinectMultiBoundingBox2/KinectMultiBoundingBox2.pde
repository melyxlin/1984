import gab.opencv.*;
import java.awt.Rectangle;
import SimpleOpenNI.*;
import netP5.*;
import oscP5.*;

// opencv variables
OpenCV opencv;
PImage src;
int maxColors = 7;
int[] hues;
int[] colors;
int rangeWidth = 10;
int colorToChange = -1;

// kinect variables
SimpleOpenNI kinect;
int kinectWidth = 640;
int kinectHeight = 480;

// osc variables
OscP5 osc;
NetAddress loc;

// bbox variables
int outputWidth = 120;
int outputHeight = 90;
int numOutputPixels;
int[] bboxXs;
int[] bboxYs;
int[] bboxWs;
int[] bboxHs;
boolean configBboxOn;
int minBboxCoordX;
int maxBboxCoordX;
int minBboxCoordY;
int maxBboxCoordY;

// motion variables
PImage[] currUsers;
PImage[] prevUsers;
int[] userPos; // horizontal coordinates
PImage[] motionDiffs;
float moveAlpha;
int[] moveThresholds;
float[] movePercents; // percentage of user image differences over body mass
float[] currAvgs;
float[] prevAvgs;
float[] motionSpikes; // computes how much the new movePercent has moved away from the previous value
boolean[] motionTriggers;
int[] motionIntervals;
boolean startTracking;

// save outputs variables
PrintWriter[] writers;

void setup() {
  // opencv config
  opencv = new OpenCV(this, kinectWidth, kinectHeight);
  size(960, 630, P2D);
  colors = new int[maxColors];
  hues = new int[maxColors];
  
   // kinect config
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  
  // oscP5 config
  osc = new OscP5(this, 1111);
  loc = new NetAddress("127.0.0.1", 8888);
  
  // bbox config
  numOutputPixels = outputWidth * outputHeight;
  bboxXs = new int[maxColors];
  bboxYs = new int[maxColors];
  bboxWs = new int[maxColors];
  bboxHs = new int[maxColors];
  configBboxOn = false;
  minBboxCoordX = -1;
  maxBboxCoordX = -1;
  minBboxCoordY = -1;
  maxBboxCoordY = -1;
  
  // motion config
  currUsers = new PImage[maxColors];
  prevUsers = new PImage[maxColors];
  userPos = new int[maxColors];
  motionDiffs = new PImage[maxColors];
  moveAlpha = 0.1;
  moveThresholds = new int[maxColors];
  movePercents = new float[maxColors];
  currAvgs = new float[maxColors];
  prevAvgs = new float[maxColors];
  motionSpikes = new float[maxColors];
  motionTriggers = new boolean[maxColors];
  motionIntervals = new int[maxColors];
  startTracking = false;
  for(int i = 0; i < maxColors; i++) {
    bboxXs[i] = -1;
    bboxYs[i] = -1;
    bboxWs[i] = -1;
    bboxHs[i] = -1;
    currUsers[i] = createImage(outputWidth, outputHeight, ALPHA);
    prevUsers[i] = createImage(outputWidth, outputHeight, ALPHA);
    userPos[i] = -1;
    motionDiffs[i] = createImage(outputWidth, outputHeight, ALPHA);
    movePercents[i] = 0;
    currAvgs[i] = 0;
    prevAvgs[i] = 0;
    motionSpikes[i] = 0;
    motionTriggers[i] = false;
    motionIntervals[i] = 0;
  }
  
  moveThresholds[0] = 20; // 1. gigi
  moveThresholds[1] = 22; // 2. sarah
  moveThresholds[2] = 24; // 3. julia
  moveThresholds[3] = 25; // 4. nathan
  moveThresholds[4] = 24; // 5. ryan
  moveThresholds[5] = 25; // 6. amanda
  moveThresholds[6] = 20; // 7. selah
  
  // save output config
  writers = new PrintWriter[maxColors];
  for(int i = 0; i < maxColors; i++) {
    writers[i] = createWriter(month() + day() + "-" + hour() + minute() + second() + "/" + i + ".txt");
  }
}

void draw() {
  background(150);
  
  // kinect update
  kinect.update();
  opencv.loadImage(kinect.userImage());
  
  // opencv update
  opencv.useColor();
  src = opencv.getSnapshot();
  opencv.useColor(HSB);
  
  // detect motion user by user
  for(int i = 0; i < maxColors; i++) {
    if(bboxXs[i] != -1) {
      getUserMotion(i);
      updateMotionTrigger(i);
    }
  }
  
  // show outputs 
  image(src, 0, 0);
  for (int i=0; i<maxColors; i++) {
    if (currUsers[i] != null) {
      image(currUsers[i], 640, i*outputHeight, outputWidth, outputHeight); 
      image(motionDiffs[i], 640+outputWidth, i*outputHeight, outputWidth, outputHeight); 
      
      noStroke();
      fill(colors[i]);
      rect(src.width, i*outputHeight, 10, outputHeight);
    }
    
    if(bboxXs[i] != -1) {
      noFill();
      stroke(255, 0, 0);
      rect(bboxXs[i], bboxYs[i], bboxWs[i], bboxHs[i]);
    }
  }
  
  
  // draw instruction text
  textSize(16);
  stroke(255);
  fill(255);
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-7] to select color", 10, 25);
  }
  if(startTracking) {
    text("tracking: true", 10, 40);
  } else {
    text("tracking: false", 10, 40);
  }
  
  //println(frameRate);
}

//////////////////////
// User and Motion functions
//////////////////////
void getUserMotion(int index) {
  getUser(index); // update currUsers[index]
  
  // get pixels in user image
  prevUsers[index].loadPixels();
  currUsers[index].loadPixels();
  motionDiffs[index].loadPixels();
  
  // compute image differencing for user image
  int movementSum = 0;
  int areaSum = 1;
  for(int i = 0; i < numOutputPixels; i++) {
    color curr = currUsers[index].pixels[i];
    color prev = prevUsers[index].pixels[i];
    int currGray = curr & 0xFF;
    int prevGray = prev & 0xFF;
    int diff = abs(currGray - prevGray);
    if(currGray > 0) areaSum++;
    if(diff > 0) movementSum++;
    motionDiffs[index].pixels[i] = color(diff);
  }
  
  // update pixels in user image
  prevUsers[index].updatePixels();
  currUsers[index].updatePixels();
  motionDiffs[index].updatePixels();
  
  // 1. update moving averages
  // 2. detect spikes in motion differences
  if(startTracking) {
    movePercents[index] = float(movementSum) / float(areaSum);
    prevAvgs[index] = currAvgs[index];
    currAvgs[index] = (1-moveAlpha) * prevAvgs[index] + moveAlpha * movePercents[index];
    motionSpikes[index] = abs(floor((movePercents[index] - currAvgs[index]) / currAvgs[index] * 100));
    
    // draw texts
    text(movePercents[index], 880, 20 + index * outputHeight);
    text(motionSpikes[index], 880, 50 + index * outputHeight);
    if(motionSpikes[index] > moveThresholds[index] && !motionTriggers[index]) {
      motionTriggers[index] = true;
      motionIntervals[index] = millis();
      sendMotionOSC(userPos[index]);
      text("Moved", 880, 80 + index * outputHeight);
    }
    if(movePercents[index] > 0.85) {
      text("MovedPercents", 880, 110 + index * outputHeight);
    }
    
    writers[index].println(millis() + ": " + movePercents[index] + " " + motionSpikes[index] + (motionTriggers[index] ? " Moved" : " ") + " " + (movePercents[index] > 0.85? " movedPercents" : " "));
    
    // update previous user images with current
    prevUsers[index].copy(currUsers[index], 0, 0, outputWidth, outputHeight, 0, 0, outputWidth, outputHeight);
  }
}

void getUser(int index) {
  opencv.loadImage(src);
  opencv.setGray(opencv.getH().clone());
  opencv.erode();
  PImage output = createImage(kinectWidth, kinectHeight, ALPHA);
  output.copy(src, bboxXs[index], bboxYs[index], bboxWs[index], bboxHs[index], bboxXs[index], bboxYs[index], bboxWs[index], bboxHs[index]);
  currUsers[index].copy(output, 0, 0, kinectWidth, kinectHeight, 0, 0, outputWidth, outputHeight);
}

void configUser(int hue) {
  opencv.loadImage(src);
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  opencv.inRange(hue-rangeWidth/2, hue+rangeWidth/2);
  opencv.erode();
  PImage output = opencv.getSnapshot();
  //currUsers[colorToChange-1].copy(output, 0, 0, kinectWidth, kinectHeight, 0, 0, outputWidth, outputHeight);
  output.loadPixels();
  int minX = kinectWidth;
  int maxX = 0;
  int minY = kinectHeight;
  int maxY = 0;
  for(int y = 0; y < kinectHeight; y++) {
    for(int x = 0; x < kinectWidth; x++) {
      int index = x + y*kinectWidth;
      color c = output.pixels[index];
      int gray = c & 0xFF;
      if(gray > 0) {
        if(x < minX) {
          minX = x;
        }
        if(x > maxX) {
          maxX = x;
        }
        if(y < minY) {
          minY = y;
        }
        if(y > maxY) {
          maxY = y; 
        }
      }
    }
  }
  output.updatePixels();
  
  minX = (minX - 20 > 0) ? minX - 20 : 0;
  minY = (minY - 20 > 0) ? minY - 20 : 0;
  int boxWidth = (maxX - minX) * 6 / 5;
  int boxHeight = (maxY - minY) * 6 / 5;
  if(colorToChange > -1) {
    bboxXs[colorToChange-1] = minX; 
    bboxYs[colorToChange-1] = minY; 
    bboxWs[colorToChange-1] = boxWidth; 
    bboxHs[colorToChange-1] = boxHeight;
    userPos[colorToChange-1] = int(map((minX + maxX)/2, 0, kinectWidth, 0, 1280));
  }
}

void configBbox(int index) {
  bboxXs[index] = minBboxCoordX;
  bboxYs[index] = minBboxCoordY;
  bboxWs[index] = maxBboxCoordX - minBboxCoordX;
  bboxHs[index] = maxBboxCoordY - minBboxCoordY;
  userPos[index] = int(map((minBboxCoordX + maxBboxCoordX)/2, 0, kinectWidth, 0, 1280));
}

void updateMotionTrigger(int index) {
  if(motionTriggers[index]) {
    //text("Moved", 880, 80 + index * outputHeight);
    if(millis() > motionIntervals[index] + 1000) motionTriggers[index] = false;
  }
}

void sendMotionOSC(float pos) {
  OscMessage msg = new OscMessage("/kinect");
  msg.add(pos);
  osc.send(msg, loc);
}

//////////////////////
// Keyboard / Mouse
//////////////////////

void mousePressed() {
  if (colorToChange > -1 && !configBboxOn) {
    
    color c = get(mouseX, mouseY);
    println("r: " + red(c) + " g: " + green(c) + " b: " + blue(c));
   
    int hue = int(map(hue(c), 0, 255, 1, 180));
    
    colors[colorToChange-1] = c;
    hues[colorToChange-1] = hue;
    configUser(hue);
    
    println("color index " + (colorToChange-1) + ", value: " + hue);
  }
  
  if (configBboxOn && minBboxCoordX == -1 && minBboxCoordY == -1) {
    minBboxCoordX = mouseX;
    minBboxCoordY = mouseY;
  }
}

void mouseReleased() {
  if(configBboxOn && maxBboxCoordX == -1 && maxBboxCoordY == -1) {
    maxBboxCoordX = mouseX;
    maxBboxCoordY = mouseY;
    configBbox(colorToChange-1);
    configBboxOn = false;
    minBboxCoordX = -1;
    maxBboxCoordX = -1;
    minBboxCoordY = -1;
    maxBboxCoordY = -1;
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
    
  } else if (key == '5') {
    colorToChange = 5;
    
  } else if (key == '6') {
    colorToChange = 6;
    
  } else if (key == '7') {
    colorToChange = 7;
    
  } else if (key == 'r') {
    for(int i = 0; i < maxColors; i++) {
      movePercents[i] = 0;
      prevAvgs[i] = 0;
      currAvgs[i] = 0;
      motionSpikes[i] = 0;
    }
  } else if (key == ESC) {
    for(int i = 0; i < maxColors; i++) {
      writers[i].flush();
      writers[i].close();
    }
    exit();
  } else if (key == 't') {
    startTracking = !startTracking;
  } else if (key == 'b') {
    configBboxOn = true; 
  }
}

void keyReleased() {
  colorToChange = -1;
  configBboxOn = false; 
}

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}