//
//  KinectOSCReceiver.cpp
//  blob-2
//
//  Created by Lo Wing Ellen on 2/2/19.
//

#include "KinectOSCReceiver.hpp"

void KinectOSCReceiver::setup() {
    receiver.setup(PORT);
}

float KinectOSCReceiver::update() {
    float triggerPos = -1.0;
    while(receiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        receiver.getNextMessage(msg);
        string msgAddr = msg.getAddress();
        size_t addrTagLim = msgAddr.find("/", 1);
        string addrTag = msgAddr.substr(1, addrTagLim-1);
        if(addrTag.compare("kinect") == 0) {
            float xPos = msg.getArgAsFloat(0);
            if(xPos > 0) {
                triggerPos = xPos;
            }
        }
    }
    return triggerPos;
}
