String lines[];
String gibberish[];
boolean randoms[];
PFont font;
int start;
int interval;
int margin;

void setup() {
  size(1280, 720);
  //fullScreen();
  pixelDensity(2);
  font = createFont("Inconsolata-Regular.ttf", 24);
  textFont(font);
  textSize(24);
  interval = 1000;
  margin = 20;
  lines = loadStrings("lines.txt");
  gibberish = new String[lines.length];
  randoms = new boolean[lines.length];
  for(int i = 0; i < gibberish.length; i++) {
    gibberish[i] = lines[i]; 
    randoms[i] = false;
  }
}

void draw() {
  background(255);
  fill(0);
  
  
  for(int i = 0; i < lines.length; i++) {
    String str = lines[i];
    if(randoms[i]) {
      if(millis() < (start + interval) ) {
        int index = int(random(0, str.length()));
        if(random(1) < 0.4) {
          gibberish[i] = gibberish[i].substring(0, index) + char(int(random(33, 126))) + gibberish[i].substring(index+1, str.length());
        }
      } else {
        int index = int(random(0, str.length()));
        if(random(1) < 0.8) {
          gibberish[i] = gibberish[i].substring(0, index) + str.charAt(index) + gibberish[i].substring(index+1, str.length());
        }
      }
    }
  }
  
  
  // drawing text char by char
  //int heightCounter = 20;
  //int widthCounter = 0;
  for(int j = 0; j < gibberish.length; j++) {
    int heightCounter = 20;
    int widthCounter = 0;
    for(int i = 0; i < gibberish[j].length(); i++){
      int linespacing = j*40;
      //int linespacing = 0;
      text(gibberish[j].charAt(i), widthCounter*20+margin, linespacing + heightCounter+margin);
      if(widthCounter*20+margin*2 > width) {
        widthCounter=0;
        heightCounter += 20;
      } else {
        widthCounter++;
      }
    }
  }
  
  //saveFrame("frames/####.png");
  //text(int(frameRate), width-40, 20);
}

void keyPressed() {
  for(int i = 0; i < lines.length; i++) {
    randoms[i] = random(1) < 0.5 ? true : false; 
  }
  start = millis();
}

void mousePressed() {
  for(int i = 0; i < lines.length; i++) {
    randoms[i] = false; 
  }
}
