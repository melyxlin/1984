class Box {
  Body body;
  float w;
  float h;
  //char s;
  String s;
  Vec2 boundX = new Vec2(0, 0);
  Vec2 boundY = new Vec2(0, 0);

  Box(float x, float y) {
    //s = char(int(random(65, 122)));
    s = slist[slist_it];
    w = 16 * s.length();
    h = 20;
    makeBody(new Vec2(x, y), w, h);
    if(x <= width/2) {
      boundX.x = 0;
      boundX.y = width/2;
    } else {
      boundX.x = width/2;
      boundX.y = width;
    }
    
    if(y <= height/2) {
      boundY.x = 0;
      boundY.y = height/2;
    } else {
      boundY.x = height/2;
      boundY.y = height;
    }
    
    textAlign(CENTER);
    textFont(orwell);
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+w*h) {
      killBody();
      return true;
    }
    return false;
  }
  
  void update() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    Vec2 vel = body.getLinearVelocity();
    if(pos.x > boundX.y || pos.x < boundX.x ) {
      body.setLinearVelocity(new Vec2(vel.x*-1, vel.y));
    } else if ( pos.y > boundY.y || pos.y < boundY.x) {
      body.setLinearVelocity(new Vec2(vel.x, vel.y*-1)); 
    }
    
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(175);
    stroke(0);
    text(s, 0, h/2);
    //noFill();
    //rect(0, 0, w, h);
    popMatrix();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    // Give it some initial random velocity
    body.setLinearVelocity(new Vec2(random(-5, 5), random(-2, 2)));
    body.setAngularVelocity(random(-2, 2));
    body.setGravityScale(0);
    body.setLinearDamping(0);
    body.setAngularDamping(0.5f);
  }
}