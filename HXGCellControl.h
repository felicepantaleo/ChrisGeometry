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
#import <Cocoa/Cocoa.h>

@interface HXGCellControl : NSWindowController {
   
    
    HistViewControl * theHist;

    double ftof,side,cside,chf;
    
    double width, height, plotwidth, plotheight;
    
    int ncell,count,iwaf;
    int cellMap[10][10];
    
    NSMutableArray * gridCells;
    NSBezierPath * waferBezier;
    NSPoint waferPoints[6];

    NSButton * pdfButton;
    NSButton * plainColorButton;
    NSButton * cellColorButton;
    NSButton * triggerColorButton;
    NSButton * numberCellsButton;
    NSButton * detIdButton;
    NSButton * triggerIdButton;
    NSButton * outlineButton;
    NSButton * gridButton;
    NSButton * showCoordsButton;
    NSButton * showDimensionsButton;
    NSButton * hyperBrightButton;
    NSButton * axesButton;

    NSButton * showInclusionCircles;
    NSButton * showInclusionCoords;
    
    
    
    BOOL drawing;
    BOOL inclusionRadii;

}

@property (assign) IBOutlet NSSegmentedControl * densityControl;
@property (assign) IBOutlet HXGCellView * cellview;
@property (assign) IBOutlet NSStepper * placementStepper;
@property (assign) IBOutlet NSTextField * placementText;

@property (readonly) int iplacement;


+ (id) sharedCellControl;

- (IBAction) setDensity:(id)sender;
- (IBAction) setPlacementIndex:(id)sender;

- (void) changePlacementIndex: (int) ip;

- (void) setWaferSize:(double) f;

- (void) drawCellsInWafer:(int)iwaf;

- (void) countCells:(int)iwaf;

- (void) drawInclusionRadii;

@end
