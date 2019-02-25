PFont font;
String lines[];
String line = "TIMES 14.2.84 MINIPLENTY MALQUOTED CHOCOLATE RECTIFY";
String displayStr = "";
int lineIt;
int charIt;

void setup() {
  size(1778, 800);
  pixelDensity(2);
  background(255);
  fill(0);
  frameRate(30);
  smooth();
  font = createFont("Inconsolata-Regular.ttf", 64);
  textFont(font);
  textSize(32);
  lines = loadStrings("lines.txt");
  lineIt = 0;
  charIt = 0;
}

void draw() {
  background(255);
  if(random(1) < 0.85) displayStr += lines[lineIt].charAt(charIt);
  else displayStr += char(int(random(33, 126)));
  for(int y = 40; y < height; y += 40) {
    int x = int(random(0, width));
    if(y == 280) x = width/2 - displayStr.length()*8;
    text(displayStr, x, y); 
  }
  
  charIt++;
  if(charIt == lines[lineIt].length()-1 ) {
    charIt = 0;
    displayStr = "";
  }
  
  if(lineIt == lines.length-1) {
    lineIt = 0;
    displayStr = "";
  }
}

void keyPressed() {
  lineIt++;
  charIt = 0;
  displayStr = "";
}
