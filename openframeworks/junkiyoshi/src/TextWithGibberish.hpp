//
//  TextWithGibberish.hpp
//  junkiyoshi
//
//  Created by Lo Wing Ellen on 2/8/19.
//

#ifndef TextWithGibberish_hpp
#define TextWithGibberish_hpp

#include <stdio.h>
#include <string>
#include "ofMain.h"

class TextWithGibberish {
public:
    void setup();
    void update();
    void draw();
    
    ofTrueTypeFont font;
    string str = "Lorem ipsum";
    string nextStr = "Nulla suscipit";
    bool randomBool;
    float randomStart;
    float randomInterval;
    string lines [4] = {"times 17.3.84 bb speech malreported africa rectify",
                        "times 19.12.83 forecasts 3 yp 4th quarter 83 misprints verify current issue",
                        "times 14.2.84 miniplenty malquoted chocolate rectify",
                        "times three period twelve period eighty-three reporting bb day order"
    };
};

#endif /* TextWithGibberish_hpp */
