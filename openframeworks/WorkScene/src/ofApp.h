#pragma once
#include "ofMain.h"
#include "Blob.hpp"

#define WIDTH 1280
#define HEIGHT 720

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
    
    // swirl operation
    ofImage screenImg;
    bool swirlOn;
    
//    KinectOSCReceiver receiver;
};

