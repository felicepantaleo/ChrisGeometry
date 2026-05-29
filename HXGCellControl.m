//
//  HXGCellControl.m
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCellControl.h"

NSString * const HXGCellSpecNotification = @"HXGNewCellSpec";

@interface HXGCellControl ()

@end

@implementation HXGCellControl

+ (id) sharedCellControl {
    
    static dispatch_once_t pred;
    static HXGCellControl * theCellControl = nil;
    
    dispatch_once(&pred, ^{ theCellControl = [[self alloc] init]; });
    return theCellControl;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGCellControl"];
    
    gridCells = [NSMutableArray array];

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    plotheight = 0.88 * ([[NSScreen mainScreen] frame].size.height-22.);
    plotwidth = 0.9 * plotheight;
    height = plotheight + 90.;
    
    width = plotwidth;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(40.,[[NSScreen mainScreen] frame].size.height-height-22.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    
    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(0.0,height - plotheight - 22.);
    vRect.size = NSMakeSize(plotwidth,plotheight);
    id test = [_cellview initWithFrame:vRect]; // some redundancy to sort out here
    if(test != _cellview) {
        NSLog(@"Marbles lost");
    }
    
    [_cellview setViewFrame:vRect];
    
    // ------------------- make pdf button
    NSRect brect = NSMakeRect(width-90.,10.,75.,20.);
    pdfButton = [[NSButton alloc] initWithFrame:brect];
    [pdfButton setTitle:@"make PDF"];
    [pdfButton setAction:@selector(makePDF:)];
    [pdfButton setBezelStyle:NSBezelStyleTexturedRounded];
    [[[self window] contentView] addSubview:pdfButton];
    
    // ---------------- cell colour choices
    brect = NSMakeRect(10.,40.,135.,18.);
    plainColorButton = [[NSButton alloc] initWithFrame:brect];
    [plainColorButton setTitle:@"monotone"];
    [plainColorButton setAction:@selector(changeColor:)];
    [plainColorButton setButtonType:NSButtonTypeRadio];
    [[plainColorButton cell] setImagePosition:NSImageRight];
    [plainColorButton setAlignment:NSTextAlignmentRight];
    [plainColorButton setTag:0];
    [[[self window] contentView] addSubview:plainColorButton];
    brect = NSMakeRect(10.,22.,135.,18.);
    cellColorButton = [[NSButton alloc] initWithFrame:brect];
    [cellColorButton setTitle:@"cell type colours"];
    [cellColorButton setAction:@selector(changeColor:)];
    [cellColorButton setButtonType:NSButtonTypeRadio];
    [[cellColorButton cell] setImagePosition:NSImageRight];
    [cellColorButton setAlignment:NSTextAlignmentRight];
    [cellColorButton setTag:1];
    [[[self window] contentView] addSubview:cellColorButton];
    brect = NSMakeRect(10.,4.,135.,18.);
    triggerColorButton = [[NSButton alloc] initWithFrame:brect];
    [triggerColorButton setTitle:@"trigger cell colours"];
    [triggerColorButton setAction:@selector(changeColor:)];
    [triggerColorButton setButtonType:NSButtonTypeRadio];
    [[triggerColorButton cell] setImagePosition:NSImageRight];
    [triggerColorButton setAlignment:NSTextAlignmentRight];
    [triggerColorButton setTag:2];
    [[[self window] contentView] addSubview:triggerColorButton];
    
    _cellview.colorCells = 1;
    [plainColorButton setState:NO];
    [cellColorButton setState:YES];
    [triggerColorButton setState:NO];
    //[triggerColorButton setEnabled:NO];
    
    // ----------- numbering of cells

    brect = NSMakeRect(150.,40.,95.,18.);
    numberCellsButton = [[NSButton alloc] initWithFrame:brect];
    [numberCellsButton setTitle:@"number cells"];
    [numberCellsButton setAction:@selector(changeNumbering:)];
    [numberCellsButton setButtonType:NSButtonTypeSwitch];
    [[numberCellsButton cell] setImagePosition:NSImageRight];
    [numberCellsButton setAlignment:NSTextAlignmentRight];
    [numberCellsButton setTag:0];
    [[[self window] contentView] addSubview:numberCellsButton];
    brect = NSMakeRect(150.,22.,95.,18.);
    detIdButton = [[NSButton alloc] initWithFrame:brect];
    [detIdButton setTitle:@"use detId"];
    [detIdButton setAction:@selector(changeNumbering:)];
    [detIdButton setButtonType:NSButtonTypeSwitch];
    [[detIdButton cell] setImagePosition:NSImageRight];
    [detIdButton setAlignment:NSTextAlignmentRight];
    [detIdButton setTag:1];
    [[[self window] contentView] addSubview:detIdButton];
    brect = NSMakeRect(150.,4.,95.,18.);
    triggerIdButton = [[NSButton alloc] initWithFrame:brect];
    [triggerIdButton setTitle:@"trigger detId"];
    [triggerIdButton setAction:@selector(changeNumbering:)];
    [triggerIdButton setButtonType:NSButtonTypeSwitch];
    [[triggerIdButton cell] setImagePosition:NSImageRight];
    [triggerIdButton setAlignment:NSTextAlignmentRight];
    [triggerIdButton setTag:2];
    [[[self window] contentView] addSubview:triggerIdButton];

    _cellview.numberCells = YES;
    _cellview.useDetId = YES;
    _cellview.triggerId = NO;
    [numberCellsButton setState:YES];
    [detIdButton setState:YES];
    [triggerIdButton setState:NO];

    // ----------- other graphics
    
    brect = NSMakeRect(250.,40.,125.,18.);
    outlineButton = [[NSButton alloc] initWithFrame:brect];
    [outlineButton setTitle:@"outline and centre"];
    [outlineButton setAction:@selector(changeGraphics:)];
    [outlineButton setButtonType:NSButtonTypeSwitch];
    [[outlineButton cell] setImagePosition:NSImageRight];
    [outlineButton setAlignment:NSTextAlignmentRight];
    [outlineButton setTag:0];
    [[[self window] contentView] addSubview:outlineButton];
    
    brect = NSMakeRect(250.,22.,125.,18.);
    gridButton = [[NSButton alloc] initWithFrame:brect];
    [gridButton setTitle:@"show grid"];
    [gridButton setAction:@selector(changeGraphics:)];
    [gridButton setButtonType:NSButtonTypeSwitch];
    [[gridButton cell] setImagePosition:NSImageRight];
    [gridButton setAlignment:NSTextAlignmentRight];
    [gridButton setTag:1];
    [[[self window] contentView] addSubview:gridButton];
    
    brect = NSMakeRect(250.,4.,125.,18.);
    showCoordsButton = [[NSButton alloc] initWithFrame:brect];
    [showCoordsButton setTitle:@"show coordinates"];
    [showCoordsButton setAction:@selector(changeGraphics:)];
    [showCoordsButton setButtonType:NSButtonTypeSwitch];
    [[showCoordsButton cell] setImagePosition:NSImageRight];
    [showCoordsButton setAlignment:NSTextAlignmentRight];
    [showCoordsButton setTag:2];
    [[[self window] contentView] addSubview:showCoordsButton];
    
    brect = NSMakeRect(385.,40.,145.,18.);
    showDimensionsButton = [[NSButton alloc] initWithFrame:brect];
    [showDimensionsButton setTitle:@"show cell dimensions"];
    [showDimensionsButton setAction:@selector(changeGraphics:)];
    [showDimensionsButton setButtonType:NSButtonTypeSwitch];
    [[showDimensionsButton cell] setImagePosition:NSImageRight];
    [showDimensionsButton setAlignment:NSTextAlignmentRight];
    [showDimensionsButton setTag:3];
    [[[self window] contentView] addSubview:showDimensionsButton];
    
    brect = NSMakeRect(385.,22.,145.,18.);
    hyperBrightButton = [[NSButton alloc] initWithFrame:brect];
    [hyperBrightButton setTitle:@"highlight edge cells"];
    [hyperBrightButton setAction:@selector(changeGraphics:)];
    [hyperBrightButton setButtonType:NSButtonTypeSwitch];
    [[hyperBrightButton cell] setImagePosition:NSImageRight];
    [hyperBrightButton setAlignment:NSTextAlignmentRight];
    [hyperBrightButton setTag:4];
    [[[self window] contentView] addSubview:hyperBrightButton];
    
    brect = NSMakeRect(385.,4.,145.,18.);
    axesButton = [[NSButton alloc] initWithFrame:brect];
    [axesButton setTitle:@"show u,v axes"];
    [axesButton setAction:@selector(changeGraphics:)];
    [axesButton setButtonType:NSButtonTypeSwitch];
    [[axesButton cell] setImagePosition:NSImageRight];
    [axesButton setAlignment:NSTextAlignmentRight];
    [axesButton setTag:6];
    [[[self window] contentView] addSubview:axesButton];
// ------------ Inclusion radii buttons
    
    brect = NSMakeRect(385.,40.,145.,18.);
    showInclusionCircles = [[NSButton alloc] initWithFrame:brect];
    [showInclusionCircles setTitle:@"show inclusion circles"];
    [showInclusionCircles setAction:@selector(changeGraphics:)];
    [showInclusionCircles setButtonType:NSButtonTypeSwitch];
    [[showInclusionCircles cell] setImagePosition:NSImageRight];
    [showInclusionCircles setAlignment:NSTextAlignmentRight];
    [showInclusionCircles setTag:5];
    [[[self window] contentView] addSubview:showInclusionCircles];
    
    brect = NSMakeRect(385.,22.,145.,18.);
    showInclusionCoords = [[NSButton alloc] initWithFrame:brect];
    [showInclusionCoords setTitle:@"show mouse radius"];
    [showInclusionCoords setAction:@selector(changeGraphics:)];
    [showInclusionCoords setButtonType:NSButtonTypeSwitch];
    [[showInclusionCoords cell] setImagePosition:NSImageRight];
    [showInclusionCoords setAlignment:NSTextAlignmentRight];
    [showInclusionCoords setTag:2];
    [[[self window] contentView] addSubview:showInclusionCoords];
    
    
    _cellview.showOutline = NO;
    [outlineButton setState:NO];
    _cellview.showGrid = YES;
    [gridButton setState:YES];
    _cellview.showCoords = NO;
    [showCoordsButton setState:NO];
    _cellview.showDimensions = NO;
    [showDimensionsButton setState:NO];
    _cellview.hyperBright = NO;
    [hyperBrightButton setState:NO];
    
    _cellview.showCircles = YES;
    [showInclusionCircles setState:YES];
    
    _cellview.showAxes = NO;
    [axesButton setState:NO];
    
    [triggerColorButton setEnabled:NO];
    [triggerIdButton setEnabled:NO];

    _iplacement = 0;
    [_placementStepper setIntValue:_iplacement];
    [_placementStepper setMaxValue:11];
    [_placementStepper setValueWraps:YES];
    [_placementText setStringValue:[NSString stringWithFormat:@"Placement index = %2d",_iplacement]];


}

- (void) hideStandard: (BOOL) hide {
    
    [plainColorButton setHidden:hide];
    [cellColorButton setHidden:hide];
    [triggerColorButton setHidden:hide];
    [numberCellsButton setHidden:hide];
    [detIdButton setHidden:hide];
    [triggerIdButton setHidden:hide];
    [outlineButton setHidden:hide];
    [gridButton setHidden:hide];
    [showCoordsButton setHidden:hide];
    [showDimensionsButton setHidden:hide];
    [hyperBrightButton setHidden:hide];
    [axesButton setHidden:hide];
    
    [_densityControl setHidden:hide];
    [_placementStepper setHidden:hide];
    [_placementText setHidden:hide];

    [showInclusionCoords setHidden:!hide];
    [showInclusionCircles setHidden:!hide];

    _cellview.showCoords = NO;
    [showInclusionCoords setState:!hide];
    
}

- (void) showWindow:(id)sender {
    [super showWindow:sender];
    
    _iplacement = (int)[_placementStepper integerValue];
    [_cellview setPlacementIndex:_iplacement];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [[self window] makeFirstResponder:_cellview];
    
    

}

#pragma mark - IBActions

- (IBAction) setPlacementIndex:(id)sender {
    
    _iplacement = (int)[_placementStepper integerValue];
    [self changePlacementIndex:_iplacement];

}

- (IBAction) setDensity:(id)sender {

    iwaf = (int) [sender selectedSegment];
    [self makeCells:iwaf];
    [_cellview drawCells:gridCells forWafer:waferBezier];
    [self changePlacementIndex:_iplacement];

    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

}

- (IBAction) makePDF:(id)sender {
    
    int ncellWaf = 3 * count * count;
    NSString * filename;
    if(inclusionRadii) {
        filename = @"inclusionRadii.pdf";
    } else {
        if(_cellview.showAxes || _cellview.numberCells) {
            filename = [NSString stringWithFormat:@"wafer%3d-ip%02d.pdf",ncellWaf,_iplacement];
        } else filename = [NSString stringWithFormat:@"wafer%3d.pdf",ncellWaf];
    }
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self->_cellview savePDF:pdfpath];
        }
    }];
    
}

- (void) changeColor:(id)sender {
    
    int tag = (int) [sender tag];
    _cellview.colorCells = tag;
    [plainColorButton setState:(tag == 0)];
    [cellColorButton setState:(tag == 1)];
    [triggerColorButton setState:(tag == 2)];
    [_cellview setNeedsDisplay:YES];
}

- (void) changeNumbering:(id)sender {
    
    int tag = (int) [sender tag];
    
    if(tag == 0) {
        _cellview.numberCells = [sender state];
    } else if(tag == 1) {
        _cellview.useDetId = [sender state];
    } else {
        _cellview.triggerId = [sender state];
        //_cellview.numberCells = NO;
        //[numberCellsButton setState:NO];
        _cellview.colorCells = 2;
        [plainColorButton setState:NO];
        [cellColorButton setState:NO];
        [triggerColorButton setState:YES];
    }
    
    [_cellview setNeedsDisplay:YES];

}

- (void) changeGraphics:(id)sender {
    
    int tag = (int) [sender tag];
    
    if(tag == 0) {
        _cellview.showOutline = [sender state];
    } else if(tag == 1) {
        _cellview.showGrid = [sender state];
    } else if(tag == 2) {
        _cellview.showCoords = [sender state];
    } else if(tag == 3) {
        _cellview.showDimensions = [sender state];
    } else if(tag == 4) {
        _cellview.hyperBright = [sender state];
    } else if(tag == 5) {
        _cellview.showCircles = [sender state];
    } else if(tag == 6) {
        _cellview.showAxes = [sender state];
        if([sender state]) [_cellview makeAxes];
    }
    
    [_cellview setNeedsDisplay:YES];

}

#pragma mark - cells geometries

- (void) changePlacementIndex: (int) ip {
    
    _iplacement = ip;
    [_placementStepper setIntValue:_iplacement];
    [_placementText setStringValue:[NSString stringWithFormat:@"Placement index = %2d",_iplacement]];

    [_cellview setPlacementIndex:_iplacement];
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];

}

- (void) setWaferSize:(double) f {
    
    ftof = f;
    side = ftof/sqrt(3.);
    waferPoints[0] = NSMakePoint(0.,-side);
    waferPoints[1] = NSMakePoint(+0.5*ftof,-0.5*side);
    waferPoints[2] = NSMakePoint(+0.5*ftof,+0.5*side);
    waferPoints[3] = NSMakePoint(0.,+side);
    waferPoints[4] = NSMakePoint(-0.5*ftof,+0.5*side);
    waferPoints[5] = NSMakePoint(-0.5*ftof,-0.5*side);
    
    waferBezier = [NSBezierPath bezierPath];
    [waferBezier moveToPoint:waferPoints[5]];
    for (int i=0; i<6; i++) { [waferBezier lineToPoint:waferPoints[i]];}
    
}

- (void) makeCells:(int) iwaf {
    
    double sidecount = 4.0 * (double)(iwaf+2);
    count = (int) sidecount+0.1;
    
    cside = ftof/(3.0*sidecount);
    _cellview.cside = cside;
    chf = cside * sqrt(3.) * 0.5;
  
    [_cellview setWaferSide:side cellCount:count];

    [gridCells removeAllObjects];
    for(int i=0;i<10;i++) {
        for(int j=0;j<10;j++) {
            cellMap[i][j]=0;
        }
    }

    int nx = 2*count;
    int ny = nx+2;
    double x = - ((double)nx)*0.75*cside - 0.5*cside;
    double y;
    ncell = 0;
    for (int ix=0; ix<(nx+2); ix++) {   // was +1 (22 Oct 2021)
        y = - ((double)(ny-1-ix%2))*chf;
        for (int iy=0; iy<ny; iy++) {
            int dummy[3];
            int * d = dummy;
            if(drawing) d = [_cellview cellDetIdAtPoint:NSMakePoint(x,y)];
            HXGCell * c = [HXGCell cellWithWafer:waferPoints side:cside at:NSMakePoint(x,y) ID:ncell andDetId:d];
            if(d[0]<10 && d[1]<10 && d[0]>-1 && d[1]>-1 && c.inside) {
                cellMap[d[0]][d[1]] = (int)gridCells.count;
           }
            [gridCells addObject:c];
            ncell++;
            y+=2.*chf;
        }
        x+=1.5*cside;
    }
}

- (void) drawCellsInWafer:(int) iwaf {

    [_densityControl setSelectedSegment:iwaf];
    
    drawing = YES;
    inclusionRadii = NO;
    _cellview.inclusionRadii = NO;
    [self hideStandard:NO];
    [self makeCells:iwaf];
    
    [_cellview drawCells:gridCells forWafer:waferBezier];
}

- (void) countCells:(int)iwaf {

    drawing = NO;
    [self makeCells:iwaf];
    
    int nbin = 500;
    double cellsInside[500];
    double dx = 0.1;
    double radius = 0.05;
    NSPoint cpoint = NSMakePoint(cside,0.);
    for (int i=0; i<nbin; i++) {
        cellsInside[i] = 0.;
        for (int j = 0; j<gridCells.count; j++) {
            HXGCell * c = [gridCells objectAtIndex:j];
            if(sqrt((cpoint.x-c.centre.x)*(cpoint.x-c.centre.x) + (cpoint.y-c.centre.y)*(cpoint.y-c.centre.y)) < radius) cellsInside[i] += 1.;
        }
        radius+=dx;
    }

    // --- show the plot
    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    NSPoint orig = NSMakePoint(200.,[[NSScreen mainScreen] frame].size.height-600.);
    NSString * tit = @"Cells inside radius";
    [theHist showWindowAt:orig withTitle:tit forPlotSize:NSMakeSize(380.,400.)];
    
    [theHist axisTitles:@"radius (mm)" And:@"Number of cells"];
    [theHist histFillColor:[NSColor whiteColor]];
    //[theHist setFixYmax:80.];
    
    [theHist drawHistogram:cellsInside Bins:nbin Xlow:0. Dx:dx Title:@"Cells inside radius"];
    int ncellWaf = 3 * count * count;
    NSString * label = [NSString stringWithFormat:@"%d cell wafer",ncellWaf];
    [theHist addLabel:label at: NSMakePoint(5.,cellsInside[nbin-5])];

#ifdef DEBUG
    [self logRadii];
#endif

}

- (void) logRadii {
    
    NSLog(@" R A D I I   F O R   C O N T A I N M E N T");
    NSLog(@" 7: %.2f mm",2.*chf);
    NSLog(@"13: %.2f mm",3.*cside);
    NSLog(@"19: %.2f mm",4.*chf);
    NSLog(@"31: %.2f mm",sqrt((4.5*cside)*(4.5*cside) + chf*chf));
    NSLog(@"37: %.2f mm",6.*chf);
    
}

- (void) drawInclusionRadii {
    
    drawing = YES;
    inclusionRadii = YES;
    _cellview.inclusionRadii=inclusionRadii;
    [self makeCells:-1]; // -1 gives large grid (for 48 cell wafer!)
 
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGCellSpecNotification object:self];
    
    _cellview.inclusionRadii = YES;
    [self hideStandard:YES];
        
    [self setCellIrColor];
    double radius[5];
    radius[0] = 2.*chf;
    radius[1] = 3.*cside;
    radius[2] = 4.*chf;
    radius[3] = sqrt((4.5*cside)*(4.5*cside) + chf*chf);
    radius[4] = 6.*chf;
    
    [_cellview setRadii:radius];
    
    
    [_cellview drawCells:gridCells forWafer:waferBezier];
    



}

- (void) setCellIrColor {
  
    int col1 = 403;
    int col2[6]  = {302,303,404,504,503,402};
    int col3[6]  = {202,304,505,604,502,301};
    int col4[6]  = {201,203,405,605,603,401};
    int col5[12] = {101,102,204,305,506,606,705,704,602,501,300,200};
    int col6[6]  = {100,103,406,706,703,400};

    
    HXGCell * c = [gridCells objectAtIndex:cellMap[col1/100][col1%100]];
    c.irColor = 1;
    for (int i=0; i<12; i++) {
        if(i < 6) {
            c = [gridCells objectAtIndex:cellMap[col2[i]/100][col2[i]%100]];
            c.irColor = 2;
            c = [gridCells objectAtIndex:cellMap[col3[i]/100][col3[i]%100]];
            c.irColor = 3;
            c = [gridCells objectAtIndex:cellMap[col4[i]/100][col4[i]%100]];
            c.irColor = 4;
            c = [gridCells objectAtIndex:cellMap[col6[i]/100][col6[i]%100]];
            c.irColor = 6;
        }
        c = [gridCells objectAtIndex:cellMap[col5[i]/100][col5[i]%100]];
        c.irColor = 5;
   }
}

@end
