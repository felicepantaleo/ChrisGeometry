//
//  HXGSensorInspectorControl.h
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HGCTerminalControl.h"
#import "HXGLayerMapFiles.h"
#import "HXGInspectorView.h"
#import "HXGWafer.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGSensorInspectorControl : NSWindowController {
    
    HXGLayerMapFiles * theMapFiles;
    HGCTerminalControl * theTerminal;
    NSSize viewSize;
    BOOL rotatedDisplay;
    NSString * idForPDF;
    BOOL newSensor;
}


@property (assign) IBOutlet HXGInspectorView * inspectorView;
@property (assign) IBOutlet NSButton * showLineButton;
@property (assign) IBOutlet NSButton * retractedButton;
@property (assign) IBOutlet NSButton * rotatedButton;

@property BOOL beyondV17;
@property BOOL alreadyRetracted;
@property NSPoint mousePoint;
@property double sidestep;

+ (id) sharedInspectorControl;
- (void) showSpecsForWafer:(HXGWafer *) wafer;
- (void) showSpecsForTileIn:(int) iRing At: (int) iphi;
- (void) makePDF;
- (IBAction) changeRetracted:(id)sender;
- (IBAction) changeRotated:(id)sender;
- (IBAction) showFileLine:(id)sender;

@end

NS_ASSUME_NONNULL_END
