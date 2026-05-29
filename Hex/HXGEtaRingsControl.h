//
//  EtaRingsControl.h
//  Lambda
//
//  Created by Chris Seez on 13/07/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HXGEtaRingsControl : NSWindowController {
    
    NSSegmentedControl * etaSegs[16];
    NSStepper * stepper[16];
    NSButton * activeB[16];
    NSButton * phiButton;
    double values[16],digh[16], digt[16], digu[16];
    
    int idigit;
    int last;
    
    NSDate * lastDigit;
    int jdigit;
    BOOL firstDigit;

}

@property BOOL drawPhiSpokes;

+ (id) sharedEtaRings;

- (IBAction) enablePhi:(id)sender;

- (double *) getEtaRings:(int *) n;

@end
