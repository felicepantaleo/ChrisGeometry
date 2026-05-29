//
//  HXGLongDiagramControl.m
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGLongDiagramControl.h"

NSString * versionDate = @"20240712";
int const maxlines = 5;

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
    
    NSString * title = [@"EDMS " stringByAppendingString:versionDate];
    title = [title stringByAppendingString:@"_HGCAL_PARAMETER_DRAWING"];
    [[self window] setTitle:title];
    _longView.fileName = [@"LongView" stringByAppendingString:versionDate];
    
    //_longView.fileName = @"LongitudinalView"; // for test...
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newCrossHairs:)
               name:HXGNewCrossHairsNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newZoneColorOption:)
               name:HXGNewColourNotification
             object:nil];

    
    NSRect wRect;                                // Here we define the window
    double height = [[NSScreen mainScreen] frame].size.height-30.;
    double width = [[NSScreen mainScreen] frame].size.width-330.;

    wRect.size = NSMakeSize(width,height);
    wRect.origin = NSZeroPoint;

    [[self window] setFrame:wRect display:YES];
    
    // Here we define the view
    outerRect = NSMakeRect(0.,0.,height-30.,height-30.);
    vRect = outerRect;
    vRect.size.width -= 15.;
    vRect.size.height -= 15.;
    vRect.origin.y += 15.;
    vRect.origin.x += 0.;

    id test = [_longView initWithFrame:vRect]; // some redundancy to sort out here
    if(test != _longView) {
        NSLog(@"Marbles lost");
    }
    
    /* -------------------------------------
       Calibration points for:
       a) (z,r) = (5262, 2713)
       b) (z,r) = (2967.7,265)
       ------------------------------------- */
    NSPoint pntazr = NSMakePoint(5262.,2713.);
    NSPoint pntbzr = NSMakePoint(2967.7,265.);
    NSPoint pntaxy = NSMakePoint(634.43,711.01);
    NSPoint pntbxy = NSMakePoint(186.34,233.05);
    
    double sx = (pntazr.x - pntbzr.x)/(pntaxy.x - pntbxy.x);
    double sy = (pntazr.y - pntbzr.y)/(pntaxy.y - pntbxy.y);
    scale = 0.5*(sx+sy);
    
    // ---- vRect origin offsets need to be subtracted when calculating zLow and rLow
    zLow = pntbzr.x - scale*pntbxy.x;
    rLow = pntbzr.y - scale*(pntbxy.y-vRect.origin.y);

    double w = (vRect.size.width + vRect.origin.x)*scale;
    double h = (vRect.size.height + vRect.origin.y)*scale;
    
    crossHairs.x = (double) (int)(w*0.5+zLow);
    crossHairs.y = (double) (int)(h*0.5+rLow);
    
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
    if(activeB[0]) return; // If programatic button construction has been done then don't repeat window setup


    [_testButton setHidden:YES];
#ifdef DEBUG
    [_testButton setHidden:NO];
#endif

    scrolling = NO;
    [_fixedButton setState:!scrolling];
    [_scrollButton setState:scrolling];
    [_magSlide setHidden:YES];
    [_magLabel setHidden:YES];
    _longView.scrolling = scrolling;

    double v = 1.4;
    for (int i=0; i<maxlines; i++) {
        digh[i] = (double) (int)   (v + 0.005);
        digt[i] = (double) (int)  ((v - digh[i])*10. + 0.1);
        digu[i] = (double) (int) (((v - digh[i])*10. - digt[i])*10.  + 0.005);
        //NSLog(@"v = %.2f: %.0f %.0f %.0f",v,digh[i],digt[i],digu[i]);
        v = v + 0.4;
    }
    
    [_magSlide setControlSize:NSControlSizeMini];
        
    NSRect brect;
    //------------ The semented control
    double xorig = self.window.frame.size.width - 220.;
    double yorig = self.window.frame.size.height - 220.;
    for (int i=0;i<maxlines;i++) {
        brect = NSMakeRect(xorig-22.,yorig,20.,20.);
        activeB[i] = [[NSButton alloc] initWithFrame:brect];
        [activeB[i] setButtonType:NSButtonTypeSwitch];
        [activeB[i] setAction:NSSelectorFromString(@"activateLine:")];
        [activeB[i] setState:NO];
        [activeB[i] setTag:i];
        [[[self window] contentView] addSubview:activeB[i]];
        
        if(i<(maxlines-1)) {
            brect = NSMakeRect(xorig+110.,yorig-12.,20.,20.);
            activeR[i] = [[NSButton alloc] initWithFrame:brect];
            [activeR[i] setButtonType:NSButtonTypeSwitch];
            [activeR[i] setAction:NSSelectorFromString(@"activateZone:")];
            [activeR[i] setState:NO];
            [activeR[i] setTag:i];
            [[[self window] contentView] addSubview:activeR[i]];
            brect = NSMakeRect(xorig+130.,yorig-12.,80.,20.);
            setColorButton[i] = [[NSButton alloc] initWithFrame:brect];
            [setColorButton[i] setButtonType:NSButtonTypeMomentaryPushIn];
            [setColorButton[i] setAction:NSSelectorFromString(@"setZoneColor:")];
            [setColorButton[i] setTitle:@"set color"];
            [setColorButton[i] setTag:i];
            [[[self window] contentView] addSubview:setColorButton[i]];

        }
        
        brect = NSMakeRect(xorig,yorig,74.,22.);
        etaSegs[i] = [[NSSegmentedControl alloc] initWithFrame:brect];
        [etaSegs[i] setSegmentCount:4];
        NSString * str = [NSString stringWithFormat:@"%.0f",digh[i]];
        [etaSegs[i] setLabel:str forSegment:0];
        [etaSegs[i] setLabel:@"." forSegment:1];
        str = [NSString stringWithFormat:@"%.0f",digt[i]];
        [etaSegs[i] setLabel:str forSegment:2];
        str = [NSString stringWithFormat:@"%.0f",digu[i]];
        [etaSegs[i] setLabel:str forSegment:3];
        [etaSegs[i] setWidth:20 forSegment:0];
        [etaSegs[i] setWidth:14 forSegment:1];
        [etaSegs[i] setWidth:20 forSegment:2];
        [etaSegs[i] setWidth:20 forSegment:3];
        //etaSegs[i].segmentStyle = NSSegmentStyleTexturedSquare; //NSSegmentStyleRounded; //NSSegmentStyleTexturedSquare;NSSegmentStyleRoundRect
        for (int j=0;j<4;j++) {[etaSegs[i] setSelected:NO forSegment:j];}
        [etaSegs[i] setAction:NSSelectorFromString(@"changeSegment:")];
        [[etaSegs[i] cell] setFont:[NSFont systemFontOfSize:12]];
        [[etaSegs[i] cell] setControlSize:NSControlSizeSmall];
        [[etaSegs[i] cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
        [[[self window] contentView] addSubview:etaSegs[i]];
        [etaSegs[i] setEnabled:NO];
        [etaSegs[i] setTag:i];
        
        //------------- the stepper
        brect = NSMakeRect(xorig+76.,yorig-2.,16.,28.); // ------- define steppers
        stepper[i] = [[NSStepper alloc] initWithFrame:brect];
        [stepper[i] setAction:NSSelectorFromString(@"newStepperValue:")];
        [[stepper[i] cell] setControlSize:NSControlSizeMini];
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
/*
 colSelButton[i] = [[NSButton alloc] initWithFrame:brect];
 [colSelButton[i] setAction:@selector(changeSelectedColor:)];
 [colSelButton[i] setTitle:@""];
 [colSelButton[i] setButtonType:NSButtonTypeOnOff];
 [colSelButton[i] setBordered:NO];
 [colSelButton[i] highlight:YES];
 [[colSelButton[i] cell] setBackgroundColor:_cellview.cPalette[i]];

 */
    NSRect crect = NSMakeRect(xorig+180.,yorig,22.,22.);
    colBoxButton = [[NSButton alloc] initWithFrame:crect];
    [colBoxButton setAction:NSSelectorFromString(@"pickColor:")];
    [colBoxButton setTitle:@""];
    [colBoxButton setButtonType:NSButtonTypeOnOff];;
    [colBoxButton setBordered:NO];
    [[colBoxButton cell] setBackgroundColor:[_longView getColor:0]];
    [colBoxButton highlight:YES];
    [[[self window] contentView] addSubview:colBoxButton];
    
    brect = NSMakeRect(xorig+160.,yorig,16.,28.); // ------- define steppers
    colStepper = [[NSStepper alloc] initWithFrame:brect];
    [colStepper setAction:NSSelectorFromString(@"newZoneColor:")];
    [colStepper setMinValue:0];
    [colStepper setMaxValue:4];
    [colStepper setIntValue:0];
    [colStepper setValueWraps:YES];
    [colStepper setIncrement:1];
    [colStepper setAutorepeat:NO];
    [[[self window] contentView] addSubview:colStepper];
    [colStepper setEnabled:YES];
    
    
    
    _longView.zLow = zLow;
    _longView.rLow = rLow;
    _longView.scale = scale;
    [_longView loadDiagram];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [[self window] makeFirstResponder:_longView];
    
    _longView.crossHairs = crossHairs;
    _longView.showcoords = NO;
    NSString * posStr = @"";
    [_positionLabel setStringValue:posStr];
//    [_crossHairsButton setToolTip:@"⌘?"];
    
    //[_calibrationButton setEnabled:NO];
    
    [self setUpLongView];

    [_longView setNeedsDisplay:YES];
    
}


- (void) newValue {
    
    _longView.nlines = 0;
    
    double eta[5] = {0.};
    for (int i=0; i<maxlines; i++) {
        if([activeB[i] state]) {
            eta[i] = digh[i] + digt[i]*0.1 + digu[i]*0.01;
            [_longView addEtaLine:eta[i]];
        }
    }
    
    // ------------ Now set zones
    
    _longView.nzones = 0;
    
    
    for (int i=0; i<maxlines-1; i++) {
        int ibefore = 99;
        int iafter =  99;
        if([activeR[i] state]) {
            for (int j=i; j>-1; j--) {
                if([activeB[j] state]) {
                    ibefore = j;
                    break;
                }
            }
            for (int j=i+1; j<maxlines; j++) {
                if([activeB[j] state]) {
                    iafter = j;
                    break;
                }
            }
            [activeR[i] setState: NO];
            if(ibefore < maxlines && iafter < maxlines) {
                [_longView addEtaZoneFrom:eta[ibefore] To:eta[iafter] Button:i];
                [activeR[ibefore] setState: YES];
            }
        }
    }
    
    
    [_longView setNeedsDisplay:YES];
}
#pragma mark - IBActions

- (IBAction) debugDump:(id)sender {
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"debugLongView";
    [theTerminal makeWindowBig];
    //[theTerminal clearString];
    [theTerminal setDarkBackground:YES];
    [theTerminal displayString:@"\n====> frame <====\n"];
    [theTerminal displayString:[_longView stringForWindowToViewOf:_longView.frame.origin]];
    
    [theTerminal displayString:@"\n====> bounds <====\n"];
    [theTerminal displayString:[_longView stringForViewToWindowOf:_longView.bounds.origin]];
    
    [theTerminal displayString:@"\n====> crossHairs <====\n"];
    [theTerminal displayString:[_longView stringForWindowToViewOf:_longView.crossHairs]];
    
    // (x,y) = (190.37,241.38)
//    [theTerminal displayString:@"\n====> crossHairs <====\n"];
 //   [theTerminal displayString:[_longView stringForWindowToViewOf:_longView.crossHairs]];

    
    [theTerminal showWindow:nil];

}

- (IBAction) calibrationMode:(id)sender {
    
    _longView.calibrationMode = [_calibrationButton state];
    [_longView setViewBounds];
    [_positionLabel setStringValue:@""];
    _longView.showcoords = NO;

}
/*
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
*/
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

- (IBAction) activateZone:(id)sender {
    int tag = (int) [sender tag];
    
    if([activeR[tag] state]) {
        if(_longView.nzones > _longView.nlines-2) {
            [activeR[tag] setState:NO];
            return;
        }
    }
    
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

- (IBAction) setZoneColor:(id)sender {
    
    int izone = (int) [sender tag];
    [_longView setZone:izone colorTo:iCol];
    [_longView setNeedsDisplay:YES];
    
}
- (IBAction) newZoneColor:(id)sender {
    
    iCol = [sender intValue];
    [[colBoxButton cell] setBackgroundColor:[_longView getColor:iCol]];
    
}

- (IBAction) pickColor:(id)sender {
    
    //NSColorPanel * theColorPanel = [NSColorPanel sharedColorPanel];
    //NSLog(@"Pick color...");
    if(!theColorPicker) theColorPicker = [HXGColorPicker sharedColorPicker];
    theColorPicker.message  = @"Select a new colour for highlighted wafers";
    theColorPicker.workingColor = [_longView getColor:iCol];
    theColorPicker.ipoint = iCol+1;
    [theColorPicker showWindow:self];

}
- (IBAction) changeScrolling:(id)sender {
    
    if([sender tag] == 0) {
        scrolling = ![_fixedButton state];
        [_scrollButton setState: scrolling];
    } else {
        scrolling = [_scrollButton state];
        [_fixedButton setState: !scrolling];
    }
    
    [self setUpLongView];
    
}

- (IBAction) changeMagnification:(id)sender {
  
    if(!scrolling) return;
    NSPoint centre;
    double power = [_magSlide doubleValue];
    
    _longView.scrollmag = pow(1.2,power);
    [_magLabel setStringValue:[NSString stringWithFormat:@"Magnification %.4f",_longView.scrollmag]];

    /*
     scrollmag = pow(1.2,power);
     NSRect f = vRect;
     _hexview.scrollmag = scrollmag;
     NSRect vis = scrollView.documentVisibleRect;
     centre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
     f.size.width *= scrollmag;
     f.size.height *= scrollmag;
     [_hexview setHexFrame:f];

     */
    
    NSRect f = vRect;
    NSRect vis = scrollView.documentVisibleRect;
    centre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
    f.size.width *= _longView.scrollmag;
    f.size.height *= _longView.scrollmag;
    [_longView setLongViewFrame:f];

//    [_hexview drawHexGrid];
    [_longView centreLongViewAt:centre];
    
}

#pragma mark - 

- (void) setUpLongView {
    
    _longView.scrollmag = 1.;
    [_magLabel setStringValue:[NSString stringWithFormat:@"Magnification %.1f",_longView.scrollmag]];
    _longView.scrolling = scrolling;

    if(!scrolling) {
        [_longView setLongViewFrame:vRect];
        [[self.window contentView] replaceSubview:scrollView with:_longView];
        [_magSlide setHidden:YES];
        [_magLabel setHidden:YES];
    } else {
        [_magSlide setHidden:NO];
        [_magLabel setHidden:NO];
        [_magSlide setDoubleValue:0];
        [_magSlide setMaxValue:12.629254];
        scrollView = [[NSScrollView alloc] initWithFrame:outerRect];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setHasHorizontalScroller:YES];
        
        [[self.window contentView] addSubview:scrollView];
        
        _longView.scrollView = scrollView;

        vRect.size = scrollView.contentSize;
        [_longView setLongViewFrame:vRect];
        scrollView.documentView = _longView;
    }

    [_longView setNeedsDisplay:YES];
    
}

- (void) makePDF {
    
    NSString * filename = @"LongitudinalView.pdf";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString * pdfpath = [[export URL] path];
            [self.longView savePDF:pdfpath];
        }
    }];
}

#pragma mark - Notification
- (void) newZoneColorOption:(NSNotification *) note {
    
    
    int ncol = [[[note userInfo] objectForKey:@"colPoint"] intValue];
    if(ncol != iCol+1) {
        NSLog(@"Need this!!! ncol = %d, iCol+1 = %d",ncol,iCol+1);
    }


    NSColor * newColor = [[note userInfo] objectForKey:@"newColor"];
    
    [[colBoxButton cell] setBackgroundColor:newColor];

    [_longView setColorFor:iCol To:newColor];
    
}

- (void) newCrossHairs:(NSNotification *) note {
 
    [_calibrationButton setEnabled:_longView.showcoords];

//    [_crossHairsButton setState:YES];
    crossHairs = _longView.crossHairs;
    NSString * posStr;
    
    if(_longView.calibrationMode) posStr = [NSString stringWithFormat:@"(x, y) = (%.2f, %.2f)",crossHairs.x,crossHairs.y];
    else posStr = [NSString stringWithFormat:@"(z, r) = (%.1f, %.1f)",crossHairs.x,crossHairs.y];
    [_positionLabel setStringValue:posStr];
    
}


@end
