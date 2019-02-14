//
//  KinectOSCReceiver.hpp
//  blob-2
//
//  Created by Lo Wing Ellen on 2/2/19.
//

#ifndef KinectOSCReceiver_hpp
#define KinectOSCReceiver_hpp

#include <stdio.h>
#include <string.h>
#include <iostream>
#include "ofMain.h"
#include "ofxOsc.h"
#include "User.hpp"

#define PORT 8888

class KinectOSCReceiver {
public:
    void setup();
    void update();
    void draw();
    void addUser(int userId);
    void updateUser(int userId, int joint, float x, float y);
    void drawUser(int userId);
    bool userExists(int userId);
    ofxOscReceiver receiver;
    vector<User> users;
    
    string jointNamesList [15] = {"head", "neck", "lShoulder", "rShoulder", "lElbow", "rElbow",
        "lHand", "rHand", "torso", "lHip", "rHip", "lKnee", "rKnee", "lFoot", "rFoot"};
};

#endif /* KinectOSCReceiver_hpp */
