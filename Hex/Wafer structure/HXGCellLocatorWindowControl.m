//
//  HXGCellLocatorWindowControl.m
//  Hex
//
//  Created by Chris Seez on 10/06/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGCellLocatorWindowControl.h"

@interface HXGCellLocatorWindowControl ()

@end


const double pruthviT = 0.1;  // Threshold of discrepancy
const double pruthviOT = 2.0; // "Over the top" = done/discussed already

@implementation HXGCellLocatorWindowControl

+ (id) sharedCellLocatorControl {
    
    static dispatch_once_t pred;
    static HXGCellLocatorWindowControl * theCellLocator = nil;
    
    dispatch_once(&pred, ^{ theCellLocator = [[self alloc] init]; });
    return theCellLocator;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGCellLocatorWindowControl"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newLayer:)
                                                 name:HXGNewLayerNotification
                                               object:nil];

    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    pruthviCell = NO;

    showTheCell = YES;
}

- (void) showWindow:(id)sender{
    
    [super showWindow:(id)sender];
    
    [_showCellButton setState:showTheCell];
    [_sendToTerminalButton setToolTip:@"Send text to\nterminal window"];

    theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];
    
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}

- (void) locatePruthviCell: (int) ipruthvi inWafer:(HXGWafer *) waf ofLayer:(int) nLayer rotated30:(BOOL) rot30 {
    
    pruthviCell = YES;
    
    if(!thePruthviCSV) thePruthviCSV = [HXGPruthviCSV sharedPruthviCSV];
    if(!theStructuredWafer) theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];

    [self locateCellsIn: waf ofLayer: nLayer rotated30: rot30];
    iu = thePruthviCSV.ciu;
    iv = thePruthviCSV.civ;
    
    //------------ !!!!!!
    //if(iu == 0 && iv == 2) return;
    //if(iu == 0 && iv == 9) return;

    
    [self locateCell];
    
    //---------- !!!!!!
    //if(!wafer.LD && wafer.type > 2 ) return;

    NSString * summaryString = @"\n\nSUMMARY for ";
    summaryString = [summaryString stringByAppendingFormat:@"Pruthvi line %d, Layer %d, Wafer %d:%d, Cell %d:%d",ipruthvi+2,thePruthviCSV.layer,thePruthviCSV.wiu,thePruthviCSV.wiv,thePruthviCSV.ciu,thePruthviCSV.civ];
    summaryString = [summaryString stringByAppendingFormat:@"\nChris:   (x,y) = (%.2f,%.2f); (Δx,Δy) = (%.2f,%.2f)",cellCentroid.x,cellCentroid.y,cellCentroid.x-gPnt.x,cellCentroid.y-gPnt.y];
    summaryString = [summaryString stringByAppendingFormat:@"\nPruthvi: (x,y) = (%.2f,%.2f); (Δx,Δy) = (%.2f,%.2f)",thePruthviCSV.cellx,thePruthviCSV.celly,thePruthviCSV.cellx-gPnt.x,thePruthviCSV.celly-gPnt.y];
    
    if(MAX(fabs(thePruthviCSV.cellx-cellCentroid.x), fabs(thePruthviCSV.celly-cellCentroid.y)) > pruthviT) {
        double dx = fabs(thePruthviCSV.cellx-gPnt.x)-fabs(cellCentroid.x-gPnt.x);
        double dy = fabs(thePruthviCSV.celly-gPnt.y)-fabs(cellCentroid.y-gPnt.y);
        if(MAX(fabs(dx), fabs(dy)) > 0.02) {
            
            [theTerminal displayString:waferString];
            [theTerminal displayString:cellString];
            
            [theTerminal displayString:summaryString];
            [theTerminal displayString:@"\n-------------------------------\n"];
        }
    }
    pruthviCell = NO;

}

- (void) locateCellsIn:(HXGWafer *) waf ofLayer:(int) nLayer rotated30:(BOOL) rot30 {
  
    if(!pruthviCell) {
        [self.window setTitle:@"Cell locator"];
        [_showCellButton setHidden:NO];
        [self showWindow:self];
    }
    
    wafer = waf;
    rot = rot30;
    wCentre = NSMakePoint(wafer.xc,wafer.yc);
    
    if(rot) {
        double xp = wafer.xc;
        double yp = wafer.yc;
        wCentre.x = xp*cos(M_PI/6.) - yp*sin(M_PI/6.);
        wCentre.y = xp*sin(M_PI/6.) + yp*cos(M_PI/6.);
    }
    
    layer = nLayer;

    NSString * typeCode[6] = {@"F",@"T",@"B",@"L",@"R",@"5"};
    NSString * density = @"HD";
    if(wafer.LD) density = @"LD";
    int thick[4] = {120,200,200,300};
    NSString * name[7] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
    NSString * refCode = @"ML-";
    if(!wafer.LD) refCode = @"MH-";
    if(wafer.type > 5) refCode = @"Obsolete";
    else refCode = [refCode stringByAppendingString:typeCode[wafer.type]];

    waferString = [NSString stringWithFormat:@"Layer %d, Cassette %d, ",layer+1,wafer.cassette];
    waferString = [waferString stringByAppendingFormat:@"Wafer %d:%d\n",wafer.detId[0],wafer.detId[1]];
    waferString = [waferString stringByAppendingFormat:@"%@ %d %@  (%@)  %dµm\n",density,wafer.type,name[wafer.type],refCode,thick[wafer.thickflag]];
    
    isMirrored = (layer < 26 && layer%2 == 1);
    if(pruthviCell) return;
    
    [_layerAndWaferTextField setStringValue:waferString];
    
    HD = !wafer.LD;
    int max = 15;
    if(HD) max = 23;
    [_iuStepper setMaxValue:max];
    [_ivStepper setMaxValue:max];
    
    int irot = wafer.channelZero;
    if(irot < 0) {
        debugString = [NSString stringWithFormat:@"!!!*** irot = %d ***!!!\n",irot];
    } else {
        debugString = @"";
        if(wafer.seenFromBack) irot = irot+6;
    }
    _startingPoint = [theStructuredWafer convertPoint:_startingPoint toReferenceFromRotated:irot];
    [theStructuredWafer makeGridToCellMapForDense:HD Partial:wafer.type];

    
    HXGStructuredCell * cell = [theStructuredWafer cellAtPoint:_startingPoint Dense:HD Partial: wafer.type != 0];
    if(!cell) {
        NSLog(@"NULL cell!");
        return;
    }
    
    if(cell.type == -1) {
        iu = 0; iv = 0;
        [self.window close];
        return;
    } else {
        iu = cell.uvId[0];
        iv = cell.uvId[1];
    }
    
    // ---- Now we know we are truly in the wafer ----
    

    [_cellIuTextField setStringValue:[NSString stringWithFormat:@"%d",iu]];
    [_cellIvTextField setStringValue:[NSString stringWithFormat:@"%d",iv]];
    [_iuStepper setIntValue:iu];
    [_ivStepper setIntValue:iv];
    
    [self locateCell];
    
    [_resultTextField setStringValue:cellString];
    [self adjustDisplaySize];
    [self postLocatorNotification:showTheCell];

}

- (void) neighbourCellsIn:(HXGWafer *) waf ofLayer:(int) nLayer rotated30:(BOOL) rot30 {
    
    [self.window setTitle:@"Nearest neighbour cells"];
    [_showCellButton setHidden:YES];

    [self showWindow:self];

    wafer = waf;
    rot = rot30;
    wCentre = NSMakePoint(wafer.xc,wafer.yc);
    
    if(rot) {
        double xp = wafer.xc;
        double yp = wafer.yc;
        wCentre.x = xp*cos(M_PI/6.) - yp*sin(M_PI/6.);
        wCentre.y = xp*sin(M_PI/6.) + yp*cos(M_PI/6.);
    }
    
    layer = nLayer;

    NSString * typeCode[6] = {@"F",@"T",@"B",@"L",@"R",@"5"};
    NSString * density = @"HD";
    if(wafer.LD) density = @"LD";
    int thick[4] = {120,200,200,300};
    NSString * name[7] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
    NSString * refCode = @"ML-";
    if(!wafer.LD) refCode = @"MH-";
    if(wafer.type > 5) refCode = @"Obsolete";
    else refCode = [refCode stringByAppendingString:typeCode[wafer.type]];

    wuv[0] = wafer.detId[0];
    wuv[1] = wafer.detId[1];
    waferString = [NSString stringWithFormat:@"Layer %d, Cassette %d, ",layer+1,wafer.cassette];
    waferString = [waferString stringByAppendingFormat:@"Wafer %d:%d\n",wafer.detId[0],wafer.detId[1]];
    waferString = [waferString stringByAppendingFormat:@"%@ %d %@  (%@)  %dµm\n",density,wafer.type,name[wafer.type],refCode,thick[wafer.thickflag]];
    
    [_layerAndWaferTextField setStringValue:waferString];
    
    isMirrored = (layer < 26 && layer%2 == 1);
    HD = !wafer.LD;
    int max = 15;
    if(HD) max = 23;
    [_iuStepper setMaxValue:max];
    [_ivStepper setMaxValue:max];
    
    int irot = wafer.channelZero;
    if(irot < 0) {
        debugString = [NSString stringWithFormat:@"!!!*** irot = %d ***!!!\n",irot];
    } else {
        debugString = @"";
        if(wafer.seenFromBack) irot = irot+6;
    }
    _startingPoint = [theStructuredWafer convertPoint:_startingPoint toReferenceFromRotated:irot];
    [theStructuredWafer makeGridToCellMapForDense:HD Partial:wafer.type];

    
    HXGStructuredCell * cell = [theStructuredWafer cellAtPoint:_startingPoint Dense:HD Partial: wafer.type != 0];
    if(!cell) {
        NSLog(@"NULL cell!");
        return;
    }
    
    if(cell.type == -1) {
        iu = 0; iv = 0;
        [self.window close];
        return;
    } else {
        iu = cell.uvId[0];
        iv = cell.uvId[1];
    }
    
    // ---- Now we know we are truly in the wafer ----
    

    [_cellIuTextField setStringValue:[NSString stringWithFormat:@"%d",iu]];
    [_cellIvTextField setStringValue:[NSString stringWithFormat:@"%d",iv]];
    [_iuStepper setIntValue:iu];
    [_ivStepper setIntValue:iv];
    
    [self findNeighbours];
    
}

#pragma mark - IBActions

- (IBAction) newValue:(id)sender {
    
    int iuold = iu;
    int ivold = iv;
    
    iu = [_iuStepper intValue];
    iv = [_ivStepper intValue];
    
    int densityNumber;
    if(HD) densityNumber = densityNumberHD;
    else   densityNumber = densityNumberLD;
    
    int halfMax = densityNumber - 1;

    if((iv > iu + halfMax) || (iv < iu - densityNumber)) { // iu:iv for non-existent cell
        iu = iuold;
        iv = ivold;
        [_iuStepper setIntValue:iu];
        [_ivStepper setIntValue:iv];
        NSBeep();
        return;
    }
    
    [_cellIuTextField setStringValue:[NSString stringWithFormat:@"%d",iu]];
    [_cellIvTextField setStringValue:[NSString stringWithFormat:@"%d",iv]];
    
    if(!neighbourFinder) {
        [self locateCell];
        [_resultTextField setStringValue:cellString];
        [self adjustDisplaySize];
        [self postLocatorNotification:showTheCell];
    } else [self findNeighbours];
    
}

- (IBAction) showCellPoint:(id)sender {
    
    showTheCell = [sender state];
    [self postLocatorNotification:showTheCell];
    
}

- (IBAction) sendToTerminal:(id)sender {
    
    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        [theTerminal clearString];
    }
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    theTerminal.suggestedName = @"CellLocations";
    
    [theTerminal displayString:waferString];
    [theTerminal displayString:cellString];
    [theTerminal displayString:@"\n          -----------\n\n"];

}

#pragma mark - Private methods

- (void) locateCell {
   
    neighbourFinder = NO;
    
    int iuiv[2];
    iuiv[0] = iu;
    iuiv[1] = iv;
  
    cellString = @"";
    if(!pruthviCell && !_retracted) cellString = @"Unretracted positions!";
    
    if(debugString.length > 0) cellString = [cellString stringByAppendingString:debugString];
    
    cellString = [cellString stringByAppendingFormat:@"\nWafer centre: (%.2f, %.2f)",wCentre.x,wCentre.y];
#ifdef DEBUG
    if(!pruthviCell) cellString = [cellString stringByAppendingFormat:@"\nClicked offset: (%.2f, %.2f)",_startingPoint.x,_startingPoint.y];
#endif
    NSPoint pnt = [theStructuredWafer centroidOfCellUvid: iuiv inWafer: wafer Mirrored:isMirrored];
    
    if(pnt.x < -1.E10) {
        cellString = [cellString stringByAppendingFormat:@"\n\nCell %d:%d does not exist",iu,iv];
        validPoint = NO;
    } else {
        NSPoint qnt = [theStructuredWafer getChosenCellGridCentre];
        if(rot) {
            double xp = pnt.x;
            double yp = pnt.y;
            pnt.x = xp*cos(M_PI/6.) - yp*sin(M_PI/6.);
            pnt.y = xp*sin(M_PI/6.) + yp*cos(M_PI/6.);
            xp = qnt.x;
            yp = qnt.y;
            qnt.x = xp*cos(M_PI/6.) - yp*sin(M_PI/6.);
            qnt.y = xp*sin(M_PI/6.) + yp*cos(M_PI/6.);
        }
        cellString = [cellString stringByAppendingFormat:@"\nCell wrt wafer centre: (%.2f, %.2f)",pnt.x,pnt.y];
        cellCentroid = NSMakePoint(pnt.x+wCentre.x,pnt.y+wCentre.y);
        cellString = [cellString stringByAppendingFormat:@"\nCell %d:%d centroid at (%.2f, %.2f)",iu,iv,cellCentroid.x,cellCentroid.y];
        gPnt = NSMakePoint(qnt.x+wCentre.x,qnt.y+wCentre.y);
        cellString = [cellString stringByAppendingFormat:@"\nGrid centre at (%.2f, %.2f)",gPnt.x,gPnt.y];
        cellString = [cellString stringByAppendingFormat:@"\n[shift vector: (%.2f, %.2f)]",pnt.x-qnt.x,pnt.y-qnt.y];
        validPoint = YES;
    }
    
}

- (void) findNeighbours {
    
    neighbourFinder = YES;
    
    if(!theNeighbours) theNeighbours = [HXGNeighbourFinder sharedNeighbourFinder];
    if(!theInterface) theInterface = [HXGDetIdInterface sharedDetInterface];
    waferList = [NSMutableArray arrayWithCapacity:3];
    cellList[0] = [NSMutableArray arrayWithCapacity:8];
    cellListList  = [NSMutableArray arrayWithCapacity:3];
    int list = 0;
    
    cuv[0] = iu; cuv[1] = iv;
    int DetId = [theInterface DetIdWithWafer: wuv andCell: cuv inLayer: layer];
    int * DetIdList = [theNeighbours nearestNeighboursOfDetId:DetId];
  
    [waferList addObject:wafer];
    HXGWafer * currentWafer = wafer;
    for (int i=0; i<8; i++) {
        if(DetIdList[i] == 0) break;
        int * cwuv = [theInterface cellAndWaferUVFromDetId:DetIdList[i]];
        if(cwuv[2] != currentWafer.detId[0] || cwuv[3] != currentWafer.detId[1]) {
            currentWafer = [theInterface waferWithU:cwuv[2] andV:cwuv[3]];
            [waferList addObject:currentWafer];
            [cellListList addObject:cellList[list++]];
            cellList[list] = [NSMutableArray arrayWithCapacity:8];
        }
        if(![theInterface cellWithU:cwuv[0] andV:cwuv[1] existsInDense:!currentWafer.LD Partial:currentWafer.type]) {
            [self badDetId:cwuv];
        }
        HXGCellIndex * index = [HXGCellIndex cellWithU:cwuv[0] andV:cwuv[1]];
        [cellList[list] addObject:index];
    }
    
    [cellListList addObject:cellList[list]];
    
    [self postNeighboursNotification:YES];

}

- (void) postLocatorNotification:(BOOL) show {
    
    NSNumber * showNeighbours = [NSNumber numberWithBool:NO];
    NSNumber * showCell = [NSNumber numberWithBool:show && validPoint];
    NSNumber * cellCentroidX = [NSNumber numberWithDouble:cellCentroid.x];
    NSNumber * cellCentroidY = [NSNumber numberWithDouble:cellCentroid.y];
    NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:showNeighbours,@"showNeighbours",showCell,@"showCell",cellCentroidX,@"cellCentroidX",cellCentroidY,@"cellCentroidY",nil];
    
    NSNotification * note = [NSNotification notificationWithName: HXGChosenCellNotification object:self userInfo:d];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];

}

- (void) postNeighboursNotification:(BOOL) show {

    cellString = [NSString stringWithFormat:@"Neighbours of seed cell %d:%d\n",iu,iv];

    for(int i=0; i<waferList.count; i++ ) {
        HXGWafer * w = waferList[i];
        if(i > 0) cellString = [cellString stringByAppendingFormat:@"\n"];
        cellString = [cellString stringByAppendingFormat:@"In wafer %d:%d\n",w.detId[0],w.detId[1]];
        NSArray * cList = cellListList[i];
        for(int j=0; j<cList.count; j++) {
            HXGCellIndex * index = cList[j];
            if(j > 0) {
                cellString = [cellString stringByAppendingString:@", "];
                if(j%3 == 0) cellString = [cellString stringByAppendingString:@"\n"];
            }
            cellString = [cellString stringByAppendingFormat:@"cell (%02d:%02d)",index.iu,index.iv];
        }
    }
    [_resultTextField setStringValue:cellString];
    [self adjustDisplaySize];
    
    
    NSNumber * showNeighbours = [NSNumber numberWithBool:show];
    NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:showNeighbours,@"showNeighbours",waferList,@"waferList",cellListList,@"cellListList",nil];
    
    NSNotification * note = [NSNotification notificationWithName: HXGChosenCellNotification object:self userInfo:d];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];

    
}

- (void) adjustDisplaySize {
    
    double lineHeight = 18.;
    double height = lineHeight * (double)[[cellString componentsSeparatedByString:@"\n"] count];
    [self.window setContentSize:NSMakeSize(281.,600.-124.+height)];
    [_resultTextField setFrame:NSMakeRect(20.,38.,241.,height)];
}

- (void) badDetId:(int *) cwuv {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    NSString * message = [NSString stringWithFormat:@"NON-EXISTANT CELL: %d:%d in wafer %d:%d",cwuv[0],cwuv[1],cwuv[2],cwuv[3]];
    [alert setMessageText:message];
    [alert setInformativeText:@"Bug needs fixing"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];

}
#pragma mark - Receipt of notifications

- (void) newLayer:(NSNotification *) note {
    
    [self.window close];

}

- (void) windowWillClose:(NSNotification *) note {
    
    [self postLocatorNotification:NO];
    
}


@end
