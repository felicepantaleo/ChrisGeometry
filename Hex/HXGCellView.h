//
//  HXGCellView.h
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCell.h"
#import "HXGrawDataMapControl.h"
#import "HXGCellLabel.h"
#import "HXGCellAreas.h"
#import "HXGActiveWafer.h"
#import "HXGNotifications.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

@interface HXGCellView : NSView {
  
    HXGrawDataMapControl * theRawDataMap;
    HXGCellAreas * theCellAreas;
    HXGActiveWafer * theActiveWafer;

    double radius[5];
    
    NSRect frameRect;
    NSRect incFrameRect;
    
    double xmax,ymax;
    NSBezierPath * waferBezier;
    NSBezierPath * activeBezier;
    NSBezierPath * killBiteBezier;
    NSPoint waferPoint[6];
    //NSPoint mouseBitePnt[6][3];
    //NSPoint altPnt1,altPnt2;
    NSBezierPath * centre;
    NSBezierPath * debugMarker;
    NSBezierPath * uvAxes;
    NSBezierPath * uarrow;
    NSBezierPath * varrow;
    NSPoint uLabelPoint;
    NSPoint vLabelPoint;
    NSBezierPath * specialAxes;
    NSBezierPath * specialUarw;
    NSBezierPath * specialVarw;
    NSPoint specialUPoint;
    NSPoint specialVPoint;
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
    NSAffineTransform * rot210Transform;
    NSAffineTransform * inverse210Transform;
    BOOL pdf;

    BOOL LDsplit[212], HDsplit[470];
    int U[470],V[470];
    BOOL cFlag[470];
    int indexInCellLabels[24][24];
    int indexInCells[24][24];

    NSBezierPath * partialBezier;
    NSBezierPath * auxBezier;
    NSBezierPath * testBezier;
    NSBezierPath * killBezier;
    NSBezierPath * activePartialBezier;
    NSBezierPath * dicingBezier[3];
    
    NSRect pRect;
    double xp0;
    double pstep;
    
    BOOL debugCellAreas;
    BOOL drawProblemCell;

}

@property int colorCells;
@property (readonly) int count;
@property double cside;
@property BOOL numberCells;
@property BOOL showGrid;
@property BOOL showOutline;
@property BOOL showCoords;
@property BOOL showDimensions;
@property BOOL allLabels;
@property BOOL triggerId;
@property BOOL hyperBright;
@property BOOL inclusionRadii;
@property BOOL showCircles;
@property BOOL showCellPoint;
@property BOOL mirror;
@property BOOL showAxes;
@property BOOL hardwareOrientation;

@property int partial;
@property BOOL HD;
@property BOOL wholePartial;
@property BOOL ispartial;

@property NSArray * cPalette;
@property NSArray * cNames;
@property NSRect paletteRect;
@property int icsel;



- (void) setViewFrame:(NSRect)fRect;

- (void) setColSelRect;

- (void) initializePlacementIndex: (int) ip;

- (void) setPlacementIndex: (int) ip;

- (void) setupPlacement: (int) ip;

- (void) setWaferSide:(double) s cellCount:(int) c;

- (void) setRadii: (double *) r;

- (void) setUpPartials;

- (void) makeAxes;

- (void) markPoint:(NSPoint) offset;

- (void) makeChanUVmap;

- (int *) cellDetIdAtPoint:(NSPoint) point;

- (NSPoint) pointAtU:(int) u andV:(int) v;

- (BOOL) acceptsFirstResponder;

- (void) savePDF:(NSString *)path;

- (void) mouseMoved:(NSEvent *)theEvent;

- (void) drawCells:(NSArray *) g forWafer:(NSPoint *) q;


@end
