//
//  HXGLongDiagramControl.h
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGNotifications.h"
#import "HXGLongView.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGLongDiagramControl : NSWindowController {
    
    NSPoint crossHairs;
    
    double zLow,rLow,scale;
    
    NSSegmentedControl * etaSegs[3];
    NSStepper * stepper[3];
    NSButton * activeB[3];
    double values[3],digh[3], digt[3], digu[3];
    
    int idigit;
    int last;
    
    NSDate * lastDigit;
    int jdigit;
    BOOL firstDigit;

    NSTimeInterval tstart;
    int repcount;

}


@property (assign) IBOutlet HXGLongView * longView;
@property (assign) IBOutlet NSTextField * positionLabel;
@property (assign) IBOutlet NSButton * crossHairsButton;
@property (assign) IBOutlet NSButton * calibrationButton;

+ (id) sharedDiagramControl;

- (IBAction) showCrossHairs:(id)sender;
- (IBAction) calibrationMode:(id)sender;
- (IBAction) adjustPosition:(id)sender;

- (void) newCrossHairs:(NSNotification *) note;


@end

NS_ASSUME_NONNULL_END
