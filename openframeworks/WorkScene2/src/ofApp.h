#pragma once
#include "ofMain.h"
#include "ofxShadertoy.h"
#include "Blob.hpp"
#include "Aura.hpp"

class ofApp : public ofBaseApp {
    
public:
    void setup();
    void update();
    void draw();
    void mousePressed(int x, int y, int button);
    void keyPressed(int key);
    
    int number_of_targets;
    int num_of_circles_per_target;
    int msgIter;
    vector<glm::vec2> targets;
    vector<Blob> msgBlobs;
    ofShader shader;
    ofVideoPlayer vid;
    ofTexture vidTexture;
    
    // slow mode variables
    bool slowMode;
    bool blobEnlargeMode;
    float blobRadiusScale;
    
    // aura variables
    ofPoint actors[7];
    Aura auras[6];
    int numAuras = 6;
};

