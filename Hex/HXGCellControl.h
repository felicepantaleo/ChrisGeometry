//
//  HXGCellControl.h
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HistViewControl.h"
#import "HXGCellView.h"
#import "HXGCell.h"
#import "HXGNotifications.h"
#import "HGCTerminalControl.h"
//#import "HXGrawDataMapControl.h"
#import <Cocoa/Cocoa.h>

@interface HXGCellControl : NSWindowController {
   
    HGCTerminalControl * theTerminal;
//    HXGrawDataMapControl * theRawDataMap;
    HistViewControl * theHist;

    double ftof,side,cside,chf;
    
    double width, height, plotwidth, plotheight;
    
    int ncell,count,iwaf;
    int cellMap[10][10];
    
    NSMutableArray * gridCells;
    //NSBezierPath * waferBezier;
    NSPoint waferPoint[6];

    // NSButton * pdfButton;
    NSButton * plainColorButton;
    NSButton * cellColorButton;
    //NSButton * triggerColorButton;
    NSButton * clickColorButton;
    NSButton * clearButton;
    NSButton * numberCellsButton;
    NSButton * allLabelsButton;
    NSButton * triggerIdButton;
    NSButton * outlineButton;
    NSButton * gridButton;
    NSButton * showCoordsButton;
    NSButton * showDimensionsButton;
    NSButton * hyperBrightButton;
    NSButton * axesButton;
    NSButton * hardwareOrientationButton;

    NSButton * showInclusionCircles;
    NSButton * showInclusionCoords;
    
    NSButton * colSelButton[50]; // Needs to be able to support cellview.cPalette.count
    
    NSPopUpButton * wholeOrPartialPopUp;
    NSPopUpButtonCell * wopCell;
    int partialChoice;
    int nchoice;
    int nPal;
    BOOL previousOrientation;
    BOOL mapped;
    
    BOOL drawing;
    BOOL inclusionRadii;

}

@property (assign) IBOutlet NSSegmentedControl * densityControl;
@property (assign) IBOutlet HXGCellView * cellview;
@property (assign) IBOutlet NSStepper * placementStepper;
@property (assign) IBOutlet NSTextField * placementText;

@property (readonly) int iplacement;
@property (readonly) BOOL HD;
@property (readonly) BOOL ispartial;
@property (readonly) BOOL cellControlWindowOpen;


+ (id) sharedCellControl;

//- (void) cleanup;

- (void) newWaferSetUp:(NSNotification *) note;

- (IBAction) setDensity:(id)sender;

- (IBAction) setupPlacement:(id)sender;

- (IBAction) changeWholeOrPartial:(id)sender;

- (void) setHardwareOrientation:(BOOL) hard;

- (void) makePDF;

- (void) changePlacementIndex: (int) ip;

- (void) setWaferSize:(double) f;

- (void) drawCellsInWafer:(int)iwaf;
/*
- (void) makeRawDataMap;

- (void) partialsRawDataMap;

- (void) rawDataMapTextFile;

- (void) cellIndexToUVMap;

- (void) writeCellIndexToUVMap;
*/
- (void) countCells:(int)iwaf;

- (void) drawInclusionRadii;

@end
