#pragma once

#include <stdio.h>
#include <string.h>
#include "ofMain.h"
#include "ofxGui.h"
#include "Blob.hpp"
#include "KinectOSCReceiver.hpp"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
        void mousePressed(int x, int y, int button);
        void keyPressed(int key);

        ofxPanel gui;
        ofxFloatSlider noiseZCtrl;
        ofxFloatSlider noiseXYCtrl;
    
        KinectOSCReceiver receiver;
    
        vector<Blob> blobs;
        ofPoint actors[7];
        int numActors = 7;
};
