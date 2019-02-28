import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import gab.opencv.*;

// kinect variables
Kinect kinect;
int kinectWidth = 640;
int kinectHeight = 520;

// opencv variables
OpenCV opencv;
PImage prev, diff;
boolean trackingMode;

// mouses variables
ArrayList<Mouse> mouses;
int numMouse;
boolean repel;
int repelTime;
float repelLikelihood;

// glitch variables
boolean invert;
boolean invertMode;

// start mode variables
boolean startMode;

void setup() {
  //size(1200, 1080);
  fullScreen();
  //pixelDensity(2);
  frameRate(20);
  background(255);
  fill(0);
  smooth();
  textSize(16);
  randomSeed(39);
  
  // kinect config
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  
  // opencv config
  opencv = new OpenCV(this, kinectWidth, kinectHeight);
  prev = createImage(kinectWidth, kinectHeight, RGB);
  diff = createImage(kinectWidth, kinectHeight, ALPHA);
  trackingMode = false;
  
  // mouses config
  mouses = new ArrayList<Mouse>();
  numMouse = 100;
  for(int i = 0; i < numMouse; i++) {
    mouses.add(new Mouse(i)); 
  }
  repel = false;
  repelTime = -1;
  repelLikelihood = 1;
  
  // glitch config
  invert = false;
  invertMode = false;
  
  // ready mode config
  startMode = false;
}

void draw() {
  background(255);
  
  // kinect n opencv update
  PImage curr = kinect.getVideoImage();
  opencv.loadImage(curr);
  opencv.diff(prev);
  diff = opencv.getSnapshot();
  prev = curr;
  //image(diff, 0, 0);
  
  // count move pixels
  if(trackingMode) {
    diff.loadPixels();
    int movementSum = 0;
    for(int y = 0; y < kinectHeight; y++) {
      for(int x = 0; x < kinectWidth; x++) {
        int index = x + y * kinectWidth;
        color diffpix = diff.pixels[index];
        int diffc = diffpix & 0xFF;
        if(diffc > 120) {
          movementSum++;
        }
      }
    }
    if(movementSum > 100) repel = true;
    if(movementSum > 50) println(movementSum);
    diff.updatePixels();
    //text("movementSum: " + movementSum, 20, 40);
  }
  if(repel) {
      if(repelTime == -1) {
        repelTime = millis();
      } else if (millis() > repelTime + 1000) { // interval 3000ms to not trigger repel again
        repel = false;
        repelTime = -1;
      }
    }
  
  // mouses update
  if(startMode) {
    updateMouses();
    for(Mouse m : mouses) {
      if(!repel) m.attractBehavior();
      if(repel && random(1) < repelLikelihood) m.fleeBehavior();
      m.update();
      m.display();
    }
  }
  
  // glitch update
  if(invertMode) {
    if(random(1) < 0.5) invert = !invert;
  } else {
    invert = false;
  }
  
  if(invert) filter(INVERT);
  
  // draw texts
  fill(255, 0, 0);
  //text("state: " + mouses.get(0).state, 20, 40);
  //text("numMouse: " + mouses.size(), 20, 60);
  //text("frameRate: " + frameRate, 20, 80);
  //text("repel likelihood: " + repelLikelihood, 20, 100);
}

void updateMouses() {
  for(int i = mouses.size() - 1; i >= 1; i--) {
    if(mouses.get(i).pos.x < -100 || mouses.get(i).pos.x > width+100 || mouses.get(i).pos.y < -100 || mouses.get(i).pos.y > height+100) {
      mouses.remove(i);
    }
  }
  
  if(mouses.size() < numMouse && !repel) {
    mouses.add(new Mouse(mouses.size()));
  }
}

void keyPressed() {
  if(key == 'i') {
    // enable invert mode
    invertMode = !invertMode;
    println("invert mode: " + invertMode);
    
  } else if (key == 't') {
    // enable tracking  
    trackingMode = !trackingMode;
    println("tracking: " + trackingMode);
    
  } else if (key == 'r') { 
    // reset
    for(Mouse m : mouses) {
      m.pos = new PVector(random(0, width), random(0, height));
      if(m.pos.x > width/4 && m.pos.x < width/4*3) {
        if(m.pos.y < height/2) m.pos.y = -10;
        else m.pos.y = height+10;
      } 
    }
    
  } else if (key == 'p') {
    // trigger
    repel = true;
    
  } else if (key == 's') {
    // start mode
    startMode = !startMode;
    println("start mode: " + startMode);
  }
}
