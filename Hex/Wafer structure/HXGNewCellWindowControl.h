//
//  HXGNewCellWindowControl.h
//  Hex
//
//  Created by Chris Seez on 26/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGStructuredWafer.h"
#import "HXGNewCellView.h"
#import "HXGNotifications.h"
#import "HGCTerminalControl.h"
#import "HXGDisplayPngControl.h"
#import "CSColours.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGNewCellWindowControl : NSWindowController {
    
    HXGStructuredWafer * theStructuredWafer;
    HGCTerminalControl * theTerminal;
    HXGDisplayPngControl * thePngDisplay;

    double width, height, plotwidth, plotheight, plotuppermargin, controlswidth;
    
    int irot;           // This is now the Sunanda iplacement; with -1 and -2 being
                        // hardware orientation and hardware mirrored
    
    int irotCellInfo;   // Co-rodinate system for cell info box (as irot, but no -2)
    
    int nchoice;
    BOOL HD;
    BOOL partial;
    int partialType;
    BOOL mirror;
    BOOL trigger;
    
    NSString * cellInfoText;
    NSString * cellName;
    
    NSPopUpButtonCell * waferMenuCell;


}

@property (assign) IBOutlet HXGNewCellView * cellView;
@property (assign) IBOutlet NSPopUpButton * densePopUp;
@property (assign) IBOutlet NSPopUpButton * waferTypePopUp;
@property (assign) IBOutlet NSPopUpButton * orientationPopUp;
@property (assign) IBOutlet NSButton * triggerButton;
@property (assign) IBOutlet NSButton * dataButton;
@property (assign) IBOutlet NSButton * drawCellsButton;
@property (assign) IBOutlet NSButton * drawGridButton;
@property (assign) IBOutlet NSButton * showDetIdButton;
@property (assign) IBOutlet NSButton * showHardButton;
@property (assign) IBOutlet NSButton * showGridCountButton;
@property (assign) IBOutlet NSButton * markCentroidButton;
@property (assign) IBOutlet NSButton * hideCellInfoButton;
@property (assign) IBOutlet NSButton * sendToTerminalButton;
@property (assign) IBOutlet NSTextField * cellInfoTextField;
@property (assign) IBOutlet NSStepper * magnifyStepper;
@property (assign) IBOutlet NSLevelIndicator * magnifyIndicator;
@property (assign) IBOutlet NSButton * disclosePdfOptionsButton;
@property (assign) IBOutlet NSButton * pdfNoTitleButton;
@property (assign) IBOutlet NSButton * pdfNoBackgroundButton;

@property (assign) IBOutlet NSStepper * placementStepper;

@property (assign) IBOutlet NSButton * helpButton;



+ (id) sharedNewCellControl;

- (void) makePDF;
- (void) testConvertPoint;
- (void) toggleDebugPolyContain;
- (BOOL) testContainsPoint:(NSPoint) pnt;

- (IBAction) changeDensity:(id)sender;
- (IBAction) changeWaferType:(id)sender;
- (IBAction) changeOrientation:(id)sender;
- (IBAction) changeDataTrigger:(id)sender;
- (IBAction) changeDrawCells:(id)sender;
- (IBAction) changeShowDetId:(id)sender;
- (IBAction) changeShowHard:(id)sender;
- (IBAction) changeShowGridCount:(id)sender;
- (IBAction) changeShowEdgeIndex:(id)sender;
- (IBAction) changeShowGeomItems:(id)sender;
- (IBAction) changeShowGrid:(id)sender;
- (IBAction) changeMirroring:(id)sender;
- (IBAction) markCentroid:(id)sender;
- (IBAction) changeMagnification: (id) sender;
- (IBAction) changePlacementForCellInfo:(id)sender;
- (IBAction) sendCellInfoToTerminal:(id)sender;
- (IBAction) changePdfDisclosure:(id)sender;
- (IBAction) changePdfOptions:(id)sender;

- (IBAction) helpOut:(id)sender;

- (IBAction) hideCellInfo:(id)sender;

@end

NS_ASSUME_NONNULL_END
