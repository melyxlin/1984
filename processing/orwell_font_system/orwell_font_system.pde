import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Box2DProcessing box2d;

ArrayList<Box> boxes;

PFont orwell;
PGraphics pg;

String [] news = {"times 17.3.84 bb speech malreported africa rectify", 
                  "times 19.12.83 forecasts 3 yp 4th quarter 83 misprints verify current issue",
                  "times 14.2.84 miniplenty malquoted chocolate rectify",
                  "times three period twelve period eighty-three reporting bb day order"
};

String s = join(news, " ");

String[] slist;
int slist_it;
int w, h;

void setup() {
  size(600, 600, P3D);
  smooth();
  
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  boxes = new ArrayList<Box>();
  orwell = createFont("Orwell.ttf", 32);
  w = 600;
  h = 600;
  //pg = createGraphics(w, h);
  slist = split(s, ' ');
  slist_it = 0;
}



void draw() {
  background(255);
  //pg.beginDraw();
  //pg.textAlign(CENTER);
  //pg.background(255);
  //pg.fill(0);
  //pg.textFont(orwell);
  //pg.text(s, pg.width/2, pg.height/2);
  //pg.endDraw();
  
  //image(pg, 0, 0);
  
  box2d.step();
  
  if(slist_it < slist.length) {
    if(random(1) < 0.1) {
      Box p = new Box(random(width), random(height));
      boxes.add(p);
      slist_it++;
    }
  } else {
   slist_it = 0; 
  }
  
  
  for(Box b: boxes) {
    b.update();
    b.display();
  }
  
  for (int i = boxes.size()-1; i >= 0; i--) {
    Box b = boxes.get(i);
    if (b.done()) {
      boxes.remove(i);
    }
  }
  
  println(frameRate);
}