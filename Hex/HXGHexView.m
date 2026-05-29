//
//  HXGHexView.m
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//
// NB: CMSSW = NO; // In fact, all code for CMSSW = YES, and all mention of CMSSW
// is redundant and could/should be stripped out...




#import "HXGHexView.h"

extern NSString * const EtaRingsUpdateNotification;
extern NSString * const PhiLinesUpdateNotification;

NSString * const HXGChosenCellNotification = @"HXGChosenCell";


const double casBoundaryWidth = 7.;
const double waferOutlineWidth = 2.87;
const double tileOutlineWidth = 2.;

const double xmax = 2150.0;
const double ymax = 2150.0;
const double xmarg = 50.0;
const double ymarg = 50.0;
const double rbeam = 20.0;

@implementation HXGHexView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        
        wafers = [NSMutableArray array];
        wholes = [NSMutableArray array];
        
        previousLayer = -1;
        _magnify = 1.0;
        rt3 = sqrt(3.0);
        _debugString = @"";
        
        self.canDrawConcurrently = YES;
        
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(newRings:)
                   name:EtaRingsUpdateNotification
                 object:nil];

        [nc addObserver:self
               selector:@selector(newLines:)
                   name:PhiLinesUpdateNotification
                 object:nil];

        [nc addObserver:self
               selector:@selector(newAbsorberDisplay:)
                   name:HXGNewAbsorberDisplayNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(updateDisplay:)
                   name:NSScrollViewDidLiveScrollNotification
                 object:nil];
 
        [nc addObserver:self
               selector:@selector(endScroll:)
                   name:NSScrollViewDidEndLiveScrollNotification
                 object:nil];

        [nc addObserver:self
               selector:@selector(newWaferHighlightColour:)
                   name:HXGNewColourNotification
                 object:nil];

        [nc addObserver:self
               selector:@selector(changeChosenCell:)
                   name:HXGChosenCellNotification
                 object:nil];
                

        theRings = [HXGEtaRingsControl sharedEtaRings];
        netarings = 0;
        theLines = [HXGPhiLinesControl sharedPhiLines];
        nphilines = 0;
        ispdf = NO;
        
        beam = [NSBezierPath bezierPath];
        [beam appendBezierPathWithArcWithCenter:NSZeroPoint radius:rbeam startAngle:0.0 endAngle:360.0];
        
        _showcoords = NO;
        tstart = 0; //[NSDate timeIntervalSinceReferenceDate];
        
        scintcolor = [[NSColor paleBlue] colorWithAlphaComponent:0.7];
        
        _showtestspot = NO;
        limitedSearch = NO;
        
        //[self setUpAxes];
        
        thirtyTransform = [NSAffineTransform transform];
        [thirtyTransform rotateByDegrees:30.];
        
        sixtyTransform = [NSAffineTransform transform];
        [sixtyTransform rotateByDegrees:60.];

        mirrorTransform = [NSAffineTransform transform];
        [mirrorTransform scaleXBy: -1. yBy: 1.];
    }
    
    theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];
    
    
        
    return self;
}

#pragma mark - setup methods

- (void) setColors:(NSArray *) hexcols {
    
    NSColor * col0 = [hexcols objectAtIndex:0];
    NSColor * col1 = [hexcols objectAtIndex:1];
    NSColor * col2 = [hexcols objectAtIndex:2];
    NSColor * col3 = [hexcols objectAtIndex:3];
    NSColor * col4 = [hexcols objectAtIndex:4];
    NSColor * col5 = [hexcols objectAtIndex:5];
    
    /*
     double rgba[4];
     [col0 getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
     NSLog(@"col0: %.3f %.3f %.3f %.3f",rgba[0],rgba[1],rgba[2],rgba[3]);
     [col1 getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
     NSLog(@"col1: %.3f %.3f %.3f %.3f",rgba[0],rgba[1],rgba[2],rgba[3]);
     [col2 getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
     NSLog(@"col2: %.3f %.3f %.3f %.3f",rgba[0],rgba[1],rgba[2],rgba[3]);
     [col3 getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
     NSLog(@"col3: %.3f %.3f %.3f %.3f",rgba[0],rgba[1],rgba[2],rgba[3]);
     */
    
    waferThicknessColors = [NSArray arrayWithObjects:col0,col1,col2,col3,nil];
    waferThicknessNames  = [NSArray arrayWithObjects:@"HD 120µ",@"HD 200µ",@"LD 200µ",@"LD 300µ",nil];
    casEdgeColor = col4;
    tileCasEdgeColor = col5;
    
    copper = [NSColor colorWithPatternImage: [NSImage imageNamed:@"copper-sheet.png"]];
    
    BOOL specialBackground = YES;
    if(specialBackground) {
        backgroundColor = [NSColor colorWithPatternImage: [NSImage imageNamed:@"reptilesBackground.png"]];
    } else backgroundColor = [NSColor windowBackgroundColor];
}

- (void) setWaferSize:(double) fsize {
    
    ftof = fsize + moduleSpacing; //---- Now in Hardware constants
    side = ftof/rt3;
    
    xlim = ftof*0.5 + 0.1;
    ylim = side + 0.1;
    
    hftof = ftof*0.5;
    sin60 = sin(M_PI/3.);
    cos60 = cos(M_PI/3.);
    hundred = 100.*hftof;
    
}

- (void) setParts:(int)f {
    
    flags = f;
    
    _numberWafers    = (flags&1)   != 0;
    _useDetId        = (flags&2)   != 0;
    _showRetracted   = (flags&4)   != 0;
    _rotateRotated   = (flags&8)   != 0;
    _showGrid        = (flags&16)  != 0;
    _showCassettes   = (flags&32)  != 0;
    _cassetteView    = (flags&64)  != 0;
    _markTypeOne     = (flags&128) != 0;
    _markTypeBar     = (flags&256) != 0;
    _numberCassettes = (flags&512) != 0;
    _showActiveWafer = (flags&32768) != 0;
    _showGridForPartials = (flags&262144) != 0;
    _showStructure   = (flags&524288) != 0;
        
}

- (void) setHexFrame:(NSRect)fRect {
    
    frameRect = fRect;
    
    if(_scrolling) {
        [_scrollView reflectScrolledClipView:_scrollView.contentView];
        [_scrollView setDrawsBackground:NO];
    }
    //NSLog(@"Setting:  %.1f, %.1f, %.1f, %.1f",fRect.origin.x,fRect.origin.y,fRect.size.width,fRect.size.height);
}

- (void) setPosition:(BOOL)show eta:(double)e phi:(double)p {
    
    _showtestspot = show;
    eta = e;
    phi = p;
    
    double phirad = phi*M_PI/180.;
    double theta = 2.*atan2(exp(-eta),1.);
    double radius = tan(theta)*_zLayer;
    xp = radius*cos(phirad);
    yp = radius*sin(phirad);
    double xl = xp;
    double yl = yp;
    
    if(_rotate30) {
        //if(!rotateRotated) {
        xl = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yl = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
        //}
    }
    
    _testpointPhysics = NSMakePoint(xp,yp);
    _testpointLayout= NSMakePoint(xl,yl);
    /*
     double phip = 180.0*atan2(yp,xp)/M_PI;
     double phil = 180.0*atan2(yl,xl)/M_PI;
     NSLog(@"setPosition: physics %.1f, layout %.1f",phip,phil);
     */
    
    [self setNeedsDisplay:YES];
}

- (void) setUpCassetteNumbering {
    
    float fsize;
    double radius,dang;
    if(_nLayer < 26) {
        radius = 1100.;
        dang = M_PI/3.;
        ncas = 6;
        fsize = 640.*_magnify;
    } else {        // ---- Improvements to be made here ----
        dang = M_PI/6.;
        ncas = 12;
        radius = 1250. + (double) (_nLayer-26) * 20.;
        fsize = 520.*_magnify;
        if(_nLayer > 32) {
            radius = (theMapFiles.rlast - 500.)*0.75;
        }
    }
    NSColor * labelColour = [[NSColor whiteColor] colorWithAlphaComponent:_casAlpha];
    NSMutableDictionary * casAttributes =  [NSMutableDictionary
                                            dictionaryWithObjectsAndKeys:
                                                [NSFont fontWithName:@"Helvetica" size:fsize],NSFontAttributeName,
                                            labelColour,NSForegroundColorAttributeName,
                                            [NSNumber numberWithDouble:3.],NSStrokeWidthAttributeName, nil];
    double angle = dang * 0.5;
    for(int i=0; i<ncas; i++) {
        NSPoint pnt = NSMakePoint(radius*cos(angle),radius*sin(angle));
        int iwaf = [self fastWaferFromPoint:NSMakePoint(800.*cos(angle),800.*sin(angle))];
        HXGWafer * wafer = [wafers objectAtIndex:iwaf];
        NSString * numstr = [NSString stringWithFormat:@"%d",wafer.cassette]; // !!!!
        casLabel[i] = [[NSMutableAttributedString alloc] initWithString:numstr attributes:casAttributes];
        casPoint[i] = NSMakePoint(pnt.x-casLabel[i].size.width*0.5,             pnt.y-casLabel[i].size.height*0.5);
        angle += dang;
        if(_rotate30 && _rotateRotated) {
            casUnRot[i] = [NSAffineTransform transform];
            casUnRot[i] = [casUnRot[i] init];
            [casUnRot[i] translateXBy:pnt.x yBy:pnt.y]; // Order of transforms seems weird...
            [casUnRot[i] rotateByDegrees:-30.];
            [casUnRot[i] translateXBy:-pnt.x yBy:-pnt.y];
            
        }
    }
}

- (void) setUpAxes {
    
    double axisLineWidth = 10.;
    //double axlen = (xmax-xmarg)*0.97;
    double axlen = maxradius*1.1;

    minusxaxis = [NSBezierPath bezierPath];
    [minusxaxis moveToPoint:NSMakePoint(0.,0.)];
    [minusxaxis lineToPoint:NSMakePoint(-axlen + 50., 0.)];
    [minusxaxis lineToPoint:NSMakePoint(-axlen + 50.,25.)];
    [minusxaxis lineToPoint:NSMakePoint(-axlen,0.)];
    [minusxaxis lineToPoint:NSMakePoint(-axlen + 50.,-25.)];
    [minusxaxis lineToPoint:NSMakePoint(-axlen + 50., 0.)];
    [minusxaxis setLineWidth:axisLineWidth];
    
    xmaxlabel = NSMakePoint(-axlen+20., -170.);
    
    plusxaxis = [NSBezierPath bezierPath];
    [plusxaxis moveToPoint:NSMakePoint(0.,0.)];
    [plusxaxis lineToPoint:NSMakePoint(axlen - 50., 0.)];
    [plusxaxis lineToPoint:NSMakePoint(axlen - 50.,25.)];
    [plusxaxis lineToPoint:NSMakePoint(axlen, 0.)];
    [plusxaxis lineToPoint:NSMakePoint(axlen - 50.,-25.)];
    [plusxaxis lineToPoint:NSMakePoint(axlen - 50., 0.)];
    [plusxaxis setLineWidth:axisLineWidth];
    
    xpaxlabel = NSMakePoint(axlen-110., -170.);
    
    uaxis = [NSBezierPath bezierPath];
    [uaxis moveToPoint:NSMakePoint(0.,0.)];
    [uaxis lineToPoint:NSMakePoint(axlen - 50., 0.)];
    [uaxis lineToPoint:NSMakePoint(axlen - 50.,25.)];
    [uaxis lineToPoint:NSMakePoint(axlen, 0.)];
    [uaxis lineToPoint:NSMakePoint(axlen - 50.,-25.)];
    [uaxis lineToPoint:NSMakePoint(axlen - 50., 0.)];
    [uaxis setLineWidth:axisLineWidth];
    
    uaxlabel = NSMakePoint(axlen-120., 30.);
    
    yaxis =  [NSBezierPath bezierPath];
    [yaxis moveToPoint:NSMakePoint(0.,0.)];
    [yaxis lineToPoint:NSMakePoint(0.,axlen - 50.)];
    [yaxis lineToPoint:NSMakePoint(25.,axlen - 50.)];
    [yaxis lineToPoint:NSMakePoint(0.,axlen)];
    [yaxis lineToPoint:NSMakePoint(-25.,axlen - 50.)];
    [yaxis lineToPoint:NSMakePoint(0.,axlen - 50.)];
    [yaxis setLineWidth:axisLineWidth];
    
    yaxlabel = NSMakePoint(50.,axlen-130.);
    
    double xv = -axlen*cos(M_PI/3.);
    double yv =  axlen*sin(M_PI/3.);
    double dxl = -50.*cos(M_PI/3.);
    double dyl =  50.*sin(M_PI/3.);
    double dxw =  25.*sin(M_PI/3.);
    double dyw =  25.*cos(M_PI/3.);
    vaxis =  [NSBezierPath bezierPath];
    [vaxis moveToPoint:NSMakePoint(0.,0.)];
    [vaxis lineToPoint:NSMakePoint(xv-dxl,yv-dyl)];
    [vaxis lineToPoint:NSMakePoint(xv-dxl-dxw,yv-dyl-dyw)];
    [vaxis lineToPoint:NSMakePoint(xv, yv)];
    [vaxis lineToPoint:NSMakePoint(xv-dxl+dxw,yv-dyl+dyw)];
    [vaxis lineToPoint:NSMakePoint(xv-dxl,yv-dyl)];
    [vaxis setLineWidth:axisLineWidth];
    
    vaxlabel = NSMakePoint(xv+80.,yv-120.);

}
#pragma mark - Notifications

- (void) newRings:(NSNotification *) note {
    
    etaRings = [theRings getEtaRings:&netarings];
    
    for (int j=1; j<netarings; j++) {      // Order by magnitude
        for (int i=1; i<netarings; i++) {
            if(etaRings[i-1] > etaRings[i]) {
                double temp = etaRings[i-1];
                etaRings[i-1] = etaRings[i];
                etaRings[i] = temp;
            }
        }
    }
    
    etaRingColor = theRings.ringColor;
    drawSpokes = theRings.drawPhiSpokes;
    [self setNeedsDisplay:YES];
}

- (void) newLines:(NSNotification *) note {
    
    phiLines = [theLines getPhiLines:&nphilines];
    
    for (int j=1; j<nphilines; j++) {      // Order by magnitude
        for (int i=1; i<nphilines; i++) {
            if(phiLines[i-1] > phiLines[i]) {
                double temp = phiLines[i-1];
                phiLines[i-1] = phiLines[i];
                phiLines[i] = temp;
            }
        }
    }
    
    [self setNeedsDisplay:YES];
    
}

- (void) updateDisplay:(NSNotification *) note {
    
    if(_showCellLabels && _scrollmag > labelsMagLimit) _suppressLabels = YES;

    [self setNeedsDisplay:YES];
}

- (void) endScroll:(NSNotification *) note {
    
    if(_suppressLabels && _scrollmag > labelsMagLimit) {
        _suppressLabels = NO;
        [self setNeedsDisplay:YES];
    }

}


- (void) newAbsorberDisplay:(NSNotification *) note {
    
    long absorberFlags = [[[note userInfo] objectForKey:@"controlFlags"] integerValue];
    
    // ----------- First the display controls
    showPbAbsorbers = (absorberFlags & 1) != 0;
    if(showPbAbsorbers && !thePbAbsorbers) thePbAbsorbers = [HXGPbAbsorbers sharedPbAbsorbers];
    
    showCuPlates   = (absorberFlags & 2) != 0;
    if(showCuPlates) {
        if(!theCuPlates) theCuPlates = [HXGCuCoolingPlates sharedCuCoolingPlates];
        alphaOdd = 0.45;
        if((absorberFlags & (2 << 17)) != 0) alphaOdd += 0.15;
        if((absorberFlags & (2 << 18)) != 0) alphaOdd += 0.3;
    }
    
    showCEHspacers = (absorberFlags & 4) != 0;
    if(showCEHspacers && !theSpacers) theSpacers = [HXGCEHspacers sharedCEHspacers];
    
    showZbars = (absorberFlags & 8) != 0;
    
    // ----------- Then the list buttons
    if((absorberFlags & (2 << 20)) != 0) {
        if(!thePbAbsorbers) thePbAbsorbers = [HXGPbAbsorbers sharedPbAbsorbers];
        [thePbAbsorbers listPolygons];
        return;
    } else if((absorberFlags & (2 << 21)) != 0) {
        if(!theCuPlates) theCuPlates = [HXGCuCoolingPlates sharedCuCoolingPlates];
        [theCuPlates listPolygons];
        return;
    }
    
    [self setNeedsDisplay:YES];
}

- (void) newWaferHighlightColour:(NSNotification *) note {
    
    int icol = [[[note userInfo] objectForKey:@"colPoint"] intValue];
    if(icol != 0) return;
    
    _waferHighlightColor = [[note userInfo] objectForKey:@"newColor"];
    [self setNeedsDisplay:YES];
    
}

- (void) changeChosenCell:(NSNotification *) note {

    showChosenCell = [[[note userInfo] objectForKey:@"showCell"] boolValue];
    if(showChosenCell) {
        cellCentroid.x = [[[note userInfo] objectForKey:@"cellCentroidX"] doubleValue];
        cellCentroid.y = [[[note userInfo] objectForKey:@"cellCentroidY"] doubleValue];
    }
    
    showNeighbours = [[[note userInfo] objectForKey:@"showNeighbours"] boolValue];
    if(showNeighbours) {
        waferList = [[note userInfo] objectForKey:@"waferList"];
        cellListList = [[note userInfo] objectForKey:@"cellListList"];
    }

    [self setNeedsDisplay:YES];
    
}


#pragma mark - doing the geometry

- (void) makeGridOnCentre {
    
    centreoncentre = YES;
    
    double dx = ftof;
    double dy = 1.5 * side;
    int nx = (xmax - xmarg)/dx + 1; // nx is *half* the number in a full +/- scale
    int ny = (ymax - ymarg)/dy;
    
    double y = - (double) ny * dy;
    
    _nhex = 0;
    [wafers removeAllObjects];
    [wholes removeAllObjects];
    
    for (int iy = -ny; iy <= ny; iy++)
    {
        double x = - (double) nx * dx;
        int mx = 2*nx+1;
        if(abs(iy)%2)
        {
            mx--;
            x += ftof/2.0;
        }
        for (int ix = 0; ix < mx; ix++)
        {
            int * did = [self waferDetIdAtPoint:NSMakePoint(x,y)];
            HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:_nhex andDetId:did];
            [wafers addObject:w];
            [wholes addObject:[w waferBezier]];
            _nhex++;
            x += dx;
        }
        y += dy;
    }
}

- (void) makeGridOnVertex {
    
    centreoncentre = NO;
    
    double dx = ftof;
    double dy = 1.5 * side;
    int nx = (xmax - xmarg)/dx; // nx is *half* the number in a full +/- scale
    int ny = (ymax - ymarg)/dy;
    
    double y = - (double) ny * dy - side/2.0;
    if(_mercedes) y -= side * 0.5;
    
    _nhex = 0;
    [wafers removeAllObjects];
    [wholes removeAllObjects];
    
    
    for (int iy = -ny; iy <= ny+1; iy++) {
        double x = - (double) nx * dx - ftof/2.0;
        int mx = 2*nx+1;
        BOOL shortrow = abs(iy)%2;
        if(_mercedes) shortrow = !shortrow;
        if(shortrow) {
            mx--;
            x += ftof/2.0;
        }
        for (int ix = 0; ix < mx+1; ix++) {
            int * did = [self waferDetIdAtPoint:NSMakePoint(x,y)];
            HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:_nhex andDetId:did];
            [wafers addObject:w];
            [wholes addObject:[w waferBezier]];
            _nhex++;
            x += dx;
        }
        y += dy;
    }
}

- (void) layoutFromFiles {

    for (int i = 0; i<_nhex; i++) {
        HXGWafer * w = [wafers objectAtIndex:i];
        w.whole = NO;
        w.part = NO;
    }
    
    if(waferThickness) free(waferThickness);
    waferThickness = calloc(_nhex, sizeof(int));

    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    //[theMapFiles makeTileBeziersForLayer:_nLayer];
    [theMapFiles makeTileBezierForLayer:_nLayer Retracted:_showRetracted];
    //if(_oneCassette != 0) [theMapFiles cassetteTileBeziersForLayer:_nLayer andCassette:_oneCassette];
    
    NSArray * layerString = [theMapFiles getMapStringsForLayer:_nLayer];
    
    int ltest;
    int tnum;
    double xw, yw;
    int ncas;
    int jrot;
    int idd[2];
    //char thick[100];
    NSString * thickStr;
    //int fudge[12] = {10,7,7,8,8,8,10,7,7,10,10,8};
    //                0 1 2 3 4 5  6 7 8  9 10 11
    for(int i=0; i<11; i++) {partialCount[i]=0;}
    thickCount[0]=0; thickCount[1]=0; thickCount[2]=0;
    
    for(int i=0; i<layerString.count; i++) {
        int thickflag=-1;
        NSString * lS = layerString[i];
        lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
        lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
        NSArray * columns = [lS componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        if(columns.count < 8) NSLog(@"flat file problem!!!");
        ltest = [columns[0] intValue];
        tnum = [columns[1] intValue];
        thickStr = columns[2]; // [columns[2] substringToIndex:1];
        xw = [columns[3] doubleValue];
        yw = [columns[4] doubleValue];
        jrot = [columns[5] doubleValue];
        idd[0] = [columns[6] doubleValue];
        idd[1] = [columns[7] doubleValue];
        if(columns.count > 8) ncas = [columns[8] doubleValue];

        /*
        const char * l = [layerString[i] UTF8String];
        int iret = sscanf(l,"%d %d %s %lf %lf %d %d %d %d",&ltest,&tnum,thick,&xw,&yw,&jrot,&idd[0],&idd[1],&ncas);
        if(iret < 8) NSLog(@"flat file problem!!!");
        NSString * thickStr = [NSString stringWithUTF8String:thick];
         */
        int il = (int) thickStr.length;
        BOOL LD = [[thickStr substringToIndex:1] isEqualToString: @"l"];
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"300"]) thickflag = 3;
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"200"]) {
            if(LD) thickflag = 2;
            else thickflag = 1;
        }
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"120"]) thickflag = 0;
 
        int symcount = 1; // using 360º files
        maxradius = 0.;
        for(int j=0; j<symcount; j++) {
            int iw = [self waferIndexFromDetId:idd];
            HXGWafer * w = [wafers objectAtIndex:iw];
            
            // --------- Here is where we optionally do RETRACTION of Si (using the v19 centres) ----------
            if(_showRetracted) [w setRetractedX:xw andY:yw];
            //else [w revertToGrid];

            
            if(w.rc > maxradius) maxradius = w.rc;
            w.LD = LD;
            w.type = tnum;
            w.thickflag = thickflag;
            w.cassette = ncas;
            w.channelZero = (jrot + 2*j)%6;
            w.fileLine = theMapFiles.firstLine + i;
            int index = -1;
            if(!LD) index = 5;
            w.seenFromBack = ([theMapFiles getTessFlagForLayer:_nLayer] == 1);
            /* ------------ Ripe for deletion --------------------
            BOOL pedroFileFudge = NO;
            if(pedroFileFudge && w.seenFromBack) {
                w.channelZero = (fudge[tnum+index+1] - w.channelZero)%6;
            }
            //if(w.seenFromBack) w.channelZero = (6 - w.channelZero)%6;
            ----------------------------------------------------------- */
            if(tnum == 0) {
                w.whole = YES;
                thickCount[thickflag++]++;
            } else {
                w.part = YES;
                partialCount[tnum + index]++;
            }
            waferThickness[iw] = thickflag;
            if(_showActiveWafer) [w constructActiveBezierMirrored:NO];
            else [w constructWaferBezierMirrored:NO];
        }
    }
    
    [self makeCassetteBezier];
    
    if(_showaxes)[self setUpAxes];

}

- (void) makeCassetteBezier {
    
    /*--------------------------------------------
      Notes on the logic in Notes app
      --------------------------------------------*/
//    cassetteBezier = [NSBezierPath bezierPath];
 
    for(int i = 0; i<12; i++) { nseg[i] = 0;}
    int nmod = 6;
    if(_nLayer > 25) nmod = 12;
    
    for (int i = 0; i<_nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole || wafer.part) {
            int * idd = wafer.detId;
            int jdd[2];
            jdd[0] = idd[0]+1;
            jdd[1] = idd[1];
            int iw = [self waferIndexFromDetId:jdd];
            HXGWafer * nextw[3];
            nextw[0] = [wafers objectAtIndex:iw];
            jdd[1]++;
            iw = [self waferIndexFromDetId:jdd];
            nextw[1] = [wafers objectAtIndex:iw];
            jdd[0] = idd[0];
            jdd[1] = idd[1]+1;
            iw = [self waferIndexFromDetId:jdd];
            nextw[2] = [wafers objectAtIndex:iw];
            for (int ln=0; ln<3; ln++) {
                int ic = wafer.cassette;
                if(ic != nextw[ln].cassette && [self lineStartingAt:ln+1 Between:wafer And:nextw[ln]]) {
//                    [cassetteBezier moveToPoint:lineStart];
//                    [cassetteBezier lineToPoint:lineEnd];
                    if(nextw[ln].cassette < ic%nmod) ic = nextw[ln].cassette;
                    [self storePointsForCassette:ic-1];
                }
            }
        }
    }
//    [cassetteBezier setLineCapStyle:NSRoundLineCapStyle];
//    [cassetteBezier setLineWidth:8.];
    
    [self makeBoundaryBeziers];
}

- (void) makeBoundaryBeziers {
    
    for (int i=0; i<12; i++) {
        if(nseg[i] > 0) {
            //NSLog(@"%d segments for cassette %d",nseg[i],i);
            int ip[50];
            
            for(int j=0; j<nseg[i]; j++) { ip[j] = j;}
            
            for (int irep = 0; irep<2; irep++) {
                for(int j=0; j<nseg[i]; j++) {
                    double rj = startSeg[ip[j]][i].x*startSeg[ip[j]][i].x + startSeg[ip[j]][i].y*startSeg[ip[j]][i].y;
                    for(int k=j+1; k<nseg[i]; k++) {
                        double rk = startSeg[ip[k]][i].x*startSeg[ip[k]][i].x + startSeg[ip[k]][i].y*startSeg[ip[k]][i].y;
                        if(rk+0.1 < rj) {
                            int ipk = ip[k];
                            ip[k] = ip[j];
                            ip[j] = ipk;
                        }
                    }
                }
            }
            cassetteBoundaryBezier[i] = [NSBezierPath bezierPath];
            [cassetteBoundaryBezier[i] moveToPoint:startSeg[ip[0]][i]];
            for(int j=0; j<nseg[i]; j++) {
                [cassetteBoundaryBezier[i] lineToPoint:endSeg[ip[j]][i]];
            }
            [cassetteBoundaryBezier[i] setLineCapStyle:NSLineCapStyleRound];
            [cassetteBoundaryBezier[i] setLineWidth:casBoundaryWidth];
        }
    }
}
- (void) storePointsForCassette: (int) ic {
   
    if(nseg[ic] > 29) return;
    
    if(lineStart.x*lineStart.x + lineStart.y*lineStart.y < lineEnd.x*lineEnd.x + lineEnd.y*lineEnd.y) {
        startSeg[nseg[ic]][ic] = lineStart;
        endSeg[nseg[ic]][ic] = lineEnd;
    } else {
        startSeg[nseg[ic]][ic] = lineEnd;
        endSeg[nseg[ic]][ic] = lineStart;
    }
    nseg[ic]++;
}

- (BOOL) lineStartingAt: (int) nin Between:(HXGWafer *) w1 And:(HXGWafer *) w2 {
   
    if((!w1.part && !w1.whole) || (!w2.part && !w2.whole)) return NO;
    
    int n = nin;
    if(w1.whole && w2.whole) {
        lineStart = w1.corner[n];
        lineEnd = w1.corner[n+1];
        return YES;
    }

    int test[11][6] = {
        1,1,0,0,1,1,   // LD 1
        0,1,1,1,1,0,   // LD 2
        1,1,1,2,0,2,   // LD 3
        2,0,2,1,1,1,   // LD 4
        1,1,1,1,0,1,   // LD 5
        0,0,0,1,1,1,   // LD 6
        1,2,0,0,2,1,   // HD 1
        2,1,1,1,1,2,   // HD 2
        1,1,1,2,0,2,   // HD 3 (index = 8)
        2,0,2,1,1,1,   // HD 4 (index = 9)
        1,1,1,2,0,2    // HD 5
    };
    

    int mm1[3] = {5,0,1}; // set up m1 and m2 to correspond to corners in w2
    int mm2[3] = {4,5,0}; // matching n and n+1 in w1
    
    int cz1 = w1.channelZero;
    int cz2 = w2.channelZero;
    int m1 = mm1[n-1];
    int m2 = mm2[n-1];

    BOOL fixUpBoj = NO;
    
    if(w1.seenFromBack) {
        int fudge[12] = {10,7,7,8,8,8,10,7,7,10,12,8}; // was 7 in 8 place
        //                0 1 2 3 4 5  6 7 8  9 10 11     & 10 in 9 place
        int i1 = w1.type;
        if(!w1.LD) i1+=6;
        
        fixUpBoj = (i1 == 10); // !!!!!!!!!!!!!!
        
        int i2 = w2.type;
        if(!w2.LD) i2+=6;
        cz1 = (fudge[i1] - cz1)%6;
        cz2 = (fudge[i2] - cz2)%6;
    }

    int p1 = 6 - cz1; //w1.channelZero;
    int p2 = 6 - cz2; //w2.channelZero;
    if(w1.whole) {             // i.e. w2 must be partial
        int index = w2.type-1;
        if(!w2.LD) index +=6;
        if(test[index][(p2+m1)%6] == 0) return NO; // bad start point
        if(test[index][(p2+m2)%6] == 0) return NO; // bad end point
        double frac = 0.72; //--------------- !!!!!
        if(w2.LD) frac = 0.5;
        if(test[index][(p2+m1)%6] == 2) {
            if(index == 6 || index == 10) frac = 1. - frac;
            double x = frac*w1.corner[n].x + (1.-frac)*w1.corner[n+1].x;
            double y = frac*w1.corner[n].y + (1.-frac)*w1.corner[n+1].y;
            lineStart = NSMakePoint(x,y);
            lineEnd = w1.corner[n+1];
            return YES;
        }
        if(test[index][(p2+m2)%6] == 2) {
            if(index == 6 || index == 10) frac = 1. - frac;
            double x = frac*w1.corner[n].x + (1.-frac)*w1.corner[n+1].x;
            double y = frac*w1.corner[n].y + (1.-frac)*w1.corner[n+1].y;
            lineStart = w1.corner[n];
            lineEnd = NSMakePoint(x,y);
            return YES;
        }
        lineStart = w1.corner[n];  // Both must be test=1
        lineEnd = w1.corner[n+1];
        return YES;
    }
    if(w2.whole) {             // i.e. w1 must be partial
        int index = w1.type-1;
        if(!w1.LD) index +=6;
        if(test[index][(p1+n)%6] == 0) return NO; // bad start point
        if(test[index][(p1+n+1)%6] == 0) return NO; // bad end point
        double frac = 0.28;
        if(w1.LD) frac = 0.5;
        if(test[index][(p1+n)%6] == 2) {
            if(index == 6 || index == 10) frac = 1. - frac;
            double x = frac*w2.corner[m1].x + (1.-frac)*w2.corner[m2].x;
            double y = frac*w2.corner[m1].y + (1.-frac)*w2.corner[m2].y;
            lineStart = NSMakePoint(x,y);
            lineEnd = w2.corner[m2];
            return YES;
        }
/* ----- Fixes a bug to remove this test and draw the full side (15/08/23)
         Clearly something wrong with the test
         Luckily the case it would be needed for seems not to exist
         Full logically correct code would require understanding exactly how (p2+m2)%6
         works...
 
        if(test[index][(p2+m2)%6] == 2) {
            if(index == 6 || index == 10) frac = 1. - frac;
            double x = frac*w2.corner[m1].x + (1.-frac)*w2.corner[m2].x;
            double y = frac*w2.corner[m1].y + (1.-frac)*w2.corner[m2].y;
            lineStart = NSMakePoint(x,y);
            lineEnd = w2.corner[m2];
            return YES;
        }
 */
        lineStart = w1.corner[n];  // Both must be test=1
        lineEnd = w1.corner[n+1];
        return YES;
    }
    //----- Now the only possibility is that both w1 and w2 are partial
    int index = w1.type-1;
    if(!w1.LD) index +=6;
    int jndex = w2.type-1;
    if(!w2.LD) jndex +=6;
    if(test[index][(p1+n)%6] == 0) return NO; // bad start point
    if(test[index][(p1+n+1)%6] == 0) return NO; // bad end point
    if(test[jndex][(p2+m1)%6] == 0) return NO; // bad start point
    if(test[jndex][(p2+m2)%6] == 0) return NO; // bad end point
    
    lineStart = w1.corner[n];
    lineEnd = w1.corner[n+1];
    
    double frac = 0.28;
    if(w1.LD) frac = 0.5;
    
    if(test[index][(p1+n)%6] == 2) {
        if(index == 6 || index == 10) frac = 1. - frac;
        double x = frac*w1.corner[n].x + (1.-frac)*w1.corner[n+1].x;
        double y = frac*w1.corner[n].y + (1.-frac)*w1.corner[n+1].y;
        lineStart = NSMakePoint(x,y);
    }

    if(test[index][(p1+n+1)%6] == 2 || fixUpBoj) {
        if(index == 6 || index == 10) frac = 1. - frac;
        double x = frac*w1.corner[n+1].x + (1.-frac)*w1.corner[n].x;
        double y = frac*w1.corner[n+1].y + (1.-frac)*w1.corner[n].y;
        lineEnd = NSMakePoint(x,y);
    }

    frac = 0.72; // !!!!
    if(w2.LD) frac = 0.5;
    if(test[index][(p2+m1)%6] == 2) {
        if(index == 6 || index == 10) frac = 1. - frac;
        double x = frac*w1.corner[n].x + (1.-frac)*w1.corner[n+1].x;
        double y = frac*w1.corner[n].y + (1.-frac)*w1.corner[n+1].y;
        lineStart = NSMakePoint(x,y);
    }

    if(test[index][(p2+m2)%6] == 2 && !fixUpBoj) {
        if(index == 6 || index == 10) frac = 1. - frac;
        double x = frac*w1.corner[n+1].x + (1.-frac)*w1.corner[n].x;
        double y = frac*w1.corner[n+1].y + (1.-frac)*w1.corner[n].y;
        lineEnd = NSMakePoint(x,y);
    }
     
    return YES;
}

- (void) drawHexGrid {

    [self setFrame:frameRect];

    NSRect bounds;

    if(_scrolling) bounds = NSMakeRect(-1.25*xmax,-1.25*ymax,2.5*xmax,2.5*ymax);
    else bounds = NSMakeRect(-_magnify*xmax,-_magnify*ymax,2.0*_magnify*xmax,2.0*_magnify*ymax);
    
    [self setBounds:bounds];

}

- (void) makeRings {
    
    for (int i=0; i<netarings; i++) {
        double t = exp(-etaRings[i]);
        double the = 2.0*atan2(t,1.);
        double rrr = _zLayer*tan(the);
        if(i%2 == 0) yeta[i] = -rrr; // + (rrr - sqrt(rrr*rrr - 10000.));
        else yeta[i] = rrr; // - (rrr - sqrt(rrr*rrr - 10000.));
        etaRingBezier[i] = [NSBezierPath bezierPath];
        [etaRingBezier[i] appendBezierPathWithArcWithCenter:NSZeroPoint radius:rrr startAngle:0.0 endAngle:360.0];
        [etaRingBezier[i] setLineWidth:4.0];
    }
}

- (void) zoomOnTestPoint:(BOOL) z {
    
    _zoom = z;
    zoomTransform = [NSAffineTransform transform];
    inverseZoomTransform = [NSAffineTransform transform];
    if(_zoom) {
        double magz = 4.;
        [zoomTransform translateXBy:-magz*testpoint.x yBy:-magz*testpoint.y];
        [zoomTransform scaleBy:magz];
        inverseZoomTransform = [inverseZoomTransform initWithTransform:zoomTransform];
        [inverseZoomTransform invert];
    }
    
    [self setNeedsDisplay:YES];
    
}

- (NSAffineTransform *) getZoomAffineTransform {
    
    return zoomTransform;
}

- (void) centreHexViewAt:(NSPoint) centre {

    if(!_scrolling) return;
    
    NSRect ff = self.frame;
    NSRect vis = _scrollView.documentVisibleRect;
    NSPoint newcentre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
    double dx = (newcentre.x - centre.x)*self.frame.size.width/self.bounds.size.width;
    double dy = (newcentre.y - centre.y)*self.frame.size.height/self.bounds.size.height;
    ff.origin.x += dx;
    ff.origin.y += dy;
    [self setHexFrame:ff];
    [self drawHexGrid];

}

- (void) shiftCentreBy:(NSPoint) shift {
    
    // shift is vector in view coordinate system
    NSRect ff = self.frame;
    ff.origin.x += shift.x*self.frame.size.width/self.bounds.size.width;
    ff.origin.y += shift.y*self.frame.size.height/self.bounds.size.height;
    //[self setHexFrame:ff];
    //[self drawHexGrid];
    self.frame = ff;
    [self setNeedsDisplay:YES];

}

- (void) testRetractions {
  
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal makeWindowBig];
    [theTerminal clearString];
    theTerminal.suggestedName = @"RetractionVectorCheck";

    
    double tolerance = 0.02;
    [theTerminal displayString:[NSString stringWithFormat:@"CHECK RETRACTION VECTORS IN LAYER %d (tolerance = %.0fμm):\n\n",_nLayer+1,tolerance*1000.]];

    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    NSArray * layerString = [theMapFiles getMapStringsForLayer:_nLayer];
    int first = [theMapFiles getFirstLineNumberForLayer:_nLayer] + 1;

    int nbad = 0;
    for(int i=0; i<layerString.count; i++) {
        NSString * lS = layerString[i];
        lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
        lS = [lS stringByReplacingOccurrencesOfString: @"  "withString:@" "];
        NSArray * columns = [lS componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        if(columns.count < 8) NSLog(@"flat file problem!!!");
        double xw = [columns[3] doubleValue];
        double yw = [columns[4] doubleValue];
        int iu = [columns[6] doubleValue];
        int iv = [columns[7] doubleValue];

        NSPoint retracted = [self retractedPointForU: (int) iu andV: (int) iv];
        if(fabs(xw - retracted.x) > tolerance || fabs(yw - retracted.y) > tolerance) {
            [theTerminal displayString:[NSString stringWithFormat:@"Line %d (%d,%d) Retracted: (%.2f,%.2f); File has: (%.2f,%.2f)\n",i+first,iu,iv,retracted.x,retracted.y,xw,yw]];
            nbad++;
        }
    }
    [theTerminal displayString:[NSString stringWithFormat:@"------> Bad values in layer %d = %d\n\n\n",_nLayer+1,nbad]];

}

#pragma mark - accessing the information

- (int *) getThickCount;
{
    
    thickCount[0]=0; thickCount[1]=0;thickCount[2]=0;
    for(int i=0;i<_nhex;i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole) thickCount[wafer.thickflag]++;
    }

    return thickCount;
}

- (NSString *) waferSummary {
    
    NSString * summary = @"";
    //summary = [NSString stringWithFormat:@", flat-to-flat = %.2f mm\n",ftof];
    summary = [summary stringByAppendingString:[self partialWaferSummary]];
    
    return summary;
}

- (void) zeroPartialTotals {
    for(int i = 0; i < 11; i++){ partialTotals[i]=0;}
}

- (int *) getPartialTotals {
    return partialTotals;
}

- (NSString *) partialWaferSummary {
    
    NSString * summary = @"Partials: ";
    NSString * tFlag = @"L";
    int hoffset = 1;
    for(int i=0; i<11; i++) {
        partialTotals[i]+=partialCount[i];
        if(i > 5) {tFlag = @"H"; hoffset = -5;}
        if(partialCount[i]>0) {
            summary = [summary stringByAppendingFormat:@"%@%d:%d; ",tFlag,i+hoffset,partialCount[i]];
        }
    }
        return summary;
}

/*
- (NSString *) getFileStrings {
    
    NSString * fileStrings = [NSString stringWithString:theMapFiles.waferFlatFile];
    fileStrings = [fileStrings stringByAppendingString:@"\n-  "];
    fileStrings = [fileStrings stringByAppendingString:theMapFiles.tileFlatFile];
    
    return fileStrings;
}
*/

- (void) countCheck {
   
    int nfull = 0;
    int npart = 0;
    for (int i = 0; i<_nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole) nfull++;
        if(wafer.part) npart++;
    }
    _nwhole += nfull;
    _npartial += npart;

    if(_nLayer == 46) NSLog(@"TOTALS: nfull = %d, npart = %d, ntot = %d",_nwhole,_npartial,_nwhole+_npartial);

}

- (void) logCentre:(NSString *) string {
  
#ifdef DEBUG

    if(!_scrolling) return;
    
    NSRect vis = _scrollView.documentVisibleRect;
    NSPoint centre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
    NSLog(@"%@: centre at (%.1f, %.1f)",string,centre.x,centre.y);
    
#endif
}

- (NSImage *) imageOfWaferTypeKey {
    
    NSSize iSize = NSMakeSize(300.,320.);
    //NSRect iRect = NSMakeRect(0.,0.,300.,320.);
    double ydelta = 0.20*iSize.height;
    double ffsize = 35.;

    NSImage * waferTypeKey = [[NSImage alloc] initWithSize:iSize];
    [waferTypeKey lockFocus];
    
    fontName = @"Helvetica";
    font = [NSFont fontWithName:fontName size:ffsize];
    keyAttributes =  [NSMutableDictionary
                       dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:ffsize],NSFontAttributeName,
                       [NSColor blackColor],NSForegroundColorAttributeName, nil];
    [keyAttributes setObject:font
                       forKey:NSFontAttributeName];

    double yoff = 20.;
    double width;
    for (int i=0; i<4; i++) {
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:waferThicknessNames[i]];
        [str addAttributes:keyAttributes range:NSMakeRange(0,str.length)];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:ffsize]
                    range:NSMakeRange(6,1)];
        if(i == 0) width = str.size.width;
        NSRect bRect = NSMakeRect(30.,yoff,width,str.size.height);
        NSColor * col = waferThicknessColors[i];
        [col set];
        bRect.origin.x -= 16.; bRect.origin.y -= 0.;
        bRect.size.width += 32.; bRect.size.height += 8.;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:4.0];
        [NSBezierPath strokeRect:bRect];
        bRect.origin.x += 16.;
        bRect.origin.y -= 2.;
        [str drawInRect:bRect];
        yoff += ydelta;
    }
    
    [waferTypeKey unlockFocus];

    return waferTypeKey;
}

#pragma mark - wafer manipulations
- (HXGWafer *) getWaferFromDetIdU: (int) wiu andV: (int) wiv {
    
    int wDetId[2];
    wDetId[0] = wiu; wDetId[1] = wiv;
    return [wafers objectAtIndex:[self waferIndexFromDetId:wDetId]];

}
- (HXGWafer *) getWafer:(int) iw {

    return [wafers objectAtIndex:iw];
    
}

- (void) refreshTestPoint {
    
    if(!_rotate30) _testpointLayout = _testpointPhysics;
    else {
        _testpointLayout.x = _testpointPhysics.x*cos(-M_PI/6.) - _testpointPhysics.y*sin(-M_PI/6.);
        _testpointLayout.y = _testpointPhysics.x*sin(-M_PI/6.) + _testpointPhysics.y*cos(-M_PI/6.);
    }
    
    /*
    double phip = 180.0*atan2(_testpointPhysics.y,_testpointPhysics.x)/M_PI;
    double phil = 180.0*atan2(_testpointLayout.y,_testpointLayout.x)/M_PI;
    NSLog(@"refreshTestPoint: physics %.1f, layout %.1f",phip,phil);
    */
}

- (int) stateAtPoint: (NSPoint) pnt {
    
    
    /* -------------------------------------------
        Revised June 2025
        Needs to be fed a point UNCORRECTED for retraction
        (so that the decision rectangles for partials work OK)
     
        istate: 0 - no sensor
                1 - whole
                2 - partial
                3 - tile in complete ring
       ------------------------------------------- */
    _dbuggery = YES;
    _debugString =  @"";
    
    NSPoint retCorPnt = pnt;
    if(_showRetracted) retCorPnt = [self correctPointForRetraction:pnt];
    
    NSPoint point = retCorPnt;
    int istate = [theMapFiles tilesContainPoint:point];

    if(istate < 99) return istate;
    
    int iw = [self fastWaferFromPoint:retCorPnt];
    if(iw >= wafers.count) {
        return 0;
    }
    
    if(_dbuggery) _debugString = [NSString stringWithFormat:@"pnt = (%.1f,%.1f), iw = %d\n",pnt.x,pnt.y,iw];
   
    HXGWafer * wafer = [wafers objectAtIndex:iw];
    
    if(_dbuggery) _debugString = [_debugString stringByAppendingFormat:@"wafer id = %d:%d, whole = %d, part = %d\n",wafer.detId[0],wafer.detId[1],wafer.whole,wafer.part];
    

    if(wafer.whole) {
        istate = 1;
    } else if(wafer.part) {
        point = pnt;
        NSRect dRect = wafer.decisionRect;
        //NSLog(@"Decision rect: %.1f %.1f %.1f %.1f",dRect.origin.x,dRect.origin.y,dRect.size.width,dRect.size.height);
        double divisor = dRect.size.width;
        if(fabs(divisor) < 1.E-10) divisor = 1.E-10;
        double m = dRect.size.height/divisor;
        double c = dRect.origin.y - dRect.origin.x*m;
        double condition = c*(m*point.x + c - point.y);
        double r = sqrt(point.x*point.x + point.y*point.y);
        if(_dbuggery) _debugString = [_debugString stringByAppendingFormat:@"condition = %.1g, r = %.1g\n",condition,r];

        if((condition > 0. && (r > 700.)) || (condition < 0. && (r<700.))) {
            istate = 2;
            if(_dbuggery) _debugString = [_debugString stringByAppendingFormat:@"\nstate = %d",istate];

        } else istate = 0;
    } else istate = 0;
    
    return istate;

}

- (void) waferClicking {
    
    int iwaf = [self fastWaferFromPoint:NSMakePoint(xp,yp)];
    HXGWafer * wafer = [wafers objectAtIndex:iwaf];
    wafer.marked = !wafer.marked;
    [self setNeedsDisplay:YES];

}

- (int) fastWaferFromPoint:(NSPoint) pnt {
 
    NSPoint point = pnt;

    double u = point.x + hundred;
    double v = point.x*cos60 + point.y*sin60 + hundred;
    double w = point.y*sin60 - point.x*cos60 + hundred;

    iu = (int) (u/hftof) - 24 - 50;
    iv = (int) (v/hftof) - 50;
    iw = (int) (w/hftof) - 50;

    int iwaf;
    if(centreoncentre) {
        irow = (iv + iw - 2)/3;
        iwaf = (iu + (irow+1)%2)/2 + irow*27 - irow/2 - 9 - 468;
    } else if(_nLayer%2) {
        irow = (iv + iw)/3;
        iwaf = (iu + (irow+1)%2)/2 + irow*26 - irow/2 + 40 - 500;
    } else {
        irow = (iv + iw - 1)/3;
        iwaf = (iu+1 + (irow+1)%2)/2 + irow*26 - irow/2 + 40 - 500;
    }
    
    
    return iwaf;
}

- (int *) waferDetIdAtPoint:(NSPoint) pnt {

    /* ------------------------------------------------
     pnt is a global x, y position
     hftof is half the flat-to-flat wafer hexagon size
     hundred = 100. * hftof (used to avoid problems with integer
                          casting of negative numbers)
     --------------------------------------------------*/
    
    NSPoint point = pnt;

    double xx = point.x;
    double yy = point.y;
    if(!centreoncentre) {
        //xx = - point.y;
        //yy = point.x;
        xx = -xx;
    }
    double u = xx + hundred;
    double v = xx*cos60 + yy*sin60 + hundred;
    double w = yy*sin60 - xx*cos60 + hundred;
    
    iu = (int) (u/hftof) - 100;
    iv = (int) (v/hftof) - 100;
    iw = (int) (w/hftof) - 100;
    
    //detId[1] = (iv + iw + 32)/3 - 10;           // Sunanda's v index (was 32)
    if(centreoncentre) {
        //detId[1] = (iv + iw + 32)/3 - 10;           // Sunanda's v index
        detId[1] = (iv + iw + 62)/3 - 20;;           // Sunanda's v index NEW
        detId[0] = 50 - ((-iu - detId[1] + 100)/2);  // Sunanda's u index
    } else {
        if(_nLayer%2) {
            detId[1] = (iv + iw + 61)/3 - 20;           // Sunanda's v index
            detId[0] = 50 - ((iu - detId[1] + 100 + 2)/2);  // Sunanda's u index
            detId[0] += 1;
            detId[1] += 1;
        } else {
            detId[1] = (iv + iw + 60)/3 - 20;           // Sunanda's v index
            detId[0] = 50 - ((iu - detId[1] + 100 + 1)/2);  // Sunanda's u index
        }
    }

    return detId;
}

- (int) waferIndexFromDetId:(int *) aDetId {
    
    int iw = aDetId[0]+20 + 26*(aDetId[1]+14);
    
    if(!centreoncentre) {
        iw = aDetId[0]+20 + 25*(aDetId[1]+15);
        if(_nLayer%2) iw -= 26;
    }
    
    return iw;
}

- (void) rotate120DetId:(int *) aDetId {
    
    int u = aDetId[0];
    int v = aDetId[1];
    /*
     For a +120 degree rotation the transform of u,v indices is:
     a) Wafer centred
     v' = u-v; u' = -v
     
     b) corner centred odd layers (Y-centred)
     v' = u - (v+1); u' = -(v+1)
     
     c) corner centred even layers (lambda-centred)
     v' = u-(v-1); u' = -(v-1)
     */
    if(centreoncentre) {
        aDetId[0] = -v;
        aDetId[1] = u-v;
    } else if(_nLayer%2) {   // i.e. EVEN layers for ORDINAL counting
        aDetId[0] = -(v-1);
        aDetId[1] = u-(v-1);
    } else {
        aDetId[0] = -(v+1);
        aDetId[1] = u-(v+1);
    }
    
}

- (NSPoint) retractedPointForU: (int) iu andV: (int) iv {
  
    double retCEE[6][2] = {4.10,2.37,0.00,4.73,-4.10,2.37,-4.10,-2.37,-0.00,-4.73,4.10,-2.37};
    double retCEH[12][2] = {6.85,1.46,4.68,5.20,2.16,6.66,-2.16,6.66,-4.68,5.20,-6.85,1.46,-6.85,-1.46,-4.68,-5.20,
        -2.16,-6.66,2.16,-6.66,4.68,-5.20,6.85,-1.46};
    
    NSPoint centre = [self centreForU: iu andV: iv];

    double x = centre.x;
    double y = centre.y;
    
    double phi = atan2(y,x);
    if(phi < 0.) phi = phi + 2.*M_PI;
    double dang,xret,yret;
    int icas0;
    if(_nLayer < 26) {
        dang = M_PI/3.;
        icas0 = (int) (phi/dang);
        xret = x + retCEE[icas0][0];
        yret = y + retCEE[icas0][1];
    } else {
        dang = M_PI/6.;
        icas0 = (int) (phi/dang);
        xret = x + retCEH[icas0][0];
        yret = y + retCEH[icas0][1];
    }
    
    return NSMakePoint(xret,yret);

}

- (NSPoint) centreForU: (int) iu andV: (int) iv {
   
    double x = 0.;
    double y = 0.;
    double u = (double) iu;
    double v = (double) iv;
    if(centreoncentre) {
        x = (u - 0.5*v) * ftof;
        y = v * 1.5 * side;
    } else {
        if(_mercedes) {
            x = (u - 0.5*v) * ftof;
            y = v * 1.5 * side - side;
        } else {
            x = (u - 0.5*v) * ftof;
            y = v * 1.5 * side + side;
        }
    }

    return NSMakePoint(x,y);
}

- (NSString *) retractionStringForU: (int) iu andV: (int) iv {
    
    NSPoint centre = [self centreForU: iu andV: iv];
    NSPoint retracted = [self retractedPointForU: iu andV: iv];
    return [NSString stringWithFormat:@"Wafer (%d,%d)\nNominal (%.2f,%.2f)\nRetracted (%.2f,%.2f)",iu,iv,centre.x,centre.y,retracted.x,retracted.y];
}

- (NSPoint) correctPointForRetraction: (NSPoint) pnt {

    /*----------------------------------------------------------------------------
     Correction applied only if in non-tile region
     -----------------------------------------------------------------------------*/
    
    double r = sqrt(pnt.x*pnt.x + pnt.y*pnt.y);
    if(r > [theMapFiles innerRingRadius]) return pnt;
    
    _testCas = -99;

    int iw = [self fastWaferFromPoint:pnt];
    if(iw < wafers.count) {
        HXGWafer * wafer = [wafers objectAtIndex:iw];
        double phi = atan2(wafer.gridyc,wafer.gridxc)+M_PI+0.01;
        double cascount = 6.;
        if(_nLayer > 25) cascount = 12.;
        double casphi = 2.*M_PI/cascount;
        _testCas = (int) ((phi+M_PI)/casphi);
        _testCas = _testCas%(int)cascount + 1;
        int CEtype = 0;
        if(_nLayer > 25) CEtype = 1;
        NSPoint retvec = [theMapFiles getRetVecForCEtype:CEtype andCassette:_testCas];
        pnt.x -= retvec.x;
        pnt.y -= retvec.y;
    }

    return pnt;
}

- (void) HDLDcomboTest {
    
    HXGNeighbourFinder * theNeighbours = [HXGNeighbourFinder sharedNeighbourFinder];
    [theNeighbours HDLDcomboTestWithWafers:wafers inLayer:_nLayer+1];
    
}

#pragma mark - PDF

- (void) savePDF:(NSString *)path With:(NSString *)summary {
    
    [self setPdfTextAttributes];
        
    ispdf = YES;
    string0 = summary;
    
    NSData * data;
    NSRect b = [self bounds];
    if(_scrolling) b = _scrollView.documentVisibleRect;
    NSRect f = [self frame];
    if(_scrolling) f = _scrollView.contentView.frame;
    f.origin = b.origin; // Strange but true...
    f.size.width *= 1.414;
    
    data = [self dataWithPDFInsideRect:f];

    [data writeToFile:path options:0 error:nil];

    //---- Back to normal after writing the file
    ispdf = NO;
    
}


#pragma mark - private methods

- (double) approxMaxRadius { // Used for locating the 30º rotation indication
    
    double radiusOut;
    for (int i = 280; i<290; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(!wafer.whole && !wafer.part) break;
        radiusOut = wafer.rc;
    }

    return radiusOut;
}


- (void) setPdfTextAttributes {
    
    NSRect b;
    if(_scrolling) {
        b = _scrollView.documentVisibleRect;
    } else {
        b = self.bounds;
    }

    t0point.x = (b.origin.x + 0.95*b.size.width);
    t0point.y = (b.origin.y + 0.8*b.size.height);
    t1point.x = (b.origin.x + 1.0*b.size.width);
    t1point.y = (b.origin.y + 0.02*b.size.height);
    keypoint.x = (b.origin.x + 1.1*b.size.width);
    keypoint.y = (b.origin.y + 0.5*b.size.height);
    keydelta = 0.05*b.size.height;
    if(_scrolling) fsize = 100.0 / _scrollmag;
    else fsize = 80.0 * _magnify;
    fontName = @"Lucida Grande";
    font = [NSFont fontWithName:fontName size:fsize];
    
    textAttributes =  [NSMutableDictionary
                       dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:fsize],NSFontAttributeName,
                       [NSColor blackColor],NSForegroundColorAttributeName,
                       [NSColor whiteColor],NSBackgroundColorAttributeName, nil];
    [textAttributes setObject:font
                       forKey:NSFontAttributeName];

    fontName = @"Helvetica";
    font = [NSFont fontWithName:fontName size:fsize*1.6];

    keyAttributes =  [NSMutableDictionary
                       dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:fsize*1.6],NSFontAttributeName,
                       [NSColor blackColor],NSForegroundColorAttributeName, nil];
    [keyAttributes setObject:font
                       forKey:NSFontAttributeName];

}
#pragma mark - mouse stuff

- (void) mouseMoved:(NSEvent *)theEvent {
    
    [self mouseMovedToPoint:[theEvent locationInWindow]];

}
    
- (void) mouseMovedToPoint:(NSPoint) point {
       
    if(!_showcoords && !_showfileline && !_dragging) return;
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.1) return;
    tstart = tnow;
    
    if(point.x > frameRect.size.width || point.y > frameRect.size.height) {
        if(infield) [self setNeedsDisplay:YES];
        infield = NO;
        iRing = -1;
        _lineString = @"";
        return;
    }

    mousePoint = [self convertPoint:point fromView: nil];
    
    if(_scrolling) {
        NSRect vis = _scrollView.documentVisibleRect;
        if(mousePoint.x < vis.origin.x || mousePoint.x > vis.origin.x+vis.size.width || mousePoint.y < vis.origin.y || mousePoint.y > vis.origin.y+vis.size.height) {
            if(infield) [self setNeedsDisplay:YES];
            infield = NO;
            return;
        }
    }
    
    infield = YES;

    if(_zoom) {
        mousePoint = [inverseZoomTransform transformPoint:mousePoint];
    }
    if(mirror) mousePoint.x = -mousePoint.x;

    
    if(_dragging) {
        NSRect vis = _scrollView.documentVisibleRect;
        NSPoint centre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
        centre.x += mousePoint.x - dragFromPoint.x;
        centre.y += mousePoint.y - dragFromPoint.y;
        [self centreHexViewAt:centre];

    }

    xp = mousePoint.x;
    yp = mousePoint.y;
    double xr = xp;
    double yr = yp;

    if(_showRetracted) {
        NSPoint rpnt = [self correctPointForRetraction:NSMakePoint(xp,yp)];
        //NSLog(@"(%.1f, %.1f) -> (%.1f, %.1f)",xr,yr,rpnt.x,rpnt.y);
        xr = rpnt.x;
        yr = rpnt.y;
    }
    rp = sqrt(xp*xp + yp*yp);
    double rrp = sqrt(xr*xr + yr*yr);

    double xrr = xr;
    double yrr = yr;
    if(_rotate30 && _rotateRotated) {
        xrr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yrr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
    }
    
    lstate = istate;
    istate = [self stateAtPoint:NSMakePoint(xrr,yrr)];
    
    lwafer = iwafer;
    iwafer = [self fastWaferFromPoint:NSMakePoint(xrr,yrr)];


    lRing = iRing;
    iRing = [theMapFiles tileRingForRadius:rrp];

    if(_showfileline) {
       if(istate != lstate || iwafer != lwafer || _nLayer != previousLayer || iRing != lRing) {
            previousLayer = _nLayer;
            if(istate == 0) _lineString = @"";
            else if(istate > 2) {
                int line = [theMapFiles getTileLineNumberForLayer: _nLayer andRing:iRing-1];
                _lineString = [NSString stringWithFormat:@"Tile line %d: ",line+1];
                _lineString = [_lineString stringByAppendingString:[theMapFiles getTileLineString:line]];
            } else if(iwafer >= wafers.count) _lineString = @"";
            else {
                HXGWafer * wafer = [wafers objectAtIndex:iwafer];
                if(wafer.part || wafer.whole ) {
                    _lineString = [NSString stringWithFormat:@"Si line %d: ",wafer.fileLine+1];
                    _lineString = [_lineString stringByAppendingString:[theMapFiles getLineNumber:wafer.fileLine]];
                } else {
                    _lineString = @"";
                }
            }
            if(!_showcoords) {
                [self setNeedsDisplay:YES];
                return;
            }
        }
        if(!_showcoords) return;
    }

    // rp = sqrt(xp*xp + yp*yp);
    // iRing = [theMapFiles tileRingForRadius:rp andLayer:_nLayer];
    double theta = atan2(rp,_zLayer);
    etap = -log(tan(theta*0.5));
    phip = 180.0*atan2(yp,xp)/M_PI;
    if(phip < 0.) phip = 360. + phip;
    double tilesPerDegree = (double) theMapFiles.layerNphi[_nLayer - theMapFiles.tileL0 + 1]/360.;
    iPhi = (int) (phip*tilesPerDegree);
    if(iRing < 0) [self waferDetIdAtPoint:NSMakePoint(xrr,yrr)];

    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    double xl,yl;
    
    if([theEvent modifierFlags]&NSEventModifierFlagControl) {
        if([theEvent modifierFlags]&NSEventModifierFlagOption) {
            [self cellLocatorRequest: theEvent forNeighbours: [theEvent modifierFlags] & NSEventModifierFlagCommand];
        } else [self inspectorRequest: theEvent];
        return;
    } else {
        mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
        
        if(_zoom) {
            mousePoint = [inverseZoomTransform transformPoint:mousePoint];
        }
        xp = mousePoint.x;
        yp = mousePoint.y;
        if(mirror) xp = -xp;

        xl = xp;
        yl = yp;

        if(([theEvent modifierFlags]&NSEventModifierFlagCommand) && clickWafers) {
            if(_rotate30 && _rotateRotated) {
                xp = xl*cos(-M_PI/6.) - yl*sin(-M_PI/6.);
                yp = xl*sin(-M_PI/6.) + yl*cos(-M_PI/6.);
            }
            [self waferClicking];
            return;
        }

        if(_rotate30 && _rotateRotated) {
            xp = xl*cos(M_PI/6.) - yl*sin(M_PI/6.);
            yp = xl*sin(M_PI/6.) + yl*cos(M_PI/6.);
        }
    }


    if([theEvent modifierFlags]&NSEventModifierFlagOption && _scrolling) {
        [self centreHexViewAt:NSMakePoint(xl,yl)];
    } else if([theEvent clickCount] > 1 || [theEvent modifierFlags]&NSEventModifierFlagShift) {
        double xph = xl;
        double yph = yl;
        if(_rotate30 && !_rotateRotated) {
            xph = xl*cos(M_PI/6.) - yl*sin(M_PI/6.);
            yph = xl*sin(M_PI/6.) + yl*cos(M_PI/6.);
        }
        _testpointPhysics = NSMakePoint(xph,yph);

        if(_zoom) [self zoomOnTestPoint:YES];

        double r = sqrt(xph*xph + yph*yph);
        double theta = atan2(r,_zLayer);
        double etaph = -log(tan(theta*0.5));
        double phiph = 180.0*atan2(yph,xph)/M_PI;
        
        if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];
        [thePosition setState:YES eta:etaph phi:phiph];
        [thePosition notify];
    } else if(_scrolling) {
        _dragging = YES;
        dragFromPoint = mousePoint; //NSMakePoint(xp,yp);
    }
}

- (void) mouseDragged:(NSEvent *)theEvent {
    
    if(!_dragging) return;
    
    if(_showCellLabels && _scrollmag > labelsMagLimit) _suppressLabels = YES;

    [_scrollView setDocumentCursor:[NSCursor closedHandCursor]];
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.01) return;
    tstart = tnow;
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];

    if(_zoom) {
        mousePoint = [inverseZoomTransform transformPoint:mousePoint];
    }
    
    if(_dragging) [self shiftCentreBy:NSMakePoint(mousePoint.x-dragFromPoint.x, mousePoint.y-dragFromPoint.y)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSViewBoundsDidChangeNotification object:nil];


}

- (void)mouseUp:(NSEvent *)theEvent {
    
    if(_dragging) {
        _dragging = NO;
        [_scrollView setDocumentCursor:[NSCursor arrowCursor]];
        if(_suppressLabels && _scrollmag > labelsMagLimit) {
            _suppressLabels = NO;
            [self setNeedsDisplay:YES];
        }
    }
}

- (void)rightMouseDown:(NSEvent *) theEvent {
    
    if([theEvent modifierFlags]&NSEventModifierFlagOption) [self cellLocatorRequest:theEvent forNeighbours: [theEvent modifierFlags] & NSEventModifierFlagCommand];
    else [self inspectorRequest:theEvent];
    
}

- (void) inspectorRequest:(NSEvent *) theEvent {
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    if(_zoom) mousePoint = [inverseZoomTransform transformPoint:mousePoint];

    xp = mousePoint.x;
    yp = mousePoint.y;
    if(mirror) xp = -xp;
    
    double xr = xp;
    double yr = yp;
    if(_rotate30 && _rotateRotated) {
        xr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
    }

    inwafer = [self fastWaferFromPoint:NSMakePoint(xr,yr)];
    rp = sqrt(xr*xr + yr*yr);
    iRing = [theMapFiles tileRingForRadius:rp];
    
    if(!theInspector) theInspector = [HXGSensorInspectorControl sharedInspectorControl];
    [theInspector.window close];
    if((inwafer < 0 || inwafer >= wafers.count) && iRing < 0) return;
    
    theInspector.mousePoint = [theEvent locationInWindow];
    theInspector.alreadyRetracted = _showRetracted;
    
    double xmag = 1./_magnify;
    if(_scrolling) xmag = _scrollmag*0.5;
    theInspector.sidestep = 60.*xmag;
    theInspector.inspectorView.rotated = _rotate30;
    theInspector.inspectorView.rotateRotated = _rotateRotated;
    theInspector.inspectorView.mirror = mirror;

    theInspector.beyondV17 = theMapFiles.version > 0;
    theInspector.inspectorView.CEtype = _nLayer/26;
    theInspector.inspectorView.nlayer = _nLayer;
    
    int iphi = [theMapFiles iphiTileAt:NSMakePoint(xr,yr)];
    if(iRing > 0 && iphi > -1) {
        [theInspector showWindow:nil];
        theInspector.inspectorView.ntiles = theMapFiles.layerNphi[_nLayer - theMapFiles.tileL0 + 1];
        theInspector.inspectorView.retract = theMapFiles.layerRshift[_nLayer - theMapFiles.tileL0 + 1];
        theInspector.sidestep *= 0.35;
        [theInspector showSpecsForTileIn:iRing At:iphi];
    } else {
        HXGWafer * w = [wafers objectAtIndex:inwafer];
        if(w.whole || w.part) {
            if(w.part) if([self stateAtPoint:NSMakePoint(xr,yr)] < 1) return;
            [theInspector showWindow:nil];
            NSPoint cp = [self convertPoint:NSMakePoint(w.xc,w.yc) toView:nil];
            cp.y = theInspector.mousePoint.y;
            theInspector.mousePoint = cp;
            [theInspector showSpecsForWafer:w];
        }
    }

}

- (void) cellLocatorRequest:(NSEvent *) theEvent forNeighbours:(BOOL) neighbours {

    if(neighbours && (!_scrolling || _scrollmag<4. || _oneCassette != 0)) return;
       
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    if(_zoom) mousePoint = [inverseZoomTransform transformPoint:mousePoint];

    xp = mousePoint.x;
    yp = mousePoint.y;
    if(mirror) xp = -xp;
    
    double xr = xp;
    double yr = yp;
    
    if(_rotate30 && _rotateRotated) {
        xr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
    }
    
    double xret = xr;
    double yret = yr;
    
    if(_showRetracted) {
        NSPoint rpnt = [self correctPointForRetraction:NSMakePoint(xr,yr)];
        //NSLog(@"(%.1f, %.1f) -> (%.1f, %.1f)",xr,yr,rpnt.x,rpnt.y);
        xret = rpnt.x;
        yret = rpnt.y;
    }

    inwafer = [self fastWaferFromPoint:NSMakePoint(xret,yret)];
    if(inwafer < 0 || inwafer >= wafers.count) return;
    HXGWafer * wafer = [wafers objectAtIndex:inwafer];
    
    if(wafer.whole || wafer.part) {
        if(wafer.part) if([self stateAtPoint:NSMakePoint(xr,yr)] < 1) return;
        theCellLocator = [HXGCellLocatorWindowControl sharedCellLocatorControl];
        theCellLocator.retracted = _showRetracted && theMapFiles.version != 0;
        theCellLocator.startingPoint = NSMakePoint(xr-wafer.xc,yr-wafer.yc);
        if(neighbours) {
            if(!theInterface) theInterface = [HXGDetIdInterface sharedDetInterface];
            [theInterface setWaferArray:wafers];
            [theCellLocator neighbourCellsIn: wafer ofLayer: _nLayer rotated30:_rotate30 && _rotateRotated];
        } else [theCellLocator locateCellsIn: wafer ofLayer: _nLayer rotated30:_rotate30 && _rotateRotated];
    }
    
}

- (void) pickColor {
    
    //NSColorPanel * theColorPanel = [NSColorPanel sharedColorPanel];
    //NSLog(@"Pick color...");
    if(!theColorPicker) theColorPicker = [HXGColorPicker sharedColorPicker];
    theColorPicker.message  = @"Select a new colour for highlighted wafers";
    theColorPicker.workingColor = _waferHighlightColor;
    theColorPicker.ipoint = 0;
    [theColorPicker showWindow:self];

}

#pragma mark - catch keyboard events

- (void) keyDown:(NSEvent *) theEvent {
    
    NSString *  const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    unichar const cup    = 0xf700;
    unichar const cdown  = 0xf701;
    unichar const cleft  = 0xf702;
    unichar const cright = 0xf703;
    
    NSUInteger modifiers = ([NSEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask);

    if((modifiers == NSEventModifierFlagCommand) && code == 0x67) { // i.e. ⌘g
        [self pickColor];
        return;
    }
    
    clickWafers = NO;
    if ((modifiers == NSEventModifierFlagCommand) && code == 0x73) { // i.e. ⌘s
        clickWafers = YES;
        return;
    }


    if ((modifiers == (NSEventModifierFlagShift | NSEventModifierFlagControl  | NSEventModifierFlagOption | NSEventModifierFlagCommand)) && code == 0x44) {
        // Could use this to post notification to turn on debug menu
        return;
    }
    
    
    if (modifiers == NSEventModifierFlagShift) { // Change magnification
    // Should be Notification to MainControl, so that it changes the slider,
    // and also works when in scroll window
        if(code == 0x5f) _magnify = MIN(_magnify*1.12,1.2544);           // i.e. shift-= (+)
        else if(code == 0x2b) _magnify = MAX(_magnify/1.12,0.7117802478);// i.e. shift-- (_)
        
        [self drawHexGrid];
    }

    if(_scrolling && _scrollmag>4.) {

        //[self mouseMovedToPoint:[_mainWindow mouseLocationOutsideOfEventStream]];

        NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
        if(tnow - tstart > 0.3) {
            nadjust = 0;
        }
        tstart = tnow;

        double dfrac[17] = {0.0005,0.0005,0.0006,0.0008,0.0013,0.0021,0.0032,0.0048,
                    0.0069,0.0096,0.0130,0.0171,0.0221,0.0280,0.0348,0.0427,0.0517};
        
        //NSRect bR = self.bounds;
        NSRect bR = _scrollView.contentView.bounds;
        double delta = bR.size.width*dfrac[nadjust];
        
        if(code == cleft) {
            bR.origin.x -= delta;
        } else if(code == cright) {
            bR.origin.x += delta;
        } else if(code == cup) {
            bR.origin.y += delta;
        } else if(code == cdown) {
            bR.origin.y -= delta;
        }
        
        //[self setBounds:bR];
        [_scrollView.contentView setBounds:bR];
        
        if (modifiers & NSEventModifierFlagShift) nadjust = 5;
        else if(nadjust < 16) nadjust++;
        [self setNeedsDisplay:YES];

        return;
    }
    nadjust = 0;


    //NSLog(@"code %0x",code);
    NSMutableDictionary * d = [NSMutableDictionary dictionary];

    if(code == cleft) {
        if(_layerSegment == 1) {
            _layerSegment = 0;
            NSNumber * newseg = [NSNumber numberWithInteger:_layerSegment];
            [d setObject:newseg forKey:@"newsegment"];
            
            note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
            NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
            [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                                       postingStyle: NSPostNow
                                                       coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                           forModes: modes];
        }
        return;
    }
    if(code == cright) {
        if(_layerSegment == 0) {
            _layerSegment = 1;
            NSNumber * newseg = [NSNumber numberWithInteger:_layerSegment];
            [d setObject:newseg forKey:@"newsegment"];

            note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
            NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
            [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                                       postingStyle: NSPostNow
                                                       coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                           forModes: modes];
        }
        return;
    }
    
    int oldlayer = _nLayer;
    
    if(code == cup) {
        if(_layerSegment == 1) _nLayer+=1;
        if(_layerSegment == 0) _nLayer+=10;
        if(_nLayer > _lastLayer) _nLayer = _lastLayer;
        fire = NO;
    } else if(code == cdown) {
        if(_layerSegment == 1) _nLayer-=1;
        if(_layerSegment == 0) _nLayer-=10;
        if(_nLayer < 0) _nLayer = 0;
        fire = NO;
    }

    if(code >= 0x0030 && code < 0x003a) {
        int digit = code & 0x000f;
        if(_layerSegment == 0 && !fire) {
            _nLayer = digit*10 + _nLayer%10;
            fire = YES;
        } else {
            fire = NO;
            _nLayer = (_nLayer/10)*10 + digit - 1; //-------------- ************** !!!
            if(_nLayer < 0) _nLayer = 0;
            if(_nLayer > _lastLayer) _nLayer = _lastLayer;
        }
    }

    
    if(_nLayer != oldlayer) {
        if(!fire) {
            NSNumber * newlayer = [NSNumber numberWithInteger:_nLayer];
            [d setObject:newlayer forKey:@"newlayer"];
            
            note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
            NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
            [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                                       postingStyle: NSPostNow
                                                       coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                           forModes: modes];
        } else {
            if(_nLayer > _lastLayer) _nLayer = _lastLayer;
            NSNumber * newlayer = [NSNumber numberWithInteger:_nLayer];
            [d setObject:newlayer forKey:@"newlayer"];
            NSNumber * newseg = [NSNumber numberWithInteger:1];
            [d setObject:newseg forKey:@"newsegment"];

            
            note = [NSNotification notificationWithName: HXGNewLayerNotification object:self userInfo:d];
            timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(delayedUpdate:) userInfo:nil repeats:NO];
        }
    }
}

- (void) delayedUpdate:(NSTimer *) aTimer {
    [timer invalidate];
    if(!fire) return;
    fire = NO;

    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];
}



#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect  {      //-----     drawRect

    NSDate * today = [NSDate date];
    double t0 = - [today timeIntervalSinceNow];

    [super drawRect:dirtyRect];

    [self setClipsToBounds:YES];
    
    if(_cassetteView && _nLayer < 26 && _nLayer%2 == 1) {
        mirror = YES;
        [mirrorTransform concat];
    } else mirror = NO;

    if(_numberCassettes || _showCassettes) [self setUpCassetteNumbering];
    
    if(_scrolling && !_dragging) [_scrollView setDocumentCursor:[NSCursor arrowCursor]];
        
    if(_zoom) [zoomTransform concat];
    
    BOOL onlyOne = (_oneCassette != 0);

    BOOL doStructure = _showStructure && _scrolling && (_scrollmag>structureMagLimit || onlyOne);
    BOOL mirStWf = NO;
    if(doStructure) if(_nLayer < 26 && _nLayer%2 == 1) mirStWf = YES;
        
    if(_rotate30 && _rotateRotated) [thirtyTransform concat];
    
    double w = 1.0;
    [[NSColor blackColor] set];

    //---- Draw the grid -----------------------------------------
    if(_showGrid) {               // && !(_rotate30 && _rotateRotated)) {
        for (int i = 0; i<_nhex; i++) {
            NSBezierPath * path = [wholes objectAtIndex:i];
            [path setLineWidth:w];
            [path stroke];
        }
    }
 
    //-------------- Cu cooling plates ---------------------------
    if(showCuPlates && _nLayer/2 < 13) {
        double alpha = 1.0;
        if(_nLayer%2 == 0) {
            NSBezierPath * path = [theCuPlates bezierCuCEEforCasLayer:_nLayer/2];
            [copper set];
            [path fill];
            [[NSColor blackColor] set];
            [path stroke];
            alpha = alphaOdd;
        }
        NSColor * col0  = [waferThicknessColors[0] colorWithAlphaComponent:alpha];
        NSColor * col1  = [waferThicknessColors[1] colorWithAlphaComponent:alpha];
        NSColor * col2  = [waferThicknessColors[2] colorWithAlphaComponent:alpha];
        NSColor * col3  = [waferThicknessColors[3] colorWithAlphaComponent:alpha];
        waferThicknessColors = [NSArray arrayWithObjects:col0,col1,col2,col3,nil];
    }
    
    //---- Draw the wafers --------------------------------------------
        
    if(doStructure) {
        theStructuredWafer.trigger = NO;
        for (int i = 0; i<_nhex; i++) {
            HXGWafer * wafer = [wafers objectAtIndex:i];
            NSPoint wpnt = NSMakePoint(wafer.xc,wafer.yc);
            if(_rotate30 && _rotateRotated) {
                wpnt = [thirtyTransform transformPoint:wpnt];
            }
            if(!mirror && !ispdf) if(wpnt.x < _loCorner.x || wpnt.x > _hiCorner.x || wpnt.y < _loCorner.y || wpnt.y > _hiCorner.y) continue;
            if(!onlyOne || wafer.cassette == _oneCassette) {
                if(showNeighbours) {
                    for(int iwn=0; iwn<waferList.count; iwn++) {
                        if(waferList[iwn] == wafer) {
                            [theStructuredWafer setNeighbourList:cellListList[iwn]];
                        }
                    }
                }
                if(wafer.whole || wafer.part) [theStructuredWafer drawCellsForWafer:wafer Mirrored:mirStWf];
            }
        }
    }

    [NSBezierPath setDefaultLineWidth:w];
    for (int i = 0; i<_nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(onlyOne && wafer.cassette != _oneCassette) continue; // !!!!!!!
        if(_scrolling) {
            NSPoint wpnt = NSMakePoint(wafer.xc,wafer.yc);
            if(_rotate30 && _rotateRotated) {
                wpnt = [thirtyTransform transformPoint:wpnt];
            }
            if(!mirror && !ispdf) if(wpnt.x < _loCorner.x || wpnt.x > _hiCorner.x || wpnt.y < _loCorner.y || wpnt.y > _hiCorner.y) continue;
        }
        if(_showGridForPartials && wafer.part && !doStructure) {
            NSBezierPath * path = [wafer waferBezier];
            [path setLineWidth:w];
            [path stroke];
        }
        if(wafer.whole || wafer.part) {
            if(!doStructure) {
                NSBezierPath * path = wafer.bezier;
                NSColor * col = [waferThicknessColors objectAtIndex:wafer.thickflag];
                if(wafer.marked) col = _waferHighlightColor;
                [col set];
                [path fill];
                if(_markTypeOne) {
                    [[NSColor redColor] set];
                    [wafer.zeroBezier fill];
                    [[NSColor blackColor] set];
                   [wafer.zeroBezier stroke];
                }
                if(wafer.whole && _markTypeBar) {
                    [[NSColor coolGrey] set];
                    [wafer.barBezier fill];
                }
                [[NSColor blackColor] set];
                [path stroke];
            }
        }
    }

    //---- Draw the tiles -----------------------------------------
    if([theMapFiles layerOfTiles]) {
            double lw = 3.;
            if(_scrolling) lw = 6./_scrollmag;
            if(onlyOne) [theMapFiles drawTileBeziersForCassette:_oneCassette];
            else [theMapFiles drawTileBeziersWithLineWidth:lw];
    }

            /*
        } else {
            [[NSColor fadedBlue] set];
            [[theMapFiles tileBodyBez] fill];
            
            if (_numberWafers && !onlyOne) { // Special coloured rings for numbering
                [[NSColor pastelBlue]set];
                [[theMapFiles tensTileRingsBez] fill];
                [[NSColor paleBlue] set];
                [[theMapFiles fivesTileRingsBez] fill];
            }
            
            [[NSColor blackColor] set];
            [[theMapFiles tileBodyOutlineBez] setLineWidth:tileOutlineWidth];
            [[theMapFiles tileBodyOutlineBez] stroke];
            
            [[NSColor fadedBlue] set];
            [[theMapFiles incompleteTileRingsBez] fill];
            [[NSColor blackColor] set];
            [[theMapFiles incompleteTileRingsBez] setLineWidth:tileOutlineWidth];
            [[theMapFiles incompleteTileRingsBez] stroke];
        }
             */
    
    //---- Spot marking (0,0): the beam line
    [[NSColor blackColor] set];
    [beam fill];
    
    //---- Mark the cassette boundaries
    if(_showCassettes && !(doStructure && _showRetracted)) {
        [casEdgeColor set];
        //[cassetteBezier stroke];
        if(!onlyOne) {
            for(int i=0; i<ncas; i++) {
                [cassetteBoundaryBezier[i] stroke];
            }
            [tileCasEdgeColor set];
            [theMapFiles.scintCassetteBez setLineCapStyle:NSLineCapStyleRound];
            [theMapFiles.scintCassetteBez setLineWidth:casBoundaryWidth];
            [theMapFiles.scintCassetteBez stroke];
        }
    }
    
    //---- Draw u,v axes ---------------------------------------------
    if(_showaxes) {
        double fsize = 160.;
        /*
        if(ispdf) {
            fsize = 320;
            [uaxis setLineWidth: 18.];
            [vaxis setLineWidth: 18.];
        }
        */
        [[NSColor blueColor] set];
        [uaxis stroke];
        [uaxis fill];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"u"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:fsize]
                    range:NSMakeRange(0,str.length)];
        [str addAttribute:NSForegroundColorAttributeName
                    value:[NSColor blueColor]
                    range:NSMakeRange(0,str.length)];
        if(mirror) {
            [mirrorTransform concat];
            [str drawAtPoint:NSMakePoint(-uaxlabel.x-str.size.width,uaxlabel.y)];
            [mirrorTransform concat];
        } else [str drawAtPoint:uaxlabel];
        [vaxis stroke];
        [vaxis fill];
        str = [[NSMutableAttributedString alloc] initWithString:@"v"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:fsize]
                    range:NSMakeRange(0,str.length)];
        [str addAttribute:NSForegroundColorAttributeName
                    value:[NSColor blueColor]
                    range:NSMakeRange(0,str.length)];
        [str drawAtPoint:vaxlabel];
    }
    
    //---- Cassette numbering
    if(_numberCassettes && !doStructure) {
        int i0 = 0;
        int i1 = ncas;
        if(onlyOne) {
            i0 = _oneCassette - 1;
            i1 = _oneCassette;
        }
        for(int i=i0; i<i1; i++) {
            int ii = i%ncas;
            if(_rotate30 && _rotateRotated) {
                [casUnRot[ii] concat];
            }
            if(mirror) {
                NSPoint cPoint = NSMakePoint(-casPoint[ii].x-casLabel[i].size.width,casPoint[ii].y);
                [mirrorTransform concat];
                [casLabel[ii] drawAtPoint:cPoint];
                [mirrorTransform concat];
            } else [casLabel[ii] drawAtPoint:casPoint[ii]];
            if(_rotate30 && _rotateRotated) {
                [casUnRot[ii] invert];
                [casUnRot[ii] concat];
                [casUnRot[ii] invert];
            }
        }
    }

    if(doStructure && _scrollmag>labelsMagLimit && (_showCellLabels || _showEdgeIndex) && !_suppressLabels) {
        for (int i = 0; i<_nhex; i++) {
            HXGWafer * wafer = [wafers objectAtIndex:i];
            NSPoint wpnt = NSMakePoint(wafer.xc,wafer.yc);
            if(_rotate30 && _rotateRotated) {
                wpnt = [thirtyTransform transformPoint:wpnt];
            }
            if(!mirror && !ispdf) if(wpnt.x < _loCorner.x || wpnt.x > _hiCorner.x || wpnt.y < _loCorner.y || wpnt.y > _hiCorner.y) continue;
            if(onlyOne) if(wafer.cassette != _oneCassette) continue;
            if(wafer.whole || wafer.part) {
                if(_showEdgeIndex) [theStructuredWafer drawEdgeIndexForWafer:wafer Mirrored:mirStWf];
                else [theStructuredWafer drawLabelsForWafer:wafer Mirrored:mirStWf];
            }
        }
    }


    

    //---- Rotation of rotated layers (end it here) --------------------------------------------------
    if(_rotateRotated && _rotate30) {
        [thirtyTransform invert];
        [thirtyTransform concat];
        [thirtyTransform invert];
    }
    
/* ===================================================================================================
     A L L   G R A P H I C S   C O N T E X T   T R A N S F O R M A T I O N S   N O W   O F F
   =================================================================================================== */
    
    //---- Draw x,y axes (which don't rotate: they stay with the page)------------------------
    if(_showaxes && !(_rotate30 && !_rotateRotated)) {
        double fsize = 160.;
        /*
        if(ispdf) {
            fsize = 320;
            [minusxaxis setLineWidth: 18.];
            [plusxaxis setLineWidth: 18.];
            [yaxis setLineWidth: 18.];
            xmaxlabel.y = 20.;
            xpaxlabel.y = - fsize - 20.;
        }
        */
        [[NSColor blackColor] set];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"x"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:fsize]
                    range:NSMakeRange(0,str.length)];
        if(_plusz) {
            [minusxaxis stroke];
            [minusxaxis fill];
            [str drawAtPoint:xmaxlabel];
        } else {
            [plusxaxis stroke];
            [plusxaxis fill];
            [str drawAtPoint:xpaxlabel];
        }
        [yaxis stroke];
        [yaxis fill];
        str = [[NSMutableAttributedString alloc] initWithString:@"y"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:fsize]
                    range:NSMakeRange(0,str.length)];
        if(mirror) {
            [mirrorTransform concat];
            [str drawAtPoint:NSMakePoint(-yaxlabel.x-str.size.width,yaxlabel.y)];
            [mirrorTransform concat];
        } else [str drawAtPoint:yaxlabel];
    }

    //---- Wafer numbering --------------------------------------------------
    int * did;
    if(_numberWafers && !onlyOne) {
        if(mirror) [mirrorTransform concat];
        for (int i = 0; i<_nhex; i++) {
            HXGWafer * wafer = [wafers objectAtIndex:i];
            NSString * xystr = @" ";
            if(_useDetId) {
                did = wafer.detId;
                xystr = [NSString stringWithFormat:@"%d:%d",did[0],did[1]];
            } else xystr = [NSString stringWithFormat:@"%03d",i];
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:52]
                        range:NSMakeRange(0,str.length)];
            [str addAttribute:NSForegroundColorAttributeName
                        value:[NSColor blackColor]
                        range:NSMakeRange(0,str.length)];
            if((wafer.whole || wafer.part)&&([theMapFiles innerRingRadius] > wafer.rc)) {
                double xd = wafer.xc;
                if(mirror) xd = -xd;
                double yd = wafer.yc;
                if(_rotate30 && _rotateRotated) {
                    xd = wafer.xc * cos(M_PI/6.) - wafer.yc * sin(M_PI/6.);
                    yd = wafer.xc * sin(M_PI/6.) + wafer.yc * cos(M_PI/6.);
                }
                [str drawAtPoint:NSMakePoint(xd - 0.5*str.size.width,yd-0.5*str.size.height)];
            }
        }
        if(mirror) [mirrorTransform concat];
        //---- Now the tile numbers
        if([theMapFiles layerOfTiles]) {
            double * t = [theMapFiles getTenList];
            double tenlist[2][10];
            memcpy(tenlist, t, 20 * sizeof( double ) );
            for(int i=0; i<theMapFiles.nten; i++) {
                NSBezierPath * outline = [NSBezierPath bezierPath];
                double cr = (tenlist[0][i]+tenlist[1][i])/(2.*1.4142);
                NSPoint cntr = NSMakePoint(cr,cr);
                [outline appendBezierPathWithArcWithCenter:cntr radius:60. startAngle:0.0 endAngle:360.0];
                [[NSColor ivoryWhite] set];
                [outline fill];
                [[NSColor blackColor] set];
                [outline setLineWidth:3.];
                [outline stroke];
                NSString * nrstr = [NSString stringWithFormat:@"%2d",theMapFiles.firstMarked + i*10];
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:nrstr];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:72]
                            range:NSMakeRange(0,str.length)];
                double h = str.size.height;
                double w = str.size.width;
                [str drawAtPoint:NSMakePoint(cr-w*0.5,cr-h*0.5)];

            }
        }
    }

    
    //------------- Pb absorbers ------------------------------
    if(showPbAbsorbers && _nLayer/2 < 13 && _nLayer%2 == 0) {
        NSBezierPath * path = [thePbAbsorbers bezierAforCassetteLayer:_nLayer/2];
        [[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];

        path = [thePbAbsorbers bezierBforCassetteLayer:_nLayer/2];
        [[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];
    }
    
    //--------------- Zbars ---------------------------------
    if(showZbars && _nLayer < 26) {
        [self drawZbars];
    }

    //-------------- Cu cooling plates ---------------------------
    if(showCuPlates && _nLayer/2 < 13 && _nLayer%2 == 1) {
        NSBezierPath * path = [theCuPlates bezierCuCEEforCasLayer:_nLayer/2];
        [copper set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];
    }

    //-------------- CEH spacers ---------------------------
    if(showCEHspacers && _nLayer > 25) {
        NSBezierPath * path = [theSpacers spacerBezierForLayer:_nLayer];
        [[NSColor pastelBlue] set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];
    }
    
    //---- phi spokes --------------------------------------
    if(drawSpokes) {
        double dphi = M_PI/18.;
        double phi = 0.;
        double r0 = 100.;
        double r1 = 2000.;
        [[NSColor darkGrayColor] set];
        for (int i=0; i < 36; i++) {
            NSPoint p0 = NSMakePoint(r0*cos(phi), r0*sin(phi));
            NSPoint p1 = NSMakePoint(r1*cos(phi), r1*sin(phi));
            phi += dphi;
            NSBezierPath * spoke = [NSBezierPath bezierPath];
            [spoke moveToPoint:p0];
            [spoke lineToPoint:p1];
            if(i%3 == 0) {
                [spoke setLineWidth:6.0];
            } else {
                [spoke setLineWidth:2.0];
            }
            [spoke stroke];
        }
    }
    
    //---- phi lines --------------------------------------------
    if(nphilines > 0) {
        double r0 = 100.;
        double r1 = 2000.;
        double wl = 4.0;
        if(_scrolling) wl = 8.0/_scrollmag;
        [[NSColor darkGrayColor] set];
        double rrr = theLines.labelRadius;
        for (int i=0; i<nphilines; i++) {
            double phi = phiLines[i] * M_PI/180.;
            NSPoint p0 = NSMakePoint(r0*cos(phi), r0*sin(phi));
            NSPoint p1 = NSMakePoint(r1*cos(phi), r1*sin(phi));
            NSBezierPath * spoke = [NSBezierPath bezierPath];
            [spoke moveToPoint:p0];
            [spoke lineToPoint:p1];
            [spoke setLineWidth:wl];
            [spoke stroke];
            double fs = 52.;
            if(_scrolling) fs = 100./_scrollmag; // 156 // && _scrollmag > 3.
            NSString * phiString = [NSString stringWithFormat:@"φ = %.1fº",phiLines[i]];
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:phiString];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:fs]
                        range:NSMakeRange(0,str.length)];
            NSRect strRect, strBox;
            double wid = [str size].width;
            double hgt = [str size].height;
            strRect.size.width = wid;
            strRect.size.height = hgt;
            strBox.size.width = wid*1.2;
            strBox.size.height = hgt*1.1;
            strRect.origin.x = rrr*cos(phi) - 0.5*strRect.size.width;
            strRect.origin.y = rrr*sin(phi) - 0.5*strRect.size.height;
            strBox.origin.x = rrr*cos(phi) - 0.5*strBox.size.width;
            strBox.origin.y = rrr*sin(phi) - 0.5*strBox.size.height;
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:strBox];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:wl];
            [NSBezierPath strokeRect:strBox];
            if(mirror) [mirrorTransform concat];
            [str drawInRect:strRect];
            if(mirror) [mirrorTransform concat];
        }
    }
    
    //---- eta rings -----------------------------------------------------------
    if(netarings > 0) {
        [self makeRings];
        for (int i=0; i<netarings; i++) {
            [etaRingColor set];
            double wl = 8.0;
            if(_scrolling) wl = 8.0/_scrollmag;
            [etaRingBezier[i] setLineWidth:wl];
            [etaRingBezier[i] stroke];
            NSString * etastr = [NSString stringWithFormat:@"η = %.2f",etaRings[i]];
            double fs = 52.;
            if(_scrolling && _scrollmag > 3.) fs = 156./_scrollmag;
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:etastr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:fs]
                        range:NSMakeRange(0,str.length)];
            NSRect etaRect;
            double wid = [str size].width*1.2;
            double hgt = [str size].height*1.2;
            etaRect.size.width = wid;
            etaRect.size.height = hgt;
            etaRect.origin.x = - 0.5*etaRect.size.width;
            etaRect.origin.y = yeta[i] - 0.5*etaRect.size.height;
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:etaRect];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:wl];
            [NSBezierPath strokeRect:etaRect];
            if(mirror) [mirrorTransform concat];
            [str drawAtPoint:NSMakePoint(etaRect.origin.x+0.1*wid,etaRect.origin.y+0.1*hgt)];
            if(mirror) [mirrorTransform concat];
       }
    }
    
    if(_showtestspot && !ispdf) { // ----------- *** TESTPOINT *** -----------------
        testpoint = _testpointPhysics;
        if(_rotate30 && !_rotateRotated) testpoint = _testpointLayout;
        
        double scale = 1.;
        if(_scrolling) scale = 1./sqrt(_scrollmag);
        testspot = [NSBezierPath crossHairsAt:testpoint withRadius:50.*scale];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:testpoint radius:50.*scale startAngle:0.0 endAngle:360.0];
        [[NSColor blackColor] set];
        [circle setLineWidth:10.*scale];
        [testspot setLineWidth:0.5*scale];
        [testspot stroke];
        [circle stroke];
    }
    
    //---- Indicate that this layer is 30º rotated
    if(_rotate30 && !_rotateRotated) {
        double radiusOut = [self approxMaxRadius];
        NSBezierPath * rotArrow = [NSBezierPath bezierPath];
        double rscale = 1.175;
        
        [rotArrow appendBezierPathWithArcWithCenter:NSZeroPoint radius:radiusOut*rscale startAngle:300.0 endAngle:335.0];
        double xah = radiusOut*rscale*cos(25.*M_PI/180.);
        double yah = -radiusOut*rscale*sin(25.*M_PI/180.);
        [rotArrow moveToPoint:NSMakePoint(xah,yah)];
        xah = radiusOut*rscale*cos(25.*M_PI/180.) - 80.*cos(45.*M_PI/180.);
        yah = -radiusOut*rscale*sin(25.*M_PI/180.)  - 80.*sin(45.*M_PI/180.);
        [rotArrow lineToPoint:NSMakePoint(xah,yah)];
        xah = radiusOut*rscale*cos(25.*M_PI/180.);
        yah = -radiusOut*rscale*sin(25.*M_PI/180.);
        [rotArrow moveToPoint:NSMakePoint(xah,yah)];
        xah = radiusOut*rscale*cos(25.*M_PI/180.) + 78.*cos(95.*M_PI/180.);
        yah = -radiusOut*rscale*sin(25.*M_PI/180.)  - 78.*sin(95.*M_PI/180.);
        [rotArrow lineToPoint:NSMakePoint(xah,yah)];

        [[NSColor blackColor] set];
        [rotArrow setLineWidth:10.0];
        [rotArrow stroke];
        
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"30º"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont boldSystemFontOfSize:120]
                    range:NSMakeRange(0,str.length)];
        /*[str addAttribute:NSBackgroundColorAttributeName
                    value:[NSColor whiteColor]
                    range:NSMakeRange(0,str.length)];*/

        xah = radiusOut*rscale*cos(42.5*M_PI/180.) + 105.;
        yah = -radiusOut*rscale*sin(42.5*M_PI/180.);
        [str drawAtPoint:NSMakePoint(xah,yah)];
    }
    
    if(_showViewCenter) {
        NSBezierPath * centreHairs = [NSBezierPath crossHairsAt:_viewCentre withRadius:250./_scrollmag];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:_viewCentre radius:250./_scrollmag startAngle:0.0 endAngle:360.0];
        [[[NSColor blackColor] colorWithAlphaComponent:0.4] set];
        [circle setLineWidth:20./_scrollmag];
        [centreHairs setLineWidth:2./_scrollmag];
        [centreHairs stroke];
        [circle stroke];
    }

    if(showChosenCell) {
        double scale = 0.4;
        if(_scrolling) scale = 1./_scrollmag;
        NSBezierPath * centreHairs = [NSBezierPath crossHairsAt:cellCentroid withRadius:200.*scale];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:cellCentroid radius:200.*scale startAngle:0.0 endAngle:360.0];
        [[[NSColor blackColor] colorWithAlphaComponent:0.6] set];
        [circle setLineWidth:20.*scale];
        [centreHairs setLineWidth:2.*scale];
        [centreHairs stroke];
        [circle stroke];
    }

    if(_zoom) [inverseZoomTransform concat]; //------ END THE ZOOM --------------------
    if(mirror) [mirrorTransform concat];    //------ END THE MIRROR ---------------

    //---- Indicate that this is a mirrored view
    if(mirror) {
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"Cassette view (i.e. mirrored)"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont boldSystemFontOfSize:120]
                    range:NSMakeRange(0,str.length)];
        double xmag = _magnify*1.2;
        if(_scrolling) xmag = 1.5/_scrollmag;
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:120.*xmag]
                    range:NSMakeRange(0,str.length)];
        
        if(_scrolling) {
            cRect = _scrollView.documentVisibleRect;
            cRect.origin.x += 0.1*str.size.width;
            cRect.origin.y += cRect.size.height - 1.2* str.size.height;
            cRect.size.width = str.size.width;
            cRect.size.height = str.size.height;

        } else {
            cRect.origin = NSMakePoint(self.bounds.origin.x+120.*_magnify,self.bounds.origin.y+self.bounds.size.height-200.*_magnify);
            cRect.size = NSMakeSize(str.size.width,str.size.height);
        }
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 8.*xmag; bRect.origin.y -= 8.*xmag;
        bRect.size.width += 16.*xmag; bRect.size.height += 16.*xmag;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0*xmag];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];

    }

    //---- Show coordinates of mouse position ----------------------------
    BOOL showiuiviw = NO;
    BOOL showirow = NO;
    BOOL showiwaf = NO;
    BOOL showcas = YES;
    if (_showcoords && infield && !ispdf) {
        NSString * xystr;
        if(iRing > 0) {
            xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, φ = %.1fº\niRing = %d, iPhi = %d",xp,yp,rp,etap,phip,iRing,iPhi];
        } else if([theMapFiles layerOfTiles] && rp > [theMapFiles innerRingRadius]) {
                xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, φ = %.1fº",xp,yp,rp,etap,phip];
        } else {
            xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, φ = %.1fº\nWafer iu:iv = %d:%d",xp,yp,rp,etap,phip,detId[0],detId[1]];
            if(showcas) xystr = [xystr stringByAppendingFormat:@"\nCassette %d",_testCas];
        }

        if(showiwaf) xystr = [xystr stringByAppendingFormat:@"\nWafer = %d",iwafer];
        if(showiuiviw) xystr = [xystr stringByAppendingFormat:@"\niu, iv, iw: %d %d %d",iu,iv,iw];
        if(showirow) xystr = [xystr stringByAppendingFormat:@"; irow = %d",irow];

        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        double xmag = _magnify*1.2;
        if(_scrolling) xmag = 1.8/_scrollmag;
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:52*xmag]
                    range:NSMakeRange(0,str.length)];
        
        if(_scrolling) {
            cRect = _scrollView.documentVisibleRect;
            cRect.origin.x += cRect.size.width - 1.2*str.size.width;
            cRect.origin.y += cRect.size.height - 1.2* str.size.height;
            cRect.size.width = str.size.width;
            cRect.size.height = str.size.height;

        } else {
            cRect.origin = NSMakePoint(self.bounds.origin.x+self.bounds.size.width-1020.*_magnify,self.bounds.origin.y+self.bounds.size.height-50.*_magnify-str.size.height);
            cRect.size = NSMakeSize(str.size.width,str.size.height);
        }
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 8.*xmag; bRect.origin.y -= 8.*xmag;
        bRect.size.width += 16.*xmag; bRect.size.height += 16.*xmag;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0*xmag];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];
    }
    
    if (_showwafercentre && infield && !ispdf) { // ---------- Show wafer centre nominal and retracted
        NSString * wcstr;
        if(iRing > 0) {
            wcstr = @"";
        } else if([theMapFiles layerOfTiles] && rp > [theMapFiles innerRingRadius]) {
            wcstr = @"";
        } else {
            wcstr = [self retractionStringForU: detId[0] andV: detId[1]];
        }
        if(wcstr.length > 0) {
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:wcstr];
            double xmag = _magnify*1.2;
            if(_scrolling) xmag = 1.5/_scrollmag;
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:52*xmag]
                        range:NSMakeRange(0,str.length)];
            
            if(_scrolling) {
                cRect = _scrollView.documentVisibleRect;
                cRect.origin.x += cRect.size.width - 1.2*str.size.width;
                cRect.origin.y += 0.03*cRect.size.height;
                cRect.size.width = str.size.width;
                cRect.size.height = str.size.height;
                
            } else {
                cRect.origin = NSMakePoint(self.bounds.origin.x+self.bounds.size.width-1000.*_magnify,self.bounds.origin.y+50.*_magnify);
                cRect.size = NSMakeSize(str.size.width,str.size.height);
            }
            [[NSColor whiteColor] set];
            NSRect bRect = cRect;
            bRect.origin.x -= 8.*xmag; bRect.origin.y -= 8.*xmag;
            bRect.size.width += 16.*xmag; bRect.size.height += 16.*xmag;
            [NSBezierPath fillRect:bRect];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:2.0*xmag];
            [NSBezierPath strokeRect:bRect];
            [str drawInRect:cRect];
        }
    }

    //------- Show flat-file line -----------------------------------
    if(_showfileline && _lineString.length > 0 && !ispdf && infield) {
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:_lineString];
        double xmag = _magnify;
        if(_scrolling) xmag = 1.5/_scrollmag;

        [str addAttribute:NSFontAttributeName
                    value:[NSFont fontWithName:@"Menlo" size:80.*xmag]
                    range:NSMakeRange(0,str.length)];
        if(_scrolling) {
            cRect = _scrollView.documentVisibleRect;
            cRect.origin.x += 0.03*cRect.size.width;
            cRect.origin.y += 0.03*cRect.size.height; //0.96
            cRect.size.width = str.size.width;
            cRect.size.height = str.size.height;

        } else {
            cRect.origin = NSMakePoint(self.bounds.origin.x+100.*_magnify,self.bounds.origin.y+50.*_magnify);
            //self.bounds.size.height-
            cRect.size = NSMakeSize(str.size.width,str.size.height);
        }
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 16.*xmag; bRect.origin.y -= 10.*xmag;
        bRect.size.width += 32.*xmag; bRect.size.height += 20.*xmag;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0*xmag];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];
    }


    if (ispdf)    {
        //[string0 drawAtPoint:t0point withAttributes:textAttributes];
        if(_pdfShowSummary) {
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:string0];
            [str addAttributes:textAttributes range:NSMakeRange(0,str.length)];
            cRect = NSMakeRect(t0point.x,t0point.y,str.size.width,str.size.height);
            [[NSColor whiteColor] set];
            NSRect bRect = cRect;
            if(_scrolling) {
                bRect.origin.x -= 16./_scrollmag; bRect.origin.y -= 10./_scrollmag;
                bRect.size.width += 32./_scrollmag; bRect.size.height += 20./_scrollmag;
            } else {
                bRect.origin.x -= 16.; bRect.origin.y -= 10.;
                bRect.size.width += 32.; bRect.size.height += 20.;
            }
            [NSBezierPath fillRect:bRect];
            [[NSColor blackColor] set];
            double lw = 3.;
            if(_scrolling) lw /= _scrollmag;
            [NSBezierPath setDefaultLineWidth:lw];
            [NSBezierPath strokeRect:bRect];
            [str drawInRect:cRect];
        }
        
        if(_pdfShowKey && !_scrolling) {
            double yoff = 0.;
            double width;
            for (int i=0; i<4; i++) {
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:waferThicknessNames[i]];
                [str addAttributes:keyAttributes range:NSMakeRange(0,str.length)];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:fsize*1.6]
                            range:NSMakeRange(6,1)];
                if(i == 0) width = str.size.width;
                cRect = NSMakeRect(keypoint.x,keypoint.y + yoff,width,str.size.height);
                NSColor * col = waferThicknessColors[i];
                [col set];
                NSRect bRect = cRect;
                bRect.origin.x -= 16.; bRect.origin.y -= 10.;
                bRect.size.width += 32.; bRect.size.height += 20.;
                [NSBezierPath fillRect:bRect];
                [[NSColor blackColor] set];
                [NSBezierPath setDefaultLineWidth:4.0];
                [NSBezierPath strokeRect:bRect];
                [str drawInRect:cRect];
                yoff += keydelta;
            }
        }

        if(_pdfShowHexDate) {
            float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
            int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
            
            NSString * vstamp = [NSString stringWithFormat:@"Hex version %.2f(%d), ",version,build];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MMM-Y"];
            vstamp = [vstamp stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
            [vstamp drawAtPoint:t1point withAttributes:textAttributes];
        }
        
    }
    _tDraw = (t0 - [today timeIntervalSinceNow])*1000.;

}

- (void) drawZbars {
    /*
    double r1[14] = {1546.4,1539.2,1548.8,1558.5,1568.1,1577.7,1587.4,
                     1597.0,1606.7,1616.8,1627.5,1638.1,1668.8,1694.9};

    double r2[14] = {1485.0,1491.7,1500.0,1508.3,1516.6,1524.9,1533.3,
                     1541.6,1549.9,1558.6,1567.8,1577.0,1586.2,1593.2};
 */
    double r1[14] = {1546.4,1539.2,1548.8,1558.5,1568.1,1577.7,1587.4,
                     1597.0,1606.7,1616.8,1627.5,1644.1,1668.8,1694.9};

    double r2[14] = {1482.0,1488.7,1497.0,1505.3,1513.6,1521.9,1530.3,
                     1538.6,1546.9,1555.6,1564.8,1574.0,1583.2,1590.2};

    double wid = 70.;
    double yshift = 70.;
    
    int ibar = (_nLayer+1)/2;
    
    NSBezierPath * zBrickC = [NSBezierPath bezierPath];    //---- Build "Central" Zbar at 90º
    [zBrickC moveToPoint:NSMakePoint(-wid*0.5,r2[ibar])];  //
    [zBrickC lineToPoint:NSMakePoint(+wid*0.5,r2[ibar])];
    [zBrickC lineToPoint:NSMakePoint(+wid*0.5,r1[ibar])];
    [zBrickC lineToPoint:NSMakePoint(-wid*0.5,r1[ibar])];
    [zBrickC closePath];
    [zBrickC setLineWidth:0.5];
    
    NSBezierPath * zBrickI = [NSBezierPath bezierPath];   //---- Build "Interconnecting" Zbar at 0º 0,60,120,...
    [zBrickI moveToPoint:NSMakePoint(r2[ibar],-yshift-wid*0.5)];
    [zBrickI lineToPoint:NSMakePoint(r2[ibar],-yshift+wid*0.5)];
    [zBrickI lineToPoint:NSMakePoint(r1[ibar],-yshift+wid*0.5)];
    [zBrickI lineToPoint:NSMakePoint(r1[ibar],-yshift-wid*0.5)];
    [zBrickI closePath];
    [zBrickI setLineWidth:0.5];

    [[NSColor blueColor] set];
    [zBrickI fill];
    [zBrickC fill];
    [[NSColor blackColor] set];
    [zBrickI stroke];
    [zBrickC stroke];

    
    for (int i=0; i<5; i++) {
        zBrickI = [sixtyTransform transformBezierPath:zBrickI];
        zBrickC = [sixtyTransform transformBezierPath:zBrickC];
        [[NSColor blueColor] set];
        [zBrickI fill];
        [zBrickC fill];
        [[NSColor blackColor] set];
        [zBrickI stroke];
        [zBrickC stroke];
    }
   /*
    int crap[3][2] = {0,1, 2,3, 4,5};
    
    NSLog(@"crap[1][1] = %d",crap[1][1]);
    NSLog(@"crap[2][0] = %d",crap[2][0]);
    //gives:
    //crap[1][1] = 3
    //crap[2][0] = 4
   */
}

@end
