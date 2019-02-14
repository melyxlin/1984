//
//  User.hpp
//  blob-2
//
//  Created by Lo Wing Ellen on 2/3/19.
//

#ifndef User_hpp
#define User_hpp

#include <stdio.h>
#include "ofMain.h"

#define NUM_JOINTS 15

class User {
public:
    void setup(int _id);
    void setJoint(int _joint, ofVec2f _pos);
    
    int id;
    ofColor color;
    ofVec2f joints [15];
};

#endif /* User_hpp */
