//
//  Blob.hpp
//  junkiyoshi
//
//  Created by Lo Wing Ellen on 2/11/19.
//

#ifndef Blob_hpp
#define Blob_hpp

#include <stdio.h>
#include "ofMain.h"

class Blob {
public:
    void setup();
    void init(float xPos, bool isLeft);
    void update();
    ofVec2f getPos(int index);
    bool isEndOfPath(ofVec2f pos);
    
    ofVec2f start;
    ofVec2f end;
    ofVec2f currPos;
    bool dir; // true: going left, false: going right
    float xseed, yseed;
    int numCircles;
    int state; // 0: idle at start, 1: in motion, 2: interpolating, 3: jittering at end
    float initTime;
    float interpolationStartTime;
    float interpolationFrameInterval;
    float jitterSpeed;
};

#endif /* Blob_hpp */
