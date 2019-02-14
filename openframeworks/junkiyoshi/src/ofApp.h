#pragma once
#include "ofMain.h"
#include "TextWithGibberish.hpp"
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
	vector<glm::vec2> targets;
    vector<Blob> msgBlobs;
	ofShader shader;
    
    TextWithGibberish text;
};
