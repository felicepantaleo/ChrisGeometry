//
//  HXGWaferInspectorControl.h
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

@interface HXGWaferInspectorControl : NSWindowController {
    
    HXGLayerMapFiles * theMapFiles;
    HGCTerminalControl * theTerminal;
    BOOL empty;
}


@property (assign) IBOutlet HXGInspectorView * inspectorView;
@property (assign) IBOutlet NSButton * showLineButton;

@property NSPoint mousePoint;

+ (id) sharedInspectorControl;
- (void) showSpecsForWafer:(HXGWafer *) wafer;
- (IBAction) showFileLine:(id)sender;

@end

NS_ASSUME_NONNULL_END
