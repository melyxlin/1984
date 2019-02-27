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
    pos = new PVector(random(10, width-10), random(10, height-10));
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    length = random(30, 50);
    weight = random(0.5, 3);
    t = random(5);
    attractSpeed = 1;
    maxspeed = 10;
    maxforce = 0.5;
    steps = int(random(8, 20));
    attract = true;
    id = _id;
    state = 0;
    jitter = 0.1;
  }
  
  void update(){
    
    // Update state
    float dist = pos.dist(attractor);
    if(dist > 200.0) {
      state = 0;
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
      jitter = 0.5;
      steps = 0;
      attractSpeed = map(frameRate, 0, 60, 20, 3);
    } else if (state == 1) {
      length = 50;
      jitter = 0.5;
      steps = 5;
      attractSpeed = map(frameRate, 0, 60, 24, 4);
    } else if (state == 2) {
      length = 60;
      jitter = 0.5;
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
  
  void attractBehavior() {
    PVector attract = attract(attractor);
    attract.mult(30); // CHANGE HERE FOR RATS ATTRACT SPEED
    applyForce(attract);
  }
  
  void fleeBehavior() {
    PVector flee = flee(attractor);
    flee.mult(400); // CHANGE HERE FOR RATS REPEL SPEED
    applyForce(flee);
  }
  
  void applyForce (PVector f) {
    acc.add(f);
  }
  
  PVector attract(PVector target) {
    PVector dir = PVector.sub(target, pos);
    float speed = attractSpeed;
    ang = dir.heading() + HALF_PI + map(noise(t), 0.0, 1.0, -jitter, jitter); 
    dir.setMag(speed);
    PVector steer = PVector.sub(dir, vel);
    steer.limit(maxforce);
    return steer;
  }
  
  PVector flee(PVector target) {
   PVector dir = PVector.sub(target, pos);
   float dist = dir.mag();
   if(readyMode) {
     if(dist < width/2) {
       ang = dir.heading() + HALF_PI + map(noise(t), 0.0, 1.0, -jitter, jitter);
       dir.setMag(maxspeed);
       dir.mult(-1);
       PVector steer = PVector.sub(dir, vel);
       steer.limit(maxforce);
       return steer;
     } else {
       return new PVector(0, 0); 
     }
   } else {
     ang = dir.heading() + HALF_PI + map(noise(t), 0.0, 1.0, -jitter, jitter);
     dir.setMag(maxspeed);
     dir.mult(-1);
     PVector steer = PVector.sub(dir, vel);
     steer.limit(maxforce);
     return steer;
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
    rotate(ang);
    if(state == 0) line(0, 0, 0, length);
    else if (state == 1) drawLine(0, 0, 0, int(length), color(0, 0, 0), color(255, 0, 0), 3);
    else if (state == 2) drawLine(0, 0, 0, int(length), color(0, 0, 0), color(255, 0, 0), 10);
    else if (state == 3) drawLine(0, 0, 0, int(length), color(0, 0, 0), color(255, 0, 0), 20);
    fill(255, 0, 0);
    popMatrix();
  }
  
  void drawLine(int x_s, int y_s, int x_e, int y_e, int col_s, int col_e, int steps) {
    float[] xs = new float[steps];
    float[] ys = new float[steps];
    color[] cs = new color[steps];
    for (int i=0; i<steps; i++) {
      float amt = (float) i / steps;
      xs[i] = lerp(x_s, x_e, amt) + amt * (noise(frameCount * 0.01 + amt + id) * 200 - 100);
      ys[i] = lerp(y_s, y_e, amt) + amt * (noise(2 + frameCount * 0.01 + amt + id) * 200 - 100);
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