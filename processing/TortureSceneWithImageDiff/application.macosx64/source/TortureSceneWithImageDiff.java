import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 
import org.openkinect.tests.*; 
import gab.opencv.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TortureSceneWithImageDiff extends PApplet {








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

public void setup() {
  //size(1200, 1080);
  
  //pixelDensity(2);
  frameRate(20);
  background(255);
  fill(0);
  
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

public void draw() {
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
        int diffpix = diff.pixels[index];
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
    if(random(1) < 0.5f) invert = !invert;
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

public void updateMouses() {
  for(int i = mouses.size() - 1; i >= 1; i--) {
    if(mouses.get(i).pos.x < -100 || mouses.get(i).pos.x > width+100 || mouses.get(i).pos.y < -100 || mouses.get(i).pos.y > height+100) {
      mouses.remove(i);
    }
  }
  
  if(mouses.size() < numMouse && !repel) {
    mouses.add(new Mouse(mouses.size()));
  }
}

public void keyPressed() {
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
class Mouse {
  float length;
  float weight;
  float ang;
  float t;
  float attractSpeed;
  float maxspeed, maxforce;
  int steps;
  PVector pos, vel, acc;
  boolean attract;
  //PVector attractor = random(1) < 0.5 ? new PVector(width/2, height/4) : new PVector(width/2, height/2); 
  PVector attractor = new PVector(width/2, random(height/2 - 200, height/2 + 200));
  int id;
  int state;
  float jitter;

  Mouse(int _id) {
    pos = new PVector(random(0, width), random(0, height));
    if(pos.x > width/4 && pos.x < width/4*3) {
      if(pos.y < height/2) pos.y = -10;
      else pos.y = height+10;
    }
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    length = random(30, 50);
    weight = random(0.5f, 3);
    t = random(5);
    attractSpeed = 1;
    maxspeed = 10;
    maxforce = 0.5f;
    steps = PApplet.parseInt(random(8, 20));
    attract = true;
    id = _id;
    state = 0;
    jitter = 0.1f;
  }
  
  public void update(){
    
    // Update state
    float dist = pos.dist(attractor);
    if(dist > 200.0f) {
      state = 0;
      //if(dist > width/2*0.9 && dist < width/2) state = 4;
    } else if (dist > 100 && dist <= 200) {
      state = 1; 
    } else if (dist > 20 && dist <= 100) {
      state = 2; 
    } else {
      state = 3; 
    }
    
    // Update lengths depending on states
    if(state == 0) {
      length = random(30, 50);
      jitter = 0.5f;
      steps = 0;
      attractSpeed = map(frameRate, 0, 60, 20, 3);
    } else if (state == 1) {
      length = 50;
      jitter = 0.5f;
      steps = 5;
      attractSpeed = map(frameRate, 0, 60, 24, 4);
    } else if (state == 2) {
      length = 60;
      jitter = 0.5f;
      steps = 20;
      attractSpeed = map(frameRate, 0, 60, 30, 7);
    } else if (state == 3) {
      length = 80;
      jitter = 5;
      steps = 30;
      attractSpeed = map(frameRate, 0, 60, 40, 10);;
    } 
    
    //Apply attract/repel force
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    
    t+=random(3);
  }
  
  public void attractBehavior() {
    PVector attract = attract(attractor);
    attract.mult(30); // CHANGE HERE FOR RATS ATTRACT SPEED
    applyForce(attract);
  }
  
  public void fleeBehavior() {
    PVector flee = flee(attractor);
    flee.mult(400); // CHANGE HERE FOR RATS REPEL SPEED
    applyForce(flee);
  }
  
  public void applyForce (PVector f) {
    acc.add(f);
  }
  
  public PVector attract(PVector target) {
    PVector dir = PVector.sub(target, pos);
    float speed = attractSpeed;
    ang = dir.heading() + HALF_PI + map(noise(t), 0.0f, 1.0f, -jitter, jitter); 
    dir.setMag(speed);
    PVector steer = PVector.sub(dir, vel);
    steer.limit(maxforce);
    return steer;
  }
  
  public PVector flee(PVector target) {
   PVector dir = PVector.sub(target, pos);
   ang = dir.heading() + HALF_PI + map(noise(t), 0.0f, 1.0f, -jitter, jitter);
   dir.setMag(maxspeed);
   dir.mult(-1);
   PVector steer = PVector.sub(dir, vel);
   steer.limit(maxforce);
   return steer;
  }
  
  public void setAttractor(PVector attractorPos) {
    attractor.x = attractorPos.x;
    attractor.y = attractorPos.y;
  }
  
  public void display(){
    strokeWeight(weight);
    stroke(0);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(ang);
    if(state == 0) line(0, 0, 0, length);
    else if (state == 1) drawLine(0, 0, 0, PApplet.parseInt(length), color(0, 0, 0), color(255, 0, 0), 3);
    else if (state == 2) drawLine(0, 0, 0, PApplet.parseInt(length), color(0, 0, 0), color(255, 0, 0), 10);
    else if (state == 3) drawLine(0, 0, 0, PApplet.parseInt(length), color(0, 0, 0), color(255, 0, 0), 20);
    fill(255, 0, 0);
    popMatrix();
  }
  
  public void drawLine(int x_s, int y_s, int x_e, int y_e, int col_s, int col_e, int steps) {
    float[] xs = new float[steps];
    float[] ys = new float[steps];
    int[] cs = new int[steps];
    for (int i=0; i<steps; i++) {
      float amt = (float) i / steps;
      xs[i] = lerp(x_s, x_e, amt) + amt * (noise(frameCount * 0.01f + amt + id) * 200 - 100);
      ys[i] = lerp(y_s, y_e, amt) + amt * (noise(2 + frameCount * 0.01f + amt + id) * 200 - 100);
      //xs[i] = lerp(x_s, x_e, amt);
      //ys[i] = lerp(y_s, y_e, amt);
      cs[i] = lerpColor(col_s, col_e, amt);
    }
    for (int i=0; i<steps-1; i++) {
      stroke(cs[i]);
      line(xs[i], ys[i], xs[i+1], ys[i+1]);
    }
  }
}
  public void settings() {  fullScreen();  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TortureSceneWithImageDiff" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
