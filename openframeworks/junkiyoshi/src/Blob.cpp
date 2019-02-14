//
//  Blob.cpp
//  junkiyoshi
//
//  Created by Lo Wing Ellen on 2/11/19.
//

#include "Blob.hpp"

void Blob::setup() {
    start.x = 0;
    start.y = float(ofGetWindowHeight() + 200.0);
    currPos = start;
    end.x = ofGetWindowWidth();
    end.y = 0;
    numCircles = 12;
    state = 0;
    interpolationFrameInterval = 60.0;
}

void Blob::init(float xPos, bool isLeft) {
    dir = isLeft;
    state = 1;
    initTime = ofGetFrameNum();
    start.x = xPos;
    start.y = float(ofGetWindowHeight() + 200.0);
    end.x = ofRandom(xPos, ofGetWindowWidth());
//    end.x = ofGetWindowWidth()*0.8;
    end.y = ofRandom(0, 600);
    currPos = start;
    jitterSpeed = 0.05;
    xseed = ofRandom(100);
    yseed = ofRandom(100);
}

void Blob::update() {
    if(state == 1 && isEndOfPath(getPos(0))) {
        state = 2;
        interpolationStartTime = ofGetFrameNum();
    } else if( state == 2 && ofGetFrameNum() > (interpolationStartTime + interpolationFrameInterval) ) {
        state = 3;
    } else if( state == 3) {
//        if(jitterSpeed < 0.05) jitterSpeed+=0.001;
    }
}

ofVec2f Blob::getPos(int index) {
    if(state == 0) {
        return start;
    } else if (state == 1) {
        ofVec2f pos;
        float time = 10.0*(ofGetFrameNum() - initTime - index * 3);
        float b = pow(end.y / start.y, 1.0/(end.x - start.x));
        float a = end.y / pow(b, end.x);
        pos.x = time;
        pos.y = a * pow(b, time);
        if(dir) pos.x = ofGetWindowWidth() - time;
        return pos;
    } else if (state == 2) {
        ofVec2f pos;
        float time = 10.0*(ofGetFrameNum() - initTime - index * 3);
        float b = pow(end.y / start.y, 1.0/(end.x - start.x));
        float a = end.y / pow(b, end.x);
        float fract = (ofGetFrameNum() - interpolationStartTime) / interpolationFrameInterval;
        pos.x = time * (1-fract) + end.x * fract;
        pos.y = a * pow(b, time) * (1-fract) + end.y * fract;
        if(dir) pos.x = (ofGetWindowWidth() - time) * (1-fract) + (ofGetWindowWidth() - end.x) * fract;
        return pos;
    } else if (state == 3) {
        float xstep = 80.0;
        float ystep = 40.0;
        // change 0.05 or multiples of index to adjust jittering
        // REPLACE ofGetFrameNum with a ramp
        float x, y;
        if(!dir) {
            x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.x - xstep, end.x + xstep);
            y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
        } else {
            x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, ofGetWindowWidth() - end.x - xstep, ofGetWindowWidth() - end.x + xstep);
            y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
        }
        return ofVec2f(x, y);
    }
}

bool Blob::isEndOfPath(ofVec2f pos) {
    // up or down, left or right
    bool isEnd = false;
    bool isUp = false;
    bool isLeft = dir;
    if(start.y > end.y) {
        isUp = true;
    }
    if((isLeft && isUp && pos.x < end.x && pos.y < end.y)  ||
       (isLeft && !isUp && pos.x < end.x && pos.y > end.y) ||
       (!isLeft && isUp && pos.x > end.x && pos.y < end.y) ||
       (!isLeft && !isUp && pos.x > end.x && pos.y > end.y)
       )
    {
        isEnd = true;
    }
    return isEnd;
}
