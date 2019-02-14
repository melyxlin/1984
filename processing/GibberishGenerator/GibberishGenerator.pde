String lines [] = {"times 17.3.84 bb speech malreported africa rectify",
                        "times 19.12.83 forecasts 3 yp 4th quarter 83 misprints verify current issue",
                        "times 14.2.84 miniplenty malquoted chocolate rectify",
                        "times three period twelve period eighty-three reporting bb day order"
    };

String str = lines[0];
String secondStr = lines[1];
boolean random;
int start;
int interval;

void setup() {
  size(600, 600);
  textSize(20);
  random = false;
  interval = 1000;
}

void draw() {
  background(150);
  fill(0);
  
  // randomizing string content
  if(random) {
    if(millis() < (start + interval)) {
      int index = int(random(0, str.length()));
      if(random(1) < 0.1) {
        str = str.substring(0, index) + char(int(random(33, 126))) + str.substring(index+1, str.length());
      } 
    } else {
      int index = int(random(0, str.length()));
      if(random(1) < 0.6) {
        str = str.substring(0, index) + secondStr.charAt(index) + str.substring(index+1, str.length());
      }
    }
  } 
  
  // transitioning into next text
  
  
  // drawing text char by char
  int heightCounter = 20;
  int widthCounter = 0;
  for(int i = 0; i < str.length(); i++){
    text(str.charAt(i), widthCounter*20, heightCounter);
    if(widthCounter*20 > width) {
      widthCounter=0;
      heightCounter += 20;
    } else {
      widthCounter++;
    }
  }
  
  text(int(frameRate), width-40, 20);
}

void keyPressed() {
  random = true;
  start = millis();
}

void mousePressed() {
  random = false;
  str = lines[0];
}