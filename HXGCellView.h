//
//  HXGCellView.h
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCell.h"
#import "HXGCellLabel.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

@interface HXGCellView : NSView {
    
    double radius[5];
    
    NSRect frameRect;
    double xmax,ymax;
    NSBezierPath * wafer;
    NSBezierPath * centre;
    NSBezierPath * debugMarker;
    NSBezierPath * uvAxes;
    NSBezierPath * uarrow;
    NSBezierPath * varrow;
    NSPoint uLabelPoint;
    NSPoint vLabelPoint;
    NSArray * gridCells;
    NSMutableArray * cellLabels;

    double waferSide;
    double waferWidth;
    double side;
    double hWidth;
    
    double sin60;
    double cos60;

    int iplacement;
    int iu;
    int iv;
    int iw;
    int idetId[3];
    int trDetId[2];
    
    NSTimeInterval tstart;
    double xp,yp;
    NSPoint mousePoint;
    NSPoint cellCentre;
    NSRect cRect;
    
    NSAffineTransform * mirrorTransform;
    NSAffineTransform * pdftransform;
    BOOL pdf;


}

@property int colorCells;
@property (readonly) int count;
@property double cside;
@property BOOL numberCells;
@property BOOL showGrid;
@property BOOL showOutline;
@property BOOL showCoords;
@property BOOL showDimensions;
@property BOOL useDetId;
@property BOOL triggerId;
@property BOOL hyperBright;
@property BOOL inclusionRadii;
@property BOOL showCircles;
@property BOOL showCellPoint;
@property BOOL mirror;
@property BOOL showAxes;

- (void) setViewFrame:(NSRect)fRect;

- (void) setPlacementIndex: (int) ip;

- (void) setWaferSide:(double) s cellCount:(int) c;

- (void) setRadii: (double *) r;

- (void) makeAxes;

- (void) markPoint:(NSPoint) offset;

- (int *) cellDetIdAtPoint:(NSPoint) point;

- (NSPoint) pointAtU:(int) u andV:(int) v;

- (BOOL) acceptsFirstResponder;

- (void) savePDF:(NSString *)path;

- (void) mouseMoved:(NSEvent *)theEvent;

- (void) drawCells:(NSArray *) g forWafer:(NSBezierPath *) q;


@end
