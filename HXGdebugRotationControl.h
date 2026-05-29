//
//  HXGdebugRotationControl.h
//  Hex
//
//  Created by Chris Seez on 17/01/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGCellControl.h"
#import "HXGPreferenceControl.h"
#import "HXGNotifications.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGdebugRotationControl : NSWindowController {
    
    HXGPreferenceControl * thePreferences;
    HXGCellControl * theCellControl;
    int iu,iv,placement;
    NSString * resultString;
    
    double NN,RR,rr;
}

@property (assign) IBOutlet NSTextField * iuText;
@property (assign) IBOutlet NSTextField * ivText;
@property (assign) IBOutlet NSTextField * placementText;
@property (assign) IBOutlet NSStepper * iuStepper;
@property (assign) IBOutlet NSStepper * ivStepper;
@property (assign) IBOutlet NSStepper * placementStepper;

@property (assign) IBOutlet NSTextField * resultText;


+ (id) sharedRotationControl;
- (void) newSpec:(NSNotification *) note;
- (IBAction) changeStepper:(id)sender;
@end

NS_ASSUME_NONNULL_END
