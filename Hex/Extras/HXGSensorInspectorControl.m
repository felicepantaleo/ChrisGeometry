//
//  HXGSensorInspectorControl.m
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGSensorInspectorControl.h"

@interface HXGSensorInspectorControl ()

@end

@implementation HXGSensorInspectorControl

+ (id) sharedInspectorControl {
    
    static dispatch_once_t pred;
    static HXGSensorInspectorControl * theInspector = nil;
    
    dispatch_once(&pred, ^{ theInspector = [[self alloc] init]; });
    return theInspector;

}

- (id)init {

    self=[super initWithWindowNibName: @"HXGSensorInspectorControl"];
    theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    return self;
}


- (void)windowDidLoad {
    
    [super windowDidLoad];
  
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    newSensor = YES;
    
}

- (void) showSpecsForWafer:(HXGWafer *) wafer {
    
    [self showWindow:self];
    
    _inspectorView.wafer = wafer;
    _inspectorView.isWafer = YES;
    rotatedDisplay = _inspectorView.rotated && _inspectorView.rotateRotated;
    if(!rotatedDisplay) _inspectorView.rotatedValues = NO;
    [_rotatedButton setState:_inspectorView.rotatedValues];
    if(!_beyondV17) _inspectorView.retractedValues = NO;
    else [_retractedButton setState:_inspectorView.retractedValues];

    
    viewSize = [_inspectorView setUpWaferInspectorDisplay];
    
    NSString * title = [NSString stringWithFormat:@"DetId = (%d, %d)",wafer.detId[0],wafer.detId[1]];
    idForPDF = [NSString stringWithFormat:@"Wafer-%d-%d",wafer.detId[0],wafer.detId[1]];
    [self.window setTitle:title];
    
    [self completeTheDisplay];
    
}

- (void) showSpecsForTileIn:(int) iRing At: (int) iphi; {
    
    [self showWindow:self];
    
    _inspectorView.isWafer = NO;
    _inspectorView.iRing = iRing;
    _inspectorView.iphi = iphi;
    _inspectorView.beyondV17 = _beyondV17;

    viewSize = [_inspectorView setUpTileInspectorDisplay];

    NSString * title = [NSString stringWithFormat:@"iRing = %d, iphi = %d",iRing,iphi];
    idForPDF = [NSString stringWithFormat:@"Tile-%d-%d",iRing,iphi];
    [self.window setTitle:title];
    
    [self completeTheDisplay];

}

- (void) completeTheDisplay {
    
    [_retractedButton setHidden:!_beyondV17 || _alreadyRetracted || !_inspectorView.isWafer];
    [_rotatedButton setHidden:!rotatedDisplay || !_inspectorView.isWafer];
    _inspectorView.alreadyRetracted = _alreadyRetracted;

    NSRect wRect;                                // Here we define the window
    if(newSensor) {
        wRect.origin = NSMakePoint(_mousePoint.x+_sidestep,_mousePoint.y-0.5*viewSize.height);
        if(wRect.origin.x > [[NSScreen mainScreen] frame].size.width - 360.) wRect.origin.x = [[NSScreen mainScreen] frame].size.width - 360.;
    } else wRect.origin = self.window.frame.origin;
    if(wRect.origin.y < 0) wRect.origin.y = 0.;
    wRect.size = viewSize;
    wRect.size.height += 30.;
    [self.window setFrame:wRect display:YES];
    
    NSRect vRect = wRect;                                // ??????? Here we define the view
    vRect.origin = NSZeroPoint;
    _inspectorView.frame = vRect;
        
    [_inspectorView setNeedsDisplay:YES];
    newSensor = NO;

}

- (void) makePDF {
    
    NSString * filename = [NSString stringWithFormat:@"%@.pdf",idForPDF];
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString * pdfpath = [[export URL] path];
            [self.inspectorView savePDF:pdfpath];
        }
    }];
}

- (IBAction) changeRetracted:(id)sender {
    
    _inspectorView.retractedValues = [sender state];
    
    if(_inspectorView.isWafer) viewSize = [_inspectorView setUpWaferInspectorDisplay];
    else viewSize = [_inspectorView setUpTileInspectorDisplay];

//    [_inspectorView setNeedsDisplay:YES];
    [self completeTheDisplay];

}

- (IBAction) changeRotated:(id)sender {
    
    _inspectorView.rotatedValues = [sender state];
    viewSize = [_inspectorView setUpWaferInspectorDisplay];
    [self completeTheDisplay];

}

- (IBAction) showFileLine:(id)sender {
    
    NSString * text = @"\nFlat-file: ";
    if(_inspectorView.isWafer) {
        text = [text stringByAppendingString:theMapFiles.waferFlatFile];
        text = [text stringByAppendingFormat:@"\nFile line %d: ",_inspectorView.wafer.fileLine+1];
        text = [text stringByAppendingString:[theMapFiles getLineNumber:_inspectorView.wafer.fileLine]];
    } else {
        text = [text stringByAppendingString:theMapFiles.tileFlatFile];
        int fileLine = [theMapFiles getTileLineNumberForLayer: _inspectorView.nlayer andRing: _inspectorView.iRing-1];
        text = [text stringByAppendingFormat:@"\nFile line %d: ",fileLine+1];
        text = [text stringByAppendingString:[theMapFiles getTileLineString:fileLine]];
    }
    text = [text stringByAppendingString:@"\n\n"];
    text = [text stringByAppendingString:_inspectorView.tString];
    text = [text stringByAppendingString:@"\n          ----------\n"];

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"SensorInspector";

    [theTerminal showWindow:nil];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal displayString:text];

}
@end
