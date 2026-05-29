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
        //NSLog(@"v = %.2f: %.0f %.0f %.0f",v,digh[i],digt[i],digu[i]);
        v = v + 0.2;
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSRect wRect;                                // Here we define the window
    double width = 222.; double height = 200.;
    wRect.origin = NSMakePoint(940.,[[NSScreen mainScreen] frame].size.height-height-200.0);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];

    // ------------------- make phi spoke button
    NSRect brect = NSMakeRect(10.,10.,175.,24.);
    phiButton = [[NSButton alloc] initWithFrame:brect];
    [phiButton setFont:[NSFont systemFontOfSize:14]];
    [phiButton setTitle:@"Draw φ spokes"];
    [phiButton setAction:@selector(enablePhi:)];
    [phiButton setButtonType:NSButtonTypeSwitch];
    [[[self window] contentView] addSubview:phiButton];
    [phiButton setState:NO];
    _drawPhiSpokes = NO;

    //------------ The semented control
    double xorig = 32.;
    double yorig = height - 62.;
    for (int i=0;i<8;i++) {
        brect = NSMakeRect(xorig-20.,yorig+4.,20.,20.);
        activeB[i] = [[NSButton alloc] initWithFrame:brect];
        [activeB[i] setButtonType:NSButtonTypeSwitch];
        [activeB[i] setAction:NSSelectorFromString(@"activateLine:")];
        [activeB[i] setState:NO];
        [activeB[i] setTag:i];
        [[[self window] contentView] addSubview:activeB[i]];

        brect = NSMakeRect(xorig,yorig,64.,26.);
        etaSegs[i] = [[NSSegmentedControl alloc] initWithFrame:brect];
        [etaSegs[i] setSegmentCount:4];
        NSString * str = [NSString stringWithFormat:@"%.0f",digh[i]];
        [etaSegs[i] setLabel:str forSegment:0];
        [etaSegs[i] setLabel:@"." forSegment:1];
        str = [NSString stringWithFormat:@"%.0f",digt[i]];
        [etaSegs[i] setLabel:str forSegment:2];
        str = [NSString stringWithFormat:@"%.0f",digu[i]];
        [etaSegs[i] setLabel:str forSegment:3];
        [etaSegs[i] setWidth:10 forSegment:0];
        [etaSegs[i] setWidth:6 forSegment:1];
        [etaSegs[i] setWidth:10 forSegment:2];
        [etaSegs[i] setWidth:10 forSegment:3];
        etaSegs[i].segmentStyle = NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare; //NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare;NSSegmentStyleRoundRect
        for (int j=0;j<4;j++) {[etaSegs[i] setSelected:NO forSegment:j];}
        [etaSegs[i] setAction:NSSelectorFromString(@"changeSegment:")];
        [[etaSegs[i] cell] setFont:[NSFont systemFontOfSize:14]];
        [[etaSegs[i] cell] setControlSize:NSControlSizeSmall];
        [[etaSegs[i] cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
        //[[etaSegs[i] cell] setSegmentStyle:NSSegmentStyleRounded];
        [[[self window] contentView] addSubview:etaSegs[i]];
        [etaSegs[i] setEnabled:NO];
        [etaSegs[i] setTag:i];

        //------------- the stepper
        brect = NSMakeRect(xorig+52.,yorig,16.,28.); // ------- define steppers
        stepper[i] = [[NSStepper alloc] initWithFrame:brect];
        [stepper[i] setAction:NSSelectorFromString(@"newStepperValue:")];
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
            xorig = 146.;
            yorig = height - 62.;
        }
    }
    
    idigit = -1;
    last = -1;
    lastDigit = [NSDate date];
    firstDigit = YES;
    //BOOL check = [[self window] makeFirstResponder:[[self window] contentView]];
    //NSLog(@"check = %d",check);
}

- (void) newValue {
    
    NSNotification * note = [NSNotification notificationWithName: EtaRingsUpdateNotification object: self];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];
}

#pragma mark - the accessor
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
/*- (void) keyUp:(NSEvent *) theEvent {
    NSLog(@"Key up...");
} */

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
 /*       time[itype] = 0.;
        [stepper setDoubleValue:0.];
        [timeSetter setLabel:@"00" forSegment:2*itype];
        [_countView setNeedsDisplay:YES]; */
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
    }
    if(idigit == 2) {
        [stepper[tag] setMaxValue:9]; [stepper[tag] setMinValue:0];
        [stepper[tag] setDoubleValue:digt[tag]];
    }
    if(idigit == 3) {
        [stepper[tag] setMaxValue:9]; [stepper[tag] setMinValue:0];
        [stepper[tag] setDoubleValue:digu[tag]];
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

    if(idigit == 0) { digh[tag] = v;}
    if(idigit == 2) { digt[tag] = v;}
    if(idigit == 3) { digu[tag] = v;}
    
    [self newValue];

}


@end
