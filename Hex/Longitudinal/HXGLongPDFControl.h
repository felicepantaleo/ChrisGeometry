//
//  HXGLongPDFControl.h
//  Hex
//
//  Created by Chris Seez on 25/11/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGLongPDFControl : NSWindowController {
/*
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
*/
}


@property (assign) IBOutlet NSView * longView;
@property (assign) IBOutlet NSTextField * positionLabel;
@property (assign) IBOutlet NSButton * crossHairsButton;
@property (assign) IBOutlet NSButton * calibrationButton;

+ (id) sharedPDFControl;
/*
- (IBAction) showCrossHairs:(id)sender;
- (IBAction) calibrationMode:(id)sender;
- (IBAction) adjustPosition:(id)sender;

- (void) newCrossHairs:(NSNotification *) note;
*/


@end

NS_ASSUME_NONNULL_END
