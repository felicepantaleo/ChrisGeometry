//
//  HXGWafer.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGWafer.h"

@implementation HXGWafer

+ (id) waferWithX:(double)x Y:(double)y Side:(double)s ID:(int)i andDetId:(int *)d; {
    HXGWafer * slf = [[HXGWafer  alloc] init];

    [slf setUpWithX:x Y:y Side:s ID:i andDetId:d];
    
    return slf;
}

- (void) setUpWithX:(double)x Y:(double)y Side:(double)s ID:(int)i andDetId:(int *)d {

    _detId = did;           // property * address's tied to class variables
    _corner = cornerPoint;
    
    _ID = i;
    did[0] = d[0]; did[1] = d[1];
    
    side = s;
    _rc = sqrt(x*x+y*y);
    _areaHex = sqrt(6.75)*side*side;

    _xc = x;
    _yc = y;
    
    [self setCorners];

}

- (void) setCorners
{
    double hftof = sqrt(0.75) * side;
    
    xoff[0] = 0.0;       yoff[0] = - side;
    xoff[1] = hftof;     yoff[1] = - side/2.0;
    xoff[2] = hftof;     yoff[2] = + side/2.0;
    xoff[3] = 0.0;       yoff[3] = + side;
    xoff[4] = - hftof;   yoff[4] = + side/2.0;
    xoff[5] = - hftof;   yoff[5] = - side/2.0;
    
    for (int i=0; i<6; i++) {
        double x = _xc + xoff[i];
        double y = _yc + yoff[i];
        cornerPoint[i] = NSMakePoint(x,y);
        rcorner[i] = sqrt(x*x+y*y);
    }

    for (int i=0; i<6; i++) {
        int j = (i+1)%6;
        //rsidea[i] = [self rmid75:i and25:j];
        rsideb[i] = [self rmiddle:i and:j];
        //rsidec[i] = [self rmid75:j and25:i];
        //xmid[i] = _xc + 0.5 * (xoff[i]+xoff[j]);
        //ymid[i] = _yc + 0.5 * (yoff[i]+yoff[j]);
    }

}

#pragma mark - decision rectangles for scan: (x1,y1) and (x2,y2) are points on the decision line

- (void) makeHalfRect {
    
    int ia = _first%6;
    int ic = (_first+3)%6;
    double x1 = _xc + xoff[ia];
    double y1 = _yc + yoff[ia];
    double x2 = _xc + xoff[ic];
    double y2 = _yc + yoff[ic];
    
    //if(fabs(atan2(_yc,_xc)*180./M_PI-49.7) < 5. && _xc > 0. && _yc > 0. && _rc > 1500.) NSLog(@"makeHalfRect: %d %d",ia,ic);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}

- (void) makeFiveRect {
    
    int ia = _first%6;
    int ic = (_first+4)%6;
    double x1 = _xc + xoff[ia];
    double y1 = _yc + yoff[ia];
    double x2 = _xc + xoff[ic];
    double y2 = _yc + yoff[ic];
    
    //if(fabs(atan2(_yc,_xc)*180./M_PI-49.7) < 5. && _xc > 0. && _yc > 0. && _rc > 1500.) NSLog(@"makeHalfRect: %d %d",ia,ic);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}

- (void) makeThreeRect {
    
    int ia = _first%6;
    //if(_failinner) NSLog(@"THREE: ID = %d, ia = %d",_ID,ia);
    int ic = (_first+2)%6;
    double x1 = _xc + xoff[ia];
    double y1 = _yc + yoff[ia];
    double x2 = _xc + xoff[ic];
    double y2 = _yc + yoff[ic];
    
    //if(fabs(atan2(_yc,_xc)*180./M_PI-49.7) < 5. && _xc > 0. && _yc > 0. && _rc > 1500.) NSLog(@"makeHalfRect: %d %d",ia,ic);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}

- (void) makeSemiRect {
    
    int ia = (_first+1)%6;
    
    //if(_failinner) NSLog(@"SEMI: ID = %d, ia = %d",_ID,ia);
    
    double x1 = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y1 = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    int ic  = (ia+3)%6;
    double x2 = _xc + 0.5*(xoff[ic]+xoff[(ic+1)%6]);
    double y2 = _yc + 0.5*(yoff[ic]+yoff[(ic+1)%6]);

    //if(fabs(_xc-1004.)<1. && (_rc-1534.)<1. && _yc>0.) NSLog(@" makeChopTwoRect %d %d %d %d",ia,ia1,ic,ic1);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}
/*
- (void) makeChopTwoRect {
    
    int ia  = (_ivertex+2)%6;
    //if(_failinner) NSLog(@"CHOPTWO: ID = %d, ia = %d",_ID,ia);
    int ia1 = (_ivertex+3)%6;
    int ic  = (_ivertex+4)%6;
    int ic1 = (_ivertex+5)%6;
    double x1 = _xc+0.5*(xoff[ia]+xoff[ia1]);
    double y1 = _yc+0.5*(yoff[ia]+yoff[ia1]);
    double x2 = _xc+0.5*(xoff[ic]+xoff[ic1]);
    double y2 = _yc+0.5*(yoff[ic]+yoff[ic1]);
    
    //if(fabs(_xc-1004.)<1. && (_rc-1534.)<1. && _yc>0.) NSLog(@" makeChopTwoRect %d %d %d %d",ia,ia1,ic,ic1);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}

- (void) makeChopFourRect {
    
    int ia  = _ivertex%6;
    //if(_failinner) NSLog(@"CHOPFOUR: ID = %d, ia = %d",_ID,ia);
    int ia1 = (_ivertex+1)%6;
    int ic  = (_ivertex+4)%6;
    int ic1 = (_ivertex+5)%6;
    double x1 = _xc+0.5*(xoff[ia]+xoff[ia1]);
    double y1 = _yc+0.5*(yoff[ia]+yoff[ia1]);
    double x2 = _xc+0.5*(xoff[ic]+xoff[ic1]);
    double y2 = _yc+0.5*(yoff[ic]+yoff[ic1]);
    
    //if(fabs(_xc-1004.)<1. && (_rc-1534.)<1. && _yc>0.) NSLog(@" makeChopTwoRect %d %d %d %d",ia,ia1,ic,ic1);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}
- (void) makeFourPlusRect {
    
    int ia = (_ivertex+4)%6;
    int ic = (_ivertex+1)%6;
    int ic1 = (ic+1)%6;
    double x1 = _xc + xoff[ia];
    double y1 = _yc + yoff[ia];
    double x2 = _xc+0.5*(xoff[ic]+xoff[ic1]);
    double y2 = _yc+0.5*(yoff[ic]+yoff[ic1]);
    
}
- (void) makeThreePlusRect {
    
    int ia = (_ivertex+4)%6;
    int ic = (_ivertex+0)%6;;
    int ic1 = (ic+1)%6;
    double x1 = _xc + xoff[ia];
    double y1 = _yc + yoff[ia];
    double x2 = _xc+0.5*(xoff[ic]+xoff[ic1]);
    double y2 = _yc+0.5*(yoff[ic]+yoff[ic1]);
    
    //if(fabs(_xc-1004.)<1. && (_rc-1534.)<1. && _yc>0.) NSLog(@" makeChopTwoRect %d %d %d %d",ia,ia1,ic,ic1);
    
    _decisionRect = NSMakeRect(x1,y1,(x1-x2),(y1-y2));
    
}
*/

#pragma mark - Utilities



- (double) rmiddle: (int) ia and: (int) ic {
    double x = _xc+0.5*(xoff[ia]+xoff[ic]);
    double y = _yc+0.5*(yoff[ia]+yoff[ic]);
    return sqrt(x*x + y*y);
}
/*
- (double) rmid75: (int) ia and25: (int) ic
{
    double x = _xc+(0.75*xoff[ia]+0.25*xoff[ic]);
    double y = _yc+(0.75*yoff[ia]+0.25*yoff[ic]);
    return sqrt(x*x + y*y);
}
 
- (double) rmidmid: (int) ia and: (int) ic
{
    double x = 0.5*(xmid[ia]+xmid[ic]);
    double y = 0.5*(ymid[ia]+ymid[ic]);
    return sqrt(x*x + y*y);
}
 */

#pragma mark - Bezier paths

- (NSBezierPath *) waferBezier
{
    
    //NSLog(@"waferBezier called");
    
    NSBezierPath * p = [NSBezierPath bezierPath];

    double x = _xc + xoff[0];
    double y = _yc + yoff[0];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=1; i<6; i++)
    {
        x = _xc + xoff[i];
        y = _yc + yoff[i];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    [p closePath];
    
    return p;
}

- (NSBezierPath *) partBezier:(int)type
{

    NSBezierPath * p = [NSBezierPath bezierPath];

    _first = 0;
    _ivertex = 0;
    
    if(type == 0) {
        _first = 3;
        _half = YES;
        p = [self halfBezier];
    } else if(type == 1) {
        _first = 4;
        _five = YES;
        p = [self fiveBezier];
    } else if(type == 2) {
        _first = 5;
        _three = YES;
        p = [self threeBezier];
    } else if(type == 3) {
        _semi = YES;
        p = [self semiBezier];
    } else if(type == 4) {
        _part5a = YES;
        p = [self part5aBezier];
    } else if(type == 5) {
        _part5b = YES;
        p = [self part5bBezier];
    } else if(type == 6) {
        _ivertex = 4;
        _choptwo = YES;
        p = [self choptwoBezier];
    } else if(type == 7) {
        _ivertex = 5;
        _chopfour = YES;
        p = [self chopfourBezier];
    } else if(type == 8){
        _halfbegin = YES;
        _ivertex = 5;
        _threeplus = YES;
        p = [self threeplusBezier];
    } else if(type == 9) {
        _halfbegin = YES;
        _ivertex = 4;
        _fourplus = YES;
        p = [self fourplusBezier];
    }
    
    [p setMiterLimit:1.0];
    [p setLineWidth:2.5];

    return p;
}

- (NSBezierPath *) part47Bezier:(int)type {
    
    NSBezierPath * p = [NSBezierPath bezierPath];

    _first = 0;
    // ----------------------------------------------------------------
    // 11 Jan 2022: orientations changed (_first and _ivertex)
    // so as to have "channel #1" at bottom (i.e. 6 o'clock)
    // 21 Feb 2022: using new 47-layer bezier routines
    // ----------------------------------------------------------------
    if(type == 0) {
        _first = 4;
        [self ldTopBezier];
    } else if(type == 1) {
        _first = 1;
        [self ldBottomBezier];
    } else if(type == 2) {
        _first = 1;
        [self ldLeftBezier];
    } else if(type == 3) {
        _first = 4;
        [self ldRightBezier];
    } else if(type == 4) {
        _first = 5;
        [self ldFiveBezier];
    } else if(type == 5) {
        _first = 3;
        [self ldThreeBezier];
    } else if(type == 6) {
        _first = 1;
        [self ldLeftBezier];
   } else if(type == 7) {
        _first = 3;
        [self ldThreeBezier];
   } else if(type == 8) { //------------
        _first = 0;
        [self hdTopBezier];
   } else if(type == 9) {
        _first = 3;
        [self hdBottomBezier];
   } else if(type == 10) {
        _first = 1;
        [self hdLeftBezier];
   } else if(type == 11) {
        _first = 4;
        [self hdRightBezier];
   } else if(type == 12) {
        _first = 1;
        [self hdFiveBezier];
   } else if(type == 13) {
        _first = 4;
        [self hdRightBezier];
    }
    
    [p setMiterLimit:1.0];
    [p setLineWidth:2.5];

    return p;
}

- (NSBezierPath *) halfBezier
{

    if(!_half) {
        NSLog(@"HALF ERROR!!!!");
        return nil;
    }
    _part = YES;

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<3; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    [p closePath];
    
    for (int i=0; i<4; i++)
    {
        ip = (ip+1)%6;
    }

     _bezier = p;
    return p;
}

- (NSBezierPath *) fiveBezier
{

    if(!_five)    {
        NSLog(@"FIVE ERROR!!!!");
        return nil;
    }

    _part = YES;

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
        
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<4; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    [p closePath];
    
    for (int i=0; i<3; i++)
    {
        ip = (ip+1)%6;
    }
    
     _bezier = p;

    return p;
}

- (NSBezierPath *) threeBezier
{

    if(!_three) {
        NSLog(@"THREE ERROR!!!!");
        return nil;
    }

    _part = YES;

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
    
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<2; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    for (int i=0; i<5; i++)
    {
        ip = (ip+1)%6;
    }
    
    [p closePath];

     _bezier = p;
   return p;
}

- (NSBezierPath *) semiBezier
{

    if(!_semi) {
        NSLog(@"SEMI ERROR!!!!");
        return nil;
    }

    _part = YES;
     

    NSBezierPath * p = [NSBezierPath bezierPath];

    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);

    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    r = sqrt(x*x + y*y);
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
    for (int i=0; i<3; i++) //should be 3!
    {
        ia = (ia+1)%6;
     }

     _bezier = p;
    return p;
}

- (NSBezierPath *) semiminusBezier
{
    
    _part = YES;
    
    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.2169598931*xoff[ia] + (1.-0.2169598931)*xoff[(ia+1)%6];
    double y = _yc + 0.2169598931*yoff[ia] + (1.-0.2169598931)*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    x = _xc + (1.-0.2169598931)*xoff[ia] + 0.2169598931*xoff[(ia+1)%6];
    y = _yc + (1.-0.2169598931)*yoff[ia] + 0.2169598931*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) part5aBezier
{
    if(!_part5a) {
        NSLog(@"PART5A ERROR!!!!");
        return nil;
    }

    _part = YES;

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.75*xoff[ia]+0.25*xoff[(ia+1)%6];
    double y = _yc + 0.75*yoff[ia]+0.25*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.25*xoff[ia]+0.75*xoff[(ia+1)%6];
    y = _yc + 0.25*yoff[ia]+0.75*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
    }
    
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) part5bBezier
{
    if(!_part5b) {
        NSLog(@"PART5B ERROR!!!!");
        return nil;
    }

    _part = YES;

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.25*xoff[ia]+0.75*xoff[(ia+1)%6];
    double y = _yc + 0.25*yoff[ia]+0.75*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.75*xoff[ia]+0.25*xoff[(ia+1)%6];
    y = _yc + 0.75*yoff[ia]+0.25*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
    }
    
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) choptwoBezier
{
    if(!_choptwo) {
        NSLog(@"CHOPTWO ERROR!!!!");
        return nil;
    }

    _part = YES;
     

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);

    for (int i=0; i<4; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    r = sqrt(x*x + y*y);
    ia = (ia+2)%6;

     _bezier = p;
    return p;
}

- (NSBezierPath *) choptwominusBezier
{
    
    _part = YES;
    
    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + (1.-0.7834520816)*xoff[ia] + 0.7834520816*xoff[(ia+1)%6];
    double y = _yc + (1.-0.7834520816)*yoff[ia] + 0.7834520816*yoff[(ia+1)%6];

    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);
    
    for (int i=0; i<4; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    x = _xc + 0.7834520816*xoff[ia] + (1.-0.7834520816)*xoff[(ia+1)%6];
    y = _yc + 0.7834520816*yoff[ia] + (1.-0.7834520816)*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    r = sqrt(x*x + y*y);
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) chopfourBezier
{
    if(!_chopfour) {
        NSLog(@"CHOPFOUR ERROR!!!!");
        return nil;
    }

    _part = YES;
     

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    double x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);
    for (int i=0; i<2; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    r = sqrt(x*x + y*y);
    ia = (ia+4)%6;
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) threeplusBezier {
    
    if(!_threeplus) {
        NSLog(@"THREEPLUS ERROR!!!!");
        return nil;
    }

    _part = YES;
     


    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    _halfbegin = (MAX(rcorner[ia],rsideb[(ia+2)%6]) > MAX(rcorner[(ia+3)%6],rsideb[ia]));
    
    double x = _xc + xoff[ia];
    double y = _yc + yoff[ia];
    double r;

    
    if(_halfbegin)
    {
        x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
        y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
        [p moveToPoint:NSMakePoint(x,y)];
        r = sqrt(x*x + y*y);
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
        r = sqrt(x*x + y*y);
    } else {
        [p moveToPoint:NSMakePoint(x,y)];
        r = sqrt(x*x + y*y);
    }
    
    for (int i=0; i<2; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
        r = sqrt(x*x + y*y);
    }
    if(!_halfbegin)
    {
        x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
        y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
        [p lineToPoint:NSMakePoint(x,y)];
        r = sqrt(x*x + y*y);
    }
    [p closePath];
    
    if(!_halfbegin)
    {
        ia = (ia+1)%6;
    }
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
    }
    
     _bezier = p;
    return p;
}

- (NSBezierPath *) fourplusBezier
{
    if(!_fourplus) {
        NSLog(@"FOURPLUS ERROR!!!!");
        return nil;
    }

    _part = YES;
     

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_ivertex+4)%6;
    
    _halfbegin = (MAX(rcorner[(ia+4)%6],rsideb[(ia+1)%6]) < MAX(rcorner[ia],rsideb[(ia+3)%6]));
    
    double x = _xc + xoff[ia];
    double y = _yc + yoff[ia];
    
    if(_halfbegin)
    {
        x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
        y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
        [p moveToPoint:NSMakePoint(x,y)];
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    } else {
        [p moveToPoint:NSMakePoint(x,y)];
    }
    
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    if(!_halfbegin)
    {
        x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
        y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
        [p lineToPoint:NSMakePoint(x,y)];
    }
    [p closePath];
        
    if(!_halfbegin)
    {
        ia = (ia+1)%6;
    }
    
    for (int i=0; i<2; i++)
    {
        ia = (ia+1)%6;
    }
    
     _bezier = p;
    return p;
}
#pragma mark - New 47-layer partial wafer beziers
- (void) constructWaferBezier {
  
    int tnum = self.type;
    int jrot = self.channelZero;
    
    if(tnum == 0) {
        [self wholeBezier];
        return;
    }
    
    if(self.LD) {
        int ldStart[6] = {1,2,2,4,3,5};
        int start = 0;
        if(_v17) start = ldStart[tnum-1];
        if(tnum == 1) {             // top
            self.first = (start+jrot+3)%6;
            [self ldTopBezier];
        } else if(tnum == 2) {       // bottom
            self.first = (start+jrot+3)%6;
            [self ldBottomBezier];
        } else if(tnum == 3) {      // left
            self.first = (start+jrot+5)%6;
            [self ldLeftBezier];
        } else if(tnum == 4) {      // right
            self.first = (start+jrot+5)%6;
            [self ldRightBezier];
        } else if(tnum == 5) {      // five
            self.first = (start+jrot+2)%6;
            [self ldFiveBezier];
        } else if(tnum == 6) {      // three
            self.first = (start+jrot+4)%6;
            [self ldThreeBezier];
        }
        return;
    } else {
        int hdStart[5] = {1,4,2,4,1};
        int start = 0;
        if(_v17) start = hdStart[tnum-1];
        if(tnum == 1) {             // HD top
            self.first = (start+jrot+5)%6;
            [self hdTopBezier];
        } else if(tnum == 2) {      // HD bottom
            self.first = (start+jrot+5)%6;
            [self hdBottomBezier];
        } else if(tnum == 3) {      // HD left
            self.first = (start+jrot+5)%6;
            [self hdLeftBezier];
        } else if(tnum == 4) {      // HD right
            self.first = (start+jrot+5)%6;
            [self hdLeftBezier];
       } else if(tnum == 5) {       // HD five
            self.first = (start+jrot+5)%6;
            [self hdFiveBezier];
       }
   }
}
- (void) wholeBezier {
    
    NSBezierPath * p = [NSBezierPath bezierPath];

    double x = _xc + xoff[0];
    double y = _yc + yoff[0];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=1; i<6; i++)
    {
        x = _xc + xoff[i];
        y = _yc + yoff[i];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    [p closePath];
    
    _bezier = p;
}

- (void) markerBezier {
    
    // ---- first the chan 1 marker bezier
    NSBezierPath * p = [NSBezierPath bezierPath];

    double x = _xc + xoff[_channelZero];
    double y = _yc + yoff[_channelZero];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    double frac = 0.2;
    double frak = 0.15;
    
    x = _xc + ((1.-frac)*xoff[_channelZero] + frac*xoff[(_channelZero+1)%6]);
    y = _yc + ((1.-frac)*yoff[_channelZero] + frac*yoff[(_channelZero+1)%6]);
    [p lineToPoint:NSMakePoint(x,y)];

    x = _xc + ((1.-frak)*xoff[_channelZero] + frak*xoff[(_channelZero+3)%6]);
    y = _yc + ((1.-frak)*yoff[_channelZero] + frak*yoff[(_channelZero+3)%6]);
    [p lineToPoint:NSMakePoint(x,y)];

    x = _xc + ((1.-frac)*xoff[_channelZero] + frac*xoff[(_channelZero+5)%6]);
    y = _yc + ((1.-frac)*yoff[_channelZero] + frac*yoff[(_channelZero+5)%6]);
    [p lineToPoint:NSMakePoint(x,y)];
    
    [p closePath];
    
    _zeroBezier = p;
    
    // ---- Now for the bar bezier
    NSBezierPath * q = [NSBezierPath bezierPath];

    x = _xc + xoff[(_channelZero+5)%6];
    y = _yc + yoff[(_channelZero+5)%6];
    [q moveToPoint:NSMakePoint(x,y)];
    
    x = _xc + ((1.-frak)*xoff[(_channelZero+5)%6] + frak*xoff[_channelZero]);
    y = _yc + ((1.-frak)*yoff[(_channelZero+5)%6] + frak*yoff[_channelZero]);
    [q lineToPoint:NSMakePoint(x,y)];

    x = _xc + ((1.-frak)*xoff[(_channelZero+3)%6] + frak*xoff[(_channelZero+2)%6]);
    y = _yc + ((1.-frak)*yoff[(_channelZero+3)%6] + frak*yoff[(_channelZero+2)%6]);
    [q lineToPoint:NSMakePoint(x,y)];
    
    x = _xc + xoff[(_channelZero+3)%6];
    y = _yc + yoff[(_channelZero+3)%6];
    [q lineToPoint:NSMakePoint(x,y)];
    
    [q closePath];
    
    _barBezier = q;

}

- (void) ldTopBezier {
    
    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<3; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    [p closePath];
    [self makeHalfRect];
    _bezier = p;
}

- (void) ldBottomBezier {
    
    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<3; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    [self makeHalfRect];
    [p closePath];
    

     _bezier = p;
}

- (void) ldLeftBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];

    int ia = (_first+4)%6;
    
    double x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);

    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    r = sqrt(x*x + y*y);
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    [self makeSemiRect];
     _bezier = p;
}

- (void) ldRightBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];

    int ia = (_first+4)%6;
    
    double x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    double y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    
    [p moveToPoint:NSMakePoint(x,y)];
    double r = sqrt(x*x + y*y);

    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + 0.5*(xoff[ia]+xoff[(ia+1)%6]);
    y = _yc + 0.5*(yoff[ia]+yoff[(ia+1)%6]);
    r = sqrt(x*x + y*y);
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    [self makeSemiRect];

     _bezier = p;
}
- (void) ldFiveBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
        
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<4; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    [p closePath];
    [self makeFiveRect];
     _bezier = p;
}

- (void) ldThreeBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ip = _first;
    
    double x = _xc + xoff[ip];
    double y = _yc + yoff[ip];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<2; i++)
    {
        ip = (ip+1)%6;
        x = _xc + xoff[ip];
        y = _yc + yoff[ip];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    
    for (int i=0; i<5; i++)
    {
        ip = (ip+1)%6;
    }
    
    [p closePath];
    [self makeThreeRect];
     _bezier = p;
    [_bezier setMiterLimit:2.];
}

- (void) hdTopBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];
    
    int ia = (_first+4)%6;
    
    double f0 = 0.72;
    double f1 = 1.0 - f0;
    
    double x = _xc + f0*xoff[ia] + f1*xoff[(ia+1)%6];
    double y = _yc + f0*yoff[ia] + f1*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
 
    for (int i=0; i<2; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + f1*xoff[ia] + f0*xoff[(ia+1)%6];
    y = _yc + f1*yoff[ia] + f0*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];

     _bezier = p;

}

- (void) hdBottomBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];

    _part = YES;
    
    double f0 = 0.28;
    double f1 = 1.0 - f0;

    int ia = (_first+3)%6;
    
    double x = _xc + f0*xoff[ia] + f1*xoff[(ia+1)%6];
    double y = _yc + f0*yoff[ia] + f1*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];

    for (int i=0; i<4; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + f1*xoff[ia] + f0*xoff[(ia+1)%6];
    y = _yc + f1*yoff[ia] + f0*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];

     _bezier = p;

}

- (void) hdLeftBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];

    _part = YES;
    
    double f0 = 0.28;
    double f1 = 1.0 - f0;

    int ia = (_first+4)%6;
    
    double x = _xc + f0*xoff[ia] + f1*xoff[(ia+1)%6];
    double y = _yc + f0*yoff[ia] + f1*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + f1*xoff[ia] + f0*xoff[(ia+1)%6];
    y = _yc + f1*yoff[ia] + f0*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
     _bezier = p;

}

- (void) hdRightBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];

    _part = YES;
    
    double f0 = 0.28;
    double f1 = 1.0 - f0;

    int ia = (_first+4)%6;
    
    double x = _xc + f0*xoff[ia] + f1*xoff[(ia+1)%6];
    double y = _yc + f0*yoff[ia] + f1*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + f1*xoff[ia] + f0*xoff[(ia+1)%6];
    y = _yc + f1*yoff[ia] + f0*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];
    
     _bezier = p;

}

- (void) hdFiveBezier {

    NSBezierPath * p = [NSBezierPath bezierPath];
    _part = YES;
    
    int ia = (_first+4)%6;
    
    double f0 = 0.28;
    double f1 = 1.0 - f0;

    double x = _xc + f1*xoff[ia]+f0*xoff[(ia+1)%6];
    double y = _yc + f1*yoff[ia]+f0*yoff[(ia+1)%6];
    
    [p moveToPoint:NSMakePoint(x,y)];
    
    for (int i=0; i<3; i++)
    {
        ia = (ia+1)%6;
        x = _xc + xoff[ia];
        y = _yc + yoff[ia];
        [p lineToPoint:NSMakePoint(x,y)];
    }
    x = _xc + f0*xoff[ia]+f1*xoff[(ia+1)%6];
    y = _yc + f0*yoff[ia]+f1*yoff[(ia+1)%6];
    [p lineToPoint:NSMakePoint(x,y)];
    [p closePath];

     _bezier = p;

}

@end
