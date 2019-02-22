PFont font;
String[] lines;
PGraphics pg;
//String line = "times 14.2.84 miniplenty malquoted chocolate rectify times 14.2.84 miniplenty malquoted chocolate rectify times 14.2.84 miniplenty malquoted chocolate rectify";
String line = "TIMES 14.2.84 MINIPLENTY MALQUOTED CHOCOLATE RECTIFY TIMES 14.2.84 MINIPLENTY MALQUOTED CHOCOLATE RECTIFY TIMES 14.2.84 MINIPLENTY MALQUOTED CHOCOLATE RECTIFY";

int cols, rows;
int xscl = 20;
int yscl = 20;
int w, h;
int x = 0;
int y = 0;
float[][] terrain;
float flying;

void setup() {
  size(1280, 720, P3D);
  pixelDensity(2);
  background(255);
  fill(0);
  frameRate(60);
  w = 1280;
  h = 720;
  cols = w / xscl;
  rows = h / yscl;
  terrain = new float[cols][rows];
  flying = 0;
  font = createFont("AvenirNext-Regular-64.vlw", 64);
  textFont(font);
  smooth();
  lines = loadStrings("script.txt");
  pg = createGraphics(800, 800);
}

void draw() {
  background(255);
  fill(0);
  
  float yoff = 0;
  for(int y = 0; y < rows; y++) {
    float xoff = 0;
    for(int x = 0; x < cols; x++) {
      float sine = sin(3 * xoff);
      if(sine < 0) sine *= -1;
      terrain[x][y] = abs(map(pow(sine, 0.1), 0, 1, 0, 100)); // read architecture book
      xoff += 0.1;
    }
    yoff += 0.1;
  }
  
  noStroke();
  noFill();
  
  pg.beginDraw();
  pg.smooth();
  pg.textAlign(CENTER);
  pg.background(255);
  pg.fill(0);
  pg.textFont(font, 16);
  for(int i = -10; i < 10; i++) {
    pg.text(line, flying*50, pg.height/2 + i*50);
  }
  pg.endDraw();
  
  textureMode(NORMAL);
  for(int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    texture(pg);
    //stroke(0);
    for(int x = 0; x < cols; x++) {
      vertex(x * xscl, y * yscl, terrain[x][y], float(x) / float(cols-1), float(y) / float(rows-1));
      vertex(x * xscl, (y+1) * yscl, terrain[x][y+1], float(x) / float(cols-1), float(y+1) / float(rows-1));
    }
    endShape();
  }
  
  flying -= .01;
  
}
