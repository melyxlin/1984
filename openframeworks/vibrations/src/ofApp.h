#pragma once

#include "ofMain.h"
#include "Message.hpp"
#include <iostream>
#include <string>

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
        int appWidth = 1280;
        int appHeight = 720;
        
        ofTrueTypeFont font;
        ofTexture strTexture;
        ofFbo strMask;
        string displayStr;
        
        vector<Message> msgs;
};
