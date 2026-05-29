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
#import "HXGCoverageControl.h"
#import "HXGEtaRingsControl.h"
#import "HXGPhiLinesControl.h"
#import "HXGNewCellWindowControl.h"
#import "HXGCellControl.h"
#import "HXGCellAreas.h"
#import "HXGLayerMapFiles.h"
#import "HGCMaterialProperties.h"
#import "HGCTerminalControl.h"
#import "HXGStackWindowControl.h"
#import "HXGStackUp.h"
#import "HXGdebugRotationControl.h"
#import "HXGDisplayPngControl.h"
#import "HXGDisplayAbsorbersControl.h"
#import "HistViewControl.h"
#import "HXGHardwareConstants.h"

#import "HXGrawDataMapControl.h"

#import "HXGNotifications.h"

#import "HXGExamineVolumes.h"

@interface HXGAppDelegate : NSObject <NSApplicationDelegate> {
    HXGMainControl * mainControl;
    HXGPartControl * partControl;
    HXGPreferenceControl * thePreferences;
    HXGPositionControl * thePosition;
    HXGLongDiagramControl * theLongDiagram;
    HXGEtaRingsControl * theEtaRings;
    HXGPhiLinesControl * thePhiLines;
    HXGNewCellWindowControl * theNewCellControl;
    HXGCellControl * theCellControl;
    HXGCellAreas * theCellAreas;
    HXGCoverageControl * theCoverage;
    HXGLayerMapFiles * theMapFiles;
    
    HGCMaterialProperties * materials;
    HGCTerminalControl * theTerminal;
    HXGStackWindowControl  * theStackControl;
    HXGStackUp * theStackUp;
    HXGdebugRotationControl * theRotationControl;
    HXGDisplayPngControl * thePngDisplay;
    HistViewControl * theHist;
    
    HXGDisplayAbsorbersControl * theAbsorbers;
    
    HXGHardwareConstants * theHardwareConstants;
    
    HXGrawDataMapControl * theRawDataMap;
    
    HXGExamineVolumes * theVolumes;

    NSDictionary * itemDict;
    
}

@property (assign) IBOutlet NSWindow * window;
@property (assign) IBOutlet NSMenuItem * undoItem;
@property (assign) IBOutlet NSMenuItem * redoItem;
@property (assign) IBOutlet NSMenuItem * numbersItem;
@property (assign) IBOutlet NSMenuItem * cpItem;

@property (assign) IBOutlet NSMenuItem * waferRadiusSummary;
@property (assign) IBOutlet NSMenuItem * listCEE;
@property (assign) IBOutlet NSMenuItem * listSi;
@property (assign) IBOutlet NSMenuItem * listZ;
@property (assign) IBOutlet NSMenuItem * listWeights;
@property (assign) IBOutlet NSMenuItem * coverageStudy;
@property (assign) IBOutlet NSMenuItem * cellPositionGames;
@property (assign) IBOutlet NSMenuItem * showLongView;

@property (assign) IBOutlet NSMenuItem * testItem;

// ---------- Hex menu
- (IBAction) preferences:(id)sender;
- (IBAction) listHardwareConstants:(id)sender;
- (IBAction) newSiLayerFile:(id)sender;
- (IBAction) changeTileFile:(id)sender;
- (IBAction) exportPDF:(id)sender;
- (IBAction) exportMultiPDF:(id)sender;

// ----------- Geometry menu
- (IBAction) addEtaRings:(id)sender;
- (IBAction) addPhiLines:(id)sender;
- (IBAction) absorberDisplayOptions:(id)sender;
- (IBAction) toggleShowCoords:(id)sender;
- (IBAction) toggleShowFileLine:(id)sender;
- (IBAction) toggleShowWaferCentre:(id)sender;
- (IBAction) setTestPosition:(id)sender;
- (IBAction) deleteTestPoint:(id)sender;
- (IBAction) checkOverlaps:(id)sender;
- (IBAction) countDetIds:(id)sender;
- (IBAction) countDetIdsWithBreakdown:(id)sender;

// ---------- Longitudinal menu
- (IBAction) showLongView:(id)sender;
- (IBAction) viewStackup:(id)sender;
- (IBAction) listStackup:(id)sender;
- (IBAction) showMaterials:(id)sender;
- (IBAction) showLayerDiagram:(id)sender;
- (IBAction) listdEdx:(id)sender;
- (IBAction) listZsi:(id)sender;
- (IBAction) listFrontZ:(id)sender;
- (IBAction) listCuZ:(id)sender;
- (IBAction) coveragePlots:(id)sender;


// ---------- Cells menu
- (IBAction) illustrateParts:(id)sender;
- (IBAction) showCells:(id)sender;
- (IBAction) countCells:(id)sender;
- (IBAction) makeRawDataMap:(id)sender;
- (IBAction) partialsRawDataMap:(id)sender;
- (IBAction) rawDataMapTextFile:(id)sender;
- (IBAction) cellIndexToUVMap:(id)sender;
- (IBAction) waferSummary:(id)sender; // "Module count listing"

//------------ Legacy and debug menu
- (IBAction) oldShowCells:(id)sender;
- (IBAction) waferRotation:(id)sender;
- (IBAction) calculateAreas:(id)sender;
- (IBAction) illustrateInclusionRadii:(id)sender;

- (IBAction) testRetractions:(id)sender;
- (IBAction) listRetractionVectors:(id)sender;
- (IBAction) dEdxAnalysis:(id)sender;
- (IBAction) pruthviCSV:(id)sender;
- (IBAction) test:(id)sender;

//------------ Help menu
- (IBAction) showReminders:(id)sender;
- (IBAction) showSiFileLineHelp:(id)sender;
- (IBAction) showReleaseNotes:(id)sender;

- (void) newPreferences:(NSNotification *) note;

@end
