import gab.opencv.*;
import netP5.*;
import oscP5.*;
import SimpleOpenNI.*;
import java.awt.Rectangle;

// osc variables
OscP5 osc;
NetAddress loc;

// kinect variables
SimpleOpenNI kinect;
int appWidth = 640;
int appHeight = 480;
int kinectWidth = 640;
int kinectHeight = 480;
int [] jointsList;

// opencv variables
OpenCV opencv;
PImage userImg;
ArrayList<Contour> contours;
int maxColors = 4;
int[] hues;
int[] colors;
int rangeWidth = 10;

PImage[] outputs;
int colorToChange = -1;

void setup() {
  size(830, 480);
  // oscP5 config
  osc = new OscP5(this, 1111);
  loc = new NetAddress("127.0.0.1", 8888);
  
  // kinect config
  fill(255, 0, 0);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  jointsList = new int [15];
  jointsList[0] = SimpleOpenNI.SKEL_HEAD; // 0
  jointsList[1] = SimpleOpenNI.SKEL_NECK; // 1
  jointsList[2] = SimpleOpenNI.SKEL_LEFT_SHOULDER; // 2
  jointsList[3] = SimpleOpenNI.SKEL_LEFT_ELBOW; // 4
  jointsList[4] = SimpleOpenNI.SKEL_RIGHT_SHOULDER; // 3
  jointsList[5] = SimpleOpenNI.SKEL_RIGHT_ELBOW; // 5
  jointsList[6] = SimpleOpenNI.SKEL_TORSO; // 8
  jointsList[7] = SimpleOpenNI.SKEL_LEFT_HIP; // 9
  jointsList[8] = SimpleOpenNI.SKEL_LEFT_KNEE; // 11
  jointsList[9] = SimpleOpenNI.SKEL_RIGHT_HIP; // 10
  jointsList[10] = SimpleOpenNI.SKEL_LEFT_FOOT; // 13
  jointsList[11] = SimpleOpenNI.SKEL_RIGHT_KNEE; // 12
  jointsList[12] = SimpleOpenNI.SKEL_RIGHT_FOOT; // 14
  jointsList[13] = SimpleOpenNI.SKEL_RIGHT_HAND; // 7
  jointsList[14] = SimpleOpenNI.SKEL_LEFT_HAND; // 6
  
  // opencv config
  opencv = new OpenCV(this, kinectWidth, kinectHeight);
  contours = new ArrayList<Contour>();
  colors = new int[maxColors];
  hues = new int[maxColors];
  outputs = new PImage[maxColors];
  
}

void draw() {
  // DEBUG OSC
  //sendSkeleton(int(random(1,4)));
  
  // CONFIGURE USER LIST
  kinect.update();
  
  // draw mirrored kinect image
  //userImg = kinect.userImage();
  //pushMatrix();
  //scale(-1.0, 1.0);
  //image(kinect.userImage(), -kinectWidth, 0);
  //popMatrix();
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  println(userList.size());
  //if(userList.size() > 0) {
  // int userId = userList.get(0);
   //if(kinect.isTrackingSkeleton(userId)) {
   //  // if we detect one user we have to draw it
   //  drawSkeleton(userId);
   //  sendSkeleton(userId);
   //}
  //}
  
  // opencv get colors
  opencv.loadImage(kinect.userImage());
  opencv.useColor();
  userImg = opencv.getSnapshot();
  opencv.useColor(HSB);
  
  detectColors();
  
  image(userImg, 0, 0);
  for (int i=0; i<outputs.length; i++) {
    if (outputs[i] != null) {
      image(outputs[i], width-userImg.width/4, i*userImg.height/4, userImg.width/4, userImg.height/4);
      
      noStroke();
      fill(colors[i]);
      rect(userImg.width, i*userImg.height/4, 30, userImg.height/4);
    }
  }
  
  textSize(20);
  stroke(255);
  fill(255);
  
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-4] to select color", 10, 25);
  }
  
  displayContoursBoundingBoxes();
}

void detectColors() {
    
  for (int i=0; i<hues.length; i++) {
    
    if (hues[i] <= 0) continue;
    
    opencv.loadImage(userImg);
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
    
  } else if (key == '5') {
    colorToChange = 5;
    
  } else if (key == '6') {
    colorToChange = 6;
    
  } else if (key == '7') {
    colorToChange = 7;
    
  }
}

void keyReleased() {
  colorToChange = -1; 
}

void sendSkeleton(int userId) {
  for(int i = 0; i < jointsList.length; i++) {
    OscMessage msg = new OscMessage("/kinect/" + userId + "/" + jointsList[i]);
    PVector pos = getJointPos(userId, jointsList[i]);  // REAL JOINT POS
    PVector mirrored = getMirrorVec(pos); // send mirrored position
    //PVector pos = new PVector(random(appWidth), random(appHeight)); // DEBUG
    msg.add(mirrored.x + "," + mirrored.y);
    osc.send(msg, loc);
  }
}

void drawSkeleton(int userId) {
  // draw mirrored skeleton
  pushMatrix();
  scale(-1.0, 1.0);
  translate(-kinectWidth, 0);
  stroke(0);
  strokeWeight(5);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
  noStroke();
  fill(255,0,0);
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
  popMatrix();
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.5) return;
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}

PVector getJointPosSafe(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.5) return new PVector(-1, -1);
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  return convertedJoint;
}

PVector getJointPos(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  //if(confidence < 0.5) return new PVector(-1, -1);
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  return convertedJoint;
}

PVector getMirrorVec(PVector vec) {
  PVector mirrored = new PVector();
  mirrored.y = vec.y;
  mirrored.x = kinectWidth/2 - (vec.x - kinectWidth/2);
  return mirrored;
}

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}