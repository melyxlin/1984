import SimpleOpenNI.*;

SimpleOpenNI kinect;
PImage kinectImg;
PImage userImg;
int currTargetX, currTargetY;
ArrayList<PVector> targets;
PVector attractor;
int kinectWidth = 640;
int kinectHeight = 480;

int appWidth = 640;
int appHeight = 480;
ArrayList<Mouse> Mouses = new ArrayList<Mouse>();
int numMouse = 100;

void setup() {
  size(640, 480);
  background(255);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  fill(255, 0, 0);
  kinect.setMirror(false);
  kinectImg = createImage(appWidth, appHeight, RGB);
  userImg = createImage(appWidth, appHeight, ALPHA);
  for(int i = 0; i < numMouse; i++) {
    Mouses.add(new Mouse());
  }
  //targets = new ArrayList<PVector>();
  currTargetX = appWidth / 2;
  currTargetY = appHeight / 2;
}

void draw() {
  background(255);
  kinect.update();
  kinectImg = kinect.userImage();
  kinectImg.loadPixels();
  userImg.loadPixels();
  for(int i = 0; i < kinectImg.pixels.length; i++){
    color c = kinectImg.pixels[i];
    if(red(c) == green(c) && red(c) == blue(c) && green(c) == blue(c)){ 
      // background
      userImg.pixels[i] = color(255);
    } else {
      // user
      userImg.pixels[i] = color(0);
    }
  }
  kinectImg.updatePixels();
  userImg.updatePixels();
  image(userImg, 0, 0);
  
  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  //for(int i = targets.size() - 1; i >= 0; i--) {
  //  targets.remove(i);
  //}
  //targets.add(new PVector(width/2, height/2));
  attractor = new PVector(width/4, height/2);
  if(userList.size() > 0) {
   int userId = userList.get(0);
   if(kinect.isTrackingSkeleton(userId)) {
     // if we detect one user we have to draw it
     drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
     //drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
     //drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
     //drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
     PVector leftHand = getJointPos(userId, SimpleOpenNI.SKEL_LEFT_HAND);
     //PVector leftFoot = getJointPos(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
     //PVector rightHand = getJointPos(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
     //PVector rightFoot = getJointPos(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
     //if(leftHand.x != -1) targets.add(leftHand);
     //if(leftFoot.x != -1) targets.add(leftFoot);
     //if(rightHand.x != -1) targets.add(rightHand);
     //if(rightFoot.x != -1) targets.add(rightFoot);
     attractor = getJointPos(userId, SimpleOpenNI.SKEL_HEAD);
     currTargetX = (int)leftHand.x;
     currTargetY = (int)leftHand.y;
   } else {
     currTargetX = width/2;
     currTargetY = height/2;
   }
  }
  
  for(int i = 0; i < numMouse; i++) {
    Mouse m = Mouses.get(i);
    m.setAttractor(attractor);
    m.behavior();
    m.update();
    m.display();
  }
  
  //println(frameRate);
}

void drawJoint(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.5) {
    return;
  }
  PVector convertedJoint = new PVector();
  kinect.convertRealWorldToProjective(joint, convertedJoint);
  convertedJoint.x = convertedJoint.x / kinectWidth * appWidth;
  convertedJoint.y = convertedJoint.y / kinectHeight * appHeight;
  fill(0, 0, 255);
  ellipse(convertedJoint.x, convertedJoint.y, 40, 40);
}

PVector getJointPos(int userId, int jointID) {
  PVector joint = new PVector();
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint);
  if(confidence < 0.5) return new PVector(-1, -1);
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