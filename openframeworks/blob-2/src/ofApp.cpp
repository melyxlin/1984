#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
    
    ofSetFrameRate(60);
    ofSetWindowTitle("Blob");
    
    ofBackground(39);
    ofSetColor(239);
    ofEnableBlendMode(ofBlendMode::OF_BLENDMODE_ADD);
    
    gui.setup();
    gui.add(noiseXYCtrl.setup("noiseXY", 0.001, 0.0001, 0.003));
    gui.add(noiseZCtrl.setup("noiseZ", 0.005, 0.0001, 0.1));
    
    receiver.setup();
    
    actors[0] = ofPoint(640, 640, 0);
    actors[1] = ofPoint(200, 250, 0);
    actors[2] = ofPoint(350, 150, 0);
    actors[3] = ofPoint(700, 200, 0);
    actors[4] = ofPoint(850, 200, 0);
    actors[5] = ofPoint(950, 450, 0);
    actors[6] = ofPoint(1100, 450, 0);
    
    for(int i = 0; i < numActors; i++) {
        Blob b;
        b.setup(actors[i].x, actors[i].y, 100, i);
        blobs.push_back(b);
    }
}

//--------------------------------------------------------------
void ofApp::update() {
    
    ofSeedRandom(39);
    receiver.update();
    for(int i = 0; i < blobs.size(); i++) {
        blobs[i].update(noiseZCtrl, noiseXYCtrl);
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    
//    GRADIENT FOR AXISMUNDI
//    ofMesh temp;
//    temp.setMode(OF_PRIMITIVE_TRIANGLE_FAN);
//    float radius = 100;
//    float x = 400;
//    float y = 400;
//    for (int deg = 0; deg < 360; deg += 36) {
//        ofPoint noise_point = ofPoint(radius * cos(deg * DEG_TO_RAD) + x, radius * sin(deg * DEG_TO_RAD) + y);
//        float noise_value = 1;
//        ofPoint circle_point = ofPoint(radius * noise_value * cos(deg * DEG_TO_RAD), radius * noise_value * sin(deg * DEG_TO_RAD));
//        temp.addVertex(circle_point);
//        if(deg / 36 / 2 == 0) temp.addColor(ofColor(119, 210, 175));
//        else if (deg / 36 / 2 == 1) temp.addColor(ofColor(246, 231, 204));
//        else if (deg / 36 / 2 == 2) temp.addColor(ofColor(220, 151, 137));
//        else if (deg / 36 / 2 == 3) temp.addColor(ofColor(167, 195, 140));
//        else if (deg / 36 / 2 == 4) temp.addColor(ofColor(104, 140, 90));
//    }
//    ofPushMatrix();
//    ofTranslate(x, y);
//    temp.draw();
//    ofPopMatrix();
    
    receiver.draw();
    for(int i = 0; i < blobs.size(); i++) {
        blobs[i].draw();
    }
    gui.draw();
    ofDrawBitmapString(ofToString((int)ofGetFrameRate()), 20, 20);
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {
    Blob b;
    b.setup(x, y, 100, blobs.size());
    printf("%d %d\n", x, y);
    blobs.push_back(b);
}

void ofApp::keyPressed(int key) {
    
    if(key == '1') {
        // 1984 mode
        noiseXYCtrl = 0.0025;
        noiseZCtrl = 0.05;
    } else if (key == 'a'){
        // axis mundi mode
        
    } else if (key == 't') {
        ofToggleFullscreen();
    }
}
