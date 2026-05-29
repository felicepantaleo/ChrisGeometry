//
//  HXGCellLocatorWindowControl.h
//  Hex
//
//  Created by Chris Seez on 10/06/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGWafer.h"
#import "HXGStructuredWafer.h"
#import "HXGStructuredCell.h"
#import "HXGNotifications.h"
#import "HGCTerminalControl.h"
#import "HXGNeighbourFinder.h"
#import "HXGDetIdInterface.h"
#import "HXGCellIndex.h"
#import "HXGPruthviCSV.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGCellLocatorWindowControl : NSWindowController {
    
    HXGStructuredWafer * theStructuredWafer;
    HXGWafer * wafer;
    HGCTerminalControl * theTerminal;
    HXGNeighbourFinder * theNeighbours;
    HXGDetIdInterface * theInterface;
    HXGPruthviCSV * thePruthviCSV;

    NSMutableArray * waferList;
    NSMutableArray * cellList[3];
    NSMutableArray * cellListList;
    
    NSPoint wCentre;
    NSPoint cellCentroid;
    BOOL showTheCell;
    BOOL validPoint;
    BOOL neighbourFinder;
    BOOL pruthviCell;
 
    NSString * debugString;
    NSString * waferString;
    NSString * cellString;
    
    int wuv[2];
    int cuv[2];
    int iu,iv;
    int layer;
    BOOL HD;
    BOOL isMirrored;
    BOOL rot;
    
    NSPoint gPnt,pPnt;
    
}

@property BOOL retracted;
@property NSPoint startingPoint;

@property (assign) IBOutlet NSTextField * layerAndWaferTextField;
@property (assign) IBOutlet NSTextField * cellIuTextField;
@property (assign) IBOutlet NSTextField * cellIvTextField;
@property (assign) IBOutlet NSTextField * resultTextField;

@property (assign) IBOutlet NSStepper * iuStepper;
@property (assign) IBOutlet NSStepper * ivStepper;

@property (assign) IBOutlet NSButton * showCellButton;
@property (assign) IBOutlet NSButton * sendToTerminalButton;

extern const int densityNumberLD;
extern const int densityNumberHD;

+ (id) sharedCellLocatorControl;

- (void) orderBack:(id) sender;

- (void) locatePruthviCell: (int) ipruthvi inWafer:(HXGWafer *) waf ofLayer:(int) nLayer rotated30:(BOOL) rot30;

- (void) locateCellsIn:(HXGWafer *) wafer ofLayer:(int) nLayer rotated30:(BOOL) rot;

- (void) neighbourCellsIn:(HXGWafer *) waf ofLayer:(int) nLayer rotated30:(BOOL) rot30;

- (IBAction) newValue:(id)sender;

- (IBAction) showCellPoint:(id)sender;

- (IBAction) sendToTerminal:(id)sender;

- (void) newLayer:(NSNotification *) note;

@end

NS_ASSUME_NONNULL_END
