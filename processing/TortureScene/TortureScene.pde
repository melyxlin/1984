// WALL PROJECTION
import SimpleOpenNI.*;

// kinect variables
SimpleOpenNI kinect;
PImage kinectImg;
PImage userImg;
int kinectWidth = 640;
int kinectHeight = 480;
int appWidth = 889;
int appHeight = 400;

// target velocity analysis variables
PVector currPos, prevPos;
PVector currVel, prevVel;
PVector currAccel, prevAccel;
boolean repelBool;
float repelThresh;

// mouses variables
ArrayList<Mouse> mouses;
int numMouse;

// targets variables
ArrayList<PVector> targets;

// scrollbars
HScrollbar thresh;

void setup() {
  size(889, 700);
  frameRate(60);
  background(255);
  fill(0);
  smooth();
  textSize(16);
  
  // kinect config
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  kinectImg = createImage(kinectWidth, kinectHeight, RGB);
  userImg = createImage(kinectWidth, kinectHeight, ALPHA);
  
  // target velocity analysis config
  currPos = new PVector(0, 0);
  prevPos = new PVector(0, 0);
  currVel = new PVector(0, 0);
  prevVel = new PVector(0, 0);
  currAccel = new PVector(0, 0);
  prevAccel = new PVector(0, 0);
  repelBool = false;
  repelThresh = 10;
  
  // mouses config
  mouses = new ArrayList<Mouse>();
  numMouse = 100;
  for(int i = 0; i < numMouse; i++) {
    mouses.add(new Mouse(i)); 
  }
  
  // targets config
  targets = new ArrayList<PVector>();
  targets.add(new PVector(width/2, height/2));
  
  // scrollbar config
  thresh = new HScrollbar(kinectWidth + 10, 20, 160, 16, 1);
}

void draw() {
  background(255);
  
  // kinect update
  kinect.update();
  kinectImg = kinect.userImage();
  image(kinectImg, 0, kinectHeight);
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if(userList.size() > 0) {
    int userId = userList.get(0);
    if(kinect.isTrackingSkeleton(userId)) {
      drawSkeleton(userId);
      drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
      PVector head = getJointPos(userId, SimpleOpenNI.SKEL_HEAD);
       // track head acceleration
      updateVectors(head);
    }
  }
  
  // track cursor acceleration
  //updateVectors(new PVector(mouseX, mouseY));
  
  // mouses update
  updateMouses();
  for(Mouse m : mouses) {
    m.attractBehavior();
    //if(repelBool && random(1) < 0.9) m.fleeBehavior();
    if(repelBool) m.fleeBehavior();
    m.update();
    m.display();
  }
  
  // targets update
  for(int i = targets.size() - 1; i >= 1; i--) {
    targets.remove(i);
  }
  targets.add(currPos);
  
  // thresh update
  thresh.update();
  thresh.display();
  repelThresh = map(thresh.getPos(), 720, 890, 10, 300);
  
  // draw texts
  fill(255, 0, 0);
  text("currAccel: " + currAccel.mag(), 20, 20);
  text("repelThreshold: " + repelThresh, 20, 40);
  text("numMouse: " + mouses.size(), 20, 60);
  text("frameRate: " + frameRate, 20, 80);
  println("currAccel: " + currAccel.mag());
}

void updateVectors(PVector pos) {
  // target velocity analysis update
  currPos = pos;
  currVel = PVector.sub(currPos, prevPos);
  currAccel = PVector.sub(currVel, prevVel);
  repelBool = (currAccel.mag() > repelThresh) ? true : false;
  prevPos = currPos;
  prevVel = currVel;
  prevAccel = currAccel;
}

void keyPressed(int key) {
  if(key == 'r') {
    currPos = new PVector(0, 0);
    prevPos = new PVector(0, 0);
    currVel = new PVector(0, 0);
    prevVel = new PVector(0, 0);
    currAccel = new PVector(0, 0);
    prevAccel = new PVector(0, 0);
  }
}

void updateMouses() {
  for(int i = mouses.size() - 1; i >= 1; i--) {
    if(mouses.get(i).pos.x < -100 || mouses.get(i).pos.x > width+100 || mouses.get(i).pos.y < -100 || mouses.get(i).pos.y > height+100) {
      mouses.remove(i);
    }
  }
  
  if(mouses.size() < numMouse) {
    if(random(1) < 0.2) mouses.add(new Mouse(mouses.size()));
  }
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.2) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  convertedJoint.x = convertedJoint.x / kinectWidth * appWidth;
  convertedJoint.y = convertedJoint.y / kinectHeight * appHeight;
  noStroke();
  fill(255, 0, 0);
  ellipse(convertedJoint.x, convertedJoint.y, 20, 20);
}

PVector getJointPos(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.2) return new PVector(-1, -1);
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  convertedJoint.x = convertedJoint.x / kinectWidth * appWidth;
  convertedJoint.y = convertedJoint.y / kinectHeight * appHeight;
  return convertedJoint;
}

void onNewUser(SimpleOpenNI kinect, int userID) {
  println("Start skeleton tracking");
  kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

//Draw the skeleton
void drawSkeleton(int userId) {
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
}