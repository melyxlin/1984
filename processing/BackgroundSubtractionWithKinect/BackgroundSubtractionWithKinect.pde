import gab.opencv.*;

import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect kinect;
OpenCV opencv;

void setup() {
  size(640, 520);
  kinect = new Kinect(this);
  kinect.initDepth();
  kinect.initVideo();
  opencv = new OpenCV(this, 640, 520);
  opencv.startBackgroundSubtraction(5, 3, 0.5);
}

void draw() {
  background(0);
  //image(kinect.getVideoImage(), 0, 0);
  opencv.loadImage(kinect.getDepthImage());
  opencv.updateBackground();
  opencv.dilate();
  opencv.erode();
  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  image(opencv.getSnapshot(), 0, 0);
  for(Contour contour : opencv.findContours()) {
    contour.draw(); 
  }
}
