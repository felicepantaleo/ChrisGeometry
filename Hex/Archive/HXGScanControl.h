//
//  HXGScanControl.h
//  Hex
//
//  Created by Chris Seez on 19/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGNotifications.h"

@interface HXGScanControl : NSWindowController {
    
    int nlayers;
    BOOL radiationLengths;
    BOOL removePb;
    BOOL trimCEH;
    BOOL outerscan;
    double CEHtrim;
    double progressCount;
}

@property (assign) IBOutlet NSTextField * layerslabel;
@property (assign) IBOutlet NSTextField * CEHlabel;
@property (assign) IBOutlet NSStepper * layerstepper;
@property (assign) IBOutlet NSStepper * CEHstepper;

@property (assign) IBOutlet NSButton * X0button;
@property (assign) IBOutlet NSButton * Lambutton;
@property (assign) IBOutlet NSButton * Pbbutton;
@property (assign) IBOutlet NSButton * CEHbutton;
@property (assign) IBOutlet NSButton * scanbutton;
@property (assign) IBOutlet NSButton * cancelbutton;


+ (id) sharedScanControl;

- (void) initializeScanTypeOuter:(BOOL) outer;

- (IBAction) changeLayers:(id)sender;

- (IBAction) changeThickUnit:(id)sender;

- (IBAction) changeCEH:(id)sender;

- (IBAction) changePb:(id)sender;

- (IBAction) scan:(id)sender;

- (IBAction) cancel:(id)sender;

@end
