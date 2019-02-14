//
//  User.cpp
//  blob-2
//
//  Created by Lo Wing Ellen on 2/3/19.
//

#include "User.hpp"

void User::setup(int _id)
{
    ofSeedRandom(_id);
    id = _id;
    color = ofColor(ofRandom(0, 255), ofRandom(0, 255), ofRandom(0, 255));
    for(int i = 0; i < NUM_JOINTS; i++) joints[i] = ofVec2f(10, 0);
}

void User::setJoint(int _joint, ofVec2f _pos)
{
    joints[_joint] = _pos;
}
