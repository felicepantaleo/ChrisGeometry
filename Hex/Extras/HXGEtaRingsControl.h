//
//  EtaRingsControl.h
//  Lambda
//
//  Created by Chris Seez on 13/07/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSColours.h"

@interface HXGEtaRingsControl : NSWindowController {
    
    NSSegmentedControl * etaSegs[16];
    NSStepper * stepper[16];
    NSButton * activeB[16];
    NSButton * phiButton;
    NSButton * ringColorButton[4];
    NSBox * selBox[4];
    double values[16],digh[16], digt[16], digu[16];
    
    NSColor * ringChoices[4];
    
    int idigit;
    int last;
    
    NSDate * lastDigit;
    int jdigit;
    BOOL firstDigit;

}

@property (readonly) BOOL drawPhiSpokes;
@property (readonly) NSColor * ringColor;
@property int iRingColor;


+ (id) sharedEtaRings;

- (void) orderBack:(id) sender;

- (IBAction) enablePhi:(id)sender;

- (double *) getEtaRings:(int *) n;

@end
