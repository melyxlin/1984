#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {

	ofSetFrameRate(60);
	ofSetWindowTitle("openframeworks");

	number_of_targets = 72;
    num_of_circles_per_target = 8;
	for (int i = 0; i < number_of_targets; i++) {
		this->targets.push_back(glm::vec2());
	}
    
    for (int i = 0; i < number_of_targets/num_of_circles_per_target; i++) {
        Blob b;
        b.setup();
        msgBlobs.push_back(b);
    }
    
	this->shader.load("shader/shader.vert", "shader/shader.frag");
    text.setup();
}
//--------------------------------------------------------------
void ofApp::update() {

    text.update();
    
    for(int i = 0; i < msgBlobs.size(); i++) {
        Blob b = msgBlobs[i];
        msgBlobs[i].update();
        for(int j = 0; j < num_of_circles_per_target; j++) {
            int x, y;
            ofVec2f pos = msgBlobs[i].getPos(j);
            x = int(pos.x);
            y = int(pos.y);
            this->targets[i*num_of_circles_per_target+j] = glm::vec2(x, y);
        }
//        printf("%d %d, ", i, b.state);
    }
//    printf("\n");
}

//--------------------------------------------------------------
void ofApp::draw() {
    this->shader.begin();
    this->shader.setUniform1f("time", ofGetElapsedTimef());
    this->shader.setUniform2f("resolution", ofGetWidth(), ofGetHeight());
    this->shader.setUniform2fv("targets", &this->targets[0].x, this->number_of_targets);
    ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
    this->shader.end();
    
    text.draw();
    ofDrawBitmapString(ofToString((int)ofGetFrameRate()), 700, 700);
}

void ofApp::mousePressed(int x, int y, int button) {
    
}

void ofApp::keyPressed(int key) {
    text.randomBool = true;
    text.randomStart = ofGetElapsedTimef();
    if(key == '0') {
        msgBlobs[0].init(1, false);
    } else if (key == '1') {
        msgBlobs[1].init(100, false);
    } else if (key == '2') {
        msgBlobs[2].init(WIDTH/2, false);
    } else if (key == '3') {
        msgBlobs[3].init(500, false);
    } else if (key == '4') {
        msgBlobs[4].init(100, false);
    } else if (key == '5') {
        msgBlobs[5].init(WIDTH/2, true);
    } else if (key == '6') {
        msgBlobs[6].init(1, true);
    } else if (key == '7') {
        msgBlobs[7].init(150, true);
    } else if (key == '8') {
        msgBlobs[8].init(500, true);
    }
}
