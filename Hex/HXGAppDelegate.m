//
//  HXGAppDelegate.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGAppDelegate.h"

@implementation HXGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [_testItem setEnabled:NO];
    [_cellPositionGames setEnabled:NO];

#ifdef DEBUG
    NSLog(@"     *************************");
    NSLog(@"     * Starting up: debug on *");
    NSLog(@"     *************************");
    [_testItem setEnabled:YES];
    [_cellPositionGames setEnabled:YES];
#endif
    
    if(!theHardwareConstants) theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];

    
    if(!mainControl) mainControl = [[HXGMainControl alloc] init];
    [mainControl showWindow:nil];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newPreferences:)
               name:HXGNewPreferencesNotification
             object:nil];
    
}

- (void) newPreferences:(NSNotification *) note {
            
}

#pragma mark - Hex menu IBActions

- (IBAction) preferences:(id)sender {
    
    if(!thePreferences) thePreferences = [HXGPreferenceControl sharedPreferences];

    [thePreferences showWindow:nil];
}

- (IBAction) listHardwareConstants:(id)sender {
    
    if(!theHardwareConstants) theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];
    [theHardwareConstants writeConstantsToTerminal];
}


- (IBAction) newSiLayerFile:(id)sender {
    
    [mainControl chooseOtherSiFileAndTile:NO];
}

- (IBAction) changeTileFile:(id)sender {
    
    [mainControl chooseOtherTileFile];
}

- (IBAction) exportPDF:(id)sender {
    
    NSArray * orderedWindows = [NSApp orderedWindows];
    NSWindow * frontWindow = orderedWindows[0];
    int nw = 0;
    
    while ([frontWindow.windowController respondsToSelector: @selector(orderBack:)]) {
        [frontWindow.windowController orderBack:self];
        nw++;
        frontWindow = orderedWindows[nw];
    }
    
    if(mainControl.mainwindow == frontWindow) [mainControl exportPDF];
    else {
        if([frontWindow.windowController respondsToSelector: @selector(makePDF)]) {
            [frontWindow.windowController makePDF];
        } else NSBeep();
    }
    
    for (int i=0; i<nw; i++) {
        [orderedWindows[i] orderFront:self];
    }
}

- (IBAction) exportMultiPDF:(id)sender {
    
    [mainControl exportMultiPDF];
}

#pragma mark - Geometry menu

- (IBAction) addEtaRings:(id)sender {
    
    theEtaRings = [HXGEtaRingsControl sharedEtaRings];
    theEtaRings.iRingColor = mainControl.etaRingColor;
    [theEtaRings showWindow:nil];
}

- (IBAction) addPhiLines:(id)sender {
    
    thePhiLines = [HXGPhiLinesControl sharedPhiLines];
    [thePhiLines showWindow:nil];
    
}

- (IBAction) absorberDisplayOptions:(id)sender {

    if(!theAbsorbers) theAbsorbers = [HXGDisplayAbsorbersControl sharedAbsorberControl];
    [theAbsorbers showWindow:self];
    
}


- (IBAction) toggleShowCoords:(id)sender; {
    
    BOOL show = ![sender state];
    [sender setState:show];
    [mainControl setShowCoords:show];

}

- (IBAction) toggleShowFileLine:(id)sender; {
    
    BOOL show = ![sender state];
    [sender setState:show];
    [mainControl setShowFileLine:show];

}

- (IBAction) toggleShowWaferCentre:(id)sender; {
    
    BOOL show = ![sender state];
    [sender setState:show];
    [mainControl setShowWaferCentre:show];

}


- (IBAction) setTestPosition:(id)sender {
    if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];
    [thePosition showWindow:nil];
}

- (IBAction) deleteTestPoint:(id)sender {
    [mainControl deleteTestPoint];
}


- (IBAction) countDetIds:(id)sender {
    
    [mainControl detIdCount];
}

- (IBAction) countDetIdsWithBreakdown:(id)sender {
    
    [mainControl detIdCountWithBreakdown];
}


/* #pragma mark - Boundaries menu IBActions

- (IBAction) innerLongitudinal:(id)sender {
    
    // make a dictionary to pass down the line...
    itemDict = [NSDictionary dictionaryWithObjectsAndKeys:_undoItem,@"undo",_redoItem,@"redo",_numbersItem,@"numbers",nil];
    [mainControl innerBoundary:(NSDictionary *) itemDict];
    
}

- (IBAction) undo:(id)sender {
    if(!theIBControl) theIBControl = [HXGInnerBoundaryControl sharedInnerBoundaryControl];
    [theIBControl popStackAndRedraw:YES];
}

- (IBAction) redo:(id)sender {
    if(!theIBControl) theIBControl = [HXGInnerBoundaryControl sharedInnerBoundaryControl];
    [theIBControl pushStackAndRedraw:YES];
    }


- (IBAction) innerPDF:(id)sender {
    [mainControl innerPDF:NO];
}

- (IBAction) innerConfigPDF:(id)sender {
    [mainControl innerPDF:YES];
} */

/*- (IBAction) toggleShow60:(id)sender {
    [mainControl toggleShow60];
} */
/*
- (IBAction) outerScan:(id)sender {
    if(!theScan) theScan = [HXGScanControl sharedScanControl];
    [theScan initializeScanTypeOuter:YES];
    [theScan showWindow:nil];
}

- (IBAction) innerScan:(id)sender {
    if(!theScan) theScan = [HXGScanControl sharedScanControl];
    [theScan initializeScanTypeOuter:NO];
    [theScan showWindow:nil];
}
*/
#pragma mark - Longitudinal menu items

- (IBAction) showLongView:(id)sender {
   
    
    if(!theLongDiagram) theLongDiagram = [HXGLongDiagramControl sharedDiagramControl];

    [theLongDiagram showWindow:nil];

}

- (IBAction) viewStackup:(id)sender {
        
    if(!theStackControl) theStackControl = [HXGStackWindowControl sharedStackControl];
    [theStackControl showWindow:nil];
}

- (IBAction) listStackup:(id)sender {
    
    if(!theStackControl) theStackControl = [HXGStackWindowControl sharedStackControl];
    [theStackControl listStackupInformation];
    
}

- (IBAction) showMaterials:(id)sender {
    
    if(!materials) materials = [HGCMaterialProperties sharedMaterials];
    [materials showMaterials];
}

- (IBAction) showLayerDiagram:(id)sender {

    if(!thePngDisplay) thePngDisplay = [HXGDisplayPngControl sharedPngDisplayControl];
    [thePngDisplay setPngFile:@"LayerDimensions20240712"];
    [thePngDisplay setWindowTitle:@"Layer dimensions from 20240712_PARAMETER_DRAWING_VER_2.1" andPdfName:@"LayerDimensions"];
    [thePngDisplay setWidthFraction:1.];
    [thePngDisplay setTopFraction:0.2 andLeftFraction:0.];
    [thePngDisplay.window setBackgroundColor:[NSColor whiteColor]];
    [thePngDisplay showWindow:nil];
    
}

- (IBAction) listdEdx:(id)sender {
    
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp layerdEdx];

}

- (IBAction) listZsi:(id)sender {
    
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp sensorZ];

}

- (IBAction) listFrontZ:(id)sender {
    
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp absorberFronts];

}


- (IBAction) coveragePlots:(id)sender {
    
    if(!theCoverage) theCoverage = [HXGCoverageControl sharedCoverageControl];
    [theCoverage showWindow:nil];
    
}


#pragma mark - Si wafer menu IBActions

- (IBAction) illustrateParts:(id)sender {
    if(!partControl) partControl = [[HXGPartControl alloc] init];
    [partControl showWindow:self];
}

- (IBAction) showCells:(id)sender {
    
    
    if(!theNewCellControl) theNewCellControl = [HXGNewCellWindowControl sharedNewCellControl];
    [theNewCellControl showWindow:nil];

}

- (IBAction) countCells:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    //[mainControl setupCellGeometry];
    [theCellControl setWaferSize:layoutHexagonWidth];
    
    int iwaf = (int) [sender tag];
    [theCellControl countCells:iwaf];
    
}

- (IBAction) makeRawDataMap:(id)sender {

    /*
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    else [theCellControl cleanup];

    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl showWindow:nil];
    [theCellControl makeRawDataMap];
     */
    
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    else [theRawDataMap initialize];
    theRawDataMap.partialWafer = NO;
    [theRawDataMap showWindow:nil];

}

- (IBAction) partialsRawDataMap:(id)sender {

    /*
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    else [theCellControl cleanup];
    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl showWindow:nil];
    [theCellControl partialsRawDataMap];
     */
 
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    else [theRawDataMap initialize];
    theRawDataMap.partialWafer = YES;
    [theRawDataMap showWindow:nil];

}

- (IBAction) rawDataMapTextFile:(id)sender {
 
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    else {
        [theRawDataMap.window close];
        [theRawDataMap initialize];
    }
    [theRawDataMap setupRawDataMapTextFile:mainControl.mainwindow];

}
- (IBAction) cellIndexToUVMap:(id)sender {
 
    /*
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    else [theCellControl cleanup];
    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl showWindow:nil];
    [theCellControl cellIndexToUVMap];
     */
 
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal clearString];
    [theTerminal makeWindowBig];

    theRawDataMap.partialWafer = NO;
    NSString * LDwhole = [theRawDataMap wholeUVMapForHD:NO];
    NSString * HDwhole = [theRawDataMap wholeUVMapForHD:YES];

    
    theRawDataMap.partialWafer = YES;
    NSString * LDpartial = [theRawDataMap partialUVMapForHD:NO];
    NSString * HDpartial = [theRawDataMap partialUVMapForHD:YES];
    
    NSArray * LDw = [LDwhole componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray * HDw = [HDwhole componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray * LDp = [LDpartial componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray * HDp = [HDpartial componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    [theTerminal displayString:@"  LD whole    |   HD whole    |  LD partial   |  HD partial   |\n"];
    for(int i=0; i<HDp.count-1; i++) {
        NSString * line;
        if(i < LDw.count-1) line = [NSString stringWithString:LDw[i]];
        else line = @"            ";
        if(i < HDw.count-1) line = [line stringByAppendingFormat:@"  | %@",HDw[i]];
        else line = [line stringByAppendingString:@"  |             "];
        if(i < LDp.count-1) line = [line stringByAppendingFormat:@"  | %@",LDp[i]];
        else line = [line stringByAppendingString:@"  |             "];
        line = [line stringByAppendingFormat:@"  | %@  |\n",HDp[i]];
        [theTerminal displayString:line];
    }
     
    theTerminal.suggestedName = @"CellIndexToUVmap";
    [theTerminal showWindow:nil];

}

- (IBAction) waferSummary:(id)sender {
    
    [mainControl pedroStyleSummary];
}


#pragma mark - Legacy and debug menu

- (IBAction) oldShowCells:(id)sender {
    
    if(theRotationControl) [theRotationControl.window close];
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
 //   else [theCellControl cleanup];
    //[mainControl setupCellGeometry];
    [theCellControl setWaferSize:layoutHexagonWidth];

    [theCellControl showWindow:nil];
    [theCellControl drawCellsInWafer:0]; // 0 chooses LD (192)

}

- (IBAction) waferRotation:(id)sender {
    
    if(!theRotationControl) theRotationControl = [HXGdebugRotationControl sharedRotationControl];

    [theRotationControl showWindow:nil];

}

- (IBAction) checkOverlaps:(id)sender {
    
    [mainControl checkSiTileOverlaps];
}

- (IBAction) calculateAreas:(id)sender {
    
    theCellAreas = [HXGCellAreas sharedCellAreas];
    [theCellAreas calculateCellAreas];
}

- (IBAction) illustrateInclusionRadii:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl showWindow:nil];
    [theCellControl drawInclusionRadii];

}

- (IBAction) listCuZ:(id)sender {
    
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp frontBackCEECu];

}


- (IBAction) test:(id)sender {
//    [mainControl testHisto];
    
//    if(!theVolumes) theVolumes = [HXGExamineVolumes sharedVolumes];
//    [theVolumes birthdayNonsense];
    
//    [mainControl.hexview HDLDcomboTest];

    if(!theNewCellControl) theNewCellControl = [HXGNewCellWindowControl sharedNewCellControl];
    [theNewCellControl toggleDebugPolyContain];
}

- (IBAction) testRetractions:(id)sender {
    mainControl.testRetractions = !mainControl.testRetractions;
}

- (IBAction) listRetractionVectors:(id)sender {
        
    NSString * outputString = @"CE-E (calculated):\n";
    
    double delta = M_PI/3.;
    double phi = M_PI/6.;
    double r = 4.734;
    
    for (int i=0; i<6; i++) {
        double x = r*cos(phi);
        double y = r*sin(phi);
        outputString = [outputString stringByAppendingFormat:@" %.2f %.2f",x,y];
        phi += delta;
    }

    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    outputString = [outputString stringByAppendingString:@"\n\nCE-E (from layer map file):\n"];

    for (int i=0; i<6; i++) {
        double x = [theMapFiles getRetVecForCEtype:0 andCassette:i+1].x;
        double y = [theMapFiles getRetVecForCEtype:0 andCassette:i+1].y;
        outputString = [outputString stringByAppendingFormat:@" %.2f %.2f",x,y];
    }
  
    outputString = [outputString stringByAppendingString:@"\n\nCE-H:\n"];
    
    double phi1 = M_PI/15.;
    double phi2 = phi1 * 4.;
    r = 7.;
    for (int i=0; i<6; i++) {
        double x = r*cos(phi1);
        double y = r*sin(phi1);
        outputString = [outputString stringByAppendingFormat:@" %.2f %.2f",x,y];
        x = r*cos(phi2);
        y = r*sin(phi2);
        outputString = [outputString stringByAppendingFormat:@" %.2f %.2f",x,y];
        phi1 += delta;
        phi2 += delta;
    }
    
    outputString = [outputString stringByAppendingString:@"\n\nCE-H (from layer map file):\n"];

    for (int i=0; i<12; i++) {
        double x = [theMapFiles getRetVecForCEtype:1 andCassette:i+1].x;
        double y = [theMapFiles getRetVecForCEtype:1 andCassette:i+1].y;
        outputString = [outputString stringByAppendingFormat:@" %.2f %.2f",x,y];
    }

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal clearString];
    [theTerminal makeWindowWide];
    theTerminal.suggestedName = @"RetractionVectors";

    [theTerminal displayString:outputString];
    

}

- (IBAction) dEdxAnalysis:(id)sender {
    
    if(!theVolumes) theVolumes = [HXGExamineVolumes sharedVolumes];
    [theVolumes loadFileAndDoIt:[mainControl window]];
    //[theVolumes dEdxOnePass];
    
}

- (IBAction) pruthviCSV:(id)sender {
    
    [mainControl performPruthviCheck];
}

#pragma mark - Help menu
- (IBAction) showReminders:(id)sender {
     
    if(!thePngDisplay) thePngDisplay = [HXGDisplayPngControl sharedPngDisplayControl];
    [thePngDisplay setPngFile:@"HexHelp"];
    [thePngDisplay setWindowTitle:@"Aide-memoire" andPdfName:@"HexHelp"];
    [thePngDisplay setHeightFraction:0.7];
    [thePngDisplay setTopFraction:0. andLeftFraction:0.3];
    [thePngDisplay.window setBackgroundColor:[NSColor whiteColor]];
    [thePngDisplay showWindow:nil];

}

- (IBAction) showSiFileLineHelp:(id)sender {
    
    if(!thePngDisplay) thePngDisplay = [HXGDisplayPngControl sharedPngDisplayControl];
    [thePngDisplay setPngFile:@"SiFileLineKey"];
    [thePngDisplay setWindowTitle:@"Aide-memoire" andPdfName:@"SiFileLineKey"];
    [thePngDisplay setWidthFraction:0.3];
    [thePngDisplay setTopFraction:0. andLeftFraction:0.4];
    [thePngDisplay.window setBackgroundColor:[NSColor paleBlue]];
    [thePngDisplay showWindow:nil];

}

- (IBAction) showReleaseNotes:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    
    theTerminal.suggestedName = @"ReleaseNotes";

    [theTerminal makeWindowBig];
    [theTerminal clearString];
    [theTerminal setDarkBackground:NO];
    //---- Read the file...

    NSString * file = @"ReleaseNotes";
    NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    
    [theTerminal displayString:fileContents];

}

/*
- (IBAction) storeHardwareNumberingMap:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    else [theCellControl cleanup];
    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl showWindow:nil];
    [theCellControl writeCellIndexToUVMap];

}
*/

/*
#pragma mark - make Debug menu...

- (void) showDebugMenu; {
    NSMenu* rootMenu = [NSApp mainMenu];
    if([rootMenu itemWithTitle:@"Debug"]) return;
    NSMenuItem *newItem;
    
    // Add the menu
    //[[NSMenuItem alloc] init]
    newItem = [[NSMenuItem alloc] initWithTitle:@"Debug" action:NULL keyEquivalent:@""];
    NSMenu * debugMenu = [[NSMenu alloc] initWithTitle:@"Debug"];
    [newItem setSubmenu:debugMenu];
    [[NSApp mainMenu] addItem:newItem];
    
    // Add items

    newItem = [[NSMenuItem alloc] initWithTitle:@"Test histo" action:@selector(testHisto:) keyEquivalent:@""];
    NSMenuItem * menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];

    newItem = [[NSMenuItem alloc] initWithTitle:@"Toggle retracted centre check" action:@selector(testRetractions:) keyEquivalent:@""];
    menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];

    newItem = [[NSMenuItem alloc] initWithTitle:@"List retraction vectors" action:@selector(retractionVectors:) keyEquivalent:@""];
    menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];
    
 
    newItem = [[NSMenuItem alloc] initWithTitle:@"Store hardware numbering map" action:@selector(storeHardwareNumberingMap:) keyEquivalent:@""];
    menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];
}
 */

@end
