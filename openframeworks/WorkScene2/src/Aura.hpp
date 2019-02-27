//
//  Aura.hpp
//  WorkScene
//
//  Created by Ellen Lo on 2/22/19.
//
//

#ifndef Aura_hpp
#define Aura_hpp

#include <stdio.h>
#include "ofMain.h"

class Aura {
public:
    void setup(int x_, int y_, float r_, int id_);
    void update();
    void draw();
    ofPoint make_rect_point(float len, int deg, int z = 0);
    
    ofPolyline poly;
    ofPath path;
    ofPath prevpath;
    int id;
    int x;
    int y;
    float radius;
    bool triggered;
    bool glowing;
    bool disappear;
    int leaving;
    int triggerTime;
    int triggerColor;
    float noiseZ;
    float noiseXY;
};


#endif /* Aura_hpp */
