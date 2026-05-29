//
//  HXGMainControl.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGMainControl.h"

NSString * const HXGNewLayerNotification = @"HXGNewLayer";

NSString * const lastFile = @"/last.state";
const int datlen = 20;
const int bignumber = 100000;

@implementation HXGMainControl

- (id)init {
    self=[super initWithWindowNibName: @"HXGMainControl"];
    thePreferences = [HXGPreferenceControl sharedPreferences];
    
    path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/Hex"];
    path = [path stringByAppendingString:lastFile];
 
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newPreferences:)
               name:HXGNewPreferecesNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(newPosition:)
               name:HXGNewPositionNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newLayer:)
               name:HXGNewLayerNotification
             object:nil];

    removePb = YES;
    radiationLengths = YES;

    return self;
}

- (void) showWindow:(id)sender {
    [super showWindow:sender];
    
    [_hexview setColors:[thePreferences getColors]];

    if(![self restoreHex]) [self setDefaults];
    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    nLayers = 47;
    _hexview.lastLayer = nLayers - 1;
    
    [_hexview setWaferSize:thePreferences.ftof8];
    
    [self setLayerSeg:layer];
    
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    [_gridButton setState:showGrid];
    [_rotateButton setState:rotateRotated];
    [_v16Button setState:!useV17];
    [_v17Button setState:useV17];
    theMapFiles.useV17 = useV17;
    [theMapFiles loadFile];
    [_numberWafersButton setState:numberWafers];
    [_markZeroButton setState:markZero];
    [_chan1Button setState:markTypeOne];
    [_barButton setEnabled:markZero];
    [_chan1Button setEnabled:markZero];
    [_barButton setState:!markTypeOne];
    
    [_showCassetteButton setState:showCassettes];

    _hexview.useDetId = useDetId;
    
    [_stepper setIntegerValue:layer+1];

    //[_hexview makeInnerLayouts];
    
    [_layerSegs setSelected:YES forSegment:0];
    [_layerSegs setSelected:NO forSegment:1];
    _hexview.layerSegment = 0;
    
    _hexview.nLayer = layer;
    
    [_axisButton setState:NO];
    _hexview.showaxes = NO;
    _hexview.plusz = NO;
    [_pluszButton setState:_hexview.plusz];
    [_minuszButton setState:!_hexview.plusz];
    [_pluszButton setEnabled:_hexview.showaxes];
    [_minuszButton setEnabled:_hexview.showaxes];

    //[_axisButton setHidden:!_hexview.numberWafers];
    //[_pluszButton setHidden:!_hexview.numberWafers];
    //[_minuszButton setHidden:!_hexview.numberWafers];
    
    
    [_removeTestPointButton setHidden:YES];
    [_testPointBox setHidden:YES];

    [self showResult];

}


- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    height = [[NSScreen mainScreen] frame].size.height-22.0;   //
    width = height * 1.414;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSZeroPoint;
    wRect.size = NSMakeSize(width,height);
    [_mainwindow setFrameOrigin:NSZeroPoint];
    [_mainwindow setFrame:wRect display:YES];
        
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(4.0,4.0);
    vRect.size = NSMakeSize(height-30.0,height-30.0);
    [_hexview setHexFrame:vRect];
    
    [self loadZfor47];
    
}

- (void)windowWillClose:(NSNotification *)notification {
    
    //if(layer >= theConfiguration.nLayers) layer = 0;
    [self saveHex];
    
    //[theConfiguration writeLast];
    
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];
}

- (void) setShowCoords:(BOOL)show {
   
    [_mainwindow setAcceptsMouseMovedEvents:YES];
    [_mainwindow makeFirstResponder:_hexview];

    _hexview.showcoords = show;
    if(!show) [_hexview setNeedsDisplay:YES]; // Clear the current display
    else [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];
}

- (void) setShowFileLine:(BOOL)show {
    
    [_mainwindow setAcceptsMouseMovedEvents:show];
    [_mainwindow makeFirstResponder:_hexview];

    _hexview.showfileline = show;
    [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];
    if(!show) [_hexview setNeedsDisplay:YES]; // Clear the current display
}

- (void) prepareText {
    
    int tmap[47] = {
        0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,
        1,1,1,1,1,1,1,1,1,1, 1,
        2,2,2,2,2,2,2,2,2,2};
    NSString * layerText[3] = {@"(CEE cassette", @"(CEH fine sampling)", @"(CEH coarse sampling)"};
    
    summary = [NSString stringWithFormat:@"Layer %d ",layer+1];
    summary = [summary stringByAppendingString:layerText[tmap[layer]]];
    if(tmap[layer] == 0) {
        summary = [summary stringByAppendingFormat:@" %d)",layer/2 + 1];
    }
    summary = [summary stringByAppendingFormat:@"\nz = %.1f mm\n",zLayer[layer]];
    summary = [summary stringByAppendingFormat:@"Using layout files:\n-  %@\n",[_hexview getFileStrings]];

    summary = [summary stringByAppendingString:@"8\" wafers"];
    summary = [summary stringByAppendingString:[_hexview waferSummary]];
}

- (void) showResult {
    
    int flag = [theMapFiles getTessFlagForLayer:layer];
    BOOL mercedes = NO;
    if(flag == 2) {mercedes = NO; centreoncentre = NO;}
    else if(flag == 3) {mercedes = YES; centreoncentre = NO;}
    else centreoncentre = YES;
    _hexview.mercedes = mercedes;
    _hexview.rotate30 = (flag == 4);
    _hexview.nLayer = layer;
    zL = zLayer[layer];
    _hexview.zLayer = zL;

    if(centreoncentre) [_hexview makeGridOnCentre];
    else [_hexview makeGridOnVertex];

    [_hexview layoutFromFiles];

    [_mainwindow makeFirstResponder:_hexview];
    [self prepareText];
    if(showpoint) [self testTestPoint];
    else [_testText setStringValue:@""];
    [_summaryText setStringValue:summary];
    [_hexview drawHexGrid];
}
#pragma mark - IBActions

- (IBAction) changeLayer:(id)sender
{
    int oldlayer = layer;
    layer = (int)[_stepper integerValue] - 1;
    if(layer >= nLayers) {
        layer = nLayers - 1;
        [_stepper setIntegerValue:layer+1];
        [self setLayerSeg:layer];
    }
    
    if(layer != oldlayer) {
        NSNumber * newlayer = [NSNumber numberWithInteger:layer];
        NSDictionary * d = [NSDictionary dictionaryWithObject:newlayer forKey:@"newlayer"];
        
        NSNotification * note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
        NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
        [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                                   postingStyle: NSPostNow
                                                   coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                       forModes: modes];
    }
    
    
}

- (IBAction) changeLayerSegment:(id)sender {
    
    _hexview.layerSegment = _layerSegs.selectedSegment;
    
}


- (IBAction) changeDisplay:(id)sender {
    
    useDetId = [_detIdbutton state];
    showGrid = [_gridButton state];
    rotateRotated = [_rotateButton state];
    markZero = [_markZeroButton state];
    showCassettes = [_showCassetteButton state];
    [_barButton setEnabled:markZero];
    [_chan1Button setEnabled:markZero];

    
    if(sender == _rotateButton) [self deleteTestPoint];
    
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    
    [_hexview setNeedsDisplay:YES];
}

- (IBAction) changeFile:(id)sender {
    
    useV17 = [sender tag] == 1;
    [_v17Button setState:useV17];
    [_v16Button setState:!useV17];
    
    theMapFiles.useV17 = useV17;
    [theMapFiles loadFile];
    
    _hexview.useV17 = useV17;

    nLayers = 47; //--- no longer needed...
    _hexview.lastLayer = nLayers - 1; //--- no longer needed...
    
    NSNumber * newlayer = [NSNumber numberWithInteger:layer];
    NSDictionary * d = [NSDictionary dictionaryWithObject:newlayer forKey:@"newlayer"];
    
    NSNotification * note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];

}

- (IBAction) changeMarker:(id)sender {
    
    if([sender tag] == 0) {
        markTypeOne = [sender state];
        [_barButton setState:!markTypeOne];
    } else {
        markTypeOne = ![sender state];
        [_chan1Button setState:markTypeOne];
    }
    _hexview.markTypeOne = markTypeOne;
    [_hexview setNeedsDisplay:YES];
}

- (IBAction) axisDisplay:(id)sender {
    
    if([sender tag] == 0) {
        _hexview.showaxes = [_axisButton state];
        [_pluszButton setEnabled:_hexview.showaxes];
        [_minuszButton setEnabled:_hexview.showaxes];
        [_hexview setNeedsDisplay:YES];
    } else {
        _hexview.plusz = ([sender tag] == 1);
        [_pluszButton setState:_hexview.plusz];
        [_minuszButton setState:!_hexview.plusz];
        if(_hexview.showaxes) [_hexview setNeedsDisplay:YES];
    }
    
}

- (IBAction) changeMagnification:(id)sender {
    
    if([sender tag] == 0) _hexview.magnify = MIN(_hexview.magnify*1.12,1.2544);
    else _hexview.magnify = MAX(_hexview.magnify/1.12,0.7117802478);
    
    [_hexview drawHexGrid];

}

- (IBAction) changeWaferNumbering:(id)sender{
    
    numberWafers = [sender state];
    int flags = [self encodeParts];
    [_hexview setParts:flags];

    _hexview.numberWafers = numberWafers; // Not needed when flags system set up
    
    if(numberWafers) _hexview.plusz = NO;
/*
    [_pluszButton setHidden:numberWafers];
    [_minuszButton setHidden:numberWafers];
    if(!numberWafers) {
        [_pluszButton setState:_hexview.plusz];
        [_minuszButton setState:!_hexview.plusz];
    }
*/
    [_hexview setNeedsDisplay:YES];
}

- (IBAction) zoomOnTestPoint:(id)sender {
    
    [_hexview zoomOnTestPoint:[sender state]];
}


#pragma mark - Gaps study games

- (void) gapsStudy {
 
#ifdef DEBUG
    short hit[400][7000] = {};
    int currentLayer = layer;
    int netastep = 400;
    double eta1 = 1.695;
    double eta2 = 1.815;
    double step = (eta2-eta1)/(double) netastep;
    int nphistep = (int) (2.*M_PI/step)/3.; // steps for 120 degrees
    NSLog(@"step = %.5f; nphistep = %d",step,nphistep);
    
    
    for(int lay=33; lay<37; lay++) {
        layer = lay;
        [self showResult];
        double eta = eta1;
        for(int ieta=0;ieta<netastep;ieta++) {
            double theta = 2.*atan2(exp(-eta),1.);
            double r = tan(theta)*zL;
            double phi = 0.;
            for(int iphi=0;iphi<nphistep;iphi++) {
                NSPoint point = NSMakePoint(r*cos(phi),r*sin(phi));
                int istate = [_hexview stateAtPoint:point];
                if(istate > 1) hit[ieta][iphi] += 10;
                if(istate > 0) hit[ieta][iphi] += 1;
                phi += step;
            }
            eta += step;
        }

    }
    
    layer = currentLayer;
    [self showResult];
    
    double fracZero4[400];
    double fracZero3[400];
    double fracZero2[400];
    double fracZero1[400];
    double fracZero4noT[400];
    double fracZero3noT[400];
    double fracZero2noT[400];
    double fracZero1noT[400];
   for(int ieta=0;ieta<netastep;ieta++) {
       int count4 = 0;
       int count3 = 0;
       int count2 = 0;
       int count1 = 0;
       int count4noT = 0;
       int count3noT = 0;
       int count2noT = 0;
       int count1noT = 0;
       for(int iphi=0;iphi<nphistep;iphi++) {
           if(hit[ieta][iphi]%10 == 4) count4++;
           if(hit[ieta][iphi]%10 == 3) count3++;
           if(hit[ieta][iphi]%10 == 2) count2++;
           if(hit[ieta][iphi]%10 == 1) count1++;
           if(hit[ieta][iphi]/10 == 4) count4noT++;
           if(hit[ieta][iphi]/10 == 3) count3noT++;
           if(hit[ieta][iphi]/10 == 2) count2noT++;
           if(hit[ieta][iphi]/10 == 1) count1noT++;
       }
       if(count4+count3+count2+count1 != nphistep) {
           NSLog(@"Sum = %d, nphistep = %d",count4+count3+count2+count1,nphistep);
       }
       if(count4noT+count3noT+count2noT+count1noT != nphistep) {
           NSLog(@"noT Sum = %d, nphistep = %d",count4noT+count3noT+count2noT+count1noT,nphistep);
       }
       fracZero4[ieta] = 100.*(double) count4/(double)nphistep;
       fracZero3[ieta] = 100.*(double) count3/(double)nphistep;
       fracZero2[ieta] = 100.*(double) count2/(double)nphistep;
       fracZero1[ieta] = 100.*(double) count1/(double)nphistep;
       fracZero4noT[ieta] = 100.*(double) count4noT/(double)nphistep;
       fracZero3noT[ieta] = 100.*(double) count3noT/(double)nphistep;
       fracZero2noT[ieta] = 100.*(double) count2noT/(double)nphistep;
       fracZero1noT[ieta] = 100.*(double) count1noT/(double)nphistep;
    }
    
    // --- show histos
    
    hist1 = [HistViewControl histViewControl];
    NSColor * col = [[NSColor peachOrange] colorWithAlphaComponent:0.3];

    NSPoint orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 600.,[[NSScreen mainScreen] frame].size.height-100.);
    NSString * title = @"Layers 34-37: 1 hit";
    [hist1 showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(500.,400.)];
    
    NSString * ytit = @"Fraction of φ (%)";
    [hist1 axisTitles:@"η" And:ytit];
    [hist1 fixYmax:100.];
    [hist1 addHistogram:fracZero1noT Bins:netastep Xlow:eta1 Dx:step Title:title];
    [hist1 histFillColor:[NSColor orchidPink]];
    [hist1 addHistogram:fracZero1 withColor:col];
    //[hist1 addLabel:title at:NSMakePoint(eta1+0.3*netastep*step,85.)];
    [hist1 drawHistogram];
    
    // ---- hist 2
    
    hist2 = [HistViewControl histViewControl];
    
    orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 900.,[[NSScreen mainScreen] frame].size.height-100.);
    title = @"Layers 34-37: 2 hits";
    [hist2 showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(500.,400.)];
    
    ytit = @"Fraction of φ (%)";
    [hist2 axisTitles:@"η" And:ytit];
    [hist2 fixYmax:100.];
    [hist2 addHistogram:fracZero2noT Bins:netastep Xlow:eta1 Dx:step Title:title];
    [hist2 histFillColor:[NSColor orchidPink]];
    [hist2 addHistogram:fracZero2 withColor:col];
    //[hist2 addLabel:title at:NSMakePoint(eta1+0.3*netastep*step,85.)];
    [hist2 drawHistogram];

    // ---- hist 3
    
    hist3 = [HistViewControl histViewControl];
    
    orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 1200.,[[NSScreen mainScreen] frame].size.height-100.);
    title = @"Layers 34-37: 3 hits";
    [hist3 showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(500.,400.)];
    
    ytit = @"Fraction of φ (%)";
    [hist3 axisTitles:@"η" And:ytit];
    [hist3 fixYmax:100.];
    [hist3 addHistogram:fracZero3noT Bins:netastep Xlow:eta1 Dx:step Title:title];
    [hist3 histFillColor:[NSColor orchidPink]];
    [hist3 addHistogram:fracZero3 withColor:col];
    //[hist3 addLabel:title at:NSMakePoint(eta1+0.3*netastep*step,85.)];
    [hist3 drawHistogram];

    //--- hist 4
    hist4 = [HistViewControl histViewControl];
    
    orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 1500.,[[NSScreen mainScreen] frame].size.height-100.);
    title = @"Layers 34-37: 4 hits";
    [hist4 showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(500.,400.)];
    
    ytit = @"Fraction of φ (%)";
    [hist4 axisTitles:@"η" And:ytit];
    [hist4 fixYmax:100.];
    [hist4 addHistogram:fracZero4noT Bins:netastep Xlow:eta1 Dx:step Title:title];
    [hist4 histFillColor:[NSColor orchidPink]];
    [hist4 addHistogram:fracZero4 withColor:col];
    //[hist3 addLabel:title at:NSMakePoint(eta1+0.3*netastep*step,85.)];
    [hist4 drawHistogram];
#endif

}

#pragma mark - input/output of files

- (void) exportPDF {
    
    NSString * filename = [NSString stringWithFormat:@"Layer%02d.pdf",layer+1];
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Export PDF file"];
    [export beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self.hexview savePDF:pdfpath With:self->summary];
        }
    }];
}

- (void) exportMultiPDF
{
    int oldlayer = layer;
    double oldmag = _hexview.magnify;
    
    NSString * filename = @"Layer01.pdf";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Export PDF files"];
    [export setShowsTagField:NO];
    [export setPrompt:@"Save pdf set"];
    NSString * message =[NSString stringWithFormat:@"Pictures for layers starting at two-digit number (default 01) up to %d",nLayers];
    [export setMessage:message];
    [export beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            NSString * pathstem = [pdfpath substringToIndex:pdfpath.length-6];
            NSString * remains = [pdfpath substringWithRange:NSMakeRange(pdfpath.length-6, 6)];
            const char * ch = [remains UTF8String];
            int istart;
            sscanf(ch,"%02d",&istart);
            istart = MAX(istart,1);
            istart = MIN(istart,self->nLayers);
            //NSLog(@"remains = %@, istart = %d",remains,istart);
            
            //--- Loop over layers ----------------------------------------
            
            double mag[47] = {0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71,   // 1-8
                0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, // 9-30
                0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
                0.8, 0.8,
                1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,                     // 31-39
                1.2544, 1.2544,                                       // 40-41
                1.2544, 1.2544, 1.2544, 1.2544, 1.2544, 1.2544 // 41-47
            };
            
            for (int l=istart-1; l<self->nLayers; l++) {
                //--- Loop over the scan points
                self->layer = l;
                self->_hexview.magnify = mag[l];
                [self->_hexview drawHexGrid];
                self->_hexview.nLayer = self->layer;
                self->_hexview.zLayer = self->zL;
                [self->_hexview layoutFromFiles];
                [self showResult];
                pdfpath = [pathstem stringByAppendingFormat:@"%02d.pdf",self->layer+1];
                [self->_hexview savePDF:pdfpath With:self->summary];
                
            } //---------- end loop over layers
            // --- Restore previous state
            self->_hexview.magnify = oldmag;
            [self->_hexview drawHexGrid];
            
            self->layer = oldlayer;
            [self->_stepper setIntegerValue:self->layer+1];
            [self setLayerSeg:self->layer];
            self->zL = self->zLayer[self->layer];
            //[self calculateRadii];
            self->_hexview.nLayer = self->layer;
            self->_hexview.zLayer = self->zL;
            [self->_hexview layoutFromFiles];
            [self showResult];

        } else return;
    }];
}

#pragma mark - Notifications
- (void) newPreferences:(NSNotification *) note {
    
    [_hexview setColors:[thePreferences getColors]];
    [_hexview  setWaferSize:thePreferences.ftof8];
    
    // !! [self loadLayers];
    
    if(centreoncentre) [_hexview makeGridOnCentre];
    else [_hexview makeGridOnVertex];
    
    //[self calculateRadii];
    _hexview.nLayer = layer;
    _hexview.zLayer = zL;
    [_hexview layoutFromFiles];

    [self showResult];
}

- (void) newPosition:(NSNotification *) note {
    
    if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];
    etatest = [thePosition eta];
    phitest = [thePosition phi];
    showpoint = [thePosition showposition];

    [_hexview setPosition:showpoint eta:etatest phi:phitest];
    [self testTestPoint];
    
}
- (void) newLayer:(NSNotification *) note
{
    if([[note userInfo] objectForKey:@"newlayer"]) {
        NSNumber * newlayer = [[note userInfo] objectForKey:@"newlayer"];
        layer = (int) [newlayer integerValue];
        
        [_stepper setIntegerValue:layer+1];
        
        [self setLayerSeg:layer];
        [self showResult];
        [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];

    }
    if([[note userInfo] objectForKey:@"newsegment"]) {
        NSNumber * newsegment = [[note userInfo] objectForKey:@"newsegment"];
        [_layerSegs setSelected:YES forSegment:[newsegment integerValue]];
        [_layerSegs setSelected:NO forSegment:1 - [newsegment integerValue]];
        _hexview.layerSegment = [newsegment integerValue];
    }
}

- (void) testHisto {
    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    
    double lower[14] = {
        2492.4,2492.4,2492.4,2492.4,
        2292.1,2292.1,
        1595.1,1595.1,1595.1,1595.1,
        1565.5,1565.5,1565.5,1565.5
    };
    double upper[14] = {
        3099.6,3099.6,3099.6,3099.6,
        2777.9,2777.9,
        2080.8,2080.8,2080.8,2080.8,
        1929.8,1929.8,1929.8,1929.8
    };

    double dx = 1.;
    double xlo = 33.5;
    int nbins = 14;

    NSPoint orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 1000.,[[NSScreen mainScreen] frame].size.height-100.);
    NSString * title = @"Dead area";
    [theHist showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(350.,400.)];

    [theHist axisTitles:@"Layer" And:@"Area (cm2)"];
    
    [theHist histFillColor:[NSColor raspberryRed]];
    theHist.histView.binDividers = YES;

    [theHist addHistogram:upper Bins:nbins Xlow:xlo Dx:dx Title:@"Area without sensors"];
    [theHist addHistogram:lower withColor:[NSColor peachOrange]];
    [theHist drawHistogram];

}

- (BOOL) toggleWaferNumbering {
   
    _hexview.numberWafers = !_hexview.numberWafers;
    //[_axisButton setHidden:!_hexview.numberWafers];
    //[_pluszButton setHidden:!_hexview.numberWafers];
    //[_minuszButton setHidden:!_hexview.numberWafers];

    [_hexview setNeedsDisplay:YES];
    
    
    return _hexview.numberWafers;
}

- (void) testTestPoint {

    [_removeTestPointButton setHidden:!showpoint];
    [_testPointBox setHidden:!showpoint];
    [_zoomButton setHidden:!showpoint];

    if(!showpoint) {
        [_testText setStringValue:@""];
        return;
    }
    
    double phirad = phitest*M_PI/180.;
    double theta = 2.*atan2(exp(-etatest),1.);
    double radius = tan(theta)*zL;
    double xx = radius*cos(phirad);
    double yy = radius*sin(phirad);
    
    int istate = [_hexview stateAtPoint:NSMakePoint(xx,yy)];
    NSString * testStateString = [NSString stringWithFormat:@"Test point state: %d",istate];
    [_testText setStringValue:testStateString];
    [_testText setToolTip:@"0 = no sensor\n1 = three\n2 = other partial\n3 = whole\n4 = tile in complete ring\n5 = tile in incomplete ring"];

}


- (void) deleteTestPoint {
    
    _hexview.showtestspot = NO;
    showpoint = NO;
    [_removeTestPointButton setHidden:!showpoint];
    [_testPointBox setHidden:!showpoint];
    [_zoomButton setHidden:!showpoint];
    [_zoomButton setState:NO];
    [_hexview zoomOnTestPoint:NO];


    [_testText setStringValue:@""];
    [_hexview setNeedsDisplay:YES];
}

#pragma mark - Output summary files

- (void) writeWaferSummary
{
    NSString * filename = @"wafers.txt";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"File for wafer summary"];
    [export beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * fpath = [[export URL] path];
            [self performSelector: @selector(waferSummary:) withObject: fpath afterDelay:0];
        }
    }];
}

- (void) waferSummary:(NSString *) fpath
{
    int saveLayer = layer;
    
    int thicktot[3] = {0,0,0};
    [_hexview zeroPartialTotals];
    NSString * waferSummary = [NSString stringWithFormat:@"8\" wafers (flat-to-flat %.1fmm)\nUsing flat-files:\n-  ",thePreferences.ftof8];
    
    waferSummary = [waferSummary stringByAppendingString:[_hexview getFileStrings]];
    waferSummary = [waferSummary stringByAppendingString:@"\n\n"];

    
    //_hexview.nwhole = 0;         //---- Startuo zeroing for _hexview.countCheck
    //_hexview.npartial = 0;
    
    for(int l=0; l<nLayers; l++) {
        layer = l;
        int flag = [theMapFiles getTessFlagForLayer:layer];
        BOOL mercedes = NO;
        if(flag == 2) {mercedes = NO; centreoncentre = NO;}
        else if(flag == 3) {mercedes = YES; centreoncentre = NO;}
        else centreoncentre = YES;
        _hexview.mercedes = mercedes;
        _hexview.rotate30 = (flag == 4);
        _hexview.nLayer = layer;
        _hexview.zLayer = zL;
        [_hexview layoutFromFiles];
        //[_hexview countCheck];
        int * thick = [_hexview getThickCount];
        waferSummary = [waferSummary stringByAppendingFormat:
                        @"Layer %2d 300µm:%3d, 200µm:%3d, 120µm:%3d (%3d) %@\n",l+1,thick[2],thick[1],thick[0],thick[0]+thick[1]+thick[2],[_hexview partialWaferSummary]];
        thicktot[0] += thick[0]; thicktot[1] += thick[1]; thicktot[2] += thick[2];
    }
    
    waferSummary = [waferSummary stringByAppendingFormat:
                        @"\nTOTAL: 300µm:%3d, 200µm:%3d, 120µm:%3d\n",thicktot[2],thicktot[1],thicktot[0]];
    int sumwafers = thicktot[2] + thicktot[1] + thicktot[0];
    waferSummary = [waferSummary stringByAppendingFormat:
                    @"\nGRAND TOTAL: %d full wafers\n\nPartial wafer totals: ",sumwafers];
    
     
    int * pp = [_hexview getPartialTotals];
    NSString * tFlag = @"L";
    int pTot = 0;
    int hoffset = 1;

    for(int i=0; i<11; i++) {
        if(i > 5) {tFlag = @"H"; hoffset = -5;}
        if(pp[i]>0) {
            waferSummary = [waferSummary stringByAppendingFormat:@"%@%d:%d; ",tFlag,i+hoffset,pp[i]];
            pTot += pp[i];
        }
    }
    waferSummary = [waferSummary stringByAppendingFormat:
                    @"\nTOTAL: %d partial wafers\n",pTot];
    waferSummary = [waferSummary stringByAppendingFormat:
                    @"\nGRAND TOTAL: %d wafers (counting partials as one)\n",sumwafers+pTot];


    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
    
    NSString * vstamp = [NSString stringWithFormat:@"Hex version %.2f(%d), ",version,build];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-Y"];
    vstamp = [vstamp stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
    waferSummary = [waferSummary stringByAppendingString:vstamp];
    
    [waferSummary writeToFile:fpath atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    layer = saveLayer;    // --- now return everything to how it was
    //[self calculateRadii];
    _hexview.nLayer = layer;
    _hexview.zLayer = zL;
    [_hexview layoutFromFiles];
;
}
#pragma mark - private method

- (void) setLayerSeg:(int) l {

    int lvis = l+1;
    NSString * str = [NSString stringWithFormat:@"%1d",lvis/10];
    [_layerSegs setLabel:str forSegment:0];
    str = [NSString stringWithFormat:@"%1d",lvis%10];
    [_layerSegs setLabel:str forSegment:1];

}

#pragma mark - persistency

- (BOOL) saveHex {
    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    NSMutableData * data = [NSMutableData dataWithBytes:&version length:4];
    
    int flags = [self encodeParts];
    
    [data replaceBytesInRange:NSMakeRange(4,4) withBytes:&flags];
    [data replaceBytesInRange:NSMakeRange(8,8) withBytes:&etainr];
    [data replaceBytesInRange:NSMakeRange(16,4) withBytes:&layer];
    
    if(![data writeToFile:path atomically:NO])
    {
        NSLog(@"Write failure!");
        return NO;
    }
   
    return YES;
  
}

- (int) encodeParts {
    
    int flags = 0;
    
    if(numberWafers)  flags += 1;
    if(useDetId)      flags += 2;
    if(useV17)        flags += 4;
    if(rotateRotated) flags += 8;
    if(showGrid)      flags += 16;
    if(showCassettes) flags += 32;
    if(markZero)      flags += 64;
    if(markTypeOne)   flags += 128;
    
    return flags;
}

- (void) decodeParts:(int) flags {
    
    numberWafers  = (flags&1)  != 0;
    useDetId      = (flags&2)  != 0;
    useV17        = (flags&4)  != 0;
    rotateRotated = (flags&8)  != 0;
    showGrid      = (flags&16) != 0;
    showCassettes = (flags&32) != 0;
    markZero      = (flags&64) != 0;
    markTypeOne   = (flags&128)!= 0;
}

- (BOOL) restoreHex {

    NSData * data = [NSData dataWithContentsOfFile:path];
    if(!data)
    {
        NSLog(@"**** Read failure **** for path %@",path);
        return NO;
    }
    if(!(data.length == datlen))
    {
        NSLog(@"***** ERROR ***** Read %ld bytes in file %@",data.length,path);
        return NO;
    }

    float version;
    [data getBytes:&version range:NSMakeRange(0,4)];    // unload the stuff here

    if(version < 3.0) {
        NSLog(@"restoreHex: discarding old version state (%.2f)",version);
        return NO;
    }
    
    int flags;
    [data getBytes:&flags range:NSMakeRange(4,4)];
    [data getBytes:&etainr range:NSMakeRange(8,8)];
    [data getBytes:&layer range:NSMakeRange(16,4)];

    [self decodeParts:flags];

    return YES;
}

- (void) setDefaults {

    layer = 0;
    etainr = 3.0;
    
    numberWafers  = NO;
    useDetId      = YES;
    useV17        = YES;
    rotateRotated = YES;
    showGrid      = YES;
    showCassettes = YES;
    markZero      = YES;
    markTypeOne   = YES;

}

#pragma mark - layer z position

- (void) loadZfor47 {
    double z47[47] = {
      3221.,3232.,3252.,3262.,3283.,3293.,3313.,3324.,3344.,3354.,
      3374.,3385.,3405.,3415.,3435.,3446.,3466.,3476.,3500.,3510.,
      3534.,3544.,3568.,3578.,3601.,3612.,3678.,3741.,3804.,3867.,
      3930.,3993.,4056.,4119.,4182.,4245.,4308.,4390.,4472.,4555.,
      4637.,4719.,4801.,4884.,4966.,5048.,5130.
    };
    
    for(int i=0; i<47; i++) {
        zLayer[i] = z47[i];
    }
}

@end
