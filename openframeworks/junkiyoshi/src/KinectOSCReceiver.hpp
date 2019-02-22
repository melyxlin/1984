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

#define PORT 8888

class KinectOSCReceiver {
public:
    void setup();
    float update();
    ofxOscReceiver receiver;
    
    string jointNamesList [15] = {"head", "neck", "lShoulder", "rShoulder", "lElbow", "rElbow",
        "lHand", "rHand", "torso", "lHip", "rHip", "lKnee", "rKnee", "lFoot", "rFoot"};
};

#endif /* KinectOSCReceiver_hpp */
