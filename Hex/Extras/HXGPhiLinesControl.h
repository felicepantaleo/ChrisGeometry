//
//  HXGPhiLinesControl.h
//  Hex
//
//  Created by Chris Seez on 15/04/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSColours.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGPhiLinesControl : NSWindowController {
    
    NSSegmentedControl * phiSegs[16];
    NSStepper * stepper[16];
    NSButton * activeB[16];
    double values[16],digh[16], digt[16], digu[16];
    
    int idigit;
    int last;
    
    NSDate * lastDigit;
    int jdigit;
    BOOL firstDigit;

}

@property (assign) IBOutlet NSSlider * labelSlide;
@property (readonly) double labelRadius;

+ (id) sharedPhiLines;

- (IBAction) changeLabelRadius:(id)sender;

- (void) orderBack:(id) sender;

- (double *) getPhiLines:(int *) n;




@end

NS_ASSUME_NONNULL_END
