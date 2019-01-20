Mouse m;
ArrayList<Mouse> Mouses = new ArrayList<Mouse>();
int numMouse = 100;
int prevMouseX, prevMouseY;

void setup() {
  size(600, 600);
  background(255);
  for(int i = 0; i < numMouse; i++) {
    Mouses.add(new Mouse());
  }
}

void draw() {
  background(255);
  for(int i = 0; i < numMouse; i++) {
    Mouse m = Mouses.get(i);
    m.behavior();
    m.update();
    m.display();
  }
  prevMouseX = mouseX;
  prevMouseY = mouseY;
  
  println(frameRate);
}