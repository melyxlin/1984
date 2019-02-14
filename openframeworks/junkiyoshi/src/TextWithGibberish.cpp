//
//  TextWithGibberish.cpp
//  junkiyoshi
//
//  Created by Lo Wing Ellen on 2/8/19.
//

#include "TextWithGibberish.hpp"

void TextWithGibberish::setup() {
    font.load("Orwell.ttf", 32);
    randomBool = false;
    randomInterval = 1;
    str = lines[0];
    nextStr = lines[1];
}

void TextWithGibberish::update() {
    if(randomBool) {
        int index = int(floor(ofRandom(str.length())));
        if(ofGetElapsedTimef() < (randomStart + randomInterval)) {
            if(ofRandom(1) < 0.3) {
                str = str.substr(0, index) + char((int)ofRandom(33, 126)) + str.substr(index + 1, (int)str.length());
            }
        } else {
            if(str.compare(nextStr) != 0) {
                if(ofRandom(1) < 0.6) {
                    str = str.substr(0, index) + nextStr[index] + str.substr(index+1, (int)str.length());
                }
            } else {
                randomBool = false;
            }
        }
    }
}

void TextWithGibberish::draw() {
    ofPushStyle();
    ofSetColor(0);
    font.drawString(str, 20, ofGetScreenHeight()/2);
//    for (int i = 0; i < int(str.length()); i++) {
//        font.drawString(string(1, str.at(i)), 20 + i*24, ofGetScreenHeight()/2-font.stringHeight(str)/2);
//    }
    ofPopStyle();
}

