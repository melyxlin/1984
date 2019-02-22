#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {

	ofSetFrameRate(60);
	ofSetWindowTitle("openframeworks");

	number_of_targets = 180;
    num_of_circles_per_target = 6;
	for (int i = 0; i < number_of_targets; i++) {
		this->targets.push_back(glm::vec2());
	}
    
    msgIter = 0;
    for (int i = 0; i < number_of_targets/num_of_circles_per_target; i++) {
        Blob b;
        b.setup();
        b.numCircles = num_of_circles_per_target;
        msgBlobs.push_back(b);
    }
    
	this->shader.load("shader/shader.vert", "shader/shader.frag");
    vid.load("text.mp4");
    vid.play();
    
    receiver.setup();
}
//--------------------------------------------------------------
void ofApp::update() {

    vid.update();
    float triggerPos = receiver.update();
    
    if(triggerPos >= 0){
        float blobPos = triggerPos;
        bool dir = false;
        if(triggerPos > WIDTH/2) {
            blobPos = abs(triggerPos - WIDTH);
            dir = true;
        }
        if(msgIter < number_of_targets/num_of_circles_per_target) {
            msgBlobs[msgIter].init(blobPos, dir);
            printf("start xpos: %f, end: (%f, %f)\n", blobPos, msgBlobs[msgIter].end.x, msgBlobs[msgIter].end.y);
            msgIter++;
        } else {
            msgIter = 0;
        }
    }
    
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
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    this->shader.begin();
    this->shader.setUniform1f("time", ofGetElapsedTimef());
    this->shader.setUniform2f("resolution", ofGetWidth(), ofGetHeight());
    this->shader.setUniformTexture("tex0", vid.getTexture(), 1);
    this->shader.setUniform2fv("targets", &this->targets[0].x, this->number_of_targets);
    ofBackground(0);
    ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
    vid.draw(0, 0, ofGetWidth(), ofGetHeight());
    this->shader.end();
    ofDrawBitmapString(ofToString((int)ofGetFrameRate()), 700, 700);
}

void ofApp::mousePressed(int x, int y, int button) {
    if(vid.isPlaying()) vid.stop();
    else vid.play();
}

void ofApp::keyPressed(int key) {
    
    if(key == 'r') {
        // reset
        for(int i = 0; i < msgBlobs.size(); i++) {
            msgBlobs[i].setup();
        }
    } else if (key == 't') {
        ofToggleFullscreen();
    } else if (key == 'x') {
        screenImg.grabScreen(0, 0, WIDTH, HEIGHT);
        screenImg.save("screen.png");
    } else {
        if(msgIter < number_of_targets/num_of_circles_per_target) {
            float xpos = ofRandom(1, WIDTH/2);
            float dir = ofRandom(1) < 0.5 ? true : false;
            msgBlobs[msgIter].init(xpos, dir);
            printf("start xpos: %f, end: (%f, %f)\n", xpos, msgBlobs[msgIter].end.x, msgBlobs[msgIter].end.y);
            msgIter++;
        } else {
            msgIter = 0;
        }
    }
}
