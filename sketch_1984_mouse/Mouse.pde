class Mouse {
  float length;
  float weight;
  float ang;
  float t;
  float maxspeed, maxforce;
  PVector pos, vel, acc;
  boolean attract;
  PVector attractor = new PVector(width/2, height/2); 
  int Y_AXIS = 1;
  int X_AXIS = 2;

  Mouse() {
    pos = new PVector(random(10, width-10), random(10, height-10));
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    length = random(30, 50);
    weight = random(0.5, 3);
    t = random(5);
    maxspeed = random(4, 10);
    maxforce = 0.5;
    attract = true;
  }
  
  void update(){
    
    //Apply attract/repel force
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    
    t+=random(3);
  }
  
  void behavior() {
   PVector attract = attract(attractor);
   PVector target = targets.get(0);
   if(targets.size() > 1) {
     float minDist = 3000;
     int minIndex = 1;
     for(int i = 1; i < targets.size(); i++) {
       float dist = pos.dist(targets.get(i));
       if(dist < minDist) {
         minDist = dist;
         minIndex = i;
       }
     }
     target.x = int(targets.get(minIndex).x);
     target.y = int(targets.get(minIndex).y);
   }
   PVector flee = flee(target);
   attract.mult(2);
   flee.mult(50);
   applyForce(attract);
   applyForce(flee);
  }
  
  void applyForce (PVector f) {
    acc.add(f);
  }
  
  PVector attract(PVector target) {
    PVector dir = PVector.sub(target, pos);
    float dist = dir.mag();
    float speed = maxspeed;
    if(dist < 300.0) {
      ang = dir.heading() + HALF_PI + map(noise(t), 0.0, 1.0, -0.5, 0.5);
      speed = map(dist, 0, 300, 0, maxspeed); 
    }
    dir.setMag(speed);
    PVector steer = PVector.sub(dir, vel);
    steer.limit(maxforce);
    return steer;
  }
  
  PVector flee(PVector target) {
   PVector dir = PVector.sub(target, pos);
   float dist = dir.mag();
   //println(dist);
   if(dist < 200.0) {
     ang = dir.heading() + HALF_PI + map(noise(t), 0.0, 1.0, -0.5, 0.5);
     dir.setMag(maxspeed);
     dir.mult(-1);
     PVector steer = PVector.sub(dir, vel);
     steer.limit(maxforce);
     return steer;
   } else {
     return new PVector(0,0);
   }
  }
  
  void setAttractor(PVector attractorPos) {
    attractor.x = attractorPos.x;
    attractor.y = attractorPos.y;
  }
  
  void display(){
    strokeWeight(weight);
    stroke(0);
    pushMatrix();
    translate(pos.x, pos.y);
    // set gradient here!
    rotate(ang);
    line(0, 0, 0, length);
    //drawLine(0, 0, int(length), int(length), color(0, 0, 0), color(255, 0, 0), 60); 
    fill(255, 0, 0);
    popMatrix();
  }
  
  void drawLine(int x_s, int y_s, int x_e, int y_e, int col_s, int col_e, int steps) {
    float[] xs = new float[steps];
    float[] ys = new float[steps];
    color[] cs = new color[steps];
    for (int i=0; i<steps; i++) {
      float amt = (float) i / steps;
      xs[i] = lerp(x_s, x_e, amt) + amt * (noise(frameCount * 0.01 + amt) * 200 - 100);
      ys[i] = lerp(y_s, y_e, amt) + amt * (noise(2 + frameCount * 0.01 + amt) * 200 - 100);
      cs[i] = lerpColor(col_s, col_e, amt);
    }
    for (int i=0; i<steps-1; i++) {
      stroke(cs[i]);
      line(xs[i], ys[i], xs[i+1], ys[i+1]);
    }
  }
  
  
}