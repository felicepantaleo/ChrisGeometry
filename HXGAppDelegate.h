//
//  HXGAppDelegate.h
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGMainControl.h"
#import "HXGPreferenceControl.h"
#import "HXGPartControl.h"
#import "HXGPositionControl.h"
#import "HXGLongDiagramControl.h"
// #import "HXGScanControl.h"
#import "HXGEtaRingsControl.h"
#import "HXGCellControl.h"
#import "HGCMaterials.h"
#import "HGCTerminalControl.h"
#import "HXGStackWindowControl.h"
#import "HXGStackUp.h"
#import "HXGdebugRotationControl.h"

#import "HXGNotifications.h"



@interface HXGAppDelegate : NSObject <NSApplicationDelegate>
{
    HXGMainControl * mainControl;
    HXGPartControl * partControl;
    HXGPreferenceControl * thePreferences;
    HXGPositionControl * thePosition;
    HXGLongDiagramControl * theLongDiagram;
    HXGEtaRingsControl * theEtaRings;
    HXGCellControl * theCellControl;
    
    HGCMaterials * materials;
    HGCTerminalControl * theTerminal;
    HXGStackWindowControl  * theStackControl;
    HXGStackUp * theStackUp;
    HXGdebugRotationControl * theRotationControl;

    NSDictionary * itemDict;

}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenuItem * undoItem;
@property (assign) IBOutlet NSMenuItem * redoItem;
@property (assign) IBOutlet NSMenuItem * numbersItem;
@property (assign) IBOutlet NSMenuItem * cpItem;

@property (assign) IBOutlet NSMenuItem * waferRadiusSummary;
@property (assign) IBOutlet NSMenuItem * listCEE;
@property (assign) IBOutlet NSMenuItem * listSi;
@property (assign) IBOutlet NSMenuItem * listZ;
@property (assign) IBOutlet NSMenuItem * listWeights;
@property (assign) IBOutlet NSMenuItem * gapsStudy;
@property (assign) IBOutlet NSMenuItem * showLongView;


- (IBAction) preferences:(id)sender;
- (IBAction) waferSummary:(id)sender;
- (IBAction) exportPDF:(id)sender;
- (IBAction) exportMultiPDF:(id)sender;

- (IBAction) illustrateParts:(id)sender;
- (IBAction) addEtaRings:(id)sender;
- (IBAction) toggleShowCoords:(id)sender;
- (IBAction) toggleShowFileLine:(id)sender;
- (IBAction) setTestPosition:(id)sender;
- (IBAction) deleteTestPoint:(id)sender;

- (IBAction) showCells:(id)sender;
- (IBAction) waferRotation:(id)sender;
- (IBAction) countCells:(id)sender;
- (IBAction) illustrateInclusionRadii:(id)sender;

//- (IBAction) copy:(id)sender;

- (IBAction) showMaterials:(id)sender;
- (IBAction) viewStackup:(id)sender;
- (IBAction) listdEdx:(id)sender;
- (IBAction) listZsi:(id)sender;
- (IBAction) listFrontZ:(id)sender;


- (IBAction) testHisto:(id)sender;
- (IBAction) pickColour:(id)sender;

- (void) newPreferences:(NSNotification *) note;

@end
