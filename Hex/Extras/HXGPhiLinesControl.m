//
//  HXGPhiLinesControl.m
//  Hex
//
//  Created by Chris Seez on 15/04/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import "HXGPhiLinesControl.h"

@interface HXGPhiLinesControl ()

@end

NSString * const PhiLinesUpdateNotification = @"PhiLinesUpdate";

@implementation HXGPhiLinesControl


+ (id) sharedPhiLines {
    
    static dispatch_once_t pred;
    static HXGPhiLinesControl * thePhi = nil;
    
    dispatch_once(&pred, ^{ thePhi = [[self alloc] init]; });
    return thePhi;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGPhiLinesControl"];

    double v = 5.;
    for (int i=0; i<16; i++) {
        digh[i] = (double) (((int) v)/10);
        digt[i] = fmod(v,10.);
        digu[i] = 0.;
        v+=5.;
    }
    
    _labelRadius = 1000.;
 
    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    NSRect wRect;                                // Here we define the window
    double width = 238.; double height = 206.;
    wRect.origin = NSMakePoint([[NSScreen mainScreen] frame].size.width-width,[[NSScreen mainScreen] frame].size.height-height-258.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    
    NSRect brect;
    double segWidth = 19.;
    double pntWidth = 14.;

    
    //------------ The segmented control
    double xorig = 6.;
    double yorig = height - 62.;
    for (int i=0;i<8;i++) {
        brect = NSMakeRect(xorig,yorig+2.,20.,20.);
        activeB[i] = [[NSButton alloc] initWithFrame:brect];
        [activeB[i] setButtonType:NSButtonTypeSwitch];
        [activeB[i] setAction:NSSelectorFromString(@"activateLine:")];
        [activeB[i] setState:NO];
        [activeB[i] setTag:i];
        [[[self window] contentView] addSubview:activeB[i]];
        
        brect = NSMakeRect(xorig+18.,yorig,74.,20.); //64 (for 10 6 10 10)
        phiSegs[i] = [[NSSegmentedControl alloc] initWithFrame:brect];
        [phiSegs[i] setSegmentCount:4];
        NSString * str = [NSString stringWithFormat:@"%.0f",digh[i]];
        [phiSegs[i] setLabel:str forSegment:0];
        str = [NSString stringWithFormat:@"%.0f",digt[i]];
        [phiSegs[i] setLabel:str forSegment:1];
        str = [NSString stringWithFormat:@"%.0f",digu[i]];
        [phiSegs[i] setLabel:@"." forSegment:2];
        [phiSegs[i] setLabel:str forSegment:3];
        [phiSegs[i] setWidth:segWidth forSegment:0];
        [phiSegs[i] setWidth:segWidth forSegment:1];
        [phiSegs[i] setWidth:pntWidth forSegment:2];
        [phiSegs[i] setWidth:segWidth forSegment:3];
        for (int j=0;j<4;j++) {[phiSegs[i] setSelected:NO forSegment:j];}
        [phiSegs[i] setAction:NSSelectorFromString(@"changeSegment:")];
        [[phiSegs[i] cell] setFont:[NSFont systemFontOfSize:12]];
        [[phiSegs[i] cell] setControlSize:NSControlSizeRegular];
        [[phiSegs[i] cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
        //[phiSegs[i] setSegmentStyle:NSSegmentStyleTexturedSquare];
        //[[phiSegs[i] cell] setSegmentStyle:NSSegmentStyleTexturedSquare];
        //NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare; //NSSegmentStyleRounded; //NSSegmentStyleRoundRect
        //NSSegmentStyleSmallSquare
        [[[self window] contentView] addSubview:phiSegs[i]];
        [phiSegs[i] setEnabled:NO];
        [phiSegs[i] setTag:i];
        
        //------------- the stepper
        brect = NSMakeRect(xorig+94.,yorig-2.,16.,28.); // ------- define steppers
        stepper[i] = [[NSStepper alloc] initWithFrame:brect];
        [stepper[i] setAction:NSSelectorFromString(@"newStepperValue:")];
        [stepper[i] setControlSize:NSControlSizeSmall];
        [stepper[i] setMinValue:0];
        [stepper[i] setMaxValue:9];
        [stepper[i] setDoubleValue:0];
        [stepper[i] setValueWraps:YES];
        [stepper[i] setIncrement:1];
        [stepper[i] setAutorepeat:NO];
        [[[self window] contentView] addSubview:stepper[i]];
        [stepper[i] setEnabled:NO];
        [stepper[i] setTag:i];
        
        
        yorig -= 30.;
        if(i == 3) {
            xorig = 124.;
            yorig = height - 62.;
        }
    }
    
    idigit = -1;
    last = -1;
    lastDigit = [NSDate date];
    firstDigit = YES;
    [[self window] makeFirstResponder:[[self window] contentView]];

}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];

    //NSColor * veryFaded = [[NSColor pastelBlue] blendedColorWithFraction:0.7 ofColor:[NSColor whiteColor]];
    //veryFaded = [veryFaded colorWithAlphaComponent:0.85];
    //[self.window setBackgroundColor:veryFaded];
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}

- (void) newValue {
    
    NSNotification * note = [NSNotification notificationWithName: PhiLinesUpdateNotification object: self];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];
}

#pragma mark - accessors

- (double *) getPhiLines:(int *) n {
   
    int nn = 0;
    for (int i=0; i<16; i++) {
        if([activeB[i] state]) {
            values[nn] = 10.*digh[i] + digt[i] + digu[i]*0.1;
            nn++;
        }
    }
    n[0] = nn;
    return values;
}

#pragma mark - catch keyboard events

- (void) keyDown:(NSEvent *) theEvent {
    
    if(last < 0) return;
    
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    
    unichar const cup    = 0xf700;
    unichar const cdown  = 0xf701;
    unichar const cleft  = 0xf702;
    unichar const cright = 0xf703;
    unichar const cdel   = 0x007f;
 
    //NSString*   const   chmod   =   [theEvent characters];
    //unichar     const   cdmod   =   [chmod characterAtIndex:0];
    //NSLog(@"cdmod = %0x, keyCode = %d",cdmod,[theEvent keyCode]);

    
    if(code == cup) {
        double v = [stepper[last] doubleValue] + 1.;
        idigit = (int) phiSegs[last].selectedSegment;
        if(idigit == 0) {
            if(v > 5.) v = 0.;
        } else if(v > 9.) v = 0.;
        [stepper[last] setDoubleValue:v];
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [phiSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 1) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        [self newValue];

        return;
    }
    if(code == cdown) {
        double v = [stepper[last] doubleValue] - 1.;
        if(idigit == 0) {
            if(v < 0.) v = 5.;
        } else if(v < 0.) v = 9.;
        [stepper[last] setDoubleValue:v];
        idigit = (int) phiSegs[last].selectedSegment;
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [phiSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 1) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        [self newValue];
        
        return;
    }
    if(code == cleft) {
        int old = (int) phiSegs[last].selectedSegment;
        if(old > 0) idigit = old - 1;
        else return;
        if(idigit == 2) idigit = 1;
        if(idigit == 0) {
            [stepper[last] setMaxValue:5];
            [stepper[last] setDoubleValue:digh[last]];
        }
        if(idigit == 1) {
            [stepper[last] setMaxValue:9];
            [stepper[last] setDoubleValue:digt[last]];
        }
        if(idigit == 3) {
            [stepper[last] setMaxValue:9];
            [stepper[last] setDoubleValue:digu[last]];
        }
        [phiSegs[last] setSelected:NO forSegment:old];
        [phiSegs[last] setSelected:YES forSegment:idigit];
        return;
    }
    if(code == cright) {
        int old = (int) phiSegs[last].selectedSegment;
        if(old < 3) idigit = old + 1;
        else return;
        if(idigit == 2) idigit = 3;
        if(idigit == 0) {
            [stepper[last] setMaxValue:5];
            [stepper[last] setDoubleValue:digh[last]];
        }
        if(idigit == 1) {
            [stepper[last] setMaxValue:9];
            [stepper[last] setDoubleValue:digt[last]];
        }
        if(idigit == 3) {
            [stepper[last] setMaxValue:9];
            [stepper[last] setDoubleValue:digu[last]];
        }
        [phiSegs[last] setSelected:NO forSegment:old];
        [phiSegs[last] setSelected:YES forSegment:idigit];
        return;
    }
    if(code == cdel) {
    //time[itype] = 0.;
     //   [stepper setDoubleValue:0.];
     //   [timeSetter setLabel:@"00" forSegment:2*itype];
     //   [_countView setNeedsDisplay:YES];
        return;
    }
    if(code >= 0x0030 && code < 0x003a) {
        int digit = code & 0x000f;
        double v = (double) digit;
        idigit = (int) phiSegs[last].selectedSegment;
        if(v > 5.  && idigit == 0) return;
        [stepper[last] setDoubleValue:v];
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [phiSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 1) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        
        int map[4] = {1,3,0,3};
        [phiSegs[last] setSelected:NO forSegment:idigit];
        idigit = map[idigit];
        [phiSegs[last] setSelected:YES forSegment:idigit];
        [self newValue];


        return;
    }
}

#pragma mark - IBActions

- (IBAction) activateLine:(id)sender {
    
    int tag = (int) [sender tag];
    
    [phiSegs[tag] setEnabled:[activeB[tag] state]];
    [stepper[tag] setEnabled:[activeB[tag] state]];
    if(last > -1 && idigit > -1) [phiSegs[last] setSelected:NO forSegment:idigit];
    if([activeB[tag] state]) {
        [stepper[tag] setDoubleValue:digh[tag]];
        [stepper[tag] setMaxValue:5];
        last = tag;
        idigit = 0;
        [phiSegs[last] setSelected:YES forSegment:idigit];
    } else {
        last = -1;
    }
    idigit = 0;
    [self newValue];
}

- (IBAction) changeSegment:(id)sender {
    
    if(last > -1 && idigit > -1) [phiSegs[last] setSelected:NO forSegment:idigit];

    int tag = (int) [sender tag];
    last = tag;
    int newdigit = (int) phiSegs[tag].selectedSegment;
    if(newdigit == 2) {
        idigit = 0;
        [phiSegs[last] setSelected:NO forSegment:2];
        [phiSegs[last] setSelected:YES forSegment:1];
    }
    else idigit = newdigit;
    
    if(idigit == 0) {
        [stepper[tag] setMaxValue:5];
        [stepper[tag] setDoubleValue:digh[tag]];
    }
    if(idigit == 1) {
        [stepper[tag] setMaxValue:9];
        [stepper[tag] setDoubleValue:digt[tag]];
    }
    if(idigit == 3) {
        [stepper[tag] setMaxValue:9];
        [stepper[tag] setDoubleValue:digu[tag]];
    }
}

- (IBAction) newStepperValue:(id)sender {
    
    int tag = (int) [sender tag];
    if(tag != last) {
        if(last > -1 && idigit > -1) [phiSegs[last] setSelected:NO forSegment:idigit];
        last = tag; idigit = 0;
        [phiSegs[last] setSelected:YES forSegment:idigit];
        [stepper[tag] setMaxValue:5];
        [stepper[tag] setDoubleValue:digh[tag]];
    }
    
    double v = [stepper[tag] doubleValue];
    idigit = (int) phiSegs[tag].selectedSegment;
    if(idigit < 0) {
        idigit = 0;
        [stepper[tag] setMaxValue:5];
        [stepper[tag] setDoubleValue:digh[tag]];
        [phiSegs[tag] setSelected:YES forSegment:idigit];
    }
    
    NSString * str = [NSString stringWithFormat:@"%.0f",v];
    [phiSegs[tag] setLabel:str forSegment:idigit];

    if(idigit == 0) digh[tag] = v;
    
    if(idigit == 1) {
        if(digt[tag] == 9 && v == 0) {
            if(digh[tag] < 5) {
                digh[tag] += 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [phiSegs[tag] setLabel:str forSegment:0];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digt[tag]];
                [phiSegs[tag] setLabel:@"9" forSegment:3];
                return;
            }
        }
        if(digt[tag] == 0 && v == 9) {
            if(digh[tag] > 1) {
                digh[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [phiSegs[tag] setLabel:str forSegment:0];
            }  else {
                NSBeep();
                [stepper[tag] setDoubleValue:digh[tag]];
                [phiSegs[tag] setLabel:@"0" forSegment:1];
                return;
            }
        }
        digt[tag] = v;
    }
    
    if(idigit == 3) {
        if(digu[tag] == 9 && v == 0) {
            if(digt[tag] < 9) {
                digt[tag] += 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digt[tag]];
                [phiSegs[tag] setLabel:str forSegment:1];
            } else if(digh[tag] < 5) {
                digt[tag] = 0;
                digh[tag] += 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [phiSegs[tag] setLabel:str forSegment:0];
                [phiSegs[tag] setLabel:@"0" forSegment:1];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digu[tag]];
                [phiSegs[tag] setLabel:@"9" forSegment:3];
                return;
            }
        }
        if(digu[tag] == 0 && v == 9) {
            if(digt[tag] > 0) {
                digt[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digt[tag]];
                [phiSegs[tag] setLabel:str forSegment:1];
            } else if(digh[tag] > 0) {
                digt[tag] = 9;
                digh[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [phiSegs[tag] setLabel:str forSegment:0];
                [phiSegs[tag] setLabel:@"9" forSegment:1];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digu[tag]];
                [phiSegs[tag] setLabel:@"0" forSegment:3];
                return;
            }
        }
        digu[tag] = v;
    }
    
    [self newValue];
    
}

- (IBAction) changeLabelRadius:(id)sender {
    
    _labelRadius = [sender doubleValue];
    [self newValue];

}

@end
