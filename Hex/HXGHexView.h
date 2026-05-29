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
#import "HXGPhiLinesControl.h"
#import "HXGStructs.h"
#import "HXGNotifications.h"
#import "HXGLayerMapFiles.h"
#import "HXGPbAbsorbers.h"
#import "HXGCuCoolingPlates.h"
#import "HXGCEHspacers.h"
#import "HistViewControl.h"
#import "HXGSensorInspectorControl.h"
#import "HGCTerminalControl.h"
#import "HXGColorPicker.h"
#import "CSColours.h"
#import "CSBeziers.h"
#import "HXGStructuredWafer.h"
#import "HXGCellLocatorWindowControl.h"
#import "HXGDetIdInterface.h"
#import "HXGHardwareConstants.h"
#import "HXGNeighbourFinder.h"

@interface HXGHexView : NSView {
    
    HXGPositionControl * thePosition;
    HXGEtaRingsControl * theRings;
    HXGPhiLinesControl * theLines;
    HXGLayerMapFiles * theMapFiles;
    HXGSensorInspectorControl * theInspector;
    HXGPbAbsorbers * thePbAbsorbers;
    HXGCuCoolingPlates * theCuPlates;
    HXGCEHspacers * theSpacers;
    HistViewControl * theHist;
    HGCTerminalControl * theTerminal;
    HXGColorPicker * theColorPicker;
    HXGStructuredWafer * theStructuredWafer;
    HXGCellLocatorWindowControl * theCellLocator;
    HXGDetIdInterface * theInterface;
    
    NSMutableArray * wafers;
    NSMutableArray * wholes;
    
    int * waferThickness;
    int thickCount[4];                //---- Looks like this is unused....
    NSArray * waferThicknessColors;
    NSArray * waferThicknessNames;

    BOOL centreoncentre;
    
    int partialCount[11];
    int partialTotals[11];
    
    NSRect frameRect;
    
    NSBezierPath * beam;
    NSBezierPath * testspot;
    NSBezierPath * scintilatortorus;
    NSBezierPath * etaThree;
//    NSBezierPath * cassetteBezier;
    
    NSColor * casEdgeColor;
    NSColor * tileCasEdgeColor;
    NSColor * copper;
    NSColor * backgroundColor;
    double alphaOdd;
    NSBezierPath * cassetteBoundaryBezier[12];
    NSPoint startSeg[50][12],endSeg[50][12];
    int nseg[12];
    
    NSPoint testpoint;

    double maxradius;
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
    NSColor * etaRingColor;
    
    //double rAbsorber[100];
    //double etaLmtOut;
   // double etaLmtInr;
    
    double rt3;
    double ftof;
    double side;
  //  double hrad[3], hlim[3];
    int flags;
    
    BOOL infield;
    int iRing, iPhi, lRing;
    NSTimeInterval tstart;
    double xp,yp,etap, phip, rp;
    NSPoint mousePoint;
    NSPoint dragFromPoint;
    NSRect cRect;
    double hundred;
    int detId[2];
    int detIdRot[2];
    int iu,iv,iw,irow;
    int iwafer,lwafer;
    int istate,lstate;
    int inwafer;
    int previousLayer;

    double eta, phi;
    
    NSString * string0;
    BOOL ispdf;
    NSPoint  t0point;
    NSPoint  t1point;
    NSPoint  keypoint;
    double keydelta;
    NSString * fontName;
    float fsize;
    NSMutableDictionary * textAttributes;
    NSMutableDictionary * keyAttributes;
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
    
    NSBezierPath * phiLineBezier[8];
    double * phiLines;
    int nphilines;

    BOOL showPbAbsorbers;
    BOOL showCuPlates;
    BOOL showZbars;
    BOOL showCEHspacers;
    
    NSNotification * note;
    NSTimer * timer;
    BOOL fire;
 
    NSAffineTransform * thirtyTransform;
    NSAffineTransform * sixtyTransform;
    NSAffineTransform * mirrorTransform;
    BOOL mirror;

    NSAffineTransform * zoomTransform;
    NSAffineTransform * inverseZoomTransform;
    
    NSPoint lineStart;
    NSPoint lineEnd;

    int totTries[500],totHits[500],totThrees[500];
    int netastep;
    
    int ncas;
    NSPoint casPoint[12];
    NSAttributedString * casLabel[12];
    NSAffineTransform * casUnRot[12];
    
    BOOL clickWafers;
    
    NSPoint cellCentroid;
    BOOL showChosenCell;
    BOOL showNeighbours;
    NSArray * waferList;
    NSArray * cellListList;
    
    int nadjust;
}

//---- Controls for display
@property BOOL rotate30;
@property BOOL showcoords;
@property BOOL showfileline;
@property BOOL showwafercentre;
@property BOOL showtestspot;
@property BOOL showaxes;
@property BOOL plusz;
@property double casAlpha;
@property NSColor * waferHighlightColor;

//---- Those in the flags
@property BOOL numberWafers;
@property BOOL useDetId;
@property BOOL rotateRotated;
@property BOOL showGrid;
@property BOOL showGridForPartials;
@property BOOL numberCassettes;
@property BOOL showCassettes;
@property BOOL cassetteView;
@property BOOL markTypeOne;
@property BOOL markTypeBar;

//----- pdf output options
@property BOOL pdfShowKey;
@property BOOL pdfShowSummary;
@property BOOL pdfShowHexDate;


@property NSPoint testpointPhysics;
@property NSPoint testpointLayout;


@property int nLayer; //  INTERNAL counting is from zero, using this variable
                      //  EXTERNAL display and interface is by ordinal value
@property double zLayer;
@property long layerSegment;
@property BOOL special;
@property (readonly) int nhex;

@property int testCas;

@property double tolerance;

@property int lastLayer;
@property (readonly) NSString * specialTit;
@property (readonly) int outSet;
@property NSString * lineString;

@property double magnify;

@property BOOL scrolling;
@property BOOL dragging;
@property double scrollmag;
@property NSScrollView * scrollView;
@property (readonly) BOOL zoom;
@property NSPoint viewCentre;
@property BOOL showViewCenter;
@property BOOL showStructure;
@property BOOL showRetracted;
@property BOOL showActiveWafer;
@property BOOL showCellLabels;
@property BOOL suppressLabels;
@property BOOL showEdgeIndex;


@property int newMap;
@property BOOL mercedes;
@property int nwhole;
@property int npartial;

@property int oneCassette;

@property NSString * debugString;
@property BOOL dbuggery;
@property NSPoint loCorner;
@property NSPoint hiCorner;

@property double tDraw;

@property NSWindow * mainWindow;

extern const double structureMagLimit;
extern const double labelsMagLimit;

- (void) setWaferSize:(double) fsize;

- (void) setUpAxes;

- (void) layoutFromFiles;

- (int *) getThickCount;

- (NSString *) waferSummary;

- (void) zeroPartialTotals;

- (int *) getPartialTotals;

- (NSString *) partialWaferSummary;

//- (NSString *) getFileStrings;

- (void) countCheck;

- (void) centreHexViewAt:(NSPoint) centre;

- (NSImage *) imageOfWaferTypeKey;

- (void) logCentre:(NSString *) string;

- (HXGWafer *) getWaferFromDetIdU: (int) wiu andV: (int) wiv;

- (HXGWafer *) getWafer:(int) iw;

- (void) refreshTestPoint;

- (int) stateAtPoint: (NSPoint) pnt;

- (NSPoint) correctPointForRetraction: (NSPoint) pnt;

- (void) setColors:(NSArray *) hexcols;

- (void) setHexFrame:(NSRect)fRect;

- (void) setParts:(int)flags;

- (void) setPosition:(BOOL)show eta:(double)e phi:(double)p;

- (void) makeGridOnCentre;

- (void) makeGridOnVertex;

- (void) drawHexGrid;

- (void) testRetractions;

- (void) zoomOnTestPoint:(BOOL) z;

- (NSAffineTransform *) getZoomAffineTransform;

- (void) HDLDcomboTest;

- (void) savePDF:(NSString *)path With:(NSString *)summary;

- (void) mouseMovedToPoint:(NSPoint) point;

- (void) mouseMoved:(NSEvent *)theEvent;

//- (void) setWaferHighlightColor:(NSColor *) newColor;


@end
