//
//  Blob.cpp
//  junkiyoshi
//
//  Created by Lo Wing Ellen on 2/11/19.
//

#include "Blob.hpp"

void Blob::setup() {
    start.x = 0;
    start.y = float(ofGetWindowHeight() + 80.0);
    currPos = start;
    end.x = ofGetWindowWidth();
    end.y = 0;
    state = 0;
    interpolationFrameInterval = 60.0;
    moveSpeed = 20.0;
    indexIncrement = 0.2;
}

void Blob::init(float xPos, bool isLeft) {
    dir = isLeft;
    state = 1;
    initTime = ofGetFrameNum();
    start.x = xPos;
    start.y = float(ofGetWindowHeight() + 200.0);
    end.x = ofRandom(xPos+400, ofGetWindowWidth());
    end.y = ofRandom(20, ofGetWindowHeight()*0.9);
    currPos = start;
    jitterSpeed = ofMap(ofGetFrameRate(), 0, 60, 0.1, 0.05);
    xseed = ofRandom(100);
    yseed = ofRandom(100);
}

void Blob::update() {
    if(state == 1 || state == 2) {
        moveSpeed = ofMap(ofGetFrameRate(), 0, 40, 80, 30);
        indexIncrement = 0.2;
    } else {
        indexIncrement = 1.0;
    }
    if(state == 1 && isEndOfPath(getPos(0))) {
        state = 2;
        interpolationStartTime = ofGetFrameNum();
    } else if( state == 2 && ofGetFrameNum() > (interpolationStartTime + interpolationFrameInterval) ) {
        state = 3;
    } 
}

ofVec2f Blob::getPos(int index) {
    ofVec2f pos;
    if(state == 0) {
        pos = start;
    } else if (state == 1) {
        float time = moveSpeed*(ofGetFrameNum() - initTime - index * indexIncrement);
        float b = pow(end.y / start.y, 1.0/(end.x - start.x));
        float a = end.y / pow(b, end.x);
        pos.x = time;
        pos.y = a * pow(b, time);
        if(dir) pos.x = ofGetWindowWidth() - time;
    } else if (state == 2) {
        float time = moveSpeed*(ofGetFrameNum() - initTime - index * indexIncrement);
        float b = pow(end.y / start.y, 1.0/(end.x - start.x));
        float a = end.y / pow(b, end.x);
        pos.x = time;
        pos.y = a * pow(b, time);
        if(dir) pos.x = ofGetWindowWidth() - time;
        if(isEndOfPath(pos)) {
            if(!dir) {
                pos.x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.x - xstep, end.x + xstep);
                pos.y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
            } else {
                pos.x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, ofGetWindowWidth() - end.x - xstep, ofGetWindowWidth() - end.x + xstep);
                pos.y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
            }
        }
    } else if (state == 3) {
        // change 0.05 or multiples of index to adjust jittering
        // REPLACE ofGetFrameNum with a ramp
        if(!dir) {
            pos.x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.x - xstep, end.x + xstep);
            pos.y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
        } else {
            pos.x = ofMap(ofNoise(xseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, ofGetWindowWidth() - end.x - xstep, ofGetWindowWidth() - end.x + xstep);
            pos.y = ofMap(ofNoise(yseed, jitterSpeed*(ofGetFrameNum() - index*1)), 0, 1, end.y - ystep, end.y + ystep);
        }
    }
    return pos;
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
