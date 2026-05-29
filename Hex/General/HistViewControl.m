//
//  HistViewControl.m
//  Hex
//
//  Created by Chris Seez on 25/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HistViewControl.h"

@interface HistViewControl ()

@end

@implementation HistViewControl

+ (id) sharedHistViewControl {
    
    static dispatch_once_t pred;
    static HistViewControl * thePlot = nil;
    
    dispatch_once(&pred, ^{ thePlot = [[self alloc] init]; });
    return thePlot;
}
/*
+ (id) histViewControl {
    
    return [[self alloc] init];
    
}
*/
- (id)init {
    
    self=[super initWithWindowNibName: @"HistViewControl"];
    
    plotwidth = 400.;
    plotheight = 400.;
    freeHeight = 35.;
    histWindowTitle = @"Histogram viewer";
    windowOrigin = NSMakePoint([[NSScreen mainScreen] frame].size.width - plotwidth - 100.,[[NSScreen mainScreen] frame].size.height-plotheight-100.);

    return self;
}

- (void) showWindowAt:(NSPoint)p withTitle:(NSString *) tit forPlotSize:(NSSize) s {
    
    _histView.binDividers = NO;
    _histView.nstacked = 0;
        
    windowOrigin = p;
    histWindowTitle = [NSString stringWithString:tit];
    _pdfFileName = [NSString stringWithString:tit];
    plotwidth = s.width+64.;  // ---- need to set up control of margins in HistView
    plotheight = s.height+64.; //     and maybe also font sizes
    [self windowDidLoad];
    
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    self.window.title = histWindowTitle;
    height = plotheight + freeHeight + 22.;
    width = plotwidth;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = windowOrigin;
    wRect.size = NSMakeSize(width,height);
    [self.window setFrameOrigin:NSZeroPoint];
    [self.window setFrame:wRect display:YES];
    
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(0.0,freeHeight);
    vRect.size = NSMakeSize(plotwidth,plotheight);
    [_histView setPlotFrame:vRect];
    
    _histView.specialPlot = _specialPlot;
    

    /*
    if(!_pdfButton) _pdfButton = [[NSButton alloc] initWithFrame:NSMakeRect(width - 100.,5.,95.,30.)];
    else [_pdfButton setFrame:NSMakeRect(width - 100.,5.,95.,30.)];
    [_pdfButton setTitle:@"make PDF"];
    [_pdfButton setAction:@selector(makePDF:)];
    [_pdfButton setBezelStyle:NSBezelStyleRounded];
    [[self.window contentView] addSubview:_pdfButton];
    NSLog(@"_histWindow = %@",self.window);
*/

}


- (IBAction) makePDF:(id)sender {
    
    NSSavePanel *export = [NSSavePanel savePanel];
    _pdfFileName = [_pdfFileName stringByAppendingString:@".pdf"];
    [export setNameFieldStringValue:_pdfFileName];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self.histView savePDF:pdfpath];
        }
    }];

}

- (void) makePDF {
    [self makePDF:self];
}


- (void) displayHist {
    
    [self performSelector:@selector(display:)
                withObject:self
                afterDelay:0.001];

}

- (void) display: (id) dummy {
    
    [self.histView setNeedsDisplay:YES];
    _specialPlot = NO;

}

- (void) drawHistogram {
    [_histView setNeedsDisplay:YES];
}


#pragma mark - Additional adjustments

- (void) histFillColor:(NSColor *) fillColor {
    [_histView setFillColor:fillColor For:0];
}
- (void) histFillColor:(NSColor *) fillColor For:(int) n {
    [_histView setFillColor:fillColor For:n];
}
- (void) fixYmax:(double) ymax {
    _histView.fixedYmax = ymax;
}

- (void) addLabel:(NSString *) label at:(NSPoint) p {
    
    [_histView addLabel:label at:p];
}

- (void) addPointLabel:(NSString *) label at:(NSPoint) p {
    
    [_histView addPointLabel:label at:p];
}

- (void) axisTitles: (NSString *) xtit And:(NSString *) ytit {
    
    [self showWindow:nil];
    
    NSString * fname = @"Helvetica";

    NSMutableAttributedString * xtitma = [[NSMutableAttributedString alloc] initWithString:xtit];
    [xtitma addAttribute:NSFontAttributeName
                   value:[NSFont fontWithName:fname size:18]
                   range:NSMakeRange(0,xtitma.length)];
    
    NSMutableAttributedString * ytitma = [[NSMutableAttributedString alloc] initWithString:ytit];
    [ytitma addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:fname size:18]
                range:NSMakeRange(0,ytitma.length)];

    _histView.xtit = xtitma;
    _histView.ytit = ytitma;
    
}

- (void) axisAttributedTitles: (NSMutableAttributedString *) xtit And:(NSMutableAttributedString *) ytit {
    
    [self showWindow:nil];
    _histView.xtit = xtit;
    _histView.ytit = ytit;
    
}

#pragma mark - Loading contents and drawing

- (void) drawHistogram:(double *)contents Bins:(int)nbin Xlow:(double)xlo Dx:(double)dx Title:(NSString *)tit {
    /*
     Simple draw single histo
     */
    _histView.nstacked = 0;
    [self showWindow:nil];
    _histView.contents = contents;
    _histView.nbin = nbin;
    _histView.xlo = xlo;
    _histView.deltax = dx;
    _histView.title = tit;

    [_histView setUpHist];
    [_histView setNeedsDisplay:YES];
}


- (void) makeHistogram:(double *)contents Bins:(int)nbin Xlow:(double)xlo Dx:(double)dx Title:(NSString *)tit {
    
    _histView.nstacked = 0;
    [self showWindow:nil];
    _histView.contents = contents;
    _histView.nbin = nbin;
    _histView.xlo = xlo;
    _histView.deltax = dx;
    _histView.title = tit;

    [_histView setUpHist];
}

- (void) addHistogram:(double *)contents {
    
    _histView.nstacked += 1;
    _histView.contents = contents;
    [_histView makeHistoBezier];

}

- (void) addHistogram:(double *)contents withColor:(NSColor *) color {
 
    [self addHistogram:contents];
    [_histView setFillColor:color For:_histView.nstacked];

}

#pragma mark - plotting points

- (void) makePlotFrame:(NSRect) f {
    
    [_histView setUpPlot:f];
    
}

- (void) plotPoints:(NSPoint *) pnt count:(int) npnt {
    
    _histView.nstacked = 0;
    [self showWindow:nil];
    _histView.nbin = npnt;
    [_histView makePlotBezier: pnt];
    [_histView setNeedsDisplay:YES];

}

- (void) addPoints:(NSPoint *) pnt {
    
    _histView.nstacked++;
    [self showWindow:nil];
    [_histView makePlotBezier: pnt];
    [_histView setNeedsDisplay:YES];

}

@end
