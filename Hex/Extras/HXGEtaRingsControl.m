//
//  EtaRingsControl.m
//  Lambda
//
//  Created by Chris Seez on 13/07/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "HXGEtaRingsControl.h"

@interface HXGEtaRingsControl ()

@end

NSString * const EtaRingsUpdateNotification = @"EtaRingsUpdate";

@implementation HXGEtaRingsControl

const double segWidth = 19.;
const double pntWidth = 14.;

+ (id) sharedEtaRings {
    
    static dispatch_once_t pred;
    static HXGEtaRingsControl * theEta = nil;
    
    dispatch_once(&pred, ^{ theEta = [[self alloc] init]; });
    return theEta;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGEtaRingsControl"];
    
    double v = 1.4;
    for (int i=0; i<16; i++) {
        digh[i] = (double) (int)   (v + 0.005);
        digt[i] = (double) (int)  ((v - digh[i])*10. + 0.1);
        digu[i] = (double) (int) (((v - digh[i])*10. - digt[i])*10.  + 0.005);
        v = v + 0.2;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSRect wRect;                                // Here we define the window
    double width = 238.; double height = 226.;
    wRect.origin = NSMakePoint([[NSScreen mainScreen] frame].size.width-width,[[NSScreen mainScreen] frame].size.height-height-30.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    
    // ------------------- make the ring colour selection buttons
    
    ringChoices[0] = [NSColor redColor];
    ringChoices[1] = [NSColor blueColor];
    ringChoices[2] = [NSColor wildViolet];
    ringChoices[3] = [NSColor darkGrayColor];
    
    NSRect brect = NSMakeRect(50.,42.,20.,20.);
    NSRect crect = NSMakeRect(46.,38.,28.,28.);
    for(int i=0; i<4; i++) {
        selBox[i] = [[NSBox alloc] initWithFrame:crect];
        [selBox[i] setBoxType:NSBoxCustom];
        [selBox[i] setBorderColor:[NSColor windowBackgroundColor]];
        [selBox[i] setBorderWidth:1.];
        [[[self window] contentView] addSubview:selBox[i]];
        ringColorButton[i] = [[NSButton alloc] initWithFrame:brect];
        [ringColorButton[i] setTitle:@""];
        [ringColorButton[i] setButtonType:NSButtonTypeOnOff];
        [ringColorButton[i] setBordered:NO];
        [ringColorButton[i] highlight:YES];
        [[ringColorButton[i] cell] setBackgroundColor:ringChoices[i]];
        [[[self window] contentView] addSubview:ringColorButton[i]];
        [ringColorButton[i] setTag:i];
        [ringColorButton[i] setAction:@selector(changeSelectedColor:)];
        brect.origin.x += 40.;
        crect.origin.x += 40.;
    }
    [selBox[_iRingColor] setBorderWidth:2.];
    [selBox[_iRingColor] setBorderColor:[NSColor blackColor]];
    _ringColor = ringChoices[_iRingColor];
    
    // ------------------- make phi spoke button
    brect = NSMakeRect(6.,6.,175.,24.);
    phiButton = [[NSButton alloc] initWithFrame:brect];
    [phiButton setFont:[NSFont systemFontOfSize:12]];
    [phiButton setTitle:@"Draw φ spokes"];
    [phiButton setAction:@selector(enablePhi:)];
    [phiButton setButtonType:NSButtonTypeSwitch];
    [[[self window] contentView] addSubview:phiButton];
    [phiButton setState:NO];
    _drawPhiSpokes = NO;
    
    //------------ The semented control
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
        etaSegs[i] = [[NSSegmentedControl alloc] initWithFrame:brect];
        [etaSegs[i] setSegmentCount:4];
        NSString * str = [NSString stringWithFormat:@"%.0f",digh[i]];
        [etaSegs[i] setLabel:str forSegment:0];
        [etaSegs[i] setLabel:@"." forSegment:1];
        str = [NSString stringWithFormat:@"%.0f",digt[i]];
        [etaSegs[i] setLabel:str forSegment:2];
        str = [NSString stringWithFormat:@"%.0f",digu[i]];
        [etaSegs[i] setLabel:str forSegment:3];
        [etaSegs[i] setWidth:segWidth forSegment:0];
        [etaSegs[i] setWidth:pntWidth forSegment:1];
        [etaSegs[i] setWidth:segWidth forSegment:2];
        [etaSegs[i] setWidth:segWidth forSegment:3];
        for (int j=0;j<4;j++) {[etaSegs[i] setSelected:NO forSegment:j];}
        [etaSegs[i] setAction:NSSelectorFromString(@"changeSegment:")];
        [[etaSegs[i] cell] setFont:[NSFont systemFontOfSize:12]];
        [[etaSegs[i] cell] setControlSize:NSControlSizeRegular];
        [[etaSegs[i] cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
        //[etaSegs[i] setSegmentStyle:NSSegmentStyleTexturedSquare];
        //[[etaSegs[i] cell] setSegmentStyle:NSSegmentStyleTexturedSquare];
        //NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare; //NSSegmentStyleRounded; //NSSegmentStyleRoundRect
        //NSSegmentStyleSmallSquare
        [[[self window] contentView] addSubview:etaSegs[i]];
        [etaSegs[i] setEnabled:NO];
        [etaSegs[i] setTag:i];
        
        //------------- the stepper
        brect = NSMakeRect(xorig+94.,yorig-2.,16.,28.); // ------- define steppers
        stepper[i] = [[NSStepper alloc] initWithFrame:brect];
        [stepper[i] setAction:NSSelectorFromString(@"newStepperValue:")];
        [stepper[i] setControlSize:NSControlSizeSmall];
        [stepper[i] setMinValue:0];
        [stepper[i] setMaxValue:9];
        [stepper[i] setDoubleValue:0];
        [stepper[i] setValueWraps:NO];
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
    
    NSNotification * note = [NSNotification notificationWithName: EtaRingsUpdateNotification object: self];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];
}

#pragma mark - accessors

- (double *) getEtaRings:(int *) n {
    
    int nn = 0;
    for (int i=0; i<16; i++) {
        if([activeB[i] state]) {
            values[nn] = digh[i] + digt[i]*0.1 + digu[i]*0.01;
            nn++;
        }
    }
    n[0] = nn;
    return values;
}

#pragma mark - catch keyboard events


-(void)selectNextKeyView:(id)sender {
    NSLog(@"Oh, really cool!");
}
//- (void) keyUp:(NSEvent *) theEvent {
//    NSLog(@"Key up...");
//}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
    // Needs to be in NSView subclass...
    NSLog(@"performKeyEquivalent");
    return NO;
}

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
        idigit = (int) etaSegs[last].selectedSegment;
        if(v > 3. && idigit == 0) v = 1.;
        if(v > 9. && idigit > 0) v = 0.;
        [stepper[last] setDoubleValue:v];
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [etaSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 2) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        [self newValue];

        return;
    }
    if(code == cdown) {
        double v = [stepper[last] doubleValue] - 1.;
        if(v < 1. && idigit == 0) v = 3.;
        if(v < 0. && idigit > 0) v = 9.;
        [stepper[last] setDoubleValue:v];
        idigit = (int) etaSegs[last].selectedSegment;
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [etaSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 2) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        [self newValue];
        
        return;
    }
    if(code == cleft) {
        int old = (int) etaSegs[last].selectedSegment;
        if(old > 0) idigit = old - 1;
        else return;
        if(idigit == 1) idigit = 0;
        if(idigit == 0) {
            [stepper[last] setMaxValue:3]; [stepper[last] setMinValue:1];
            [stepper[last] setDoubleValue:digh[last]];
        }
        if(idigit == 2) {
            [stepper[last] setMaxValue:9]; [stepper[last] setMinValue:0];
            [stepper[last] setDoubleValue:digt[last]];
        }
        if(idigit == 3) {
            [stepper[last] setMaxValue:9]; [stepper[last] setMinValue:0];
            [stepper[last] setDoubleValue:digu[last]];
        }
        [etaSegs[last] setSelected:NO forSegment:old];
        [etaSegs[last] setSelected:YES forSegment:idigit];
        return;
    }
    if(code == cright) {
        int old = (int) etaSegs[last].selectedSegment;
        if(old < 3) idigit = old + 1;
        else return;
        if(idigit == 1) idigit = 2;
        if(idigit == 0) {
            [stepper[last] setMaxValue:3]; [stepper[last] setMinValue:1];
            [stepper[last] setDoubleValue:digh[last]];
        }
        if(idigit == 2) {
            [stepper[last] setMaxValue:9]; [stepper[last] setMinValue:0];
            [stepper[last] setDoubleValue:digt[last]];
        }
        if(idigit == 3) {
            [stepper[last] setMaxValue:9]; [stepper[last] setMinValue:0];
            [stepper[last] setDoubleValue:digu[last]];
        }
        [etaSegs[last] setSelected:NO forSegment:old];
        [etaSegs[last] setSelected:YES forSegment:idigit];
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
        idigit = (int) etaSegs[last].selectedSegment;
        if((v > 3. || v < 1.) && idigit == 0) return;
        [stepper[last] setDoubleValue:v];
        NSString * str = [NSString stringWithFormat:@"%.0f",v];
        [etaSegs[last] setLabel:str forSegment:idigit];
        
        if(idigit == 0) { digh[last] = v;}
        if(idigit == 2) { digt[last] = v;}
        if(idigit == 3) { digu[last] = v;}
        
        int map[4] = {2,0,3,3};
        [etaSegs[last] setSelected:NO forSegment:idigit];
        idigit = map[idigit];
        [etaSegs[last] setSelected:YES forSegment:idigit];
        [self newValue];


        return;
    }
}

#pragma mark - IBActions

- (void) changeSelectedColor: (id) sender {
    
    [selBox[_iRingColor] setBorderWidth:1.];
    [selBox[_iRingColor] setBorderColor:[NSColor windowBackgroundColor]];
    
    _iRingColor = (int) [sender tag];

    [selBox[_iRingColor] setBorderWidth:2.];
    [selBox[_iRingColor] setBorderColor:[NSColor blackColor]];
    
    _ringColor = ringChoices[_iRingColor];

    [self newValue];

}

- (IBAction) enablePhi:(id)sender {
    
    _drawPhiSpokes = [phiButton state];
    [self newValue];
    
}


- (IBAction) activateLine:(id)sender {
    
    int tag = (int) [sender tag];
    [etaSegs[tag] setEnabled:[activeB[tag] state]];
    [stepper[tag] setEnabled:[activeB[tag] state]];
    if(last > -1 && idigit > -1) [etaSegs[last] setSelected:NO forSegment:idigit];
    if([activeB[tag] state]) {
        [stepper[tag] setDoubleValue:digh[tag]];
        [stepper[tag] setMaxValue:3];
        [stepper[tag] setMinValue:1];
        last = tag;
        idigit = 0;
        [etaSegs[last] setSelected:YES forSegment:idigit];
    } else {
        last = -1;
    }
    idigit = 0;
    [self newValue];
}

- (IBAction) changeSegment:(id)sender {
    
    if(last > -1 && idigit > -1) [etaSegs[last] setSelected:NO forSegment:idigit];

    int tag = (int) [sender tag];
    last = tag;
    int newdigit = (int) etaSegs[tag].selectedSegment;
    if(newdigit == 1) {
        idigit = 0;
        [etaSegs[last] setSelected:NO forSegment:1];
        [etaSegs[last] setSelected:YES forSegment:0];
    }
    else idigit = newdigit;
    
    if(idigit == 0) {
        [stepper[tag] setMaxValue:3]; [stepper[tag] setMinValue:1];
        [stepper[tag] setDoubleValue:digh[tag]];
        [stepper[tag] setValueWraps:NO];
    }
    if(idigit == 2) {
        [stepper[tag] setMaxValue:9]; [stepper[tag] setMinValue:0];
        [stepper[tag] setDoubleValue:digt[tag]];
        [stepper[tag] setValueWraps:YES];
    }
    if(idigit == 3) {
        [stepper[tag] setMaxValue:9]; [stepper[tag] setMinValue:0];
        [stepper[tag] setDoubleValue:digu[tag]];
        [stepper[tag] setValueWraps:YES];
    }
}

- (IBAction) newStepperValue:(id)sender {
    
    int tag = (int) [sender tag];
    if(tag != last) {
        if(last > -1 && idigit > -1) [etaSegs[last] setSelected:NO forSegment:idigit];
        last = tag; idigit = 0;
        [etaSegs[last] setSelected:YES forSegment:idigit];
        [stepper[tag] setMaxValue:3]; [stepper[tag] setMinValue:1];
        [stepper[tag] setDoubleValue:digh[tag]];
    }
    
    double v = [stepper[tag] doubleValue];
    idigit = (int) etaSegs[tag].selectedSegment;
    if(idigit < 0) {
        idigit = 0;
        [stepper[tag] setMaxValue:3]; [stepper[tag] setMinValue:1];
        [stepper[tag] setDoubleValue:digh[tag]];
        [etaSegs[tag] setSelected:YES forSegment:idigit];
    }
    
    NSString * str = [NSString stringWithFormat:@"%.0f",v];
    [etaSegs[tag] setLabel:str forSegment:idigit];

    if(idigit == 0) digh[tag] = v;
    
    if(idigit == 2) {
        if(digt[tag] == 9 && v == 0) {
            if(digh[tag] < 3) {
                digh[tag] += 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [etaSegs[tag] setLabel:str forSegment:0];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digt[tag]];
                [etaSegs[tag] setLabel:@"9" forSegment:2];
                return;
            }
        }
        if(digt[tag] == 0 && v == 9) {
            if(digh[tag] > 1) {
                digh[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [etaSegs[tag] setLabel:str forSegment:0];
            }  else {
                NSBeep();
                [stepper[tag] setDoubleValue:digh[tag]];
                [etaSegs[tag] setLabel:@"0" forSegment:2];
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
                [etaSegs[tag] setLabel:str forSegment:2];
            } else if(digh[tag] < 3) {
                digt[tag] = 0;
                digh[tag] += 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [etaSegs[tag] setLabel:str forSegment:0];
                [etaSegs[tag] setLabel:@"0" forSegment:2];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digu[tag]];
                [etaSegs[tag] setLabel:@"9" forSegment:3];
                return;
            }
        }
        if(digu[tag] == 0 && v == 9) {
            if(digt[tag] > 0) {
                digt[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digt[tag]];
                [etaSegs[tag] setLabel:str forSegment:2];
            } else if(digh[tag] > 1) {
                digt[tag] = 9;
                digh[tag] -= 1;
                NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
                [etaSegs[tag] setLabel:str forSegment:0];
                [etaSegs[tag] setLabel:@"9" forSegment:2];
            } else {
                NSBeep();
                [stepper[tag] setDoubleValue:digu[tag]];
                [etaSegs[tag] setLabel:@"0" forSegment:3];
                return;
            }
        }
        digu[tag] = v;
    }
    
    [self newValue];

}


@end
