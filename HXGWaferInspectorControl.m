//
//  HXGWaferInspectorControl.m
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGWaferInspectorControl.h"

@interface HXGWaferInspectorControl ()

@end

@implementation HXGWaferInspectorControl

+ (id) sharedInspectorControl {
    
    static dispatch_once_t pred;
    static HXGWaferInspectorControl * theInspector = nil;
    
    dispatch_once(&pred, ^{ theInspector = [[self alloc] init]; });
    return theInspector;

}

- (id)init {

    self=[super initWithWindowNibName: @"HXGWaferInspectorControl"];
    theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    return self;
}


- (void)windowDidLoad {
    
    [super windowDidLoad];
  
}

- (void) showWindow:(id)sender {
    [super showWindow:sender];

}

- (void) showSpecsForWafer:(HXGWafer *) wafer {
  
    [self showWindow:self];

    _inspectorView.wafer = wafer;
    empty = !(wafer.whole || wafer.part);
    
    NSSize viewSize = [_inspectorView setUpTheInspectorDisplay];
 
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(_mousePoint.x+40.,_mousePoint.y-0.5*viewSize.height);
    if(wRect.origin.y < 0) wRect.origin.y = 0.;
    wRect.size = viewSize;
    wRect.size.height += 30.;
    [self.window setFrame:wRect display:YES];
    
    NSRect vRect = wRect;                                // Here we define the view
    vRect.origin = NSZeroPoint;
    _inspectorView.frame = vRect;
    
    NSString * title = [NSString stringWithFormat:@"(%d,%d)",wafer.detId[0],wafer.detId[1]];
    [self.window setTitle:title];
    
    [_inspectorView setNeedsDisplay:YES];



}

- (IBAction) showFileLine:(id)sender {
    
    if(empty) return;
    
    NSString * text = @"\nFlat-file: ";
    text = [text stringByAppendingString:theMapFiles.waferFlatFile];
    text = [text stringByAppendingFormat:@"\n%d: ",_inspectorView.wafer.fileLine+1];
    text = [text stringByAppendingString:[theMapFiles getLineNumber:_inspectorView.wafer.fileLine]];
    text = [text stringByAppendingString:@"\n\n"];
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal showWindow:nil];
    [theTerminal displayString:text];


}
@end
