//
//  HXGMainControl.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGMainControl.h"

NSString * const hexHome = @"/Hex";
NSString * const HXGNewLayerNotification = @"HXGNewLayer";

NSString * const lastFile = @"/last.state";
const int datlen = 20;
const int bignumber = 100000;

const double structureMagLimit = 4.;
const double labelsMagLimit = 10.;

const int nphistep = 6000;


@implementation HXGMainControl

//#pragma GCC diagnostic ignored "-Wgnu-folding-constant"

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGMainControl"];
    thePreferences = [HXGPreferenceControl sharedPreferences];
    theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];
    
    pathroot = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:hexHome];
    siDirPath = [pathroot stringByAppendingString:@"/SiliconLayerDescription"];
    siNameFilePath = [pathroot stringByAppendingString:@"/siNameFile"];
    tileDirPath = [pathroot stringByAppendingString:@"/TileLayerDescription"];
    tileNameFilePath = [pathroot stringByAppendingString:@"/tileNameFile"];
    
    if(thePreferences.buildNewStructure) {
        [self simpleAlert:@"Building new layer description file structure"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm createDirectoryAtPath:siDirPath withIntermediateDirectories:NO attributes:nil error:nil]) {
            Verbosity(@"Created %@",siDirPath);
        } else [self diskProblems];
        NSString * file = @"geomnew_corrected_360_V2"; //@"v17-22042022-cmssw_flatfile";
        NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
        NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                            encoding:NSUTF8StringEncoding error:nil];
        file = [file stringByAppendingString:@".txt"];
        NSString * path = [siDirPath stringByAppendingFormat:@"/%@",file];
        [fileContents writeToFile:path
                       atomically:YES
                         encoding: NSASCIIStringEncoding
                            error:NULL];
        file = @"modmapv16.6_cmssw_flatfile";
        fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
        fileContents = [NSString stringWithContentsOfFile:fullPath
                                                 encoding:NSUTF8StringEncoding error:nil];
        file = [file stringByAppendingString:@".txt"];
        path = [siDirPath stringByAppendingFormat:@"/%@",file];
        [fileContents writeToFile:path
                       atomically:YES
                         encoding: NSASCIIStringEncoding
                            error:NULL];
        [file writeToFile:siNameFilePath
               atomically:YES
                 encoding: NSASCIIStringEncoding
                    error:NULL];
        
        if([fm createDirectoryAtPath:tileDirPath withIntermediateDirectories:NO attributes:nil error:nil]) {
            Verbosity(@"Created %@",tileDirPath);
        } else [self diskProblems];
        file = @"tilefile-Nov2023";
        fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
        fileContents = [NSString stringWithContentsOfFile:fullPath
                                                 encoding:NSUTF8StringEncoding error:nil];
        file = [file stringByAppendingString:@".txt"];
        path = [tileDirPath stringByAppendingFormat:@"/%@",file];
        [fileContents writeToFile:path
                       atomically:YES
                         encoding: NSASCIIStringEncoding
                            error:NULL];
        [file writeToFile:tileNameFilePath
               atomically:YES
                 encoding: NSASCIIStringEncoding
                    error:NULL];
        file = @"tiles_posts_pattern_spaces-scenario13k";
        fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"txt"];
        fileContents = [NSString stringWithContentsOfFile:fullPath
                                                 encoding:NSUTF8StringEncoding error:nil];
        file = [file stringByAppendingString:@".txt"];
        path = [tileDirPath stringByAppendingFormat:@"/%@",file];
        [fileContents writeToFile:path
                       atomically:YES
                         encoding: NSASCIIStringEncoding
                            error:NULL];
        
    }
    
    
    path = [pathroot stringByAppendingString:lastFile];
    
    theRings = [HXGEtaRingsControl sharedEtaRings];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newPreferences:)
               name:HXGNewPreferencesNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(newPosition:)
               name:HXGNewPositionNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newLayer:)
               name:HXGNewLayerNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newRings:)
               name:EtaRingsUpdateNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(coverageStudy:)
               name:HXGCoverageStudyNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(newCentre:)
               name:NSViewBoundsDidChangeNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(liveScroll:)
               name:NSScrollViewDidLiveScrollNotification
             object:nil];
/*
    [nc addObserver:self
           selector:@selector(liveScroll:)
               name:NSScrollViewDidEndLiveScrollNotification
             object:nil];
*/
    
    
    //removePb = YES;
    //radiationLengths = YES;
#ifdef DEBUG
    //    for(int i=0;i<7000;i++) {etafirst[i]=0.;}
    //    NSLog(@"path = %@",path);
#endif
    
    return self;
}



- (void) windowDidLoad {
    
    [super windowDidLoad];
    
    height = [[NSScreen mainScreen] frame].size.height-30.0;   // Bloody Tahoe (22->30 for menu bar)
    width = height * 1.414 - 30.;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSZeroPoint;
    wRect.size = NSMakeSize(width,height);
    [_mainwindow setFrameOrigin:NSZeroPoint];
    [_mainwindow setFrame:wRect display:YES];
    
    vRect = _mainwindow.contentView.frame;
    vRect.size.width = vRect.size.height;
    
    [self loadZfor47];
    
    [self setHexBackground:thePreferences.flags];
    
}

- (void) setHexBackground: (int) backflag {
    
    NSColor * backgroundColor = [NSColor windowBackgroundColor];
    if(backflag == 1) {
        NSColor * veryFadedBlue = [[NSColor fadedBlue] blendedColorWithFraction:0.5 ofColor:[NSColor whiteColor]];
        backgroundColor = [veryFadedBlue colorWithAlphaComponent:0.85];
    } else if(backflag > 1) {
        NSString * backfile;
        if(backflag == 2) backfile = @"EscherRippledSurfaceBackground.jpg";
        else if(backflag == 3) backfile = @"reptilesBackground.png";
        NSImage * backgImage = [NSImage imageNamed: backfile];
        if(backflag == 2) {
            double rat = backgImage.size.width/backgImage.size.height;
            NSSize newSize;
            if(rat > width/height) newSize = NSMakeSize(width/rat,height);
            else newSize = NSMakeSize(width,height*rat);
            backgImage = [self resizedImage:backgImage toPixelDimensions:newSize];
        }
        backgroundColor = [NSColor colorWithPatternImage: backgImage];
    }
    [_mainwindow setBackgroundColor:backgroundColor];
    
}


- (NSImage *) resizedImage:(NSImage *)sourceImage toPixelDimensions:(NSSize)newSize {
    // Source - https://stackoverflow.com/a/38442746
    // Posted by Marco, modified by community. See post 'Timeline' for change history
    // Retrieved 2026-02-21, License - CC BY-SA 3.0

    if (! sourceImage.isValid) return nil;

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes:NULL
                            pixelsWide:newSize.width
                            pixelsHigh:newSize.height
                         bitsPerSample:8
                       samplesPerPixel:4
                              hasAlpha:YES
                              isPlanar:NO
                        colorSpaceName:NSCalibratedRGBColorSpace
                           bytesPerRow:0
                          bitsPerPixel:0];
    rep.size = newSize;

    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];

    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage addRepresentation:rep];
    return newImage;
}


- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
    _hexview.casAlpha = thePreferences.casAlpha;
    [_hexview setColors:[thePreferences getColors]];
    
    if(![self restoreHex]) [self setDefaults];
    
    scrolling = NO;
    [_scrollButton setState:scrolling];
    [_scrollThresholdBox setHidden:!scrolling];
    
    _hexview.scrolling = scrolling;
    _hexview.mainWindow = _mainwindow;
    
    _hexview.nLayer = layer;
    //[_hexview setUpAxes];
    
    //[self setUpHexView];
    
    //---- Need menu tick setting here
    NSMenu * rootMenu = [NSApp mainMenu];
    NSMenuItem * geomItem = [rootMenu itemWithTitle:@"Geometry"];
    NSMenuItem * showItem = [geomItem.submenu itemWithTitle:@"Show coordinates"];
    [showItem setState:_hexview.showcoords];
    showItem = [geomItem.submenu itemWithTitle:@"Show layout file line"];
    [showItem setState:_hexview.showfileline];
    NSMenuItem * hexItem = [rootMenu itemWithTitle:@"Hex"];
    showItem = [hexItem.submenu itemWithTitle:@"Show thickness colour key in pdf"];
    
    
    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    //---- layer description files
    theMapFiles.siNameFilePath = siNameFilePath;
    theMapFiles.tileNameFilePath = tileNameFilePath;
    theMapFiles.siDirPath = siDirPath;
    theMapFiles.tileDirPath = tileDirPath;
    theMapFiles.version = version;
    
    [_otherFileNamesField setStringValue:@""];
    otherSiFileName = @"";
    otherTileFileName = @"";
    
    [self readOtherFileNames];
    
    nLayers = 47;
    _hexview.lastLayer = nLayers - 1;
    
    [_hexview setWaferSize:layoutHexagonWidth];
    _hexview.waferHighlightColor = thePreferences.waferHighLightColor;
    
    
    [self setLayerSeg:layer];
    
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    
    [_v17Button setState:version == 0];
    [_v19Button setState:version == 1];
    [_otherButton setState:version == 2];
        
    [_gridButton setState:showGrid];
    [_partialGridButton setState:showGridForPartials];
    [_rotateButton setState:rotateRotated];
    [_retractedButton setState:showRetracted];
    [_activeOnlyButton setState:showActiveWafer];
    [_showCellLabelsButton setState:_hexview.showCellLabels];
    
    if([_v17Button state]) {
        _hexview.showRetracted = NO;
        [_retractedButton setEnabled:NO];
    }
    
    if(![theMapFiles loadFiles]) {
        version = 1;
        [_otherButton setState:version == 2];
        [_v19Button setState:version == 1];
        [_v17Button setState:version == 0];
        theMapFiles.version = version;
        [theMapFiles loadFiles];
    }
    
    [_v17Button setToolTip:theMapFiles.version0tooltip];
    [_v19Button setToolTip:theMapFiles.version1tooltip];


    
    [_numberWafersButton setState:numberWafers];
    [_barButton setEnabled:YES];
    [_chan1Button setEnabled:YES];
    [_chan1Button setState:markTypeOne];
    [_barButton setState:markTypeBar];
    [_detIdbutton setState:useDetId];
    [_cassetteViewButton setState:cassetteView];
    
    [_showCassetteButton setState:showCassettes];
    [_numberCassetteButton setState:numberCassettes];
    
    _hexview.useDetId = useDetId;
    
    [_stepper setIntegerValue:layer+1];
    
    [_layerSegs setSelected:NO forSegment:0];
    [_layerSegs setSelected:YES forSegment:1];
    _hexview.layerSegment = 1;
    
    [_axisButton setState:NO];
    _hexview.showaxes = NO;
    _hexview.plusz = NO;
    [_pluszButton setState:_hexview.plusz];
    [_minuszButton setState:!_hexview.plusz];
    [_pluszButton setEnabled:_hexview.showaxes];
    [_minuszButton setEnabled:_hexview.showaxes];
    
    [_pdfOptionsButton setState:NO];          // ----- pdf options -----
    [_pdfShowKeyButton setState:YES];
    [_pdfShowSummaryButton setState:YES];
    [_pdfShowHexDateButton setState:YES];
    [_pdfShowKeyButton setHidden:YES];
    [_pdfShowSummaryButton setHidden:YES];
    [_pdfShowHexDateButton setHidden:YES];
    _hexview.pdfShowKey = [_pdfShowKeyButton state];
    _hexview.pdfShowSummary = [_pdfShowSummaryButton state];
    _hexview.pdfShowHexDate = [_pdfShowHexDateButton state];
    
    
    [_removeTestPointButton setHidden:YES];
    [_testPointBox setHidden:YES];
    
    [_lockButton setState:locked];
    [_lockButton setToolTip:@"locked: magification retained when layer changed\nunlocked: magification optimized when layer changed"];
    
    if(!locked) [self setOptimumMagnification];
    
    [self setUpHexView];
    
    [self showResult];
    
    if(_hexview.showcoords || _hexview.showfileline) {
        [_mainwindow setAcceptsMouseMovedEvents:YES];
        [_mainwindow makeFirstResponder:_hexview];
        [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];
    }
    
    onlyOneCassette = NO;
    oneCassette = 0;
    _oneCassetteStepper.minValue = 1;
    _oneCassetteStepper.increment = 1;
    [_oneCassetteButton setState:NO];
    
    _magSlide.allowsTickMarkValuesOnly = NO;
    
    [self setUpOneCassette];
    
}

- (void) setUpHexView {
    
    _hexview.scrolling = scrolling;
    [_centreText setHidden:!scrolling];
    [_showCentreButton setHidden:!scrolling];
    if(!scrolling) [_showCentreButton setState:NO];
    _hexview.showViewCenter = [_showCentreButton state];
    [_showStructureButton setState:_hexview.showStructure];
    [_showStructureButton setHidden:!scrolling];
    [_showCellLabelsButton setHidden:!scrolling];
    [_showEdgeIndexButton  setHidden:!scrolling];
    [_showCellLabelsButton setEnabled:_hexview.showStructure];
    [_showEdgeIndexButton setEnabled:_hexview.showStructure];
    [_pdfShowKeyButton setEnabled:!scrolling];
    
    
    if(!scrolling) {
        //[scrollView removeFromSuperview];
        [_hexview setHexFrame:vRect];
        [[_mainwindow contentView] replaceSubview:scrollView with:_hexview];
        _hexview.magnify = 1.;
    } else {
        scrollView = [[NSScrollView alloc] initWithFrame:vRect];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setHasHorizontalScroller:YES];
        
        [[_mainwindow contentView] addSubview:scrollView];
        scRect = vRect;
        scRect.size = scrollView.contentSize;
        [_hexview setHexFrame:scRect];
        scrollView.documentView = _hexview;
        _hexview.scrollView = scrollView;
        scrollmag = 1.;
        _hexview.scrollmag = scrollmag;
        [_hexview.scrollView.contentView setPostsBoundsChangedNotifications:YES];
        
    }
    [_hexview drawHexGrid];
    
    halfBoundsSize = _hexview.bounds.size;
    halfBoundsSize.width *= 0.5;
    halfBoundsSize.height *= 0.5;
    
}

/*
 - (void) centreHexViewAt:(NSPoint) centre {
 
 if(locked) return;
 
 NSRect ff = _hexview.frame;
 NSRect vis = scrollView.documentVisibleRect;
 NSPoint newcentre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
 double dx = (newcentre.x - centre.x)*_hexview.frame.size.width/_hexview.bounds.size.width;
 double dy = (newcentre.y - centre.y)*_hexview.frame.size.height/_hexview.bounds.size.height;
 ff.origin.x += dx;
 ff.origin.y += dy;
 [_hexview setHexFrame:ff];
 [_hexview drawHexGrid];
 
 }
 */
- (void)windowWillClose:(NSNotification *)notification {
    
    //if(layer >= theConfiguration.nLayers) layer = 0;
    version = theMapFiles.version;
    
    [self saveHex];
    
    //[theConfiguration writeLast];
    
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];
}


#pragma mark - IBActions

- (IBAction) changeLayer:(id)sender {
    
    /*
     double p = [_magSlide doubleValue];
     double m = _hexview.magnify;
     NSLog(@"Layer was %d with slide = %.1f, magnify = %.1f",layer+1,p,m);
     */
    
    
    int oldlayer = layer;
    layer = (int)[_stepper integerValue] - 1;
    if(layer >= nLayers) {
        layer = nLayers - 1;
        [_stepper setIntegerValue:layer+1];
        [self setLayerSeg:layer];
    }
    
    if(layer != oldlayer) {
        [self setUpOneCassette];
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
    showCassettes = [_showCassetteButton state];
    cassetteView = [_cassetteViewButton state];
    numberCassettes = [_numberCassetteButton state];
    showGridForPartials = [_partialGridButton state];
    _hexview.showCellLabels = [_showCellLabelsButton state];
    _hexview.showEdgeIndex = [_showEdgeIndexButton state];
    
    
    if(sender == _rotateButton) {
        if(!theCellLocator) theCellLocator = [HXGCellLocatorWindowControl sharedCellLocatorControl];
        [theCellLocator.window close];
    }
    
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    
    [_hexview setNeedsDisplay:YES];
}

- (IBAction) changeRetraction:(id)sender {
    
    showRetracted = [_retractedButton state];
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    
    if(!theCellLocator) theCellLocator = [HXGCellLocatorWindowControl sharedCellLocatorControl];
    [theCellLocator.window close];
    
    [self showResult];
    
    [_hexview setNeedsDisplay:YES];
    
}

- (IBAction) changeActive:(id)sender {
    
    showActiveWafer = [_activeOnlyButton state];
    int flags = [self encodeParts];
    [_hexview setParts:flags];
    /*
     if(!theCellLocator) theCellLocator = [HXGCellLocatorWindowControl sharedCellLocatorControl];
     [theCellLocator.window close];
     */
    [self showResult];
    
    [_hexview setNeedsDisplay:YES];
    
}

- (IBAction) changeFile:(id)sender {
    
    int versionBefore = version;
    
    version = (int) [sender tag];
    
    [_retractedButton setEnabled:version != 0];
    if(version == 0) {
        _hexview.showRetracted = NO;
    } else _hexview.showRetracted = [_retractedButton state];
    
    theMapFiles.version = version;
    
    if(version == 2 && versionBefore ==2) [self chooseOtherSiFileAndTile:YES];
    
    [self displayForNewFile];
    
}


- (IBAction) changeMarker:(id)sender {
    
    markTypeOne = [_chan1Button state];
    markTypeBar = [_barButton state];
    _hexview.markTypeOne = markTypeOne;
    _hexview.markTypeBar = markTypeBar;
    [_hexview setNeedsDisplay:YES];
}

- (IBAction) axisDisplay:(id)sender {
    
    if([sender tag] == 0) {
        _hexview.showaxes = [_axisButton state];
        [_pluszButton setEnabled:_hexview.showaxes];
        [_minuszButton setEnabled:_hexview.showaxes];
        if(_hexview.showaxes) [_hexview setUpAxes];
        [_hexview setNeedsDisplay:YES];
    } else {
        _hexview.plusz = ([sender tag] == 1);
        [_pluszButton setState:_hexview.plusz];
        [_minuszButton setState:!_hexview.plusz];
        if(_hexview.showaxes) [_hexview setNeedsDisplay:YES];
    }
    
    
}
- (IBAction) changeMagLock:(id)sender {
    
    locked = [sender state];
    if(!locked) {
        [self setOptimumMagnification];
        [self showResult];
    }
    
}

- (IBAction) changeScrolling:(id)sender {
    
    
    scrolling = [sender state];
    [_lockButton setHidden:scrolling];
    
    [_scrollThresholdBox setHidden:!scrolling];
    _magSlide.allowsTickMarkValuesOnly = NO;
    
    
    
    if(!scrolling) {
        if(!locked) [self setOptimumMagnification];
        // [_magSlide setDoubleValue:8.];
    } else {
        //---- translate from existing (scrolling) magSlide to scrollmag
        double power = log(1.25/_hexview.magnify)/log(1.2);
        [_magSlide setDoubleValue:power];
    }
    
    
    [self setUpHexView];
    
    [_zoomButton setHidden:!showpoint || _hexview.scrolling];
    if(!_hexview.scrolling) [_hexview zoomOnTestPoint:[_zoomButton state]];
    else [_hexview zoomOnTestPoint:NO];
    
    [self changeMagnification:nil];
    
}

- (IBAction) showCentre:(id)sender {
    
    _hexview.showViewCenter = [sender state];
    [self newCentre:nil];
    [_hexview setNeedsDisplay:YES];
    
}
- (IBAction) changeStructureDisplay:(id)sender {
    
    if([sender tag] == 0) _hexview.showStructure = [sender state];
    
    [_showCellLabelsButton setEnabled:_hexview.showStructure];
    [_showEdgeIndexButton setEnabled:_hexview.showStructure];
    
    [_hexview setNeedsDisplay:YES];
    
}

- (IBAction) changeMagnification:(id)sender {
    
    NSPoint centre;
    double power = [_magSlide doubleValue];
        
    if(!scrolling) {
        _hexview.magnify = pow(1.03,8.-power);
    } else {
        scrollmag = pow(1.2,power);
        NSRect f = scRect;
        _hexview.scrollmag = scrollmag;
        NSRect vis = scrollView.documentVisibleRect;
        centre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
        f.size.width *= scrollmag;
        f.size.height *= scrollmag;
        [_hexview setHexFrame:f];
        if(_hexview.showCellLabels && scrollmag > labelsMagLimit) {
            _hexview.suppressLabels = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                                                     selector: @selector(finishMagSlide) object: nil ];
            [self performSelector: @selector(finishMagSlide) withObject: nil
                       afterDelay: 0.0];
        }
    }
    
    [_hexview drawHexGrid];
    if(scrolling) {
        [_hexview centreHexViewAt:centre];
        [self newCentre:nil];
    }
    [_hexview setNeedsDisplay:YES];
    
}

- (void) finishMagSlide {
    
    _hexview.suppressLabels = NO;
    if(scrollmag > labelsMagLimit) [_hexview setNeedsDisplay:YES];
    //NSLog(@"scrollmag = %.2f",scrollmag);

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
  
    _hexview.showViewCenter = NO;
    [_showCentreButton setState:NO];
    [_showCentreButton setHidden:YES];
    [_centreText setHidden:YES];

    [_hexview zoomOnTestPoint:[sender state]];
}

- (IBAction) changeOnlyOneCassette:(id)sender {
    
    oneCassette = (int) [_oneCassetteStepper integerValue];
    onlyOneCassette = [_oneCassetteButton state];
    [self setUpOneCassette];
    
    [self showResult];
    
}

- (IBAction) changePdfOptions:(id)sender {

    BOOL hidden = ![_pdfOptionsButton state];
    [_pdfShowKeyButton setHidden:hidden];
    [_pdfShowSummaryButton setHidden:hidden];
    [_pdfShowHexDateButton setHidden:hidden];
    
    _hexview.pdfShowKey = [_pdfShowKeyButton state];
    _hexview.pdfShowSummary = [_pdfShowSummaryButton state];
    _hexview.pdfShowHexDate = [_pdfShowHexDateButton state];

}


#pragma mark - methods called from AppDelegate (menu items)

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

- (void) setShowWaferCentre:(BOOL)show {
    
    //[_mainwindow setAcceptsMouseMovedEvents:show];
    [_mainwindow makeFirstResponder:_hexview];
    
    _hexview.showwafercentre = show;
    [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];
    if(!show) [_hexview setNeedsDisplay:YES]; // Clear the current display
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
    
    [theHist makeHistogram:upper Bins:nbins Xlow:xlo Dx:dx Title:@"Area without sensors"];
    [theHist addHistogram:lower withColor:[NSColor peachOrange]];
    theHist.pdfFileName = @"DebugTestHisto";
    [theHist displayHist];

    //[theHist drawHistogram];
    
}

- (BOOL) toggleWaferNumbering {
    
    _hexview.numberWafers = !_hexview.numberWafers;
    //[_axisButton setHidden:!_hexview.numberWafers];
    //[_pluszButton setHidden:!_hexview.numberWafers];
    //[_minuszButton setHidden:!_hexview.numberWafers];
    
    [_hexview setNeedsDisplay:YES];
    
    
    return _hexview.numberWafers;
}

- (void) deleteTestPoint {
    
    _hexview.showtestspot = NO;
    showpoint = NO;
    [_removeTestPointButton setHidden:!showpoint];
    [_testPointBox setHidden:!showpoint];
    [_zoomButton setHidden:!showpoint];
    [_zoomButton setState:NO];
    [_hexview zoomOnTestPoint:NO];
   
    /* --- what is this doing here? (6 June 2025)
    _hexview.showViewCenter = !_hexview.scrolling;
    [_showCentreButton setState:NO];
    [_showCentreButton setHidden:!_hexview.scrolling];
    [_centreText setHidden:!_hexview.scrolling];
    */

    
    
    [_testText setStringValue:@""];
    [_hexview setNeedsDisplay:YES];
}

- (void) performPruthviCheck {
    
    // For security: need check we are in v19 and retracted!!!
    
    // First instantiate reader of Pruthvi's csv file, and HXGCellLocatorWindowControl
    if(!thePruthviCSV) thePruthviCSV = [HXGPruthviCSV sharedPruthviCSV];
    if(!theCellLocator) theCellLocator = [HXGCellLocatorWindowControl sharedCellLocatorControl];
    
    NSOpenPanel * import = [NSOpenPanel openPanel];
    [import setCanChooseFiles:YES];
    NSString * message = @"Choose Pruthvi csv file having line format: ctype,cpos,lay,wu,wv,cu,cv,cox,coy";
    message = [message stringByAppendingFormat:@"; Default is <%@>",thePruthviCSV.csvFile];
    [import setMessage:message];
    [import setPrompt:@"Choose file"];
    NSArray * orderedWindows = [NSApp orderedWindows];
    NSWindow * frontWindow = orderedWindows[0];

    [import beginSheetModalForWindow:frontWindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString * csvpath = [[import URL] path];
            [self->thePruthviCSV readCSVfile:csvpath];
            [self loopOnPruthviCSV];
        } else {
            [self->thePruthviCSV readCSVfile:self->thePruthviCSV.csvFile];
            [self loopOnPruthviCSV];
        }
    }];

}
 
- (void) loopOnPruthviCSV {
    /* ------ Loop over lines in file ------------------------------------------------------
       1. change layer as necessary
       2. call modified HXGCellLocatorWindowControl->locateCellsIn:(HXGWafer *) waf etc etc
          (which does not show the HXGCellLocator window, but just outputs to Terminal)
     --------------------------------------------------------------------------------------- */
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal clearString];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    theTerminal.suggestedName = @"CellLocations";


    int nloop = thePruthviCSV.nLines;
    int originalLayer = layer;
    
    for(int i=0; i<nloop; i++) {
        if(![thePruthviCSV setCurrentLine:i]) {
            [theTerminal displayString:[NSString stringWithFormat:@"*** ERROR decoding file:\n%@\n                                 STOPPING ***",thePruthviCSV.csvFile]];
            break;
        }
        if(thePruthviCSV.layer - 1 != layer) {
            layer = thePruthviCSV.layer - 1;
            if(layer < 0 || layer > 46) {
                NSLog(@"BAD PRUTHVI LAYER %d at line %d",thePruthviCSV.layer,i);
                continue;
            }
            [self showResult];
        }
        HXGWafer * wafer = [_hexview getWaferFromDetIdU:thePruthviCSV.wiu andV:thePruthviCSV.wiv];
        [theCellLocator locatePruthviCell: i inWafer:wafer ofLayer: layer rotated30:(_hexview.rotate30 && rotateRotated)];
    }
    
    layer = originalLayer;
    [self showResult];

}



#pragma mark - Output summary files

- (void) writeWaferSummary //--- Superceded code (and only use of _hexview getThickCount
{
    NSString * filename = @"wafers.txt";
    NSSavePanel * export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
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
    
    int thicktot[4] = {0,0,0,0};
    [_hexview zeroPartialTotals];
    NSString * waferSummary = @"Using flat-files:\n-  ";
    
    NSString * fileStrings = [NSString stringWithString:theMapFiles.waferFlatFile];
    if(version == 2) fileStrings = otherSiFileName;
    fileStrings = [fileStrings stringByAppendingString:@"\n-  "];
    fileStrings = otherTileFileName;
    
    waferSummary = [waferSummary stringByAppendingString:fileStrings];
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
                        @"Layer %2d 300µm:%3d, HD200:%3d, LD200:%3d, 120µm:%3d (%3d) %@\n",l+1,thick[3],thick[2],thick[1],thick[0],thick[0]+thick[1]+thick[2]+thick[3],[_hexview partialWaferSummary]];
        thicktot[0] += thick[0]; thicktot[1] += thick[1]; thicktot[2] += thick[2]; thicktot[3] += thick[3];
    }
    
    waferSummary = [waferSummary stringByAppendingFormat:
                    @"\nTOTAL: 300µm:%3d, HD200:%3d, LD200:%3d, 120µm:%3d\n",thicktot[3],thicktot[2],thicktot[1],thicktot[0]];
    int sumwafers = thicktot[3] + thicktot[2] + thicktot[1] + thicktot[0];
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
    
    waferSummary = [waferSummary stringByAppendingString:@"\n\nTOTALS FOR BOTH ENDCAPS:\n\n"];
    waferSummary = [waferSummary stringByAppendingFormat:@"Full wafers LD: %d, HD: %d\nPartial wafer totals: ",2*(thicktot[2]+thicktot[1]),2*thicktot[0]];
    
    hoffset = 1;
    tFlag = @"L";
    for(int i=0; i<11; i++) {
        if(i > 5) {tFlag = @"H"; hoffset = -5;}
        if(pp[i]>0) {
            waferSummary = [waferSummary stringByAppendingFormat:@"%@%d:%d; ",tFlag,i+hoffset,2*pp[i]];
            pTot += pp[i];
        }
    }
    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
    
    NSString * vstamp = [NSString stringWithFormat:@"\n\nHex version %.2f(%d), ",version,build];
    
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

- (void) pedroStyleSummary {
    
    NSString * newline;
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    
    newline = [NSString stringWithString:theMapFiles.waferFlatFile];
    if(version == 2) newline = otherSiFileName;
    newline = [NSString stringWithFormat:@"File: %@\n\n",newline];
    [theTerminal displayString:newline];
    [theTerminal displayString:@"Module counts for two endcaps\n\n"];
    [theTerminal displayString:@"------------------------------------\n"];
    [theTerminal displayString:@"Dens Thick Type    CEE    CEH  Total\n"];
    [theTerminal displayString:@"------------------------------------\n"];
    
    int count[2][4][6][2] = {0};
    BOOL warned = NO;
    
    for (int ilay=0; ilay<47; ilay++) {
        int ltest,tnum;
        NSString * thickStr;
        int icee = 0;
        if(ilay > 25) icee = 1;
        NSArray * layerString = [theMapFiles getMapStringsForLayer:ilay];
        for(int i=0; i<layerString.count; i++) {
            NSString * lS = layerString[i];
            lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
            lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
            NSArray * columns = [lS componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];
            ltest = [columns[0] intValue];
            tnum = [columns[1] intValue];
            thickStr = columns[2];
            int il = (int) thickStr.length;
            BOOL LD = [[thickStr substringToIndex:1] isEqualToString: @"l"];
            int thickflag=-1;
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"300"]) thickflag = 3;
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"200"]) {
                if(LD) thickflag = 2;
                else thickflag = 1;
            }
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"120"]) thickflag = 0;
            int idens = 0;
            if(LD) idens = 1;
            if(tnum > 5) {
                if(!warned) {
                    NSAlert * alert = [[NSAlert alloc] init];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"The flatfile appears to contain Threes"];
                    [alert setInformativeText:@"The threes will be ignored"];
                    [alert setAlertStyle:NSAlertStyleWarning];
                    [alert runModal];
                    warned = YES;
                }
            } else count[idens][thickflag][tnum][icee]++;
        }
    }
    
    NSString * denseStr[2] = {@"  HD",@"  LD"};
    int ithick[4] = {120,200,200,300};
    NSString * typeStr[6] = {@"0-F",@"1-T",@"2-B",@"3-L",@"4-R",@"5-5"};
    for (int i0=0; i0<2; i0++) {
        for (int i1=0; i1<4; i1++) {
            BOOL didshow = NO;
            for (int i2=0; i2<6; i2++) {
                if(count[i0][i1][i2][0] != 0 || count[i0][i1][i2][1] != 0) {
                    didshow = YES;
                    int cee = 2*count[i0][i1][i2][0];
                    int ceh = 2*count[i0][i1][i2][1];
                    int total = cee + ceh;
                    newline = [NSString stringWithString:denseStr[i0]];
                    newline = [newline stringByAppendingFormat:@"%6d  %@ %6d %6d %6d\n",ithick[i1],typeStr[i2],cee,ceh,total];
                    [theTerminal displayString:newline];
                }
            }
            if(didshow)[theTerminal displayString:@"------------------------------------\n"];
        }
    }
    
    theTerminal.suggestedName = @"WaferSummary";

    [theTerminal showWindow:nil];
}

- (void) detIdCountWithBreakdown {
    
    showbreakdown = YES;
    [self detIdCount];
    
}

- (void) detIdCount {
    
    NSString * newline;
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    else [theTerminal clearString];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    
    newline = [NSString stringWithString:theMapFiles.waferFlatFile];
    if(version == 2) newline = otherSiFileName;
    newline = [NSString stringWithFormat:@"File: %@\n\n",newline];
    [theTerminal displayString:newline];
    [theTerminal displayString:@"detId count for one and (two) endcaps\n"];
    [theTerminal displayString:@"-----------------Si-------------------\n"];
    
    int totCEE = 0;
    int totCEH = 0;
    
    for (int ilay=0; ilay<47; ilay++) {
        int count[2][4][7] = {0};
        int ltest,tnum;
        NSString * thickStr;
        NSArray * layerString = [theMapFiles getMapStringsForLayer:ilay];
        for(int i=0; i<layerString.count; i++) {
            NSString * lS = layerString[i];
            lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
            lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
            NSArray * columns = [lS componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];
            ltest = [columns[0] intValue];
            tnum = [columns[1] intValue];
            thickStr = columns[2];
            int il = (int) thickStr.length;
            BOOL LD = [[thickStr substringToIndex:1] isEqualToString: @"l"];
            int thickflag=-1;
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"300"]) thickflag = 3;
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"200"]) {
                if(LD) thickflag = 2;
                else thickflag = 1;
            }
            if([[thickStr substringFromIndex:il-3] isEqualToString: @"120"]) thickflag = 0;
            int idens = 0;
            if(!LD) idens = 1;
            count[idens][thickflag][tnum]++;
        }
        
        int layerTot = 0;
        int waferCellCount[2][7] = {192, 92,100,100,100,164, 34,432,165,267,138,138,  0,  0};

        for (int i0=0; i0<2; i0++) {
            for (int i1=0; i1<4; i1++) {
                for (int i2=0; i2<7; i2++) {
                    if(count[i0][i1][i2] != 0) {
                        layerTot += count[i0][i1][i2]*waferCellCount[i0][i2];
                        //if(ilay < 26) NSLog(@"Layer %d: Count for dens,thick,type %d %d %d = %d x %d => %d",ilay+1,i0,i1,i2,count[i0][i1][i2],waferCellCount[i0][i2],count[i0][i1][i2]*waferCellCount[i0][i2]);
                    }
                }
            }
        }
        int twoTot = layerTot*2;
        newline = [NSString stringWithFormat:@"Layer %2d, detId count = %5d (%6d)\n",ilay+1,layerTot,twoTot];
        [theTerminal displayString:newline];
        
        // ------ Show breakdowns ----------
        if(showbreakdown) {
            NSString * dStr[2] = {@"LD",@"HD"};
            NSString * tStr[4] = {@"120",@"200",@"200",@"300"};
            NSString * pStr[7] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
            int tfull = 0;
            for (int i0=0; i0<2; i0++) {
                for (int i1=0; i1<4; i1++) {
                    for (int i2=0; i2<7; i2++) {
                        if(count[i0][i1][i2] != 0) {
                            newline = [NSString stringWithFormat:@"    %5d, (%5d), %@μ %@%d (%@)\n",count[i0][i1][i2]*waferCellCount[i0][i2],2*count[i0][i1][i2]*waferCellCount[i0][i2],tStr[i1],dStr[i0],i2,pStr[i2]];
                            [theTerminal displayString:newline];
                            if(i2 == 0) tfull += 2*count[i0][i1][i2]*waferCellCount[i0][i2];
                        }
                    }
                }
            }
            newline = [NSString stringWithFormat:@"  Bharat 0: %5d\n",tfull];
            [theTerminal displayString:newline];

        }
        // ------ End show breakdown
        
        if(ilay > 25) totCEH += layerTot;
        else totCEE += layerTot;
    }
    
    newline = [NSString stringWithFormat:@"\n\nTotal CEE = %d (%d)\nTotal CEH = %d (%d)\nTOTAL = %d (%d)",totCEE,totCEE*2,totCEH,totCEH*2,totCEE+totCEH,2*(totCEE+totCEH)];
    
    [theTerminal displayString:newline];
    
    newline = [NSString stringWithFormat:@"\n\n\n%@\n\nNumber of tiles per layer\n-------------------------",theMapFiles.tileFlatFile];

    int total = 0;
    for(int l=33; l<47; l++) {
        int n = [theMapFiles countOfTilesInLayer:l];
        newline = [newline stringByAppendingFormat:@"\nLayer %2d : %5d (%5d)",l+1,n,2*n];
        total += n;
    }

    newline = [newline stringByAppendingFormat:@"\n\nTotal tiles = %d (%d)",total,2*total];

    newline = [newline stringByAppendingFormat:@"\n\nTOTAL Si+tiles = %d (%d)\n------------------------------------\n",total+totCEE+totCEH,2*(total+totCEE+totCEH)];
    [theTerminal displayString:newline];

    theTerminal.suggestedName = @"DetIdCount";

    [theTerminal showWindow:nil];
    showbreakdown = NO;
    
}

- (void) checkSiTileOverlaps {

    BOOL prevActive = showActiveWafer;
    showActiveWafer = NO;
    [_activeOnlyButton setState:showActiveWafer];
    [self changeActive:self];

    BOOL prevRetracted = showRetracted;
    showRetracted = YES;
    [_retractedButton setState:showRetracted];
    [self changeRetraction:self];    
    
    int firstLayer = 38-1;
    int lastLayer = 47-1;
    int currentLayer = layer;
    
    NSString * summary = [NSString stringWithFormat:@"Overlaps in layers %d - %d\n--------------------------\n\n",firstLayer+1,lastLayer+1];
                                 
    
    for(int lay=firstLayer; lay<lastLayer+1; lay++) {
        summary = [summary stringByAppendingFormat:@"\nLayer %d\n\n",lay+1];
        layer = lay;
        [self showResult];
        double rfirst = [theMapFiles innerRingRadius];
        double rlim = rfirst; // - 10.;
        int philist[50] = {0};
        int id1[50], id2[50];
        int nlist = 0;
        for (int iw=0; iw<_hexview.nhex; iw++) {
            HXGWafer * wafer = [_hexview getWafer:iw];
            if(wafer.whole || wafer.part) {
                if(wafer.rmax > rlim) {
                    NSPoint retcorner = wafer.maxcorner;
                    int overlap = [theMapFiles iphiTileAt:retcorner];
                    if(overlap > -1) {
                        philist[nlist] = overlap;
                        id1[nlist] = wafer.detId[0];
                        id2[nlist] = wafer.detId[1];
                        nlist++;
                        if(nlist > 49) break;
                    }
                }
            }
        }
        if(nlist == 0) continue;
        // ------ now sort the list
        int map[50];
        for(int i=0; i<nlist; i++) {
            map[i] = i;
        }
        for(int i=0; i<nlist; i++) {
            for(int j=1; j<nlist; j++) {
                if(philist[map[j]]<philist[map[j-1]]) {
                    int k = map[j];
                    map[j] = map[j-1];
                    map[j-1] = k;
                }
            }
        }
        // ------ now list discarding the duplicates
        int count = 1;
        summary = [summary stringByAppendingFormat:@"%2d: iphi = %d; wafer detId = %d:%d\n",count,philist[map[0]],id1[map[0]],id2[map[0]]];
        for(int i=1; i<nlist; i++) {
            if(philist[map[i]] == philist[map[i-1]]) continue;
            count++;
            summary = [summary stringByAppendingFormat:@"%2d: iphi = %d; wafer detId = %d:%d\n",count,philist[map[i]],id1[map[i]],id2[map[i]]];
        }
    }
    
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    theTerminal.suggestedName = @"SiTileOverlaps";
    [theTerminal displayString:summary];

    //--- Restore main graphics
    if(prevActive != showActiveWafer) {
        showActiveWafer = prevActive;
        [_activeOnlyButton setState:showActiveWafer];
        [self changeActive:self];
    }
    if(prevRetracted != showRetracted) {
        showRetracted = prevRetracted;
        [_retractedButton setState:showRetracted];
        [self changeRetraction:self];
    }
    layer = currentLayer;
    [self showResult];

}

#pragma mark - input/output of files

- (void) exportPDF {
    
    NSString * filename = [NSString stringWithFormat:@"Layer%02d.pdf",layer+1];
    NSSavePanel * export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
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

- (void) exportMultiPDF {
    
    int oldlayer = layer;
    double oldmag = _hexview.magnify;
    
    NSString * filename = @"Layer01.pdf";
    NSString * message =[NSString stringWithFormat:@"Pictures for layers starting at two-digit number (default 01) up to %d",nLayers];
    int last = 47;
    if(cassetteView) {
        message = @"Pictures for even layers of CE-E starting at two-digit number (default 02) up to 26";
        filename = @"Layer02.pdf";
        last = 26;
    }
    
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Export PDF files"];
    [export setShowsTagField:NO];
    [export setPrompt:@"Save pdf set"];
    [export setMessage:message];
    
    [export beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSString * pdfpath = [[export URL] path];
            NSString * pathstem = [pdfpath substringToIndex:pdfpath.length-6];
            NSString * remains = [pdfpath substringWithRange:NSMakeRange(pdfpath.length-6, 6)];
            int istart = [remains intValue];
            istart = MAX(istart,1);
            if(self->cassetteView) istart = 2 * ((istart+1)/2);
            istart = MIN(istart,last);
            
            //--- Loop over layers ----------------------------------------
            
            double mag[47] = {0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71,   // 1-8
                0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, // 9-30
                0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8,
                0.8, 0.8,
                1.0, 1.0, 1.0, 1.0, 1.0, 1.1, 1.1, 1.2, 1.2,                     // 31-39
                1.2544, 1.2544,                                       // 40-41
                1.2544, 1.2544, 1.2544, 1.2544, 1.2544, 1.2544 }; // 41-47
            
            for (int l=istart-1; l<last; l++) {
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
                if(self->cassetteView) l++;
                
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
    
    [self setHexBackground:thePreferences.flags];

    [_hexview setColors:[thePreferences getColors]];
    _hexview.casAlpha = thePreferences.casAlpha;
    
    if(centreoncentre) [_hexview makeGridOnCentre];
    else [_hexview makeGridOnVertex];
    
    _hexview.nLayer = layer;
    _hexview.zLayer = zL;
    [_hexview layoutFromFiles];
    
    if(!scrolling && !locked)[self setOptimumMagnification];
    [self showResult];
}

- (void) newPosition:(NSNotification *) note {
    
    if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];

    double etatest = [thePosition eta];
    double phitest = [thePosition phi];
    showpoint = [thePosition showposition];
    
    [_hexview setPosition:showpoint eta:etatest phi:phitest];
    
    [self testTestPoint];
    
}

- (void) newLayer:(NSNotification *) note {
    
    if([[note userInfo] objectForKey:@"newlayer"]) {
        NSNumber * newlayer = [[note userInfo] objectForKey:@"newlayer"];
        
        layer = (int) [newlayer integerValue];
        
        [_stepper setIntegerValue:layer+1];
        
        [self setLayerSeg:layer];
        if(!scrolling && !locked)[self setOptimumMagnification];
        if(showpoint) {
            [self setLayerFlags];
            [_hexview refreshTestPoint];
            [self testTestPoint];
        }

        [self showResult];
        [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];
        if(_testRetractions) [_hexview testRetractions];
        
    }
    if([[note userInfo] objectForKey:@"newsegment"]) {
        NSNumber * newsegment = [[note userInfo] objectForKey:@"newsegment"];
        [_layerSegs setSelected:YES forSegment:[newsegment integerValue]];
        [_layerSegs setSelected:NO forSegment:1 - [newsegment integerValue]];
        _hexview.layerSegment = [newsegment integerValue];
    }
}

- (void) newRings:(NSNotification *) note {
    
    _etaRingColor = theRings.iRingColor;
}

- (void) liveScroll:(NSNotification *) note {
    
    [_hexview mouseMovedToPoint:[_mainwindow mouseLocationOutsideOfEventStream]];

}


- (void) newCentre:(NSNotification *) note {
    
    NSRect bs = _hexview.scrollView.contentView.bounds;

    double magmult = 1./_hexview.scrollmag;
    NSPoint borg = [_hexview convertPoint:bs.origin fromView: _hexview.scrollView.contentView];

    _hexview.loCorner = NSMakePoint(borg.x-100.,borg.y-100.);
    _hexview.hiCorner = NSMakePoint(borg.x+_hexview.bounds.size.width*magmult+100.,
                                    borg.y+_hexview.bounds.size.width*magmult+100.);
    

    if(!_hexview.showViewCenter) {
        //NSString * ttext = [NSString stringWithFormat:@"Draw Δt: %.3fms",_hexview.tDraw];
        //[_centreText setStringValue:ttext];
        [_centreText setStringValue:@""];
        return;
    }

    
    NSPoint centre;
    centre.x = borg.x + halfBoundsSize.width*magmult;
    centre.y = borg.y + halfBoundsSize.width*magmult;
    _hexview.viewCentre = centre;

    NSString * ctext = @"";
    ctext = [ctext stringByAppendingFormat:@"(x, y) = (%.1f, %.1f)",centre.x,centre.y];
    
    double r = sqrt(centre.x*centre.x + centre.y*centre.y);
    ctext = [ctext stringByAppendingFormat:@"\n r = %.1f",r];

    if(r > 120.) {
        double theta = atan2(r,_hexview.zLayer);
        double eta = -log(tan(theta*0.5));
        double phi = 180.0*atan2(centre.y,centre.x)/M_PI;
        if(phi < 0.) phi += 360.;
        ctext = [ctext stringByAppendingFormat:@"\n (η, φ) = (%.3f, %.1fº)",eta,phi];
    }

    [_centreText setStringValue:ctext];
    
}


- (void) coverageStudy:(NSNotification *) note {

    if(!theCoverage) theCoverage = [HXGCoverageControl sharedCoverageControl];
    int firstLayer = theCoverage.first - 1;
    int lastLayer = theCoverage.last;
 
    // -Wno-vla-extension
    
    double etafirstOuter[6000] = {};
    double etafirstInner[6000] = {}; // !!
    int limitLayerInner[6000] = {};
    int limitLayerOuter[6000] = {}; // !!
    int currentLayer = layer;
    double step = (2.*M_PI/3.)/(double) (nphistep-1);
 
    for(int iphi=0;iphi<nphistep;iphi++) {
        etafirstInner[iphi] = 99.;
    }
   
    NSTimeInterval touter = 0.;
    NSTimeInterval tinner = 0.;
  
    
    for(int lay=firstLayer; lay<lastLayer; lay++) {
        layer = lay;
        [self showResult];

        double phi = 0.;
/* ----------------------------------------------------------------------------
    For each phi bin cross the boundary from a no hit place and find the first
    eta value for a hit.
               
    First consider the outer boundary
   ---------------------------------------------------------------------------- */
        double eta1 = 1.30;
        double eta2 = 1.75;
        //int netastep = (int) ((eta2-eta1)/step);
        
        NSTimeInterval tstart = [NSDate timeIntervalSinceReferenceDate];

        for(int iphi=0;iphi<nphistep;iphi++) {
            double deta = (eta2-eta1)*0.5;
            double eta = eta1 + deta;;
            BOOL lasthit = YES;
            while (deta > step*0.1 || !lasthit) {
                deta *= 0.5;
                double theta = 2.*atan2(exp(-eta),1.);
                double r = tan(theta)*zL;
                NSPoint point = NSMakePoint(r*cos(phi),r*sin(phi));
                if(_hexview.rotate30) {
                    double x = point.x;
                    double y = point.y;
                    point.x = x*cos(-M_PI/6.) - y*sin(-M_PI/6.);
                    point.y = x*sin(-M_PI/6.) + y*cos(-M_PI/6.);
                }

                int istate = [_hexview stateAtPoint:point];
                if(istate > 0) {
                    eta -= deta;
                    lasthit = YES;
                } else {
                    eta += deta;
                    lasthit = NO;
                }
            }
            if(eta > etafirstOuter[iphi]) {
                etafirstOuter[iphi] = eta;
                limitLayerOuter[iphi] = lay+1;
            }
            /*
            for(int ieta=0;ieta<netastep;ieta++) { //---------------- eta loop
                double theta = 2.*atan2(exp(-eta),1.);
                double r = tan(theta)*zL;
                NSPoint point = NSMakePoint(r*cos(phi),r*sin(phi));
                int istate = [_hexview stateAtPoint:point];
                if(istate > 0) {
                        if(eta > etafirstOuter[iphi]) {
                            etafirstOuter[iphi] = eta;
                            limitLayerOuter[iphi] = lay+1;
                        }
                        break;
                }
                eta += step;
            }                                      //---------------- End eta loop
             */
            phi += step;
        }
        NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
        touter = tnow-tstart;

/* ----------------------------------------------------------------------------
    Now repeat for the inner boundary.
                   
    Now travelling from high to lower eta...
   ---------------------------------------------------------------------------- */
        eta1 = 3.2;
        eta2 = 2.7;
        //netastep = (int) ((eta1-eta2)/step);

       tstart = [NSDate timeIntervalSinceReferenceDate];

        for(int iphi=0;iphi<nphistep;iphi++) {
            double deta = (eta1-eta2)*0.5;
            double eta = eta1 - deta;;
            BOOL lasthit = YES;
            while (deta > step*0.1 || !lasthit) {
                deta *= 0.5;
                double theta = 2.*atan2(exp(-eta),1.);
                double r = tan(theta)*zL;
                NSPoint point = NSMakePoint(r*cos(phi),r*sin(phi));
                if(_hexview.rotate30) {
                    double x = point.x;
                    double y = point.y;
                    point.x = x*cos(-M_PI/6.) - y*sin(-M_PI/6.);
                    point.y = x*sin(-M_PI/6.) + y*cos(-M_PI/6.);
                }

                int istate = [_hexview stateAtPoint:point];
                if(istate > 0) {
                    eta += deta;
                    lasthit = YES;
                } else {
                    eta -= deta;
                    lasthit = NO;
                }
            }
            if(eta < etafirstInner[iphi]) {
                etafirstInner[iphi] = eta;
                limitLayerInner[iphi] = lay+1;
            }
 /*
            double eta = eta1;
            for(int ieta=0;ieta<netastep;ieta++) { //---------------- eta loop
                double theta = 2.*atan2(exp(-eta),1.);
                double r = tan(theta)*zL;
                NSPoint point = NSMakePoint(r*cos(phi),r*sin(phi));
                int istate = [_hexview stateAtPoint:point];
                if(istate > 0) {
                        if(eta < etafirstInner[iphi]) {
                            etafirstInner[iphi] = eta;
                            limitLayerInner[iphi] = lay+1;
                        }
                        break;
                }
                eta -= step;
            }                                      //---------------- End eta loop
             */
            phi += step;
        }
        tnow = [NSDate timeIntervalSinceReferenceDate];
        tinner = tnow-tstart;
        //NSLog(@"Layer %d: tinner = %.6f; touter = %.6f",lay+1,tinner,touter);
    }

    //--- Restore main graphics
    layer = currentLayer;
    [self showResult];

    NSPoint limPointOuter[6000];
    double zfront = 3221.;
    double phiULimOut;
    double etaULimOut = 0.;
    int layerULimOut;
    for(int iphi=0;iphi<nphistep;iphi++) {
        double phi = iphi*step;
        double eta = etafirstOuter[iphi];
        double theta = 2.*atan2(exp(-eta), 1.);
        double r = tan(theta)*zfront;
        limPointOuter[iphi] = NSMakePoint(r*cos(phi),r*sin(phi));
        if(eta > etaULimOut) {
            etaULimOut = eta;
            phiULimOut = phi;
            layerULimOut = limitLayerOuter[iphi];
        }
    }

    NSPoint limPointInner[6000];
    double phiULimIn;
    double etaULimIn = 999.;
    int layerULimIn;
    for(int iphi=0;iphi<nphistep;iphi++) {
        double phi = iphi*step;
        double eta = etafirstInner[iphi];
        double theta = 2.*atan2(exp(-eta), 1.);
        double r = tan(theta)*zfront;
        limPointInner[iphi] = NSMakePoint(r*cos(phi),r*sin(phi));
        if(eta < etaULimIn) {
            etaULimIn = eta;
            phiULimIn = phi;
            layerULimIn = limitLayerInner[iphi];
        }
    }

    ////[theProgress.window close];

    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    NSRect fRect = NSMakeRect(-700.,0.,2400.,1400.);
  //  NSRect fRect = NSMakeRect(-375.,0.,1150.,750.);
    NSPoint orig = NSMakePoint(100.,[[NSScreen mainScreen] frame].size.height-22.);
    NSString * title = @"Full coverage in CEE";
    theHist.specialPlot = YES;
    [theHist showWindowAt:orig withTitle:title forPlotSize:NSMakeSize(1150.,750.)];

    [theHist makePlotFrame:fRect];
    [theHist histFillColor:[NSColor titaniumWhite] For:1];
    [theHist plotPoints:limPointOuter count:nphistep];
    [theHist addPoints:limPointInner];

 
    for(int iphi=0;iphi<nphistep;iphi++) {
        double phi = iphi*step;
        double eta = etafirstOuter[iphi];
        double theta = 2.*atan2(exp(-eta),1.);
        double r = tan(theta)*zfront;
        limPointOuter[iphi] = NSMakePoint(r*cos(phi),r*sin(phi));
    }
    NSString * fileString = [NSString stringWithString:theMapFiles.waferFlatFile];
    if(version == 2) fileString = otherSiFileName;
    fileString = [fileString substringToIndex:fileString.length - 4];

    int frontNlayers = 1;
    NSString * limstring;
    if(firstLayer == 0) {
        frontNlayers = lastLayer;
        limstring = [NSString stringWithFormat:@"%@\nCoverage in %d front layers\n",fileString,frontNlayers];
    } else {
        limstring = [NSString stringWithFormat:@"%@\nCoverage in layers %d to %d\n",fileString,firstLayer+1,lastLayer];
    }
   limstring = [limstring stringByAppendingFormat:@"Outer worst at (η,φ) = (%.3f,%.1fº) (layer %d)\nInner worst at (η,φ) = (%.3f,%.1fº) (layer %d)",etaULimOut,phiULimOut*180./M_PI,layerULimOut,etaULimIn,phiULimIn*180./M_PI,layerULimIn];
    
    [theHist addLabel:limstring at:NSMakePoint(700.,1350.)];
    double phi = phiULimOut;
    double eta = etaULimOut + 0.0065; //((double)(((int)(100.*etaULim))+2))*0.01;
    double theta = 2.*atan2(exp(-eta),1.);
    double r = tan(theta)*zfront;
    
    NSPoint endpoint = NSMakePoint(r*cos(phi),r*sin(phi));
    r -= 100.;
    NSPoint startpoint = NSMakePoint(r*cos(phi),r*sin(phi));
    [theHist.histView drawArrowFrom:startpoint To:endpoint headSize:20.];
    

    phi = phiULimIn;
    eta = etaULimIn - 0.033; //((double)(((int)(100.*etaULim))+2))*0.01;
    theta = 2.*atan2(exp(-eta),1.);
    r = tan(theta)*zfront;
    
    endpoint = NSMakePoint(r*cos(phi),r*sin(phi));
    r += 100.;
    startpoint = NSMakePoint(r*cos(phi),r*sin(phi));
    [theHist.histView drawArrowFrom:startpoint To:endpoint headSize:20.];
    
    theHist.pdfFileName = [NSString stringWithFormat:@"Coverage%d-%d-%@",firstLayer+1,lastLayer,fileString];
 
    [theHist displayHist];

}

#pragma mark - Layer description file manipulation

- (void) chooseOtherSiFileAndTile: (BOOL) tileAlso {

    version = 2;

    __block NSString * otherpath;
    NSOpenPanel * import = [NSOpenPanel openPanel];
    [import setCanChooseFiles:YES];
    NSString * message = [@"Change Si layer description file." stringByAppendingFormat:@"\nCurrently using %@\nIf a files is chosen that is not currently in this directory, it will be imported.",otherSiFileName];
    [import setMessage:message];
    [import setPrompt:@"Choose file"];
    [import setDirectoryURL:[NSURL fileURLWithPath:siDirPath]];
    [import beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            otherpath = [[import URL] path];
            NSArray * pathComponents = [otherpath pathComponents];
            NSString * filename = pathComponents[pathComponents.count-1];
            NSString * fullOtherPath = [self->siDirPath stringByAppendingFormat:@"/%@",filename];
            if(![otherpath isEqualToString:fullOtherPath]) {
                BOOL OK = [NSFileManager.defaultManager copyItemAtPath:otherpath
                    toPath:fullOtherPath
                     error:nil];
                if(!OK) {
                    [self simpleAlert:@"FAIL to copy file"];
                    return;
                }
             }
            [self setSiOther:filename];
        }
        if(tileAlso) [self chooseOtherTileFile];
        else [self displayForNewFile];
    }];

}

- (void) chooseOtherTileFile {
    
    version = 2;
    __block NSString * otherpath;
    NSOpenPanel * import = [NSOpenPanel openPanel];
    [import setCanChooseFiles:YES];
    NSString * message = [@"Change SiPM/tiles layer description file." stringByAppendingFormat:@"\nCurrently using %@\nIf a files is chosen that is not currently in this directory, it will be imported.",otherTileFileName];
    [import setMessage:message];
    [import setPrompt:@"Choose file"];
    [import setDirectoryURL:[NSURL fileURLWithPath:tileDirPath]];
    [import beginSheetModalForWindow:_mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            otherpath = [[import URL] path];
            NSArray * pathComponents = [otherpath pathComponents];
            NSString * filename = pathComponents[pathComponents.count-1];
            NSString * fullOtherPath = [self->tileDirPath stringByAppendingFormat:@"/%@",filename];
            if(![otherpath isEqualToString:fullOtherPath]) {
                BOOL OK = [NSFileManager.defaultManager copyItemAtPath:otherpath
                    toPath:fullOtherPath
                     error:nil];
                if(!OK) {
                    [self simpleAlert:@"FAIL to copy file"];
                    return;
                }
             }
            [self setTileOther:filename];
        }
        [self displayForNewFile]; // Could have some mechanism for only-if-needed...
    }];

}

- (void) setSiOther:(NSString *) filename {
    
    otherSiFileName = filename;
     
    [filename writeToFile:siNameFilePath
                    atomically:YES
                        encoding: NSASCIIStringEncoding
                            error:NULL];

    NSString * toolTipText = [@"Other files:\n" stringByAppendingFormat:@"%@\n%@",otherSiFileName,otherTileFileName];
    [_otherFileNamesField setToolTip:toolTipText];
    [_otherButton setToolTip:toolTipText];

     
}

- (void) setTileOther:(NSString *) filename {
    
    otherTileFileName = filename;
    
    [filename writeToFile:tileNameFilePath
                   atomically:YES
                       encoding: NSASCIIStringEncoding
                           error:NULL];
    
    NSString * toolTipText = [@"Other files:\n" stringByAppendingFormat:@"%@\n%@",otherSiFileName,otherTileFileName];
    [_otherFileNamesField setToolTip:toolTipText];
    [_otherButton setToolTip:toolTipText];

}
- (void) readOtherFileNames {
    
    NSString * otherpath = [NSString stringWithContentsOfFile:siNameFilePath
                                                     encoding:NSASCIIStringEncoding
                                                        error:NULL];
    otherSiFileName = otherpath;
    theMapFiles.siNameFilePath = siNameFilePath;
    
    otherpath = [NSString stringWithContentsOfFile:tileNameFilePath
                                                     encoding:NSASCIIStringEncoding
                                                        error:NULL];
    otherTileFileName = otherpath;
    theMapFiles.tileNameFilePath = tileNameFilePath;

    NSString * toolTipText = [@"Other files:\n" stringByAppendingFormat:@"%@\n%@",otherSiFileName,otherTileFileName];
    [_otherFileNamesField setToolTip:toolTipText];
    [_otherButton setToolTip:toolTipText];

}

- (void) displayForNewFile {
  
    [_otherButton setState:version == 2];
    [_v19Button setState:version == 1];
    [_v17Button setState:version == 0];
    
    theMapFiles.version = version;

    if(![theMapFiles loadFiles]) {
        version = 1;
        [_otherButton setState:version == 2];
        [_v19Button setState:version == 1];
        [_v17Button setState:version == 0];
        theMapFiles.version = version;
        [theMapFiles loadFiles];
    }
  
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
/*
- (void) viewSavedSiFilesInFinder {
    
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[pathroot stringByAppendingFormat:@"/SiliconLayerDescription/"] error:NULL];
    
    NSArray * fileURLs = [NSArray arrayWithObjects:[NSURL fileURLWithPath:[pathroot stringByAppendingFormat:@"/SiliconLayerDescription/%@",files[0]] isDirectory:NO], nil];
    
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];

}
*/
#pragma mark - showResult and other private methods
- (void) setLayerFlags {
    
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

}
- (void) showResult {
    
    [self setLayerFlags];
    
    if(centreoncentre) [_hexview makeGridOnCentre];
    else [_hexview makeGridOnVertex];

    [_hexview layoutFromFiles];

    [_mainwindow makeFirstResponder:_hexview];
    [self prepareText];
    if(showpoint) [self testTestPoint];
    else [_testText setStringValue:@""];
    [_summaryText setStringValue:summary];
        
    [_hexview drawHexGrid];
    
    _hexview.suppressLabels = (scrolling && scrollmag>labelsMagLimit && _hexview.showCellLabels);
    
    [_hexview setNeedsDisplay:YES];
    
    if(_hexview.suppressLabels) [self performSelector: @selector(redisplay) withObject: nil
                   afterDelay: 0.0];
    
    [_waferTypeKey setImage:[_hexview imageOfWaferTypeKey]];
    
}

- (void) redisplay {
    _hexview.suppressLabels = NO;
    [_hexview setNeedsDisplay:YES];
}

- (void) prepareText {

    int tmap[47] = {
        0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,
        1,1,1,1,1,1,1,1,1,1, 1,
        2,2,2,2,2,2,2,2,2,2};
    NSString * tString[2] = {@"fine",@"coarse"};
    
    NSString * layerText = @"(CE-E cassette";
    
    summary = [NSString stringWithFormat:@"Layer %d ",layer+1];
    if(tmap[layer] != 0 ) {
        layerText = [NSString stringWithFormat:@"(CE-H %d, %@ sampling)",layer-25,tString[tmap[layer]-1]];
    }
    summary = [summary stringByAppendingString:layerText];
    if(tmap[layer] == 0) {
        summary = [summary stringByAppendingFormat:@" %d)",layer/2 + 1];
    }
    
    double z = zLayer[layer];

    summary = [summary stringByAppendingFormat:@"\nz = %.1f mm\n",z];
    
    NSString * fileStrings = [NSString stringWithString:theMapFiles.waferFlatFile];
    fileStrings = [fileStrings stringByAppendingString:@"\n-  "];
    fileStrings = [fileStrings stringByAppendingString:theMapFiles.tileFlatFile];
    if(version == 2) {
        fileStrings = otherSiFileName;
        fileStrings = [fileStrings stringByAppendingString:@"\n-  "];
        fileStrings = [fileStrings stringByAppendingString:otherTileFileName];
    }

    
    summary = [summary stringByAppendingFormat:@"Using layout files:\n-  %@\n",fileStrings];

    summary = [summary stringByAppendingString:[_hexview waferSummary]];
}

- (void) setLayerSeg:(int) l {

    int lvis = l+1;
    NSString * str = [NSString stringWithFormat:@"%1d",lvis/10];
    [_layerSegs setLabel:str forSegment:0];
    str = [NSString stringWithFormat:@"%1d",lvis%10];
    [_layerSegs setLabel:str forSegment:1];

}

- (void) setUpOneCassette {
    
    [_oneCassetteText setHidden:!onlyOneCassette];
    [_oneCassetteStepper setHidden:!onlyOneCassette];

    if(onlyOneCassette) {
        int max = 6;
        if(layer > 25) max = 12;
        _oneCassetteStepper.maxValue = max;
        if(oneCassette > max || oneCassette < 1) oneCassette = 1;
        NSString * oneCassetteString = [NSString stringWithFormat:@"%d",oneCassette];
        [_oneCassetteText setStringValue:oneCassetteString];
        [_oneCassetteStepper setIntValue:oneCassette];
    }
    if(onlyOneCassette) _hexview.oneCassette = oneCassette;
    else _hexview.oneCassette = 0;


}

- (void) setOptimumMagnification {

    double optimumMagnification[47] = {
        16.4,16.4,16.4,16.4,16.4,16.4,16.4,16.4,16.0,16.0,
        16.0,16.0,16.0,16.0,16.0,16.0,16.0,16.0,16.0,16.0,
        16.0,16.0,16.0,16.0,14.5,14.5,14.2,14.2,13.6,13.6,
        11.5,10.5, 8.5, 9.7, 8.3, 6.8, 6.8, 4.0, 2.2, 1.0,
         1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};

    if(!scrolling && !locked) {
        double power = optimumMagnification[layer];
        [_magSlide setDoubleValue:power];
        _hexview.magnify = pow(1.03,8.-power);
    }

}

- (void) testTestPoint {

    [_removeTestPointButton setHidden:!showpoint];
    [_testPointBox setHidden:!showpoint];
    [_zoomButton setHidden:!showpoint || _hexview.scrolling];

    if(!showpoint) {
        [_testText setStringValue:@""];
        return;
    }
// ---- Make phitest and etatest local; here use hexview.testpointLayout
  
    //_hexview.dbuggery = YES;
    NSPoint point = _hexview.testpointLayout;

    int istate = [_hexview stateAtPoint:point];
    //_hexview.dbuggery = NO;
    NSString * testStateString = [NSString stringWithFormat:@"Test point state: %d (NB: no dead\nspace between wafers!)\n(η,φ) = (%.3f,%.2fº)\n",istate,thePosition.eta,thePosition.phi];
    testStateString = [testStateString stringByAppendingFormat:@"testpointLayout = (%.1f,%.1f)\n",_hexview.testpointLayout.x,_hexview.testpointLayout.y];
#ifdef DEBUG
    testStateString = [testStateString stringByAppendingString:_hexview.debugString];
#endif
    [_testText setStringValue:testStateString];
    [_testText setToolTip:@"0 = no sensor\n1 = whole\n2 = partial\n3 = tile"];

}


#pragma mark - persistency

- (BOOL) saveHex {
    
    float hVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    NSMutableData * data = [NSMutableData dataWithBytes:&hVersion length:4];
    
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
    
    if(numberWafers)    flags += 1;
    if(useDetId)        flags += 2;
    if(showRetracted)   flags += 4;
    if(rotateRotated)   flags += 8;
    if(showGrid)        flags += 16;
    if(showCassettes)   flags += 32;
    if(cassetteView)    flags += 64;
    if(markTypeOne)     flags += 128;
    if(markTypeBar)     flags += 256;
    if(numberCassettes) flags += 512;
    if(locked)          flags += 1024;
    if(_hexview.showcoords)     flags += 2048;
    if(_hexview.showfileline)   flags += 4096;
    flags += version << 13;
    if(showActiveWafer)         flags += 32768;
    flags += _etaRingColor << 16;
    if(showGridForPartials)     flags += 262144;
    if(_hexview.showStructure)  flags += 524288;
    if(_hexview.showCellLabels) flags += 1048576; // 2^20

    return flags;
}

- (void) decodeParts:(int) flags {
    
    numberWafers    = (flags&1)   != 0;
    useDetId        = (flags&2)   != 0;
    showRetracted   = (flags&4)   != 0;
    rotateRotated   = (flags&8)   != 0;
    showGrid        = (flags&16)  != 0;
    showCassettes   = (flags&32)  != 0;
    cassetteView    = (flags&64)  != 0;
    markTypeOne     = (flags&128) != 0;
    markTypeBar     = (flags&256) != 0;
    numberCassettes = (flags&512) != 0;
    locked          = (flags&1024)!= 0;
    _hexview.showcoords   = (flags&2048) != 0;
    _hexview.showfileline = (flags&4096) != 0;
    version = (flags >> 13) & 3;   // version uses two bits
    showActiveWafer = (flags&32768)      != 0;
    _etaRingColor = (flags >> 16) & 3;   // etaRingColor uses two bits
    showGridForPartials = (flags&262144)      != 0;
    _hexview.showStructure = (flags&524288)   != 0;
    _hexview.showCellLabels = (flags&1048576) != 0; // 2^20
}

- (BOOL) restoreHex {

    NSData * data = [NSData dataWithContentsOfFile:path];
    if(!data)
    {
        //NSLog(@"**** Read failure **** for path %@",path);
        return NO;
    }
    if(!(data.length == datlen))
    {
        NSLog(@"***** ERROR ***** Read %ld bytes in file %@",data.length,path);
        return NO;
    }

    
    float hVersion;
    [data getBytes:&hVersion range:NSMakeRange(0,4)];    // unload the stuff here

    if(hVersion < 3.0) {
        NSLog(@"restoreHex: discarding old version state (%.2f)",hVersion);
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

    version = 1;
    _etaRingColor = 1;

    numberWafers    = YES;
    useDetId        = YES;
    showRetracted   = YES;
    showActiveWafer = YES;
    rotateRotated   = YES;
    showGrid        = NO;
    showCassettes   = YES;
    markTypeOne     = YES;
    markTypeBar     = YES;
    numberCassettes = YES;
    cassetteView    = NO;
    showGridForPartials     = YES;
    _hexview.showcoords     = YES;
    _hexview.showfileline   = YES;
    _hexview.showStructure  = NO;
    _hexview.showStructure  = NO;
    _hexview.showCellLabels = NO;
    
}
#pragma mark - Alerts
- (void) simpleAlert: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setShowsSuppressionButton:NO];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }

}

- (void) fishcakeAlert: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setShowsSuppressionButton:NO];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }

}

- (void) diskProblems {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Unrecoverable disk problem"];
    [alert setInformativeText:@"Bailing out - this shouldn't happen..."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];
    
}

#pragma mark - layer z position

- (void) loadZfor47 {
    /*
    double z47[47] = {
      3221.,3232.,3252.,3262.,3283.,3293.,3313.,3324.,3344.,3354.,
      3374.,3385.,3405.,3415.,3435.,3446.,3466.,3476.,3500.,3510.,
      3534.,3544.,3568.,3578.,3601.,3612.,3678.,3741.,3804.,3867.,
      3930.,3993.,4056.,4119.,4182.,4245.,4308.,4390.,4472.,4555.,
      4637.,4719.,4801.,4884.,4966.,5048.,5130.
    };
     */
    //--- Si sensor z position (front from front HGCAL z = 3210.5)
    double sensorZ[47] = {
    3221.46,3231.21,3252.03,3261.78,3282.60,3292.35,3313.17,3322.92,3343.74,3353.49,
    3374.31,3384.06,3404.88,3414.63,3435.45,3445.20,3466.02,3475.77,3499.87,3509.62,
    3533.69,3543.44,3567.51,3577.26,3601.33,3611.08,3679.51,3742.56,3805.61,3868.66,
    3931.71,3994.76,4057.81,4120.86,4183.91,4246.96,4310.01,4392.26,4474.51,4556.76,
    4639.01,4721.26,4803.51,4885.76,4968.01,5050.26,5132.51}; // (mm)
    
    for(int i=0; i<47; i++) {
        zLayer[i] = sensorZ[i];
    }
}

@end
