//
//  HXGCoverageControl.h
//  Hex
//
//  Created by Chris Seez on 21/01/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGNotifications.h"
#import <Cocoa/Cocoa.h>

    

NS_ASSUME_NONNULL_BEGIN

@interface HXGCoverageControl : NSWindowController {


}

@property (readonly) int first;
@property (readonly) int last;


@property (assign) IBOutlet NSButton * okbutton;
@property (assign) IBOutlet NSButton * cancelbutton;

@property (assign) IBOutlet NSTextField * firststring;
@property (assign) IBOutlet NSTextField * laststring;

@property (assign) IBOutlet NSStepper * firststepper;
@property (assign) IBOutlet NSStepper * laststepper;


+ (id) sharedCoverageControl;

- (void) orderBack:(id) sender;

- (IBAction) changeValue:(id)sender;
- (IBAction) closeDialogue:(id)sender;


@end

NS_ASSUME_NONNULL_END
