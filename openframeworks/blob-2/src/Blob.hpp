//
//  Blob.hpp
//  blob-2
//
//  Created by Lo Wing Ellen on 1/27/19.
//

#include <stdio.h>
#include "ofMain.h"
#include "ofxGui.h"

#ifndef Blob_hpp
#define Blob_hpp

class Blob {
    public:
        void setup(int x_, int y_, float r_, int id_);
        void update(float noiseZ, float noiseXY);
        void draw();
        ofPoint make_rect_point(float len, int deg, int z = 0);
    
        ofPolyline poly;
        ofPath path;
        ofPath prevpath;
        int id;
        int x;
        int y;
        float radius;
//        float noise_value;
    };

#endif /* Blob_hpp */
