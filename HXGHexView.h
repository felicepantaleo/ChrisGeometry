//
//  HXGHexView.h
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGWafer.h"
#import "HXGPositionControl.h"
#import "HXGEtaRingsControl.h"
#import "HXGStructs.h"
#import "HXGNotifications.h"
#import "HXGLayerMapFiles.h"
#import "HistViewControl.h"
#import "HXGWaferInspectorControl.h"
#import "CSColours.h"
#import "CSBeziers.h"

@interface HXGHexView : NSView {
    
    HXGPositionControl * thePosition;
    HXGEtaRingsControl * theRings;
    HXGLayerMapFiles * theMapFiles;
    HXGWaferInspectorControl * theInspector;
    HistViewControl * theHist;

               //           ***** March 2020 *****
    int hlayer; //  INTERNAL counting is from zero, using this variable
               //  EXTERNAL display and interface is (or is meant to be) by ordinal value
               // -------------------------------------------------------------------------
    
    NSMutableArray * wafers;
    NSMutableArray * wholes;
    
    int * waferThickness;
    int thickCount[3];
    NSArray * waferThicknessColors;
    
    BOOL centreoncentre;
    
    int partialCount[11];
    int partialTotals[11];
    
    NSRect frameRect;
    
    NSBezierPath * beam;
    NSBezierPath * testspot;
    NSBezierPath * scintilatortorus;
    NSBezierPath * etaThree;
    NSBezierPath * cassetteBezier;
    NSPoint testpoint;

    
    NSBezierPath * plusxaxis;
    NSBezierPath * minusxaxis;
    NSBezierPath * yaxis;
    NSBezierPath * uaxis;
    NSBezierPath * vaxis;
    NSPoint xpaxlabel;
    NSPoint xmaxlabel;
    NSPoint yaxlabel;
    NSPoint uaxlabel;
    NSPoint vaxlabel;
    
    NSColor * scintcolor;
    NSColor *col0, *col1, *col2, *col3;
    
    double cassetegap;
    
    double rAbsorber[100];
    double etaLmtOut;
    double etaLmtInr;
    
    double rt3;
    double ftof;
    double side;
  //  double hrad[3], hlim[3];
    int nhex;
    int flags;
    
    BOOL infield; int iRing, iPhi;
    NSTimeInterval tstart;
    double xp, yp, etap, phip, rp;
    NSPoint mousePoint;
    NSRect cRect;
    double hundred;
    int detId[2];
    int detIdRot[2];
    int iu,iv,iw,irow;
    int iwafer,lwafer;
    int inwafer;

    double eta, phi;
    
    NSString * string0;
    BOOL showtext;
    NSPoint  t0point;
    NSPoint  t1point;
    NSString * fontName;
    float fsize;
    NSMutableDictionary * textAttributes;
    NSFont * font;
    
    BOOL limitedSearch;
    int iwMin,iwMax;
    double xlim;
    double ylim;
    
    double hftof;
    double sin60;
    double cos60;
    
    NSBezierPath * etaRingBezier[8];
    double yeta[8];
    double * etaRings;
    int netarings;
    BOOL drawSpokes;
        
    NSNotification * note;
    NSTimer * timer;
    BOOL fire;
 
    NSAffineTransform * thirtyTransform;
    
    NSAffineTransform * zoomTransform;
    NSAffineTransform * inverseZoomTransform;
    BOOL zoom;
    
    NSPoint lineStart;
    NSPoint lineEnd;

    int totTries[500],totHits[500],totThrees[500];
    int netastep;
}

//---- Controls for display
@property double magnify;
@property BOOL rotate30;
@property BOOL showcoords;
@property BOOL showfileline;
@property BOOL showtestspot;
@property BOOL showaxes;
@property BOOL plusz;
          //---- Those in the flags
@property BOOL numberWafers;
@property BOOL useDetId;
@property BOOL useV17;
@property BOOL rotateRotated;
@property BOOL showGrid;
@property BOOL showCassettes;
@property BOOL markZero;
@property BOOL markTypeOne;
//-----

@property int nLayer;
@property double zLayer;
@property long layerSegment;
@property BOOL special;

@property double tolerance;

@property int lastLayer;
@property (readonly) NSString * specialTit;
@property (readonly) int outSet;
@property NSString * lineString;


@property int newMap;

@property BOOL mercedes;

@property int nwhole;
@property int npartial;

- (void) setWaferSize:(double) fsize;

- (void) layoutFromFiles;

- (int *) getThickCount;

- (NSString *) waferSummary;

- (void) zeroPartialTotals;

- (int *) getPartialTotals;

- (NSString *) partialWaferSummary;

- (NSString *) getFileStrings;

- (void) countCheck;

//- (void) setUnlimitedSearch;

- (int) stateAtPoint: (NSPoint) pnt;

- (void) setColors:(NSArray *) hexcols;

- (void) setHexFrame:(NSRect)fRect;

- (void) setParts:(int)flags;

- (void) setPosition:(BOOL)show eta:(double)e phi:(double)p;

- (void) makeGridOnCentre;

- (void) makeGridOnVertex;

- (void) drawHexGrid;

- (void) zoomOnTestPoint:(BOOL) z;

- (void) savePDF:(NSString *)path With:(NSString *)summary;

- (void) mouseMovedToPoint:(NSPoint) point;

- (void) mouseMoved:(NSEvent *)theEvent;


@end
