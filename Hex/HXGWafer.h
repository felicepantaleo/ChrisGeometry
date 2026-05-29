//
//  HXGWafer.h
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXGHardwareConstants.h"

@interface HXGWafer : NSObject {
    
    
    HXGHardwareConstants * theHardwareConstants;

    double xd;
    double yd;
    double side;
    
    double xoff[6];
    double yoff[6];
    
    NSPoint cornerPoint[6];
    double rcorner[6];
    //double dorner[5];
    int did[2];
    
    NSAffineTransform * mirrorTransform;
    BOOL doReflection;
    BOOL onlyActive;

    double rsideb[6]; // will go when pre-47 crap goes
   // double rsidea[6], rsideb[6], rsidec[6]; // These two lines for demolition?
   // double xmid[6], ymid[6];
    
   // int layer;
    
    
}

@property BOOL debugPrint;

@property (readonly) int ID;
@property (readonly) int * detId;

@property (readonly) NSBezierPath * bezier;
@property (readonly) NSBezierPath * zeroBezier;
@property (readonly) NSBezierPath * barBezier;

@property int type; // Whole or partial etc
@property BOOL LD;
@property int thickflag;
/* ---- thickflag:
 0 = HD120
 1 = HD200
 2 = LD200
 3 = LD300
----      */
@property BOOL part;
@property BOOL whole;
@property int channelZero;
@property int cassette;
//@property BOOL v17;
@property int fileLine;
@property BOOL marked;
@property BOOL seenFromBack; // Means: when viewed from vertex the wafer surface seen is the back side... (hence the need for XOR with mirror in cassette view)

/*
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
*/
@property (readonly) double rc;
@property (readonly) double xc;
@property (readonly) double yc;
@property (readonly) double gridxc;
@property (readonly) double gridyc;
@property (readonly) double rmax;
@property (readonly) NSPoint maxcorner;
@property (readonly) NSPoint * corner;
@property double areaHex;
@property NSBezierPath * test;

@property (readonly) NSRect decisionRect; // Used for stateAtPoint in HexView

//@property BOOL halfbegin; // Needed only for pre-47 stuff
//@property int ivertex;    // Needed only for pre-47 stuff
@property int first;



+ (id) waferWithX:(double)x Y:(double)y Side:(double)s ID:(int)i andDetId:(int *)d;

- (void) setRetractedX:(double) x andY: (double) y;
- (void) revertToGrid;
//- (void) makePartialBezier;

//- (NSBezierPath *) partBezier:(int)type;
- (NSBezierPath *) part47Bezier:(int)type;

- (NSBezierPath *) waferBezier;

- (void) completePartialBezierForHD: (BOOL) HD;


/*
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
 */
- (void) constructActiveBezierMirrored:(BOOL) mirror;
- (void) constructWaferBezierMirrored:(BOOL) mirror;
- (void) wholeBezier;
- (void) markerBezierMirrored:(BOOL) mirror;
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
