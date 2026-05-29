//
//  HXGNewCellWindowControl.m
//  Hex
//
//  Created by Chris Seez on 26/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGNewCellWindowControl.h"

@interface HXGNewCellWindowControl ()

@end

NSString * ldMenu[5] = {@"LD1 Top Half",@"LD2 Bottom half",@"LD3 Left semi",@"LD4 Right semi",@"LD5 Five"};
NSString * hdMenu[4] = {@"HD1 Top",@"HD2 Bottom",@"HD3 Left",@"HD4 Right"};
NSString * orientMenu[7] = {@"Hardware orientation", @"Reference orientation", @"Reference + 1 x 60º", @"Reference + 2 x 60º", @"Reference + 3 x 60º", @"Reference + 4 x 60º", @"Reference + 5 x 60º"};

const int lineheight = 16.75;

@implementation HXGNewCellWindowControl

+ (id) sharedNewCellControl {
    
    static dispatch_once_t pred;
    static HXGNewCellWindowControl * theNewCellControl = nil;
    
    dispatch_once(&pred, ^{ theNewCellControl = [[self alloc] init]; });
    return theNewCellControl;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGNewCellWindowControl"];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
   
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newCellInfo:)
               name:HXGNewCellInfoNotification
             object:nil];

    plotheight = [[NSScreen mainScreen] frame].size.height-30.;
    plotuppermargin = 80.;
    plotwidth = plotheight - plotuppermargin;
        
    controlswidth = 390.;
    height = plotheight;
    width = plotwidth + controlswidth;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSZeroPoint;
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];

    //[self.window.contentView setFrame:wRect];
    
    //NSRect cR = self.window.contentView.frame;

    NSRect vRect;                                // Here we define the view
    vRect.origin = NSZeroPoint;
    vRect.size = NSMakeSize(plotwidth,plotheight);
    
    [_cellView setViewFrame:vRect];
    
    [_densePopUp removeAllItems];
    [_densePopUp addItemWithTitle:@"LD"];
    [_densePopUp addItemWithTitle:@"HD"];
   
    [_placementStepper setControlSize:NSControlSizeSmall];
    [self makeOrientationMenu];
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
    [_densePopUp selectItemAtIndex:(int) HD];
    
    waferMenuCell = [_waferTypePopUp cell];
    [self changeWaferType:self];
    irot = -1;
    _cellView.irot = irot;

    [_drawCellsButton setState:YES];
    _cellView.drawCells = YES;
    
    [_showDetIdButton setState:YES];
    _cellView.showDetId = YES;
    
    [_showHardButton setState:YES];
    _cellView.showHard = YES;
    [_markCentroidButton setHidden:YES];
    
    trigger = NO;
    _cellView.trigger = trigger;
    [_dataButton setState:!trigger];
    [_triggerButton setState:trigger];

    
    [_sendToTerminalButton setToolTip:@"Send text to\nterminal window"];
    [self hideCellInfo:self];
    
    [_disclosePdfOptionsButton setState:YES];
    [_pdfNoTitleButton setHidden:YES];
    [_pdfNoBackgroundButton setHidden:YES];
    
    mirror = NO;
    
    theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];
    theStructuredWafer.trigger = trigger;
    
    [_helpButton setToolTip:@"⇧-click: show cell details\n⇧-⌥-click: show cell details and debug details"];


    [self describeWafer];

    [self makeWaferMenuTriggerChoice]; // includes setNeedsDisplay
    waferMenuCell = [_waferTypePopUp cell];
    [self changeWaferType:self];

}

- (void) makePDF {
    
    NSString * filename = @"LD";
    if(HD) filename = @"HD";
    if(partial && partialType == 0) filename = [filename stringByAppendingString:@"partial"];
    else filename = [filename stringByAppendingFormat:@"%d",partialType];
    if(trigger) filename = [filename stringByAppendingString:@"TriggerCells.pdf"];
    else filename = [filename stringByAppendingString:@"WaferCells.pdf"];
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString * pdfpath = [[export URL] path];
            [self.cellView savePDF:pdfpath];
        }
    }];
}

#pragma mark - Notifications
- (void) newCellInfo:(NSNotification *) note {
  
    NSString * orientString[13] =
       {@"Hardward orientation",@"Ref orientation (ip=0)",@"Placement index = 1",
        @"Placement index = 2",@"Placement index = 3",@"Placement index = 4",
        @"Placement index = 5",@"Placement index = 6",@"Placement index = 7",
        @"Placement index = 8",@"Placement index = 9",@"Placement index = 10",
        @"Placement index = 11"};
    
    HXGStructuredCell * cs = [theStructuredWafer cellAtPoint:_cellView.mousePoint Dense: HD Partial:partial];
    if(cs.type < 0) return;
    
    NSPoint pnt = [theStructuredWafer convertPoint:_cellView.mousePoint toRotated:irotCellInfo fromRotated:0];
    NSString * text = [NSString stringWithFormat:@"    [%@ used for (x,y) coordinates]\n\nClick at (%.1f, %.1f)",orientString[irotCellInfo+1],pnt.x,pnt.y];
    
    int ihard = cs.hard;
    if(partial) ihard = cs.partialHard;
    text = [text stringByAppendingFormat:@"\n(iu, iv) = (%d, %d); hardware number = %d",cs.uvId[0],cs.uvId[1],ihard];
    cellName = [NSString stringWithFormat:@"Cell_%d_%d",cs.uvId[0],cs.uvId[1]];
    
    BOOL calib = cs.calib;
    if(partial) calib = cs.partialCalib;
    if(calib) text = [text stringByAppendingFormat:@"\nIncludes calibration cell with hardware number = %d",ihard+1];
    
    BOOL present = NO;
    HXGStructuredCell * csib;
    if(cs.split) {
        csib = cs.siblingCell;
        if(partialType == 0 || [csib isPresentInType:partialType]) {
            ihard = csib.partialHard;
            text = [text stringByAppendingFormat:@"\nRead out together with cell  %d",ihard];
            present = YES;
        }
    }
    
    text = [text stringByAppendingString:[theStructuredWafer triggerAndRocTextForCell:cs inPartial:partialType]];

    NSString * str = @"Cell";
    if(calib) str = @"Total cell";
    text = [text stringByAppendingFormat:@"\n\n%@ area = %.4f",str,[cs getCellArea]];
    if(calib) text = [text stringByAppendingFormat:@"\nCalibration cell area = %.3f",[theStructuredWafer getCalibAreaForDense:HD]];
    
    NSPoint centre = [theStructuredWafer convertPoint:cs.centre toRotated:irotCellInfo fromRotated:-1];
    text = [text stringByAppendingFormat:@"\n\nGrid hexagon centre = (%.2f, %.2f)",centre.x,centre.y];
    
    NSPoint centroid = [cs getCellCentroid];
    
    centroid = [theStructuredWafer convertPoint:centroid toReferenceFromRotated:-1];
    NSPoint cntrdpnt = [theStructuredWafer convertPoint:centroid toRotated:irotCellInfo fromRotated:0];

    NSPoint ctroidSib;
    if(cs.split && present) {
        ctroidSib = [theStructuredWafer convertPoint:[csib getCellCentroid] toReferenceFromRotated:-1];
        pnt = [theStructuredWafer convertPoint:ctroidSib toRotated:irotCellInfo fromRotated:0];
        text = [text stringByAppendingFormat:@"\nPair of split cells have centroids at:\n(%.2f, %.2f) and (%.2f, %.2f)",cntrdpnt.x,cntrdpnt.y,pnt.x,pnt.y];
        double combx = 0.5 * (centroid.x + ctroidSib.x);
        double comby = 0.5 * (centroid.y + ctroidSib.y);
        centroid = NSMakePoint(combx,comby);
        cntrdpnt = [theStructuredWafer convertPoint:centroid toRotated:irotCellInfo fromRotated:0];
        double cdx = cntrdpnt.x - centre.x;
        double cdy = cntrdpnt.y - centre.y;
        text = [text stringByAppendingFormat:@"\nMean centroid of pair = (%.2f, %.2f)\ni.e. (Δx, Δy) = (%.2f, %.2f))",cntrdpnt.x,cntrdpnt.y,cdx,cdy];
    } else {
        double dx = cntrdpnt.x - centre.x;
        double dy = cntrdpnt.y - centre.y;
        if(cs.split) text = [text stringByAppendingString:@"\nSplit cell!"];
        text = [text stringByAppendingFormat:@"\nCell centroid = (%.2f, %.2f)\ni.e. (Δx, Δy) = (%.2f, %.2f)",cntrdpnt.x,cntrdpnt.y,dx,dy];
    }
 
    // --- Convert centroid to display coordinates
    
    _cellView.centroid = centroid;

    // ----------- If debug requested add debug string --------------
    if(_cellView.cellDebug) text = [text stringByAppendingString:[self debugTextForCell:cs]];

    // ----------- Adjust height of display box ---------------------    
    NSArray * lines = [text componentsSeparatedByCharactersInSet:
                       [NSCharacterSet newlineCharacterSet]];
    int nlines = (int) lines.count + 1;
    lines = [NSArray array];
    double height = lineheight * (double)nlines;
    
    NSRect cR = _cellInfoTextField.frame;
    double top = cR.origin.y + cR.size.height;
    cR.size.height = height;
    cR.origin.y = top - height;
    [_cellInfoTextField setFrame:cR];
    
    NSRect sR = _sendToTerminalButton.frame;
    sR.origin.y = cR.origin.y;
    [_sendToTerminalButton setFrame:sR];
    // -----------------------------------------------------------------
    
    [_cellInfoTextField setStringValue:text];

    [_placementStepper setHidden:NO];
    [_hideCellInfoButton setHidden:NO];
    [_cellInfoTextField setHidden:NO];
    [_sendToTerminalButton setHidden:NO];

    _cellView.highlight = YES;
    _cellView.highlightChanged = YES;
    [_markCentroidButton setHidden:NO];
    _cellView.markCentroid = [_markCentroidButton state];
    _cellView.highlightCell = cs;

    [_cellView setNeedsDisplay:YES];
    
    text = [text stringByAppendingString:@"\n\n---------------------------------------------------\n\n"];
    
    cellInfoText = [NSString stringWithString:[self waferString]];

    cellInfoText = [cellInfoText stringByAppendingFormat:@"\n\n%@",text];
    
}

#pragma mark - IBActions
- (IBAction) changeDensity:(id)sender {
    
    BOOL oldHD = HD;
    HD = [_densePopUp indexOfSelectedItem] == 1;
    
    if(HD != oldHD) [self makeWaferMenuTriggerChoice];
    
    _cellView.HD = HD;
    
    [self hideCellInfo:self];
    [self resetMagnification];
    [self describeWafer];
    
    [_cellView setNeedsDisplay:YES];
    
}
- (IBAction) changeWaferType:(id)sender{
    
    partialType = (int) [_waferTypePopUp indexOfSelectedItem];
    partial = (partialType != 0);
    _cellView.partial = partial;
    if(partialType  > nchoice) partialType = 0;
    _cellView.partialType = partialType;
    
    [self hideCellInfo:self];
    [self resetMagnification];
    [self describeWafer];
    
    if(sender != self) [_cellView setNeedsDisplay:YES];

}
- (IBAction) changeOrientation:(id)sender{
    
    int oldrot = irot;
    irot = (int) [_orientationPopUp indexOfSelectedItem] - 1;
    
    if(mirror) {
        if(irot < 0) irot = -2;
        else irot += 6;
    }
    
    if(irot != oldrot) {
        _cellView.irot = irot;
        
        //[self hideCellInfo:self];
        _cellView.highlightChanged = _cellView.highlight;
        [self resetMagnification];
        [self describeWafer];
        
        [_cellView setNeedsDisplay:YES];
    }

}

- (IBAction) changeDataTrigger:(id)sender {
    
    trigger = [sender tag] == 1;
    [_dataButton setState:!trigger];
    [_triggerButton setState:trigger];
    
    if(trigger) [_showDetIdButton setTitle:@"Show trigger ROC:link:cell labels"];
    else [_showDetIdButton setTitle:@"Show iu:iv labels"];
    
    [self makeWaferMenuTriggerChoice];
    
    theStructuredWafer.trigger = trigger;
    _cellView.trigger = trigger;
    
    [_cellView setNeedsDisplay:YES];

}

- (IBAction) changeDrawCells:(id)sender {
    
    _cellView.drawCells = [sender state];
    [self checkForEmptyDisplay:YES];
    
    [_cellView setNeedsDisplay:YES];
}

- (IBAction) changeShowDetId:(id)sender {
    
    _cellView.showDetId = [sender state];
    
    [_cellView setNeedsDisplay:YES];
}

- (IBAction) changeShowHard:(id)sender {
    
    _cellView.showHard = [sender state];
    
    [_cellView setNeedsDisplay:YES];
}

- (IBAction) changeShowGridCount:(id)sender {
 
    _cellView.showGridCount = [sender state];
    [_showDetIdButton setEnabled:![sender state]];
    [_showHardButton setEnabled:![sender state]];
    [_cellView setNeedsDisplay:YES];

}

- (IBAction) changeShowEdgeIndex:(id)sender {
 
    _cellView.showEdgeIndex = [sender state];
    [_showDetIdButton setEnabled:![sender state]];
    [_showHardButton setEnabled:![sender state]];
    [_showGridCountButton setEnabled:![sender state]];
    _cellView.showGridCount = [_showGridCountButton state] && ![sender state];
    [_cellView setNeedsDisplay:YES];

}

- (IBAction) changeShowGeomItems:(id)sender {
    
    if([sender tag] == 0) _cellView.showLayoutHexagon = [sender state];
    else if([sender tag] == 1) _cellView.showPhysicalWafer = [sender state];
    else if([sender tag] == 2) _cellView.showCentre = [sender state];

    [self checkForEmptyDisplay:NO];

    [_cellView setNeedsDisplay:YES];
}

- (IBAction) changeShowGrid:(id)sender {
    
    _cellView.showGrid = [sender state];
    
    [self checkForEmptyDisplay:NO];
    
    [_cellView setNeedsDisplay:YES];
}


- (IBAction) hideCellInfo:(id)sender {
    
    [_placementStepper setHidden:YES];
    [_hideCellInfoButton setHidden:YES];
    [_cellInfoTextField setHidden:YES];
    [_sendToTerminalButton setHidden:YES];
    _cellView.highlight = NO;
    _cellView.markCentroid = NO;
    [_markCentroidButton setHidden:YES];
    [_cellView setNeedsDisplay:YES];

}

- (IBAction) changeMagnification: (id) sender {
    
    double sValue = [_magnifyStepper doubleValue];
    [_magnifyIndicator setDoubleValue:sValue];
    _cellView.magnification = pow(2.,sValue*0.5);
    [_cellView setViewBounds];
    [self.window makeFirstResponder:_cellView];


}

- (IBAction) changePlacementForCellInfo:(id)sender {
    
    irotCellInfo = [_placementStepper intValue];
    [self newCellInfo:nil];
    
}

- (IBAction) changeMirroring:(id)sender {

    mirror = [sender state];
    
    if(mirror) {
        if(irot < 0) irot = -2;
        else irot += 6;
    } else {
        if(irot < 0) irot = -1;
        else irot -= 6;
    }
    
    _cellView.highlightChanged = _cellView.highlight;

    
    _cellView.irot = irot;
    
    [self makeOrientationMenu];
    int item = irot;
    if(item < -1) item = -1;
    if(item > 5) item -=6;
    [_orientationPopUp selectItemAtIndex:item+1];
    [self describeWafer];

    [_cellView setNeedsDisplay:YES];

}

- (IBAction) markCentroid:(id)sender {
    
    _cellView.markCentroid = [sender state];
    [_cellView setNeedsDisplay:YES];
}

- (IBAction) sendCellInfoToTerminal:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = cellName;
    
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    
    [theTerminal displayString:cellInfoText];
}

- (IBAction) changePdfDisclosure:(id)sender {
    
    BOOL hidden = [sender state];
    [_pdfNoTitleButton setHidden:hidden];
    [_pdfNoBackgroundButton setHidden:hidden];
    
}
- (IBAction) changePdfOptions:(id)sender {
    
    if([sender tag] == 0) _cellView.pdfNoTitle = [sender state];
    else _cellView.pdfNoBackground = [sender state];
    
}

- (IBAction) helpOut:(id)sender {
    
    if(!thePngDisplay) thePngDisplay = [HXGDisplayPngControl sharedPngDisplayControl];
    [thePngDisplay setPngFile:@"CellViewHelp"];
    [thePngDisplay setWindowTitle:@"Aide-memoire" andPdfName:@"CellViewHelp"];
    [thePngDisplay setWidthFraction:0.3];
    [thePngDisplay setTopFraction:0.3 andLeftFraction:0.4];
    [thePngDisplay.window setBackgroundColor:[NSColor paleBlue]];
    [thePngDisplay showWindow:nil];

}

#pragma mark - Test

- (void) testConvertPoint {
    
    srandom(1); // seed the random number generator (takes unsigned long as argument)
    const int nloop = 1000000;
    const double span = 20.;
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = cellName;
    
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal displayString:@"testConvertPoint\n\n"];
    if(!theStructuredWafer) theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];

    int nfail = 0;
    for(int i=0; i<nloop; i++) {
        NSPoint pnt;
        double rand = ((double)random() / (double)RAND_MAX) - 0.5;
        pnt.x = rand*span;
        rand = ((double)random() / (double)RAND_MAX) - 0.5;
        pnt.y = rand*span;
        rand = ((double)random() / (double)RAND_MAX);
        int irot = (int) (rand*14.) - 2;
        rand = ((double)random() / (double)RAND_MAX);
        int jrot = (int) (rand*14.) - 2;
        NSPoint qnt = [theStructuredWafer convertPoint:pnt toRotated:irot fromRotated:jrot];
        NSPoint pntrev = [theStructuredWafer convertPoint:qnt toRotated:jrot fromRotated:irot];
        if(sqrt((pnt.x - pntrev.x)*(pnt.x - pntrev.x) + (pnt.y - pntrev.y)*(pnt.y - pntrev.y)) > 0.000001 || i < 20) {
            NSString * result = [NSString stringWithFormat:@"irot = %d, jrot = %d: (%.3f,%.3f) → (%.3f,%.3f) → (%.3f,%.3f)\n",irot,jrot,pnt.x,pnt.y,qnt.x,qnt.y,pntrev.x,pntrev.y];
            [theTerminal displayString:result];
            if(sqrt((pnt.x - pntrev.x)*(pnt.x - pntrev.x) + (pnt.y - pntrev.y)*(pnt.y - pntrev.y)) > 0.000001) nfail++;
        }
    }
    [theTerminal displayString: [NSString stringWithFormat:@"\nAfter %d tries %d failures",nloop,nfail]];
}

- (void) toggleDebugPolyContain {
    
    theStructuredWafer.debugPolyContain = !theStructuredWafer.debugPolyContain;
}


- (BOOL) testContainsPoint:(NSPoint) pnt {
    
    NSPoint shapePnt[4];
    shapePnt[0] = NSMakePoint(0.,5.);
    shapePnt[1] = NSMakePoint(5.,10.);
    shapePnt[2] = NSMakePoint(5.,0.);
    shapePnt[3] = NSMakePoint(0.,0.);
    
    double last = 0;
    for (int i=0; i<4; i++) {
        double dxa = shapePnt[(i+1)%4].x - shapePnt[i].x;
        double dya = shapePnt[(i+1)%4].y - shapePnt[i].y;
        double dxb = pnt.x - shapePnt[i].x;
        double dyb = pnt.y - shapePnt[i].y;
        double test = (dxa*dyb - dxb*dya);
        NSLog(@"%d test = %g",i,test);
        if(last != 0 && test*last < 0) return NO;
        last = test;
    }
    
    return YES;
}


#pragma mark - Private methods
- (void) checkForEmptyDisplay:(BOOL) wasCells {

    if(!(_cellView.drawCells || _cellView.showLayoutHexagon || _cellView.showPhysicalWafer || _cellView.showGrid)) {
        if(wasCells) {
            [_drawGridButton setState:YES];
            _cellView.showGrid = YES;
        } else {
            [_drawCellsButton setState:YES];
            _cellView.drawCells = YES;
        }
    }
    
}

- (NSString *) debugTextForCell:(HXGStructuredCell *) cd {
    
    NSString * debugText = @"\n\n------------- DEBUG TEXT -------------\n";
    debugText = [debugText stringByAppendingFormat:@"Cell grid count = %d",cd.gridCount];
    if(partial && !cd.split && cd.siblingCell) {
        HXGStructuredCell * cs = cd.siblingCell;
        debugText = [debugText stringByAppendingFormat:@" with sib at %d",cs.gridCount];
    }
    
    if(cd.special) debugText = [debugText stringByAppendingString:@"\nCell is special"];
    
    NSString * dens = @"LD";
    if(HD) dens = @"HD";
    if(partial) debugText = [debugText stringByAppendingString:@"\nCell included in:"];
    for (int i=1; i<nchoice+1; i++) {
        if([cd isPresentInType:i]) debugText = [debugText stringByAppendingFormat:@" %@%d",dens,i];
    }
    
    debugText = [debugText stringByAppendingString:@"\n\nNon-redundant cell corners"];
    NSPoint pnt[6];
    for (int i=0; i<6; i++) {
        pnt[i] = [cd getCellCorner:i];
    }

    int bits = 0;
    for (int i=0; i<6; i++) {
/* -----------------------------------------------------------------------------
   Remove redundant points - harder than it looks
   e.g. edge cells on sloping edges
   Requires line between pnt[i-1] and pnt[i+1] and distance of point i from line:
   d = fabs(Ax'+By'+C)\sqrt(A*A+B*B) for my point (x',y')
   where line is Ax+By+C=0
   ------------------------------------------------------------------------------ */
        double A = 0.;
        double B = 0.;
        double C = 0.;
        double m = 0.;
        
        if(fabs(pnt[(i+1)%6].x - pnt[(i+5)%6].x) < 0.001) {
            A = -1.;
            C = pnt[(i+1)%6].x;
        } else {
            m = (pnt[(i+1)%6].y - pnt[(i+5)%6].y)/(pnt[(i+1)%6].x - pnt[(i+5)%6].x);
            if(fabs(m) < 0.0001) {
                B = -1.;
                C = pnt[(i+1)%6].y;
            } else {
                A = m;
                B = -1.;
                C = pnt[(i+1)%6].y - m*pnt[(i+1)%6].x;
            }
        }
        if(fabs(A*pnt[i].x + B*pnt[i].y + C)/sqrt(A*A+B*B) < 0.001) {
            bits = bits | 1<<i;
        }
    }

    for(int i=0; i<6; i++){
        int j = (i+1)%6;
        if((bits & 1<<i) != 0 && (bits & 1<<j) != 0) bits = bits & ~(1<<j);
    }
    for(int i=0; i<6; i++){
        if((bits & (1<<i)) == 0) {
            NSPoint tpnt = [theStructuredWafer convertPoint:pnt[i] toRotated:irotCellInfo fromRotated:-1];
            debugText = [debugText stringByAppendingFormat:@"\n%d (x,y) = (%.3f,%.3f)",i,tpnt.x,tpnt.y];
        }
    }
    return debugText;
}

- (void) makeWaferMenuTriggerChoice {
     
    int typeSel = (int) [_waferTypePopUp indexOfSelectedItem];
    BOOL fullPartialWafer = NO;
    if(typeSel > nchoice) fullPartialWafer = YES;
    
    [_waferTypePopUp removeAllItems];
    [waferMenuCell addItemWithTitle:@"Whole wafer"];
    if(HD) nchoice = 4;
    else nchoice = 5;
    for(int i = 0; i < nchoice; i++) {
        if(HD) [waferMenuCell addItemWithTitle:hdMenu[i]];
        else [waferMenuCell addItemWithTitle:ldMenu[i]];
    }
    if(!trigger) [waferMenuCell addItemWithTitle:@"Partial wafer"];

    if(fullPartialWafer) {
        if(trigger) {
            [_waferTypePopUp selectItemAtIndex:0];
            _cellView.partial = NO;
        } else {
            [_waferTypePopUp selectItemAtIndex:nchoice+1];
            _cellView.partial = YES;
        }
    } else {                      // was: if(!tchoice)
        _cellView.partial = NO;
        _cellView.partialType = 0;
        partialType = 0;
    } // else [_waferTypePopUp selectItemAtIndex:typeSel];


    [self describeWafer];
    [_cellView setNeedsDisplay:YES];

}

- (void) makeOrientationMenu {
    
    if(mirror) {
        [_orientationPopUp removeAllItems];
        [_orientationPopUp addItemWithTitle:@"mirrored hardware"];
        for (int i=1; i<7; i++) {
            NSString * title = [NSString stringWithFormat:@"iplacement %d",i+5];
            [_orientationPopUp addItemWithTitle:title];
        }
    } else {
        [_orientationPopUp removeAllItems];
        for (int i=0; i<7; i++) {
            [_orientationPopUp addItemWithTitle:orientMenu[i]];
        }
    }
}

- (void) describeWafer {
    
    NSString * wText = [self waferString];
    wText = [wText stringByAppendingFormat:@"; %@",_orientationPopUp.titleOfSelectedItem];
    _cellView.waferDescription = [NSString stringWithString:wText];
    
}

- (NSString *) waferString {
    
    NSString * wText = @"";
    
    if(partial) {
        if(partialType == 0) {
            if(HD) wText = @"HD";
            else wText = @"LD";
            wText = [wText stringByAppendingString:@" whole partial wafer"];
        } else {
            wText = [wText stringByAppendingString:@"Partial: "];
            if(HD) wText = [wText stringByAppendingFormat:@"%@",hdMenu[partialType-1]];
            else wText = [wText stringByAppendingFormat:@"%@",ldMenu[partialType-1]];
        }
    } else {
        if(HD) wText = @"HD";
        else wText = @"LD";
        wText = [wText stringByAppendingString:@" whole wafer"];
    }

    return wText;
}

- (void) resetMagnification {
    
    [_magnifyStepper setDoubleValue:0.];
    [_magnifyIndicator setDoubleValue:0.];
    _cellView.magnification = 1.;
    [_cellView setViewBounds];
    
}

@end
