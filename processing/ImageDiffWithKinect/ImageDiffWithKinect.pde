import gab.opencv.*;

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect kinect;
int kinectWidth = 640;
int kinectHeight = 520;
OpenCV opencv;
PImage prev, diff;

void setup() {
  size(640, 520);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  opencv = new OpenCV(this, 640, 520);
  prev = createImage(640, 520, RGB);
}

void draw() {
  PImage curr = kinect.getVideoImage();
  opencv.loadImage(curr);
  opencv.diff(prev);
  diff = opencv.getSnapshot();
  prev = curr;
  image(diff, 0, 0);
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
  if(movementSum > 100) println("repel");
  diff.updatePixels();
  if(movementSum > 50) println(movementSum);
}
