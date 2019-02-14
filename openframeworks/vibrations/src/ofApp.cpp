#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    ofSetFrameRate(60);
    ofBackground(0);
    
    strTexture.allocate(appWidth, appHeight, GL_RGB);
    strMask.allocate(appWidth, appHeight, GL_RGBA);
    font.load("Orwell.ttf", 32);
}

//--------------------------------------------------------------
void ofApp::update(){
    displayStr = "times 17.3.84 bb speech malreported africa rectify";
    for(int i = msgs.size()-1; i >= 0; i--) {
        msgs[i].update();
        if(msgs[i].increment >= 1|| msgs[i].pos.x < 0 || msgs[i].pos.x > appWidth || msgs[i].pos.y < 0 || msgs[i].pos.y > appHeight) {
            msgs.erase(msgs.begin() + i);
        }
    }
    printf("%d\n", (int)msgs.size());
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(255);
    
    // draw outlines of msgs
    for(int i = 0; i < msgs.size(); i++) {
        msgs[i].drawOutline();
    }
    
    // set mask
    ofPushMatrix();
    strMask.begin();
    ofScale(1.0, -1.0);
    ofTranslate(0.0, -appHeight);
    ofClear(0,0,0,0);
    ofSetColor(0);
    for(int i = 0; i < msgs.size(); i++) {
        msgs[i].drawMask();
    }
    strMask.end();
    strTexture.setAlphaMask(strMask.getTexture());
    strTexture.draw(0, 0);
    ofPopMatrix();
    
    
    // draw strings
    ofSetColor(255);
    font.drawString(displayStr, appWidth/2-font.stringWidth(displayStr)/2, appHeight/2-font.stringHeight(displayStr)/2);
    font.drawString(displayStr, appWidth/2-font.stringWidth(displayStr)/2, 100);
    font.drawString(displayStr, appWidth/2-font.stringWidth(displayStr)/2, 600);
    strTexture.loadScreenData(0, 0, appWidth, appHeight);
    
    // frame rate debug
    ofDrawBitmapString(ofToString((int)ofGetFrameRate()), 20, 20);
}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    Message m;
    m.setup(x, y);
    msgs.push_back(m);
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 

}
