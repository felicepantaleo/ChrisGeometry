//
//  HXGAppDelegate.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGAppDelegate.h"

@implementation HXGAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifdef DEBUG
    NSLog(@"Starting up: debug on");
    [self showDebugMenu];
    [_gapsStudy setEnabled:YES];
#endif
    
    if(!thePreferences) thePreferences = [HXGPreferenceControl sharedPreferences];

    if(!mainControl) mainControl = [[HXGMainControl alloc] init];
    [mainControl showWindow:nil];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newPreferences:)
               name:HXGNewPreferecesNotification
             object:nil];
    
}

- (void) newPreferences:(NSNotification *) note {
            
}

#pragma mark - Hex menu IBActions

- (IBAction) preferences:(id)sender {
    
    [thePreferences showWindow:nil];
}

- (IBAction) waferSummary:(id)sender {
    
    [mainControl writeWaferSummary];
   
}
/*
 - (IBAction) radiusSummary:(id)sender {
    
    [mainControl writeRadiusSummary];
    
}
*/
- (IBAction) exportPDF:(id)sender {
    
    [mainControl exportPDF];
}

- (IBAction) exportMultiPDF:(id)sender {
    
    [mainControl exportMultiPDF];
}

#pragma mark - Geometry menu IBActions

- (IBAction) illustrateParts:(id)sender {
    if(!partControl) partControl = [[HXGPartControl alloc] init];
    [partControl showWindow:self];
}

- (IBAction) addEtaRings:(id)sender {
    theEtaRings = [HXGEtaRingsControl sharedEtaRings];
    [theEtaRings showWindow:nil];
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

- (IBAction) setTestPosition:(id)sender {
    if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];
    [thePosition showWindow:nil];
}
- (IBAction) deleteTestPoint:(id)sender {
    [mainControl deleteTestPoint];
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

#pragma mark - Cells menu IBActions

- (IBAction) showCells:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    //[mainControl setupCellGeometry];
    [theCellControl setWaferSize:thePreferences.ftof8];

    [theCellControl showWindow:nil];
    [theCellControl drawCellsInWafer:0]; // 0 chooses LD (192)

}

- (IBAction) waferRotation:(id)sender {
    
    if(!theRotationControl) theRotationControl = [HXGdebugRotationControl sharedRotationControl];

    [theRotationControl showWindow:nil];

}

- (IBAction) countCells:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    //[mainControl setupCellGeometry];
    [theCellControl setWaferSize:thePreferences.ftof8];
    
    int iwaf = (int) [sender tag];
    [theCellControl countCells:iwaf];
    
}

- (IBAction) illustrateInclusionRadii:(id)sender {
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];
    [theCellControl setWaferSize:thePreferences.ftof8];
    [theCellControl showWindow:nil];
    [theCellControl drawInclusionRadii];

}

#pragma mark - Longitudinal menu items

- (IBAction) showMaterials:(id)sender {
    if(!materials) materials = [HGCMaterials sharedMaterials];
    [materials showMaterials];
}

- (IBAction) viewStackup:(id)sender {
        
    if(!theStackControl) theStackControl = [HXGStackWindowControl sharedStackControl];
    [theStackControl showWindow:nil];
}

/*- (IBAction) revertToTDR:(id)sender {
    
    //if(!persistantValues) persistantValues = [HGCPersistenceControl sharedPersistence];
    
    if(!theCEEControl) theCEEControl = [CE_EWindowControl sharedCEEControl];
    [theCEEControl setValues];
    
    if(!theCEHControl) theCEHControl = [CE_HWindowControl sharedCEHControl];
    [theCEHControl setValues];
    
}*/

/*
- (IBAction) listCEEOddEven:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.cpItem = _cpItem;
    [theTerminal showWindow:nil];
    [theTerminal listCEEOddEven];
    
}

- (IBAction) listZSensors:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.cpItem = _cpItem;
    [theTerminal showWindow:nil];
    //[theTerminal listZSensors];
    double * z = [mainControl getZLayer];
    [theTerminal listTheseZ:z];
    
}

- (IBAction) listZRho:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.cpItem = _cpItem;
    [theTerminal showWindow:nil];
    [theTerminal listZRho];
    
}
*/
- (IBAction) listdEdx:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp layerdEdx];
    [theTerminal showWindow:nil];

}

- (IBAction) listZsi:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp sensorZ];
    [theTerminal showWindow:nil];

}

- (IBAction) listFrontZ:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    if(!theStackUp) theStackUp = [HXGStackUp sharedStackUp];
    [theStackUp absorberFronts];
    [theTerminal showWindow:nil];

}

- (IBAction) gapsStudy:(id)sender {
    [mainControl gapsStudy];
}

- (IBAction) showLongView:(id)sender {
   
    
    if(!theLongDiagram) theLongDiagram = [HXGLongDiagramControl sharedDiagramControl];

    [theLongDiagram showWindow:nil];

}

#pragma mark - Debug menu IBActions


- (IBAction) testHisto:(id)sender {
    [mainControl testHisto];    
}

- (IBAction) pickColour:(id)sender {
    NSLog(@"pickColour not yet implemented");
}


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
    
    newItem = [[NSMenuItem alloc] initWithTitle:@"Pick colour" action:@selector(pickColour:) keyEquivalent:@""];
    menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];
  
    /*newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Toggle wafer numbering" action:@selector(toggleWaferNumbering:) keyEquivalent:@""];
    menu = [rootMenu itemWithTitle:@"Debug"];
    [[menu submenu] addItem:newItem];*/

}

@end
