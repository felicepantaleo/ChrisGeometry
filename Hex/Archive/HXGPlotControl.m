//
//  HXGPlotControl.m
//  Hex
//
//  Created by Chris Seez on 16/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGPlotControl.h"

NSString * const HXGMakeRemovedHistoNotification = @"HXGMakeRemovedHisto";

@interface HXGPlotControl ()

@end

@implementation HXGPlotControl

+ (id) sharedPlotControl {
    
    static dispatch_once_t pred;
    static HXGPlotControl * thePlot = nil;
    
    dispatch_once(&pred, ^{ thePlot = [[self alloc] init]; });
    return thePlot;
    
}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGPlotControl"];
    
    plotwidth = 200.; // dummy default
    plotheight = 200.; // dummy default
    
    axiswidth = 24.;
    urmargin =4.;
    titlestring = @"";
    twenty = NO;
    showDepth = NO;

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self setSizeWindowAndViews];
    
    //------------------------------------------------------------------------------------------
    NSRect fRect = NSMakeRect(width-300.,48.,280.,60.);            // - Scale view
    _fview = [[HTDFadeView alloc] initWithFrame:fRect];
    [_controlbox addSubview:_fview];
    
    // ------------------- Change colours button
    NSRect srect = NSMakeRect(4.,4.,125.,25.);
    _colsButton = [[NSButton alloc] initWithFrame:srect];
    NSString * btit = @"change colours";
    [_colsButton setTitle:btit];
    [_colsButton setAction:@selector(changeColors:)];
    [_colsButton setBezelStyle:NSBezelStyleRounded];
    BOOL hide = YES;
#ifdef DEBUG
    hide = NO;
    NSLog(@"Showing change colours button: debug on");
#endif
    [_colsButton setHidden:hide]; //------------------ unhide for debugging....
    [_controlbox addSubview:_colsButton];

    // ------------------- histo removed button
    srect = NSMakeRect(width-740.,4.,180.,35.);
    _histoButton = [[NSButton alloc] initWithFrame:srect];
    [_histoButton setTitle:@"histogam removed material"];
    [_histoButton setAction:@selector(histoRemovedMaterial:)];
    [_histoButton setBezelStyle:NSBezelStyleRounded];
    showSlice = NO;
    [_histoButton setEnabled:_removed];
    [_controlbox addSubview:_histoButton];

    // ------------------- slice button
    srect = NSMakeRect(width-510.,24.,100.,22.);
    _sliceButton = [[NSButton alloc] initWithFrame:srect];
    [_sliceButton setTitle:@"set slice"];
    [_sliceButton setAlternateTitle:@"unset slice"];
    [_sliceButton setAction:@selector(toggleSlice:)];
    [_sliceButton setBezelStyle:NSBezelStyleRounded];
    [_sliceButton setButtonType:NSButtonTypeToggle];
    showSlice = NO;
    [_sliceButton setState:showSlice];
    NSString * escape = [NSString stringWithFormat:@"%C", 0x1b];
    [_sliceButton setKeyEquivalent:escape];
    [_controlbox addSubview:_sliceButton];
    
    // ------------------- rotate button
    srect = NSMakeRect(width-552.,0.,50.,47.);
    _rotateButton = [[NSButton alloc] initWithFrame:srect];
    rotStr = [[NSMutableAttributedString alloc] initWithString:@"⟳"];
    [rotStr addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:24]
                range:NSMakeRange(0,rotStr.length)];
    unrotStr = [[NSMutableAttributedString alloc] initWithString:@"⟲"];
    [unrotStr addAttribute:NSFontAttributeName
                   value:[NSFont systemFontOfSize:24]
                   range:NSMakeRange(0,unrotStr.length)];
    [_rotateButton setAttributedTitle:rotStr];
    [_rotateButton setAttributedAlternateTitle:unrotStr];
    [_rotateButton setAction:@selector(toggleRotated:)];
    [_rotateButton setButtonType:NSButtonTypeToggle];
    [_rotateButton setBezelStyle:NSBezelStyleRounded];
    [_rotateButton setEnabled:NO];
    [_rotateButton setState:rotated];
    [_controlbox addSubview:_rotateButton];

    // ------------------- make profile button
    srect = NSMakeRect(width-510.,2.,100.,22.);
    _profileButton = [[NSButton alloc] initWithFrame:srect];
    [_profileButton setTitle:@"make profile"];
    [_profileButton setAction:@selector(makeProfile:)];
    [_profileButton setBezelStyle:NSBezelStyleRounded];
    [_profileButton setEnabled:NO];
    [_controlbox addSubview:_profileButton];

    // ------------------- make pdf button
    srect = NSMakeRect(width-400.,78.,95.,35.);
    _pdfButton = [[NSButton alloc] initWithFrame:srect];
    btit = @"make PDF";
    [_pdfButton setTitle:btit];
    [_pdfButton setAction:@selector(makePDF:)];
    [_pdfButton setBezelStyle:NSBezelStyleRounded];
    [_controlbox addSubview:_pdfButton];

    // ------------------- make 20x20 cross
    srect = NSMakeRect(width-275.,14.,140.,20.);
    _twentyButton = [[NSButton alloc] initWithFrame:srect];
    btit = @"Indicate 20x20mm";
    [_twentyButton setTitle:btit];
    [_twentyButton setAction:@selector(set20x20:)];
    [_twentyButton setButtonType:NSButtonTypeSwitch];
    [_twentyButton setAlignment:1];
    [_twentyButton setImagePosition:NSImageRight];
    [_twentyButton setBezelStyle:NSBezelStyleRounded];
    [_controlbox addSubview:_twentyButton];
    [_twentyButton setState:twenty];
    
    // ------------------- data and depth buttons
    srect = NSMakeRect(width-410.,24.,130.,16.);
    _dataButton = [[NSButton alloc] initWithFrame:srect];
    btit = @"Show: max dead";
    [_dataButton setTitle:btit];
    [_dataButton setAction:@selector(setDataDepth:)];
    [_dataButton setButtonType:NSButtonTypeRadio];
    [_dataButton setAlignment:1];
    [_dataButton setImagePosition:NSImageRight];
    [_dataButton setTag:0];
    [_controlbox addSubview:_dataButton];
    [_dataButton setState:!showDepth];
    
    srect = NSMakeRect(width-410.,6.,130.,16.);
    _depthButton = [[NSButton alloc] initWithFrame:srect];
    btit = @"max depth start";
    [_depthButton setTitle:btit];
    [_depthButton setAction:@selector(setDataDepth:)];
    [_depthButton setButtonType:NSButtonTypeRadio];
    [_depthButton setAlignment:1];
    [_depthButton setImagePosition:NSImageRight];
    [_depthButton setTag:1];
    [_controlbox addSubview:_depthButton];
    [_depthButton setState:showDepth];


    srect = NSMakeRect(width-30.,15.,15.,22.); // - scale max stepper
    _stepper = [[NSStepper alloc] initWithFrame:srect];
    [_controlbox addSubview:_stepper];
    [_stepper setAction:@selector(newScale:)];
    [_stepper setMaxValue:9];
    [_stepper setMinValue:0];
    [_stepper setIncrement:1];
    double values[10] = {1.,2.,5.,10.,20.,25.,30.,40.,50.,60.};
    for (int i=0; i<10; i++) { scalevalues[i] = values[i];}
    ismax = 4;
    scalemax = scalevalues[ismax];
    [_stepper setIntegerValue:ismax];
    [_stepper setValueWraps:NO];
    
    
    srect = NSMakeRect(width-125.,18.,95.,16.);          // - max scale label
    _maxlabel = [[NSTextField alloc]initWithFrame:srect];
    [_controlbox addSubview:_maxlabel];
    [_maxlabel setBordered:NO];
    [_maxlabel setBezeled:NO];
    [_maxlabel setSelectable:NO];
    NSColor * col = [_controlbox fillColor];
    [_maxlabel setBackgroundColor:col];
    [_maxlabel setAlignment:1];
    [_maxlabel setStringValue:[NSString stringWithFormat:@"Scale max: %.0f",scalemax]];
    [_plotview setScaleMax:scalemax];
    
    srect = NSMakeRect(12.,50.,width-400.,65.);          // - title label
    _titlabel = [[NSTextField alloc]initWithFrame:srect];
    [_controlbox addSubview:_titlabel];
    [_titlabel setBordered:NO];
    [_titlabel setBezeled:NO];
    [_titlabel setSelectable:NO];
    [_titlabel setBackgroundColor:col];
    [_titlabel setAlignment:0];
    [_titlabel setFont:[NSFont systemFontOfSize:18]];
    [_titlabel setStringValue:titletext];
    
    /*srect = NSMakeRect(width-140.,height-21.,120.,20.);
    _testButton = [[NSButton alloc] initWithFrame:srect];
    [_testButton setTitle:@"make PDF"];
    [_testButton setAction:@selector(makePDF:)];
    [_testButton setBezelStyle:NSRoundedBezelStyle];
    //[[[[self window] contentView] superview] addSubview:_testButton];
    
    vRect.origin = NSMakePoint(0.,0.);
    vRect.size = NSMakeSize(120.,22.); */
    
    //titleBarView = titleBarVC.view;
    //[titleBarView setFrame:vRect];
    //[[self window] addTitlebarAccessoryViewController:titleBarVC];
    
    //[_titleBarVC.view setFrame:vRect];
    //[[self window] addTitlebarAccessoryViewController:_titleBarVC];
    //[vc.view setFrame:vRect];
    //vc.view = [[[self window] contentView] superview];
    //vc.layoutAttribute = NSLayoutAttributeRight;
    
    //[[self window] addTitlebarAccessoryViewController:vc];
    /*NSTitlebarAccessoryViewController* vc = [[NSTitlebarAccessoryViewController alloc] init];
    
    vc.view = self.window.contentView;
    vc.layoutAttribute = NSLayoutAttributeRight;
    [vc.view setFrame:vRect];
    [vc.view addSubview:_testButton];

    [self.window addTitlebarAccessoryViewController:vc];*/

}

- (void) setSizeWindowAndViews {
    
    height = plotheight + 150.;
    
    width = plotwidth+8.;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,[[NSScreen mainScreen] frame].size.height-height-22.);
    wRect.size = NSMakeSize(width,height);
    [_plotwindow setFrameOrigin:NSZeroPoint];
    [_plotwindow setFrame:wRect display:YES];
    
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(4.0,height - plotheight - 26.);
    vRect.size = NSMakeSize(plotwidth,plotheight);
    id test = [_plotview initWithFrame:vRect];
    if(test != _plotview) NSLog(@"Unexpected problem here!");
    [_plotview showSlice:NO];
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    [_sliceButton setState:showSlice];

    [_plotview setShortTitle:stitletext];
    
    [_controlbox setFrameOrigin:NSMakePoint(0.,0.)];
    [_controlbox setFrameSize:NSMakeSize(width,120.)];

}

- (void) keyDown:(NSEvent *) theEvent
{
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    unichar const cup    = 0xf700;
    unichar const cdown  = 0xf701;
    unichar const cleft  = 0xf702;
    unichar const cright = 0xf703;
    
    if(!showSlice) {
        NSBeep();
        return;
    }
    if(code == cup && rotated) _plotview.yslice+=1.;
    if(code == cdown && rotated) _plotview.yslice-=1.;
    if(code == cright) _plotview.xslice+=1.;
    if(code == cleft) _plotview.xslice-=1.;

    NSNotification * note = [NSNotification notificationWithName: HXGdragUpdateNotification object: self];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];
}


#pragma mark - IBActions

- (IBAction) histoRemovedMaterial:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGMakeRemovedHistoNotification object:self];

}
- (IBAction) newScale:(id)sender {
    ismax = (int) [_stepper integerValue];
    scalemax = scalevalues[ismax];
    [_maxlabel setStringValue:[NSString stringWithFormat:@"Scale max: %.0f",scalemax]];
    [_fview drawHorizontalScale:scalemax];
    [_plotview setScaleMax:scalemax];
    
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_sliceButton setState:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    
    [_plotview showSlice:showSlice];

}

- (IBAction) changeColors:(id)sender {
    [_plotview changeColors];
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_sliceButton setState:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    
    [_plotview showSlice:showSlice];
}

- (IBAction) makePDF:(id)sender{
   
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_sliceButton setState:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    
    [_plotview showSlice:showSlice];

    NSString * filename = @"DeadThickness.pdf";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self->_plotview savePDF:pdfpath withTitle:self->titletext];
        }
    }];
}

- (IBAction) set20x20:(id)sender {
    
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_sliceButton setState:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    
    [_plotview showSlice:showSlice];

    twenty = [_twentyButton state];
    [_plotview showTwenty:twenty];
    
}

- (IBAction) setDataDepth:(id)sender {
    
    showSlice = NO;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_sliceButton setState:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    
    [_plotview showSlice:showSlice];

   int tag = (int) [sender tag];
     if(tag == 0) {
        showDepth = ![_dataButton state];
        [_depthButton setState:showDepth];
    } else {
        showDepth = [_depthButton state];
        [_dataButton setState:!showDepth];
    }
    
    NSString * start;
    if(showDepth) start = @"Start depth of max p";
    else start = @"P";
    
    titletext = [start stringByAppendingString:titlestring];
    [_titlabel setStringValue:titletext];
    stitletext = [start stringByAppendingString:shorttitle];
    [_plotview setShortTitle:stitletext];


    scalemax = [_plotview setDataDepth:showDepth];
    double values[10] = {1.,2.,5.,10.,20.,25.,30.,40.,50.,60.};
    int i;
    for (i=0;i<10;i++) if(fabs(values[i]-scalemax)<0.1) break;
    [_stepper setIntegerValue:i];
    [_maxlabel setStringValue:[NSString stringWithFormat:@"Scale max: %.0f",scalemax]];
    [_fview drawHorizontalScale:scalemax];
    [_plotview setScaleMax:scalemax];

}

- (IBAction) toggleSlice:(id)sender {
    showSlice = !showSlice;
    rotated = NO;
    [_profileButton setEnabled:showSlice];
    [_rotateButton setEnabled:showSlice];
    [_rotateButton setState:rotated];
    [_sliceButton setState:showSlice];

    [_plotview showSlice:showSlice];

}
- (IBAction) toggleRotated:(id)sender{
    
    rotated = !rotated;
    [_plotview rotateSlice:rotated];
    
}

- (IBAction) makeProfile:(id)sender {
    if(!showSlice) return;
    
    [_plotview makeProfile];
    
    showSlice = NO;
    [_sliceButton setState:showSlice];
    [_profileButton setEnabled:NO];
    rotated = NO;
    [_rotateButton setState:rotated];
    [_rotateButton setEnabled:NO];

}


#pragma mark - setting methods

- (void) setPlotWidth: (int) w height: (int) h andScale: (double) s  {
    plotwidth = s*w + axiswidth + urmargin;
    plotheight = s*h + axiswidth + urmargin;
    scale = s;
    nbinx = w;
    nbiny = h;
    
    [self setSizeWindowAndViews];

}

- (void) setPlotDimensions: (double) bsz xlow: (double) x0 ylow: (double) y0 {
    binsize = bsz;
    xlow = x0;
    ylow = y0;
}

- (void) setTitle:(NSString *) tit andShort:(NSString *) stit {
    
    shorttitle = stit;
    titlestring = tit;
    showDepth = NO;
    [_depthButton setState:showDepth];
    [_dataButton setState:!showDepth];

    
    _plotview.showDepth=showDepth;
    NSString * start = @"P";
    titletext = [start stringByAppendingString:titlestring];
    stitletext = [start stringByAppendingString:shorttitle];
    [_titlabel setStringValue:titletext];
    [_plotview setShortTitle:stitletext];
}

- (void) loadArray:(double *) d and: (double *) e{
    
    [_histoButton setEnabled:_removed];

    [_plotview setPlotDimensions:binsize xlow:xlow ylow:ylow];
    [_plotview setPlotParams:nbinx and:nbiny scale:scale];
    scalemax = [_plotview loadPlotData:d and: e];
    double values[10] = {1.,2.,5.,10.,20.,25.,30.,40.,50.,60.};
    int i;
    for (i=0;i<10;i++) if(fabs(values[i]-scalemax)<0.1) break;
    [_stepper setIntegerValue:i];
    [_maxlabel setStringValue:[NSString stringWithFormat:@"Scale max: %.0f",scalemax]];
    [_fview drawHorizontalScale:scalemax];
    [_plotview setScaleMax:scalemax];

}



@end
