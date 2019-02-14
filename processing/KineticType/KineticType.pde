PFont font;
String[] textData;
int textDataLen;

void setup() {
  size(640, 360);
  background(0);
  fill(255);
  font = createFont("Inconsolata-Regular.ttf", 10);
  smooth();
  String[] lines = loadStrings("script.txt");
  String joinedText = join(lines, " ");
  joinedText = joinedText.replaceAll("_", "");
  textData = splitTokens(joinedText, " ¬ª¬´‚Äì_-–().,;:?!\u2014\"");
  textDataLen = textData.length;
  
}

void draw() {
  
}