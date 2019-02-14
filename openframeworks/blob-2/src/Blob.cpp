//
//  Blob.cpp
//  blob-2
//
//  Created by Lo Wing Ellen on 1/27/19.
//

#include "Blob.hpp"

void Blob::setup(int x_, int y_, float r_, int id_) {
    x = x_;
    y = y_;
    radius = r_;
    id = id_;
}

void Blob::update(float noiseZ, float noiseXY) {
    prevpath = path;
    path.clear();
//    radius += 0.1; // increments vary over time
    for (int deg = 0; deg < 360; deg += 5) {
        ofPoint noise_point = ofPoint(radius * cos(deg * DEG_TO_RAD) + x, radius * sin(deg * DEG_TO_RAD) + y);
        float noise_value = ofMap(ofNoise(noise_point.x * noiseXY, noise_point.y * noiseXY, ofGetFrameNum() * noiseZ + id), 0, 1, 0.5, 1); // default: 0.005, noise gaps decreases (controlled by z)
        ofPoint circle_point = ofPoint(radius * noise_value * cos(deg * DEG_TO_RAD), radius * noise_value * sin(deg * DEG_TO_RAD));
        if(deg == 0) {
            path.newSubPath();
            path.moveTo(circle_point);
        } else {
            path.lineTo(circle_point);
        }
    }
    path.close();
}

void Blob::draw() {
    ofPushMatrix();
    ofTranslate(x, y);
    prevpath.setFilled(false);
    prevpath.setStrokeColor(ofColor(200));
    prevpath.setStrokeWidth(2);
    prevpath.draw();
    path.setFilled(false);
    path.setStrokeColor(ofColor(255));
    path.setStrokeWidth(2);
    path.draw();
    ofPopMatrix();
}

ofPoint Blob::make_rect_point(float len, int deg, int z) {
    
    int half_len = len * 0.5;
    int param = (deg + 45) / 90;
    
    ofPoint point;
    
    switch (param % 4) {
            
        case 0:
            
            return ofPoint(half_len, ofMap((deg + 45) % 90, 0, 89, -half_len, half_len), z);
        case 1:
            
            return  ofPoint(ofMap((deg + 45) % 90, 0, 89, half_len, -half_len), half_len, z);
        case 2:
            
            return ofPoint(-half_len, ofMap((deg + 45) % 90, 0, 89, half_len, -half_len), z);
        case 3:
            
            return ofPoint(ofMap((deg + 45) % 90, 0, 89, -half_len, half_len), -half_len, z);
        default:
            
            return ofPoint(0, 0, 0);
    }
}
