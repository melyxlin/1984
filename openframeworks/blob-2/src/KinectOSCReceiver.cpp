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

void KinectOSCReceiver::update() {
    while(receiver.hasWaitingMessages()) {
        ofxOscMessage msg;
        receiver.getNextMessage(msg);
        string msgAddr = msg.getAddress();
        size_t addrTagLim = msgAddr.find("/", 1);
        string addrTag = msgAddr.substr(1, addrTagLim-1);
        if(addrTag.compare("kinect") == 0) {
            size_t userIdLim = msgAddr.find("/", addrTagLim+1);
            int userId = stoi(msgAddr.substr(addrTagLim+1, userIdLim));
            if(!userExists(userId)) {
                addUser(userId);
                printf("add user\n");
            }
            size_t jointLim = msgAddr.find("/", userIdLim+1);
            int jointId = stoi(msgAddr.substr(userIdLim+1, jointLim));
            string joint = jointNamesList[jointId];
            
            string msgStr = msg.getArgAsString(0);
            float x = stof(msgStr.substr(0, msgStr.find(",")));
            float y = stof(msgStr.substr(msgStr.find(",")+1,msgStr.find(",", msgStr.find(",")+1)));
            updateUser(userId, jointId, x, y);
            std::cout << addrTag << ":" << userId << ":" << jointId << ":" << joint << " " << x << " " << y << endl;
        }
    }
    
}

void KinectOSCReceiver::draw() {
    for(int i = 0; i < users.size(); i++) {
        User u = users[i];
        drawUser(u.id);
    }
}

void KinectOSCReceiver::addUser(int userId) {
    User u;
    u.setup(userId);
    users.push_back(u);
}

void KinectOSCReceiver::updateUser(int userId, int joint, float x, float y) {
    int i;
    for(i = 0; i < users.size(); i++) {
        int id = users[i].id;
        if(id == userId) break;
    }
    ofVec2f pos(x, y);
    users[i].setJoint(joint, pos);
}

void KinectOSCReceiver::drawUser(int userId) {
    int i;
    for(i = 0; i < users.size(); i++) {
        int id = users[i].id;
        if(id == userId) break;
    }
    User u = users[i];
    ofPushMatrix();
    ofPushStyle();
    ofSetColor(u.color);
    for(i = 0; i < NUM_JOINTS; i++) {
        ofDrawCircle(u.joints[i].x, u.joints[i].y, 5);
    }
    ofPopStyle();
    ofPopMatrix();
}

bool KinectOSCReceiver::userExists(int userId) {
    for(int i = 0; i < users.size(); i++) {
        int id = users[i].id;
        if(id == userId) return true;
    }
    return false;
}


