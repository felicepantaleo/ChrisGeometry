//
//  HXGWafer.h
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXGWafer : NSObject {
    double xd;
    double yd;
    double side;
    
    double xoff[6];
    double yoff[6];
    
    NSPoint cornerPoint[6];
    double rcorner[6];
    //double dorner[5];
    int did[2];

    double rsideb[6]; // will go when pre-47 crap goes
   // double rsidea[6], rsideb[6], rsidec[6]; // These two lines for demolition?
   // double xmid[6], ymid[6];
    
   // int layer;
    
    
}

@property (readonly) int ID;
@property (readonly) int * detId;

@property (readonly) NSBezierPath * bezier;
@property (readonly) NSBezierPath * zeroBezier;
@property (readonly) NSBezierPath * barBezier;

@property int type;
@property BOOL LD;
@property int thickflag;
@property BOOL part;
@property BOOL whole;
@property int channelZero;
@property int cassette;
@property BOOL v17;
@property int fileLine;


@property BOOL half;      // Needed only for pre-47 stuff
@property BOOL semi;      // Needed only for pre-47 stuff
@property BOOL five;      // Needed only for pre-47 stuff
@property BOOL part5a;    // Needed only for pre-47 stuff
@property BOOL part5b;    // Needed only for pre-47 stuff
@property BOOL three;     // Needed only for pre-47 stuff
@property BOOL choptwo;   // Needed only for pre-47 stuff
@property BOOL chopfour;  // Needed only for pre-47 stuff
@property BOOL threeplus; // Needed only for pre-47 stuff
@property BOOL fourplus;  // Needed only for pre-47 stuff

@property (readonly) double rc;
@property (readonly) double xc;
@property (readonly) double yc;
@property (readonly) NSPoint * corner;
@property double areaHex;
@property NSBezierPath * test;

@property (readonly) NSRect decisionRect;

@property BOOL halfbegin; // Needed only for pre-47 stuff
@property int ivertex;    // Needed only for pre-47 stuff
@property int first;



+ (id) waferWithX:(double)x Y:(double)y Side:(double)s ID:(int)i andDetId:(int *)d;


//- (void) makePartialBezier;

- (NSBezierPath *) partBezier:(int)type;
- (NSBezierPath *) part47Bezier:(int)type;

- (NSBezierPath *) waferBezier;
- (NSBezierPath *) halfBezier;
- (NSBezierPath *) fiveBezier;
- (NSBezierPath *) threeBezier;
- (NSBezierPath *) semiBezier;
- (NSBezierPath *) part5aBezier;
- (NSBezierPath *) part5bBezier;
- (NSBezierPath *) choptwoBezier;
- (NSBezierPath *) chopfourBezier;
- (NSBezierPath *) threeplusBezier;
- (NSBezierPath *) fourplusBezier;

- (NSBezierPath *) semiminusBezier;
- (NSBezierPath *) choptwominusBezier;

- (void) constructWaferBezier;

- (void) wholeBezier;
- (void) markerBezier;
- (void) ldTopBezier;
- (void) ldBottomBezier;
- (void) ldLeftBezier;
- (void) ldRightBezier;
- (void) ldFiveBezier;
- (void) ldThreeBezier;
- (void) hdTopBezier;
- (void) hdBottomBezier;
- (void) hdLeftBezier;
- (void) hdRightBezier;
- (void) hdFiveBezier;

@end
