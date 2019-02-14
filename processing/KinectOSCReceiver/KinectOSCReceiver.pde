import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress loc;

void setup() {
  size(200, 200);
  oscP5 = new OscP5(this, 8888);
  loc = new NetAddress("127.0.0.1", 12000);
}

void draw() {
}

void oscEvent(OscMessage msg) {
  String msgAddr = msg.addrPattern();
  String [] msgAddrList = msgAddr.split("/");
  if(msgAddrList[1].equals("kinect")) {
    int userId = int(msgAddrList[2]);
    String jointId = msgAddrList[3];
    String msgStr = msg.get(0).stringValue();
    float [] msgStrList = float(msgStr.split(","));
    float x = msgStrList[0];
    float y = msgStrList[1];
    println("user: " + userId + " jointId: " + jointId + " pos: (" + x + "," + y + ")");
  }
}