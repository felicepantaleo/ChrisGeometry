//
//  HXGCellControl.m
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCellControl.h"

NSString * const HXGCellSpecNotification = @"HXGNewCellSpec";

@interface HXGCellControl ()

@end

@implementation HXGCellControl

+ (id) sharedCellControl {
    
    static dispatch_once_t pred;
    static HXGCellControl * theCellControl = nil;
    
    dispatch_once(&pred, ^{ theCellControl = [[self alloc] init]; });
    return theCellControl;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGCellControl"];
    
    gridCells = [NSMutableArray array];
    
    partialChoice = 0;
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newWaferSetUp:)
               name:HXGNewWaferSetUpNotification
             object:nil];

    return self;
}



- (void)windowDidLoad {
    [super windowDidLoad];
    
    plotheight = 0.88 * ([[NSScreen mainScreen] frame].size.height-22.);
    plotwidth = 0.9 * plotheight;
    height = plotheight + 90.;
    
    width = plotwidth;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(40.,[[NSScreen mainScreen] frame].size.height-height-22.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(0.0,height - plotheight - 22.);
    vRect.size = NSMakeSize(plotwidth,plotheight);
    id test = [_cellview initWithFrame:vRect]; // some redundancy to sort out here
    if(test != _cellview) {
        NSLog(@"Marbles lost");
    }
    
    [_cellview setViewFrame:vRect];
    
/*    // ------------------- make pdf button
    NSRect brect = NSMakeRect(width-90.,6.,75.,20.);
    pdfButton = [[NSButton alloc] initWithFrame:brect];
    [pdfButton setTitle:@"make PDF"];
    [pdfButton setAction:@selector(makePDF:)];
    [pdfButton setBezelStyle:NSBezelStyleTexturedRounded];
    [pdfButton setBordered:YES];

    [pdfButton setKeyEquivalent:@"p"];
    [pdfButton setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    [[[self window] contentView] addSubview:pdfButton];
*/
    // ------------------- pop-up menu for partials choice
    NSRect brect = NSMakeRect(10.,height-55.,150.,20.);
    wholeOrPartialPopUp = [[NSPopUpButton alloc] initWithFrame:brect pullsDown:NO];
    wopCell = [wholeOrPartialPopUp cell];
    [wholeOrPartialPopUp setAction:@selector(changeWholeOrPartial:)];
    [self makePartialMenu];
    [[[self window] contentView] addSubview:wholeOrPartialPopUp];

    // ---------------- cell colour choices
    brect = NSMakeRect(2.,40.,135.,18.);
    plainColorButton = [[NSButton alloc] initWithFrame:brect];
    [plainColorButton setTitle:@"monotone"];
    [plainColorButton setAction:@selector(changeColorCoding:)];
    [plainColorButton setButtonType:NSButtonTypeRadio];
    [[plainColorButton cell] setImagePosition:NSImageRight];
    [plainColorButton setAlignment:NSTextAlignmentRight];
    [plainColorButton setTag:0];
    [[[self window] contentView] addSubview:plainColorButton];
    brect = NSMakeRect(2.,22.,135.,18.);
    cellColorButton = [[NSButton alloc] initWithFrame:brect];
    [cellColorButton setTitle:@"cell type colours"];
    [cellColorButton setAction:@selector(changeColorCoding:)];
    [cellColorButton setButtonType:NSButtonTypeRadio];
    [[cellColorButton cell] setImagePosition:NSImageRight];
    [cellColorButton setAlignment:NSTextAlignmentRight];
    [cellColorButton setTag:1];
    [[[self window] contentView] addSubview:cellColorButton];
    
    brect = NSMakeRect(2.,4.,135.,18.);
    clickColorButton = [[NSButton alloc] initWithFrame:brect];
    [clickColorButton setTitle:@"click cell colours"];
    [clickColorButton setAction:@selector(changeColorCoding:)];
    [clickColorButton setButtonType:NSButtonTypeRadio];
    [[clickColorButton cell] setImagePosition:NSImageRight];
    [clickColorButton setAlignment:NSTextAlignmentRight];
    [clickColorButton setTag:2];
    [[[self window] contentView] addSubview:clickColorButton];
    /*
    triggerColorButton = [[NSButton alloc] initWithFrame:brect];
    [triggerColorButton setTitle:@"trigger cell colours"];
    [triggerColorButton setAction:@selector(changeColorCoding:)];
    [triggerColorButton setButtonType:NSButtonTypeRadio];
    [[triggerColorButton cell] setImagePosition:NSImageRight];
    [triggerColorButton setAlignment:NSTextAlignmentRight];
    [triggerColorButton setTag:2];
    [[[self window] contentView] addSubview:triggerColorButton];
     */

    _cellview.colorCells = 1;
    [plainColorButton setState:NO];
    [cellColorButton setState:YES];
    [clickColorButton setState:NO];
    //[triggerColorButton setEnabled:NO];
    
    // ----------- colourSelectionButtons for clickColors
    
    nPal = (int) _cellview.cPalette.count;
    brect = NSMakeRect(320.-(double)nPal*11.5,780.,20.,20.);
    _cellview.paletteRect = brect;
    for(int i=0; i<nPal; i++) {
        colSelButton[i] = [[NSButton alloc] initWithFrame:brect];
        [colSelButton[i] setAction:@selector(changeSelectedColor:)];
        [colSelButton[i] setTitle:@""];
        [colSelButton[i] setButtonType:NSButtonTypeOnOff];
        [colSelButton[i] setBordered:NO];
        [colSelButton[i] highlight:YES];
        [[colSelButton[i] cell] setBackgroundColor:_cellview.cPalette[i]];
        [[[self window] contentView] addSubview:colSelButton[i]];
        [colSelButton[i] setTag:i];
        [colSelButton[i] setHidden:YES];
        brect.origin.x += 23.;
    }
    brect.origin.x += 2.;
    brect.size.width = 50.;
    //brect.size.height = 30.;
    clearButton = [[NSButton alloc] initWithFrame:brect];
    [clearButton setTitle:@"clear"];
    [clearButton setAction:@selector(clearClicked:)];
    [clearButton setButtonType:NSButtonTypeMomentaryPushIn];
    [clearButton setBezelStyle:NSBezelStyleTexturedRounded];
    [clearButton setBordered:YES];

    [clearButton setKeyEquivalent:@"\r"];
    [clearButton setKeyEquivalentModifierMask:0];
    [[[self window] contentView] addSubview:clearButton];
    [clearButton setHidden:YES];

    
    
    
    // ----------- numbering of cells

    brect = NSMakeRect(142.,40.,100.,18.);
    numberCellsButton = [[NSButton alloc] initWithFrame:brect];
    [numberCellsButton setTitle:@"number cells"];
    [numberCellsButton setAction:@selector(changeNumbering:)];
    [numberCellsButton setButtonType:NSButtonTypeSwitch];
    [[numberCellsButton cell] setImagePosition:NSImageRight];
    [numberCellsButton setAlignment:NSTextAlignmentRight];
    [numberCellsButton setTag:0];
    [[[self window] contentView] addSubview:numberCellsButton];
    
    
    brect = NSMakeRect(142.,22.,100.,18.);
    allLabelsButton = [[NSButton alloc] initWithFrame:brect];
    [allLabelsButton setTitle:@"include hw #"];
    [allLabelsButton setAction:@selector(changeNumbering:)];
    [allLabelsButton setButtonType:NSButtonTypeSwitch];
    [[allLabelsButton cell] setImagePosition:NSImageRight];
    [allLabelsButton setAlignment:NSTextAlignmentRight];
    [allLabelsButton setTag:1];
    [[[self window] contentView] addSubview:allLabelsButton];
    
    /*
    brect = NSMakeRect(150.,4.,95.,18.);
    triggerIdButton = [[NSButton alloc] initWithFrame:brect];
    [triggerIdButton setTitle:@"trigger detId"];
    [triggerIdButton setAction:@selector(changeNumbering:)];
    [triggerIdButton setButtonType:NSButtonTypeSwitch];
    [[triggerIdButton cell] setImagePosition:NSImageRight];
    [triggerIdButton setAlignment:NSTextAlignmentRight];
    [triggerIdButton setTag:2];
    [[[self window] contentView] addSubview:triggerIdButton];
     */

    _cellview.numberCells = YES;
    //_cellview.useDetId = YES;
    _cellview.triggerId = NO;
    [numberCellsButton setState:YES];
    [allLabelsButton setState:YES];
    [triggerIdButton setState:NO];

    // ----------- other graphics
    
    brect = NSMakeRect(242.,40.,135.,18.);
    outlineButton = [[NSButton alloc] initWithFrame:brect];
    [outlineButton setTitle:@"outline and centre"];
    [outlineButton setAction:@selector(changeGraphics:)];
    [outlineButton setButtonType:NSButtonTypeSwitch];
    [[outlineButton cell] setImagePosition:NSImageRight];
    [outlineButton setAlignment:NSTextAlignmentRight];
    [outlineButton setTag:0];
    [[[self window] contentView] addSubview:outlineButton];
    
    brect = NSMakeRect(242.,22.,135.,18.);
    gridButton = [[NSButton alloc] initWithFrame:brect];
    [gridButton setTitle:@"show grid"];
    [gridButton setAction:@selector(changeGraphics:)];
    [gridButton setButtonType:NSButtonTypeSwitch];
    [[gridButton cell] setImagePosition:NSImageRight];
    [gridButton setAlignment:NSTextAlignmentRight];
    [gridButton setTag:1];
    [[[self window] contentView] addSubview:gridButton];
    
    brect = NSMakeRect(242.,4.,135.,18.);
    showCoordsButton = [[NSButton alloc] initWithFrame:brect];
    [showCoordsButton setTitle:@"show coordinates"];
    [showCoordsButton setAction:@selector(changeGraphics:)];
    [showCoordsButton setButtonType:NSButtonTypeSwitch];
    [[showCoordsButton cell] setImagePosition:NSImageRight];
    [showCoordsButton setAlignment:NSTextAlignmentRight];
    [showCoordsButton setTag:2];
    [[[self window] contentView] addSubview:showCoordsButton];
    
    brect = NSMakeRect(377.,40.,155.,18.);
    showDimensionsButton = [[NSButton alloc] initWithFrame:brect];
    [showDimensionsButton setTitle:@"show cell dimensions"];
    [showDimensionsButton setAction:@selector(changeGraphics:)];
    [showDimensionsButton setButtonType:NSButtonTypeSwitch];
    [[showDimensionsButton cell] setImagePosition:NSImageRight];
    [showDimensionsButton setAlignment:NSTextAlignmentRight];
    [showDimensionsButton setTag:3];
    [[[self window] contentView] addSubview:showDimensionsButton];
    
    brect = NSMakeRect(377.,22.,155.,18.);
    hyperBrightButton = [[NSButton alloc] initWithFrame:brect];
    [hyperBrightButton setTitle:@"highlight edge cells"];
    [hyperBrightButton setAction:@selector(changeGraphics:)];
    [hyperBrightButton setButtonType:NSButtonTypeSwitch];
    [[hyperBrightButton cell] setImagePosition:NSImageRight];
    [hyperBrightButton setAlignment:NSTextAlignmentRight];
    [hyperBrightButton setTag:4];
    [[[self window] contentView] addSubview:hyperBrightButton];
    
    brect = NSMakeRect(377.,4.,155.,18.);
    axesButton = [[NSButton alloc] initWithFrame:brect];
    [axesButton setTitle:@"show u,v axes"];
    [axesButton setAction:@selector(changeGraphics:)];
    [axesButton setButtonType:NSButtonTypeSwitch];
    [[axesButton cell] setImagePosition:NSImageRight];
    [axesButton setAlignment:NSTextAlignmentRight];
    [axesButton setTag:6];
    [[[self window] contentView] addSubview:axesButton];
    
// ----------- Special module orientation choice
 
    brect = NSMakeRect(width-163.,40.,155.,18.);
    hardwareOrientationButton = [[NSButton alloc] initWithFrame:brect];
    [hardwareOrientationButton setTitle:@"Hardware orientation"];
    [hardwareOrientationButton setAction:@selector(hardwareOrientation:)];
    [hardwareOrientationButton setButtonType:NSButtonTypeSwitch];
    [[hardwareOrientationButton cell] setImagePosition:NSImageRight];
    [hardwareOrientationButton setAlignment:NSTextAlignmentRight];
    [hardwareOrientationButton setTag:0];
    [[[self window] contentView] addSubview:hardwareOrientationButton];

    
    
// ------------ Inclusion radii buttons
    
    brect = NSMakeRect(width-160.,28.,145.,18.);
    showInclusionCircles = [[NSButton alloc] initWithFrame:brect];
    [showInclusionCircles setTitle:@"show inclusion circles"];
    [showInclusionCircles setAction:@selector(changeGraphics:)];
    [showInclusionCircles setButtonType:NSButtonTypeSwitch];
    [[showInclusionCircles cell] setImagePosition:NSImageRight];
    [showInclusionCircles setAlignment:NSTextAlignmentRight];
    [showInclusionCircles setTag:5];
    [[[self window] contentView] addSubview:showInclusionCircles];
    
    brect = NSMakeRect(width-160.,10.,145.,18.);
    showInclusionCoords = [[NSButton alloc] initWithFrame:brect];
    [showInclusionCoords setTitle:@"show mouse radius"];
    [showInclusionCoords setAction:@selector(changeGraphics:)];
    [showInclusionCoords setButtonType:NSButtonTypeSwitch];
    [[showInclusionCoords cell] setImagePosition:NSImageRight];
    [showInclusionCoords setAlignment:NSTextAlignmentRight];
    [showInclusionCoords setTag:2];
    [[[self window] contentView] addSubview:showInclusionCoords];
    
    _cellview.showOutline = NO;
    _cellview.showGrid = NO;
    _cellview.showCoords = NO;
    _cellview.showDimensions = NO;
    _cellview.hyperBright = NO;
    _cellview.showCircles = YES;
    _cellview.showAxes = NO;
    _cellview.allLabels = YES;
    
    [outlineButton setState:_cellview.showOutline];
    [gridButton setState:_cellview.showGrid];
    [showCoordsButton setState:_cellview.showCoords];
    [showDimensionsButton setState:_cellview.showDimensions];
    [hyperBrightButton setState:_cellview.hyperBright];
    [showInclusionCircles setState:_cellview.showCircles];
    [axesButton setState:_cellview.showAxes];
    
    //[triggerColorButton setEnabled:NO];
    [triggerIdButton setEnabled:NO];

    _iplacement = 0;
    [_placementStepper setIntValue:_iplacement];
    [_placementStepper setMaxValue:11];
    [_placementStepper setValueWraps:YES];
    [_placementText setStringValue:[NSString stringWithFormat:@"Placement index = %2d",_iplacement]];


}

- (void) hideStandard: (BOOL) hide {
    
    [plainColorButton setHidden:hide];
    [cellColorButton setHidden:hide];
    [clickColorButton setHidden:hide];
    [numberCellsButton setHidden:hide];
    [allLabelsButton setHidden:hide];
    [triggerIdButton setHidden:hide];
    [outlineButton setHidden:hide];
    [gridButton setHidden:hide];
    [showCoordsButton setHidden:hide];
    [showDimensionsButton setHidden:hide];
    [hyperBrightButton setHidden:hide];
    [axesButton setHidden:hide];
    [hardwareOrientationButton setHidden:hide];

    [_densityControl setHidden:hide];
    [_placementStepper setHidden:hide];
    [_placementText setHidden:hide];
    [wholeOrPartialPopUp setHidden:hide];

    [showInclusionCoords setHidden:!hide];
    [showInclusionCircles setHidden:!hide];

    _cellview.showCoords = NO;
    [showInclusionCoords setState:!hide];
    
    for (int i=0; i<_cellview.cPalette.count; i++) {
        [colSelButton[i] setHidden:YES];
    }
    [clearButton setHidden:YES];
    _cellview.colorCells = 1;
    [plainColorButton setState:NO];
    [cellColorButton setState:YES];
    [clickColorButton setState:NO];

    
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
    _iplacement = (int)[_placementStepper integerValue];
    [_cellview initializePlacementIndex:_iplacement];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [[self window] makeFirstResponder:_cellview];
    
    for (int i=0; i<_cellview.cPalette.count; i++) {
        [colSelButton[i] setToolTip:_cellview.cNames[i]];
    }
    
    _cellControlWindowOpen = YES;

}

- (void)windowWillClose:(NSNotification *)notification {
  
    _cellControlWindowOpen = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];
}

/*
- (void) cleanup {
   
    if(theRawDataMap) {
        [theRawDataMap.window close];
        _cellview.showOutline = NO;
        _cellview.showGrid = NO;
        _cellview.showCoords = NO;
        _cellview.showDimensions = NO;
        _cellview.hyperBright = NO;
        _cellview.showCircles = YES;
        _cellview.showAxes = NO;
        
        [outlineButton setState:_cellview.showOutline];
        [gridButton setState:_cellview.showGrid];
        [showCoordsButton setState:_cellview.showCoords];
        [showDimensionsButton setState:_cellview.showDimensions];
        [hyperBrightButton setState:_cellview.hyperBright];
        [showInclusionCircles setState:_cellview.showCircles];
        [axesButton setState:_cellview.showAxes];
        
        [hardwareOrientationButton setState:NO];
        _cellview.hardwareOrientation = NO;

        partialChoice = 0;
        _cellview.wholePartial = NO;
        _cellview.partial = partialChoice;
        _cellview.ispartial = NO;
        
    }
}
*/
- (void) makePDF {
    
    //NSLog(@"makePDF");
    //int ncellWaf = 3 * count * count;
    NSString * filename;
    if(inclusionRadii) {
        filename = @"inclusionRadii.pdf";
    } else {
        NSString * dStr = @"LD";
        if(_cellview.HD) dStr =@"HD";
        
        if(_cellview.wholePartial) dStr = [dStr stringByAppendingString:@"partial"];
        else dStr = [dStr stringByAppendingFormat:@"%d",_cellview.partial];
        if(_cellview.hardwareOrientation) {
            filename = [dStr stringByAppendingString:@"CellNumbers.pdf"];
        } else if(_iplacement != 0) {
            filename = [dStr stringByAppendingFormat:@"ip%02d.pdf",_iplacement];
        } else filename = [dStr stringByAppendingString:@".pdf"];
    }
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self->_cellview savePDF:pdfpath];
        }
    }];
 
    //NSLog(@"EXIT makePDF");

}

#pragma mark - new setup notification
- (void) newWaferSetUp:(NSNotification *) note {
    
    // Needs to be in CellControl and similar to change density
    // Send all the info in the userInfo
    // changeSelectedRoc in rawDataMapControl needs to be split into
    // stepper action and button action (or maybe not? if can deal with halfCount better...)
  
    if([[note userInfo] objectForKey:@"setDensity"]) {
        int dens = [[[note userInfo] objectForKey:@"setDensity"] intValue];
        _HD = (dens != 0);
    }
    if([[note userInfo] objectForKey:@"setPartial"]) {
        int part = [[[note userInfo] objectForKey:@"setPartial"] intValue];
        partialChoice = part;
    }

//    [self partialsRawDataMap];
    
}


#pragma mark - IBActions

- (IBAction) setupPlacement:(id)sender {
    
    _iplacement = (int)[_placementStepper integerValue];
    [self changePlacementIndex:_iplacement];

}

- (IBAction) setDensity:(id)sender {

    iwaf = (int) [sender selectedSegment];
    _cellview.HD = (iwaf == 1);
    _cellview.wholePartial = NO;
//    theRawDataMap.partialWafer = NO;
    [self makePartialMenu];
    [self makeCells:iwaf];
    partialChoice = 0;
    //[self setHardwareOrientation:NO];
    [_cellview drawCells:gridCells forWafer:waferPoint];
    [self changePlacementIndex:_iplacement];

    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

}


- (void) changeColorCoding:(id)sender {
    
    int tag = (int) [sender tag];
    _cellview.colorCells = tag;
    [plainColorButton setState:(tag == 0)];
    [cellColorButton setState:(tag == 1)];
    [clickColorButton setState:(tag == 2)];
    [_cellview setNeedsDisplay:YES];
    
    for(int i=0;i<nPal;i++){ [colSelButton[i] setHidden:(tag != 2)]; }
    [clearButton setHidden:(tag != 2)];

    
    if(tag == 2) {
        [_cellview setColSelRect];
    } 
}

- (void) changeSelectedColor: (id) sender {
    
    _cellview.icsel = (int) [sender tag];
    [_cellview setNeedsDisplay:YES];

}

- (void) clearClicked:(id) sender {
    
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        c.clickColor = 0;
    }
    [_cellview setNeedsDisplay:YES];

}

- (void) changeNumbering:(id)sender {
    
    int tag = (int) [sender tag];
    
    if(tag == 0) {
        _cellview.numberCells = [sender state];
    } else if(tag == 1) {
        _cellview.allLabels = [sender state];
    }
    /*
    else {
        _cellview.triggerId = [sender state];
        //_cellview.numberCells = NO;
        //[numberCellsButton setState:NO];
        _cellview.colorCells = 2;
        [plainColorButton setState:NO];
        [cellColorButton setState:NO];
        [triggerColorButton setState:YES];
    }
    */
    [_cellview setNeedsDisplay:YES];

}

- (void) changeGraphics:(id)sender {
    
    int tag = (int) [sender tag];
    
    if(tag == 0) {
        _cellview.showOutline = [sender state];
    } else if(tag == 1) {
        _cellview.showGrid = [sender state];
    } else if(tag == 2) {
        _cellview.showCoords = [sender state];
    } else if(tag == 3) {
        _cellview.showDimensions = [sender state];
    } else if(tag == 4) {
        _cellview.hyperBright = [sender state];
    } else if(tag == 5) {
        _cellview.showCircles = [sender state];
    } else if(tag == 6) {
        _cellview.showAxes = [sender state];
        if([sender state]) [_cellview makeAxes];
    }
    
    [_cellview setNeedsDisplay:YES];

}

- (void) setHardwareOrientation:(BOOL) hard {
 
    [hardwareOrientationButton setState:hard];
    _cellview.hardwareOrientation = hard;
    [_placementStepper setHidden:_cellview.hardwareOrientation];
    [_placementText setHidden:_cellview.hardwareOrientation];
    [self changePlacementIndex:0];
    if(_cellview.hardwareOrientation) {
        [self changePlacementIndex:0];
        [gridButton setState:NO];
    } else {
        if(partialChoice==0) [_placementStepper setHidden:NO];
        if(partialChoice==0) [_placementText setHidden:NO];
    }

    [_placementStepper setHidden:(partialChoice!=0 || _cellview.hardwareOrientation)];
    [_placementText setHidden:(partialChoice!=0 || _cellview.hardwareOrientation)];

    [_cellview setNeedsDisplay:YES];

    if(hard) [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

}
- (void) hardwareOrientation:(id)sender {
    
    [self setHardwareOrientation:[sender state]];
}

- (IBAction) changeWholeOrPartial:(id)sender {
 
    int initialPartialChoice = partialChoice;
    partialChoice = (int) [wholeOrPartialPopUp indexOfSelectedItem];
    if(partialChoice == initialPartialChoice) return;
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        c.clickColor = 0;
    }
    for(int i=0;i<nPal;i++){ [colSelButton[i] setHidden:YES]; }
    [clearButton setHidden:YES];


    mapped = NO;
    
    _cellview.wholePartial = partialChoice > nchoice;
    _cellview.partial = partialChoice;
    _cellview.ispartial = partialChoice != 0;
    _cellview.colorCells = 1;
    [plainColorButton setState:NO];
    [cellColorButton setState:YES];
    [clickColorButton setState:NO];
    if(partialChoice != 0) {
        previousOrientation = _cellview.hardwareOrientation;
        _cellview.hardwareOrientation = YES;
        [self changePlacementIndex:0];
        [gridButton setState:NO];
        [hardwareOrientationButton setState:YES];
        if(_cellview.wholePartial) _cellview.partial = 0;
    } else {
        _cellview.hardwareOrientation = previousOrientation;
        [self changePlacementIndex:0];
        [hardwareOrientationButton setState:previousOrientation];
    }

    [_placementStepper setHidden:(partialChoice!=0 || _cellview.hardwareOrientation)];
    [_placementText setHidden:(partialChoice!=0 || _cellview.hardwareOrientation)];
    
    if(partialChoice != 0) [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

    
    [_cellview setNeedsDisplay:YES];

}
#pragma mark - cells geometries

- (void) changePlacementIndex: (int) ip {
    
    _iplacement = ip;
    [_placementStepper setIntValue:_iplacement];
    [_placementText setStringValue:[NSString stringWithFormat:@"Placement index = %2d",_iplacement]];

    [_cellview setupPlacement:_iplacement];
    [clickColorButton setEnabled:_iplacement==0];
    if(_iplacement != 0) {
        _cellview.colorCells = 1;
        [cellColorButton setState:YES];
        [clickColorButton setState:NO];
        for (int i=0;i<gridCells.count;i++) {
            HXGCell * c = [gridCells objectAtIndex:i];
            c.clickColor = 0;
        }
        for(int i=0;i<nPal;i++){ [colSelButton[i] setHidden:YES]; }
        [clearButton setHidden:YES];

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

}

- (void) setWaferSize:(double) f {
    
    ftof = f;
    side = ftof/sqrt(3.);
    waferPoint[0] = NSMakePoint(0.,-side);
    waferPoint[1] = NSMakePoint(+0.5*ftof,-0.5*side);
    waferPoint[2] = NSMakePoint(+0.5*ftof,+0.5*side);
    waferPoint[3] = NSMakePoint(0.,+side);
    waferPoint[4] = NSMakePoint(-0.5*ftof,+0.5*side);
    waferPoint[5] = NSMakePoint(-0.5*ftof,-0.5*side);
    /*
    waferBezier = [NSBezierPath bezierPath];
    [waferBezier moveToPoint:waferPoint[5]];
    for (int i=0; i<6; i++) { [waferBezier lineToPoint:waferPoint[i]];}
    */
}

- (void) makeCells:(int) iwaf {
    
    // iwaf = 0 -> LD
    // iwaf = 1 -> HD
    double sidecount = 4.0 * (double)(iwaf+2);
    count = (int) sidecount+0.1;
    
    cside = ftof/(3.0*sidecount);
    _cellview.cside = cside;
    chf = cside * sqrt(3.) * 0.5;
    
    [_cellview setWaferSide:side cellCount:count];

    [gridCells removeAllObjects];
    for(int i=0;i<10;i++) {
        for(int j=0;j<10;j++) {
            cellMap[i][j]=0;
        }
    }

    int nx = 2*count;
    int ny = nx+2;
    double x = - ((double)nx)*0.75*cside - 0.5*cside;
    double y;
    ncell = 0;
    for (int ix=0; ix<(nx+2); ix++) {   // was +1 (22 Oct 2021)
        y = - ((double)(ny-1-ix%2))*chf;
        for (int iy=0; iy<ny; iy++) {
            int dummy[3];
            int * d = dummy;
            if(drawing) d = [_cellview cellDetIdAtPoint:NSMakePoint(x,y)];
            HXGCell * c = [HXGCell cellWithWafer:waferPoint side:cside at:NSMakePoint(x,y) ID:ncell andDetId:d];
            if(d[0]<10 && d[1]<10 && d[0]>-1 && d[1]>-1 && c.inside) {
                cellMap[d[0]][d[1]] = (int)gridCells.count;
            }
            [gridCells addObject:c];
            ncell++;
            y+=2.*chf;
        }
        x+=1.5*cside;
    }

}

- (void) drawCellsInWafer:(int) iwaf {

//    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];

    [_densityControl setSelectedSegment:iwaf];
    [wholeOrPartialPopUp selectItemWithTitle:@"Whole wafer"];
    
    drawing = YES;
    inclusionRadii = NO;
    _cellview.inclusionRadii = NO;
    _cellview.partial = 0;
    _cellview.HD = (iwaf == 1);

    [self hideStandard:NO];
    [self makeCells:iwaf];
    
    [_cellview drawCells:gridCells forWafer:waferPoint];
 

}

- (void) makePartialMenu {
    
    NSString * ldMenu[5] = {@"LD1 top Half",@"LD2 Bottom half",@"LD3 Left semi",@"LD4 Right semi",@"LD5 Five"};
    NSString * hdMenu[4] = {@"HD1 Top",@"HD2 Bottom",@"HD3 Left",@"HD4 Right"};
    
    [wholeOrPartialPopUp removeAllItems];
    [wopCell addItemWithTitle:@"Whole wafer"];
    if(iwaf) nchoice = 4;
    else nchoice = 5;
    for(int i = 0; i < nchoice; i++) {
        if(iwaf) [wopCell addItemWithTitle:hdMenu[i]];
        else [wopCell addItemWithTitle:ldMenu[i]];
    }
    [wopCell addItemWithTitle:@"Partial wafer"];

    _cellview.partial = 0;

}

//#pragma mark - The raw data maps
/*
- (void) makeRawDataMap {

    if(!theRawDataMap) [self drawCellsInWafer:0];
    
    theRawDataMap.partialWafer = NO;
    [theRawDataMap showWindow:nil];

    drawing = YES;
//    [self changePlacementIndex:0]; /// !!!!!!!!!!! Yeah?
    [_cellview setupPlacement:0];
    [self drawCellsInWafer:0];
    [self drawCellsInWafer:1];
    [self.window close];
        
}

- (void) partialsRawDataMap {
 
    // ---- Don't yet understand why this is necessary...
    _cellview.hardwareOrientation = YES;
    _cellview.wholePartial = YES;
    //[self changePlacementIndex:0];
    _iplacement = 0;
    

    drawing = YES;
    //if(_HD) {
        partialChoice = 5;
        _cellview.HD = YES;
        _cellview.partial = partialChoice;
        _cellview.ispartial = YES;
        [_cellview setUpPartials];
        [self drawCellsInWafer:1];
    //} else {
        partialChoice = 6;
        _cellview.partial = partialChoice;
        _cellview.ispartial = YES;
        [self drawCellsInWafer:0];
        [_cellview setUpPartials];
    //}


    [self.window close];
    
    theRawDataMap.partialWafer = YES;
    [theRawDataMap showWindow:nil];

}

- (void) rawDataMapTextFile {
    
    if(!theRawDataMap) [self drawCellsInWafer:0];

    theRawDataMap.refTypeCode = YES; // Add some selection somewhere?

    [self makeRawDataMap];

    NSString * filename = @"WaferCellMap.txt";
    if(theRawDataMap.refTypeCode) filename = @"WaferCellMapRefCode.txt";
    NSSavePanel * export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save silicon wafer channel map"];
    [export setMessage:@"Saving full set of channel mappings for whole and partial wafers"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * path = [[export URL] path];
            [self saveRawDataMapTextFile:path];
        } else {
            [self.window close];
            [self->theRawDataMap.window close];
        }
    }];

}


- (void) saveRawDataMapTextFile: (NSString *) path {
//    0         1         2         3         4         5         6         7
//    012345678901234567890123456789012345678901234567890123456789012345678901234567890
    theRawDataMap.mapText =
    @"    Dens   Wtype     ROC HalfROC     Seq  ROCpin  SiCell  TrLink  TrCell      iu      iv   trace       t\n";
    
    [self makeRawDataMap];
    [theRawDataMap wholesText];

    [theRawDataMap setSelectedPartial:2];
    [self partialsRawDataMap];
    [theRawDataMap partialsText];
    [theRawDataMap.mapText writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    [theRawDataMap.window close];

}

- (void) cellIndexToUVMap {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];

    if(!theRawDataMap) [self drawCellsInWafer:0];
    
    theRawDataMap.partialWafer = NO;
    _cellview.hardwareOrientation = NO;
    _cellview.wholePartial = NO;
    [_cellview setupPlacement:0];
    [self drawCellsInWafer:0];
    [self drawCellsInWafer:1];
    [self.window close];
    
    [theTerminal displayString:@"-- LD full --\n"];
    [theTerminal displayString:[theRawDataMap wholeUVMapForHD:NO]];
    [theTerminal displayString:@"\n\n-- HD full --\n"];
    [theTerminal displayString:[theRawDataMap wholeUVMapForHD:YES]];

    
    theRawDataMap.partialWafer = YES;
    _cellview.hardwareOrientation = YES;
    _cellview.wholePartial = YES;
    [_cellview setupPlacement:0];
    [self drawCellsInWafer:0];
    [self drawCellsInWafer:1];
    [self.window close];

    
    [theTerminal displayString:@"\n\n-- LD partial --\n"];
    [theTerminal displayString:[theRawDataMap partialUVMapForHD:NO]];
    [theTerminal displayString:@"\n\n-- HD partial --\n"];
    [theTerminal displayString:[theRawDataMap partialUVMapForHD:YES]];
    
    [theTerminal showWindow:nil];

}

- (void) writeCellIndexToUVMap {
    
    if(!theRawDataMap) [self drawCellsInWafer:0];
    
    theRawDataMap.partialWafer = NO;
    _cellview.hardwareOrientation = NO;
    _cellview.wholePartial = NO;
    [_cellview setupPlacement:0];
    [self drawCellsInWafer:0];
    [self drawCellsInWafer:1];
    [self.window close];

    [theRawDataMap writeUVMapForHD:NO];
    [theRawDataMap writeUVMapForHD:YES];
    
    theRawDataMap.partialWafer = YES;
    _cellview.hardwareOrientation = YES;
    _cellview.wholePartial = YES;
    [_cellview setupPlacement:0];
    [self drawCellsInWafer:0];
    [self drawCellsInWafer:1];
    [self.window close];

    [theRawDataMap writePartialUVMapForHD:NO];
    [theRawDataMap writePartialUVMapForHD:YES];
}
*/
#pragma mark - Other menu items

- (void) countCells:(int)iwaf {

    drawing = NO;
    [self makeCells:iwaf];
    
    int nbin = 500;
    double cellsInside[500];
    double dx = 0.1;
    double radius = 0.0;
    NSPoint cpoint = NSMakePoint(cside,0.);
    int lastLoop = 1;
    for (int i=0; i<nbin; i++) {
        cellsInside[i] = 0.;
        for (int j = 0; j<gridCells.count; j++) {
            HXGCell * c = [gridCells objectAtIndex:j];
            if(sqrt((cpoint.x-c.centre.x)*(cpoint.x-c.centre.x) + (cpoint.y-c.centre.y)*(cpoint.y-c.centre.y)) < radius) cellsInside[i] += 1.;
        }
        if(cellsInside[i] > lastLoop) {
            // How to present this?
            //NSLog(@"%2d beyond radius %.1fmm",(int) cellsInside[i],radius);
            lastLoop = (int) cellsInside[i];
        }
        radius+=dx;
    }

    // --- show the plot
    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    NSPoint orig = NSMakePoint(200.,[[NSScreen mainScreen] frame].size.height-600.);
    NSString * tit = @"LD Cells inside radius";
    if(count == 12) tit = @"HD Cells inside radius";
    [theHist showWindowAt:orig withTitle:tit forPlotSize:NSMakeSize(380.,400.)];
    
    [theHist axisTitles:@"radius (mm)" And:@"Number of cells"];
    [theHist histFillColor:[NSColor ivoryWhite]];
    //[theHist setFixYmax:80.];
    
    [theHist drawHistogram:cellsInside Bins:nbin Xlow:0. Dx:dx Title:@"Cells inside radius"];
    int ncellWaf = 3 * count * count;
    NSString * label = @"LD";
    if(count == 12) label = @"HD";
    label = [label stringByAppendingFormat:@" wafer (%d cells)",ncellWaf];
    [theHist addLabel:label at: NSMakePoint(5.,cellsInside[nbin-5])];
    
    NSString * slab = [NSString stringWithFormat:@" 7: %.2f mm",2.*chf];
    [theHist addPointLabel:slab at: NSMakePoint(2.*chf - 0.5,7.)];
    
    slab = [NSString stringWithFormat:@"13: %.2f mm",3.*cside];
    [theHist addPointLabel:slab at: NSMakePoint(3.*cside - 0.5,13.)];
    
    slab = [NSString stringWithFormat:@"19: %.2f mm",4.*chf];
    [theHist addPointLabel:slab at: NSMakePoint(4.*chf - 0.5,19.)];
    
    slab = [NSString stringWithFormat:@"31: %.2f mm",sqrt((4.5*cside)*(4.5*cside) + chf*chf)];
    [theHist addPointLabel:slab at: NSMakePoint(sqrt((4.5*cside)*(4.5*cside) + chf*chf) - 0.5,31.)];
    
    slab = [NSString stringWithFormat:@"37: %.2f mm",6.*chf];
    [theHist addPointLabel:slab at: NSMakePoint(6.*chf - 0.5,37.)];

    slab = [NSString stringWithFormat:@"43: %.2f mm",6.*cside];
    [theHist addPointLabel:slab at: NSMakePoint(6.*cside - 0.5,43.)];

    slab = [NSString stringWithFormat:@"55: %.2f mm",sqrt((7.*chf)*(7.*chf) + (1.5*cside)*(1.5*cside))];
    [theHist addPointLabel:slab at: NSMakePoint(sqrt((7.*chf)*(7.*chf) + (1.5*cside)*(1.5*cside)) - 0.5,55.)];

    slab = [NSString stringWithFormat:@"61: %.2f mm",8.*chf];
    [theHist addPointLabel:slab at: NSMakePoint(8.*chf - 0.5,61.)];
    
    [theHist displayHist];

#ifdef DEBUG
    [self logRadii];
#endif

}

- (void) logRadii {
    
    NSLog(@" R A D I I   F O R   C O N T A I N M E N T");
    NSLog(@" 7: %.2f mm",2.*chf);
    NSLog(@"13: %.2f mm",3.*cside);
    NSLog(@"19: %.2f mm",4.*chf);
    NSLog(@"31: %.2f mm",sqrt((4.5*cside)*(4.5*cside) + chf*chf));
    NSLog(@"37: %.2f mm",6.*chf);
    NSLog(@"43: %.2f mm",6.*cside);
    NSLog(@"55: %.2f mm",sqrt((7.*chf)*(7.*chf) + (1.5*cside)*(1.5*cside)));
    NSLog(@"61: %.2f mm",8.*chf);
}

- (void) drawInclusionRadii {
    
    drawing = YES;
    inclusionRadii = YES;
    _cellview.inclusionRadii=YES;
    _iplacement = 2;
    [_cellview setPlacementIndex:2];
    [self makeCells:-1]; // -1 gives large grid (for 48 cell wafer!)

    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

    [self hideStandard:YES];

    [self setCellIrColor];
    double radius[5];
    radius[0] = 2.*chf;
    radius[1] = 3.*cside;
    radius[2] = 4.*chf;
    radius[3] = sqrt((4.5*cside)*(4.5*cside) + chf*chf);
    radius[4] = 6.*chf;
    
    [_cellview setRadii:radius];

    [_cellview drawCells:gridCells forWafer:waferPoint];
    
}

- (void) setCellIrColor {
  
    int col1 = 403;
    int col2[6]  = {302,303,404,504,503,402};
    int col3[6]  = {202,304,505,604,502,301};
    int col4[6]  = {201,203,405,605,603,401};
    int col5[12] = {101,102,204,305,506,606,705,704,602,501,300,200};
    int col6[6]  = {100,103,406,706,703,400};

    
    HXGCell * c = [gridCells objectAtIndex:cellMap[col1/100][col1%100]];
    c.irColor = 1;
    for (int i=0; i<12; i++) {
        if(i < 6) {
            c = [gridCells objectAtIndex:cellMap[col2[i]/100][col2[i]%100]];
            c.irColor = 2;
            c = [gridCells objectAtIndex:cellMap[col3[i]/100][col3[i]%100]];
            c.irColor = 3;
            c = [gridCells objectAtIndex:cellMap[col4[i]/100][col4[i]%100]];
            c.irColor = 4;
            c = [gridCells objectAtIndex:cellMap[col6[i]/100][col6[i]%100]];
            c.irColor = 6;
        }
        c = [gridCells objectAtIndex:cellMap[col5[i]/100][col5[i]%100]];
        c.irColor = 5;
   }
}

@end
