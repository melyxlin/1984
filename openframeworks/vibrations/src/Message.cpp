//
//  Message.cpp
//  vibrations
//
//  Created by Lo Wing Ellen on 2/4/19.
//

#include "Message.hpp"

void Message::setup(int x, int y){
    increment = 0;
    dir = (ofRandom(1) < 0.5f) ? true : false;
    start.x = x;
    start.y = y;
    pos = start;
    end.x = (dir) ? ofRandom(0, x) : ofRandom(x, appWidth);
    end.y = ofRandom(0, appHeight/2);
    size = 50;
    ofSetCircleResolution(100);
}

void Message::update() {
   increment += 0.01;
   pos.x = start.x * (1.0 - increment) + end.x * increment;
   pos.y = start.y * (1.0 - increment) + end.y * increment;
   size += 1;
}

void Message::drawMask() {
    ofDrawCircle(pos.x, pos.y, size);
}

void Message::drawOutline() {
    ofPushStyle();
    ofSetColor(200);
    ofSetLineWidth(10);
    ofNoFill();
    ofDrawCircle(pos.x, pos.y, size);
    ofPopStyle();
}
