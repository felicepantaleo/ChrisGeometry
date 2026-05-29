//
//  HXGStructs.h
//  Hex
//
//  Created by seez on 24/10/16.
//  Copyright © 2016 seez. All rights reserved.
//

#ifndef HXGStructs_h
#define HXGStructs_h

struct WRADII
{
    double r;
    int n;
};

struct CENTRES
{
    double r,x,y;
};

struct IBSTATE
{
    int n;
    int layout[10];
    int count[10];
    int state[10];
    int active;
};

#endif /* HXGStructs_h */
