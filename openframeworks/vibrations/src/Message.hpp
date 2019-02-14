//
//  Message.hpp
//  vibrations
//
//  Created by Lo Wing Ellen on 2/4/19.
//

#ifndef Message_hpp
#define Message_hpp

#include "ofMain.h"
#include <stdio.h>

class Message {
public:
    Message(){};
    ~Message(){};
    void setup(int x, int y);
    void update();
    void drawMask();
    void drawOutline();
    
    ofVec2f start;
    ofVec2f end;
    ofVec2f pos;
    bool dir; // true: left, false: right
    float increment;
    int size;
    
    int appWidth = 1280;
    int appHeight = 720;
};

#endif /* Message_hpp */
