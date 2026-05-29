//
//  HXGLongDiagramControl.m
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGLongDiagramControl.h"

NSString * versionDate = @"20240712"; // @"202301122";

@interface HXGLongDiagramControl ()

@end

@implementation HXGLongDiagramControl

+ (id) sharedDiagramControl {
    
    static dispatch_once_t pred;
    static HXGLongDiagramControl * theDiagramControl = nil;
    
    dispatch_once(&pred, ^{ theDiagramControl = [[self alloc] init]; });
    return theDiagramControl;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGLongDiagramControl"];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newCrossHairs:)
               name:HXGNewCrossHairsNotification
             object:nil];

    NSRect wRect;                                // Here we define the window
    double height = [[NSScreen mainScreen] frame].size.height-22.;
    double width = [[NSScreen mainScreen] frame].size.width-250.;
    wRect.origin = NSMakePoint(0.,height);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSZeroPoint;
    double vwidth = 2615.*(height-22.)/2384.;
    double vheight = height-22.;
    vRect.size = NSMakeSize(vwidth,vheight);
    id test = [_longView initWithFrame:vRect]; // some redundancy to sort out here
    if(test != _longView) {
        NSLog(@"Marbles lost");
    }
 
    scale = 4.348; //4.3807;
    zLow = 2070.5; // 2100.45;
    rLow = -542.5; //-545.75;
    double w = (vRect.size.width + vRect.origin.x)*scale;
    double h = (vRect.size.height + vRect.origin.y)*scale;

    crossHairs.x = (double) (int)(w*0.5+zLow);
    crossHairs.y = (double) (int)(h*0.5+rLow);
    
    
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
 
    double v = 1.4;
    for (int i=0; i<3; i++) {
        digh[i] = (double) (int)   (v + 0.005);
        digt[i] = (double) (int)  ((v - digh[i])*10. + 0.1);
        digu[i] = (double) (int) (((v - digh[i])*10. - digt[i])*10.  + 0.005);
        //NSLog(@"v = %.2f: %.0f %.0f %.0f",v,digh[i],digt[i],digu[i]);
        v = v + 0.8;
    }

    NSRect brect;
    //------------ The semented control
    double xorig = self.window.frame.size.width - 180.;
    double yorig = self.window.frame.size.height - 220.;
    for (int i=0;i<3;i++) {
        brect = NSMakeRect(xorig-22.,yorig+3.,20.,20.);
        activeB[i] = [[NSButton alloc] initWithFrame:brect];
        [activeB[i] setButtonType:NSButtonTypeSwitch];
        [activeB[i] setAction:NSSelectorFromString(@"activateLine:")];
        [activeB[i] setState:NO];
        [activeB[i] setTag:i];
        [[[self window] contentView] addSubview:activeB[i]];

        brect = NSMakeRect(xorig,yorig,54.,22.);
        etaSegs[i] = [[NSSegmentedControl alloc] initWithFrame:brect];
        [etaSegs[i] setSegmentCount:4];
        NSString * str = [NSString stringWithFormat:@"%.0f",digh[i]];
        [etaSegs[i] setLabel:str forSegment:0];
        [etaSegs[i] setLabel:@"." forSegment:1];
        str = [NSString stringWithFormat:@"%.0f",digt[i]];
        [etaSegs[i] setLabel:str forSegment:2];
        str = [NSString stringWithFormat:@"%.0f",digu[i]];
        [etaSegs[i] setLabel:str forSegment:3];
        [etaSegs[i] setWidth:12 forSegment:0];
        [etaSegs[i] setWidth:8 forSegment:1];
        [etaSegs[i] setWidth:12 forSegment:2];
        [etaSegs[i] setWidth:12 forSegment:3];
        etaSegs[i].segmentStyle = NSSegmentStyleTexturedSquare; //NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare;NSSegmentStyleRoundRect
        for (int j=0;j<4;j++) {[etaSegs[i] setSelected:NO forSegment:j];}
        [etaSegs[i] setAction:NSSelectorFromString(@"changeSegment:")];
        [[etaSegs[i] cell] setFont:[NSFont systemFontOfSize:12]];
        [[etaSegs[i] cell] setControlSize:NSControlSizeSmall];
        [[etaSegs[i] cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
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
        [stepper[i] setValueWraps:YES];
        [stepper[i] setIncrement:1];
        [stepper[i] setAutorepeat:NO];
        [[[self window] contentView] addSubview:stepper[i]];
        [stepper[i] setEnabled:NO];
        [stepper[i] setTag:i];

        yorig -= 30.;
    }

    _longView.zLow = zLow;
    _longView.rLow = rLow;
    _longView.scale = scale;
    [_longView loadDiagram];
    
    NSString * title = [@"EDMS " stringByAppendingString:versionDate];
    title = [title stringByAppendingString:@"_HGCAL_PARAMETER_DRAWING"];
    [[self window] setTitle:title];
    _longView.fileName = [@"LongView" stringByAppendingString:versionDate];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [[self window] makeFirstResponder:_longView];
    
    _longView.crossHairs = crossHairs;
    _longView.showcoords = NO;
    NSString * posStr = @"";
    [_positionLabel setStringValue:posStr];
    [_crossHairsButton setToolTip:@"⌘?"];
    
    [_calibrationButton setEnabled:NO];


    [_longView setNeedsDisplay:YES];
    
}

- (void) newCrossHairs:(NSNotification *) note {
    
    [_crossHairsButton setState:YES];
    crossHairs = _longView.crossHairs;
    NSString * posStr;
    if(_longView.calibrationMode) posStr = [NSString stringWithFormat:@"(x, y) = (%.2f, %.2f)",crossHairs.x,crossHairs.y];
    else posStr = [NSString stringWithFormat:@"(z, r) = (%.1f, %.1f)",crossHairs.x,crossHairs.y];
    [_positionLabel setStringValue:posStr];
}

- (void) newValue {
    
    _longView.nlines = 0;
    
    for (int i=0; i<3; i++) {
        if([activeB[i] state]) {
            double eta = digh[i] + digt[i]*0.1 + digu[i]*0.01;
            [_longView addEtaLine:eta];
        }
    }

    [_longView setNeedsDisplay:YES];
}

- (IBAction) calibrationMode:(id)sender {
    
    _longView.calibrationMode = [_calibrationButton state];
    [_longView setViewBounds];
    crossHairs = _longView.crossHairs;

    NSString * posStr;
    if(_longView.calibrationMode) posStr = [NSString stringWithFormat:@"(x, y) = (%.2f, %.2f)",crossHairs.x,crossHairs.y];
    else posStr = [NSString stringWithFormat:@"(z, r) = (%.1f, %.1f)",crossHairs.x,crossHairs.y];
    [_positionLabel setStringValue:posStr];
}

- (IBAction) showCrossHairs:(id)sender {
    
    _longView.showcoords = [_crossHairsButton state];
    [_calibrationButton setEnabled:_longView.showcoords];
    if(_longView.showcoords) _longView.calibrationMode = [_calibrationButton state];
    else _longView.calibrationMode = NO;
    [_longView setViewBounds];
    crossHairs = _longView.crossHairs;
    NSString * posStr;
    if(_longView.showcoords) {
        if(_longView.calibrationMode) posStr = [NSString stringWithFormat:@"(x, y) = (%.2f, %.2f)",crossHairs.x,crossHairs.y];
        else posStr = [NSString stringWithFormat:@"(z, r) = (%.1f, %.1f)",crossHairs.x,crossHairs.y];
    } else posStr = @"";
    [_positionLabel setStringValue:posStr];

    [_longView setNeedsDisplay:YES];

}

- (IBAction) adjustPosition:(id)sender {
    
    if(!_longView.showcoords) return;
    
    double k = 0.2;
    double kk = 0.1;
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.1) repcount+=1;
    else if(tnow - tstart < 0.5) repcount /= 2;
    else repcount = 0.;
    //if(repcount > 20) kk=4.;
    //else
    if(repcount > 15) kk=2.;
    else if(repcount > 10) kk=0.5;
    else if(repcount > 5) kk=0.2;
    k += repcount * kk;
    if(_longView.calibrationMode) k = k*0.2;

    tstart = tnow;

    double tag = (double) [sender tag];
    crossHairs = _longView.crossHairs;
    if(tag < 1.9) {
        crossHairs.y += k*(2.*tag - 1.);
    } else {
        crossHairs.x += k*(2.*(tag-2.) - 1.);
    }

    NSString * posStr;
    if(_longView.calibrationMode) posStr = [NSString stringWithFormat:@"(x, y) = (%.2f, %.2f)",crossHairs.x,crossHairs.y];
    else posStr = [NSString stringWithFormat:@"(z, r) = (%.1f, %.1f)",crossHairs.x,crossHairs.y];
    [_positionLabel setStringValue:posStr];
    _longView.crossHairs = crossHairs;
    [_longView setNeedsDisplay:YES];
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
    if(idigit == 2) {
        if((int)digt[tag] == 9 && (int) v == 0 && digh[tag] < 3.) {
            digh[tag] += 1.;
            NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
            [etaSegs[tag] setLabel:str forSegment:0];
        } else if((int)digt[tag] == 0 && (int) v == 9 && digh[tag] > 1.) {
            digh[tag] -= 1.;
            NSString * str = [NSString stringWithFormat:@"%.0f",digh[tag]];
            [etaSegs[tag] setLabel:str forSegment:0];
        }
        digt[tag] = v;
    }
    if(idigit == 3) {
        if((int)digu[tag] == 9 && (int) v == 0 && digt[tag] < 9.) {
            digt[tag] += 1.;
            NSString * str = [NSString stringWithFormat:@"%.0f",digt[tag]];
            [etaSegs[tag] setLabel:str forSegment:2];
        } else if((int)digu[tag] == 0 && (int) v == 9 && digt[tag] > 0.) {
            digt[tag] -= 1.;
            NSString * str = [NSString stringWithFormat:@"%.0f",digt[tag]];
            [etaSegs[tag] setLabel:str forSegment:2];
        }
        digu[tag] = v;
    }
    
    [self newValue];

}

@end
