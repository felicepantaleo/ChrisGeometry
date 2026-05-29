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

const double tanthetCMSSWInr = 0.0774; // value that reproduces CMSSW behaviour

const int maxwhole = 750;
const int maxrad = 120;

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
  
        _magnify = 1.0;
        rt3 = sqrt(3.0);
        
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(newRings:)
                   name:EtaRingsUpdateNotification
                 object:nil];

        theRings = [HXGEtaRingsControl sharedEtaRings];
        netarings = 0;
        showtext = NO;
        
        beam = [NSBezierPath bezierPath];
        [beam appendBezierPathWithArcWithCenter:NSZeroPoint radius:rbeam startAngle:0.0 endAngle:360.0];
        
        _showcoords = NO;
        tstart = [NSDate timeIntervalSinceReferenceDate];
 
        scintcolor = [[NSColor paleBlue] colorWithAlphaComponent:0.7];
        
        NSColor * c2 = [NSColor greyBlue]; // 300 µm
        NSColor * c1 = [NSColor sageGreen];   // 200 µm
        NSColor * c0 = [NSColor peachOrange]; ///kharkiBrown];     // 120 µm
        
        waferThicknessColors = [NSArray arrayWithObjects:c0,c1,c2,nil];
        
        _showtestspot = NO;
        limitedSearch = NO;
                
        double axisLineWidth = 10.;
        double axlen = (xmax-xmarg)*0.97;
        
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
    
    thirtyTransform = [[NSAffineTransform alloc] init];
    [thirtyTransform rotateByDegrees:30.];

    return self;
}

#pragma mark - setup methods

- (void) setColors:(NSArray *) hexcols {
    col0 = [hexcols objectAtIndex:0];
    col1 = [hexcols objectAtIndex:1];
    col2 = [hexcols objectAtIndex:2];
    col3 = [hexcols objectAtIndex:3];
}

- (void) setWaferSize:(double) fsize {
    ftof = fsize;
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

    _numberWafers  = (flags&1)  != 0;
    _useDetId      = (flags&2)  != 0;
    _useV17        = (flags&4)  != 0;
    _rotateRotated = (flags&8)  != 0;
    _showGrid      = (flags&16) != 0;
    _showCassettes = (flags&32) != 0;
    _markZero      = (flags&64) != 0;
    _markTypeOne   = (flags&128)!= 0;

}

- (void) setHexFrame:(NSRect)fRect {
    frameRect = fRect;
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
    double xr = xp;
    double yr = yp;
    if(_rotate30 && _rotateRotated) {
        xp = xr*cos(M_PI/6.) - yr*sin(M_PI/6.);
        yp = xr*sin(M_PI/6.) + yr*cos(M_PI/6.);
    }
    
    [self setNeedsDisplay:YES];
}

#pragma mark - notifications

- (void) newRings:(NSNotification *) note {
    
    etaRings = [theRings getEtaRings:&netarings];
    drawSpokes = theRings.drawPhiSpokes;
    [self setNeedsDisplay:YES];
}

- (void) updateDisplay:(NSNotification *) note {
    
    /*
    if([[note userInfo] objectForKey:@"done"]) {
        for (int i=0; i<nob; i++) {
            HXGWafer * w = [wafers objectAtIndex:obw[i]];
            obp[i] = w.partType;
            if(obp[i]==3) obr[i] = w.ivertex;
            else obr[i] = w.first;
        }
    }
     */
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
    
    nhex = 0;
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
            HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:nhex andDetId:did];
            [wafers addObject:w];
            [wholes addObject:[w waferBezier]];
            nhex++;
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
    
    nhex = 0;
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
            HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:nhex andDetId:did];
            [wafers addObject:w];
            [wholes addObject:[w waferBezier]];
            nhex++;
            x += dx;
        }
        y += dy;
    }
}

- (void) layoutFromFiles {
  
    for (int i = 0; i<nhex; i++) {
        HXGWafer * w = [wafers objectAtIndex:i];
        w.whole = NO;
        w.part = NO;
    }
    
    if(waferThickness) free(waferThickness);
    waferThickness = calloc(nhex, sizeof(int));

    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    
    [theMapFiles makeTileBeziersForLayer:_nLayer];
    
    NSArray * layerString = [theMapFiles getMapStringsForLayer:_nLayer];
    
    int ltest;
    int tnum;
    double xw, yw;
    int ncas;
    int jrot;
    int idd[2];
    char thick[100];

    for(int i=0; i<11; i++) {partialCount[i]=0;}
    thickCount[0]=0; thickCount[1]=0; thickCount[2]=0;
    
    for(int i=0; i<layerString.count; i++) {
        const char * l = [layerString[i] UTF8String];

        int thickflag=-1;

        int iret = sscanf(l,"%d %d %s %lf %lf %d %d %d %d",&ltest,&tnum,thick,&xw,&yw,&jrot,&idd[0],&idd[1],&ncas);
        if(iret < 8) NSLog(@"flat file problem!!!");
        NSString * thickStr = [NSString stringWithUTF8String:thick];
        int il = (int) thickStr.length;
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"300"]) thickflag = 2;
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"200"]) thickflag = 1;
        if([[thickStr substringFromIndex:il-3] isEqualToString: @"120"]) thickflag = 0;
        BOOL LD = [[thickStr substringToIndex:1] isEqualToString: @"l"];
        
        int symcount = 1; // using 360º files
        for(int j=0; j<symcount; j++) {
            int iw = [self waferFromDetId:idd];
            HXGWafer * w = [wafers objectAtIndex:iw];
            w.LD = LD;
            w.type = tnum;
            w.thickflag = thickflag;
            w.cassette = ncas;
            w.v17 = _useV17;
            w.channelZero = (jrot + 2*j)%6;
            w.fileLine = theMapFiles.firstLine + i;
            if(_useV17) [w markerBezier];
            if(tnum == 0) {
                w.whole = YES;
                thickCount[thickflag++]++;
            } else {
                w.part = YES;
                int index = -1;
                if(!LD) index = 5;
                partialCount[tnum + index]++;
            }
            [w constructWaferBezier];
            waferThickness[iw] = thickflag;
        }
    }
    
    if(_useV17) [self makeCassetteBezier];

}

- (void) makeCassetteBezier {
    
    /*--------------------------------------------
      Notes on the logic in Notes app
      --------------------------------------------*/
    cassetteBezier = [NSBezierPath bezierPath];
    
    for (int i = 0; i<nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole || wafer.part) {
            int * idd = wafer.detId;
            int jdd[2];
            jdd[0] = idd[0]+1;
            jdd[1] = idd[1];
            int iw = [self waferFromDetId:jdd];
            HXGWafer * nextw[3];
            nextw[0] = [wafers objectAtIndex:iw];
            jdd[1]++;
            iw = [self waferFromDetId:jdd];
            nextw[1] = [wafers objectAtIndex:iw];
            jdd[0] = idd[0];
            jdd[1] = idd[1]+1;
            iw = [self waferFromDetId:jdd];
            nextw[2] = [wafers objectAtIndex:iw];
            for (int ln=0; ln<3; ln++) {
                if(wafer.cassette != nextw[ln].cassette && [self lineStartingAt:ln+1 Between:wafer And:nextw[ln]]) {
                    [cassetteBezier moveToPoint:lineStart];
                    [cassetteBezier lineToPoint:lineEnd];
                }
            }
        }
    }
    
    [cassetteBezier setLineWidth:8.];
}

- (BOOL) lineStartingAt: (int) n Between:(HXGWafer *) w1 And:(HXGWafer *) w2 {
   
    if((!w1.part && !w1.whole) || (!w2.part && !w2.whole)) return NO;
    
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
        1,1,1,2,0,2,   // HD 3
        2,0,2,1,1,1,   // HD 4
        1,1,1,2,0,2    // HD 5
    };

    int mm1[3] = {5,0,1}; // set up m1 and m2 to correspond to corners in w2
    int mm2[3] = {4,5,0}; // matching n and n+1 in w1
    int m1 = mm1[n-1];
    int m2 = mm2[n-1];
    int p1 = 6 - w1.channelZero;
    int p2 = 6 - w2.channelZero;
    
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
        if(test[index][(p2+m2)%6] == 2) {
            if(index == 6 || index == 10) frac = 1. - frac;
            double x = frac*w2.corner[m1].x + (1.-frac)*w2.corner[m2].x;
            double y = frac*w2.corner[m1].y + (1.-frac)*w2.corner[m2].y;
            lineStart = NSMakePoint(x,y);
            lineEnd = w2.corner[m2];
            return YES;
        }
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
    if(test[index][(p1+n+1)%6] == 2) {
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
    if(test[index][(p2+m2)%6] == 2) {
        if(index == 6 || index == 10) frac = 1. - frac;
        double x = frac*w1.corner[n+1].x + (1.-frac)*w1.corner[n].x;
        double y = frac*w1.corner[n+1].y + (1.-frac)*w1.corner[n].y;
        lineEnd = NSMakePoint(x,y);
    }


    return YES;
}

- (void) drawHexGrid {

    [self setFrame:frameRect];
    
    NSRect bounds = NSMakeRect(-_magnify*xmax,-_magnify*ymax,2.0*_magnify*xmax,2.0*_magnify*ymax);
    [self setBounds:bounds];
    
    [self setNeedsDisplay:YES];
}

- (void) makeRings {
    
    for (int i=0; i<netarings; i++) {
        double t = exp(-etaRings[i]);
        double the = 2.0*atan2(t,1.);
        double rrr = _zLayer*tan(the);
        yeta[i] = -rrr;
        etaRingBezier[i] = [NSBezierPath bezierPath];
        [etaRingBezier[i] appendBezierPathWithArcWithCenter:NSZeroPoint radius:rrr startAngle:0.0 endAngle:360.0];
        [etaRingBezier[i] setLineWidth:4.0];
    }
}

- (void) zoomOnTestPoint:(BOOL) z {
    
    zoom = z;
    zoomTransform = [NSAffineTransform transform];
    inverseZoomTransform = [NSAffineTransform transform];
    if(zoom) {
        double magz = 4.;
        [zoomTransform translateXBy:-magz*testpoint.x yBy:-magz*testpoint.y];
        [zoomTransform scaleBy:magz];
        inverseZoomTransform = [inverseZoomTransform initWithTransform:zoomTransform];
        [inverseZoomTransform invert];
    }
    
    [self setNeedsDisplay:YES];
    
}
#pragma mark - accessing the information

- (int *) getThickCount;
{
    
    thickCount[0]=0; thickCount[1]=0;thickCount[2]=0;
    for(int i=0;i<nhex;i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole) thickCount[wafer.thickflag]++;
    }

    return thickCount;
}

- (NSString *) waferSummary {
    
    NSString * summary;
    summary = [NSString stringWithFormat:@", flat-to-flat = %.2f mm\n",ftof];
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
/*    }
    
    
    BOOL none = YES;
    if(nhalf > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"a:%d ",nhalf];
        partialCount[0]+=nhalf;
    }
    
    if(nfive > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"b:%d ",nfive];
        partialCount[1]+=nfive;
    }
    
    if(nthree > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"c:%d ",nthree];
        partialCount[2]+=nthree;
    }
    
    if(nsemi > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"d:%d ",nsemi];
        partialCount[3]+=nsemi;
    }
    
    if(nsemiminus > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"dm:%d ",nsemiminus];
        partialCount[10]+=nsemiminus;
    }
    
    if(npart5a > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"e:%d ",npart5a];
        partialCount[4]+=npart5a;
   }
    
    if(npart5b > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"f:%d ",npart5b];
        partialCount[5]+=npart5b;
    }
    
    if(nchoptwos > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"g:%d ",nchoptwos];
        partialCount[6]+=nchoptwos;
    }
    
    if(nchoptwominus > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"gm:%d ",nchoptwominus];
        partialCount[11]+=nchoptwominus;
    }
    
    if(nchopfours > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"h:%d ",nchopfours];
        partialCount[7]+=nchopfours;
    }
    
    if(nthreeplus > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"i:%d ",nthreeplus];
        partialCount[8]+=nthreeplus;
    }
    
    if(nfourplus > 0)
    {
        none = NO;
        summary = [summary stringByAppendingFormat:@"j:%d ",nfourplus];
        partialCount[9]+=nfourplus;
    }
    
    if(none) summary = [summary stringByAppendingString:@"none"];

    return summary;
 */
}

- (NSString *) getFileStrings {
    
    NSString * fileStrings = [NSString stringWithString:theMapFiles.waferFlatFile];
    fileStrings = [fileStrings stringByAppendingString:@"\n-  "];
    fileStrings = [fileStrings stringByAppendingString:theMapFiles.tileFlatFile];
    
    return fileStrings;
}

- (void) countCheck {
   
    int nfull = 0;
    int npart = 0;
    for (int i = 0; i<nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole) nfull++;
        if(wafer.part) npart++;
    }
    _nwhole += nfull;
    _npartial += npart;

    if(_nLayer == 46) NSLog(@"TOTALS: nfull = %d, npart = %d, ntot = %d",_nwhole,_npartial,_nwhole+_npartial);

}

#pragma mark - wafer manipulations
- (int) stateAtPoint: (NSPoint) pnt {
    
    /* -------------------------------------------
        Revised 23 Feb 2022
        istate: 0 - no sensor
                1 - three
                2 - other partial
                3 - whole
                4 - tile in complete ring
                5 - tile in incomplete ring
       ------------------------------------------- */

    int istate = 999.;
    NSPoint point = pnt;
    
    if([theMapFiles.tileBodyBez containsPoint:pnt]) return 4;
    if([theMapFiles.incompleteTileRingsBez containsPoint:pnt]) return 5;

    iwafer = [self fastWaferFromPoint:pnt];
    HXGWafer * wafer = [wafers objectAtIndex:iwafer];

    if(wafer.whole) {
        istate = 3;
    } else if(wafer.part) {
        NSRect dRect = wafer.decisionRect;
        double divisor = dRect.size.width;
        if(fabs(divisor) < 1.E-10) divisor = 1.E-10;
        double m = dRect.size.height/divisor;
        double c = dRect.origin.y - dRect.origin.x*m;
        double condition = c*(m*point.x + c - point.y);
        double r = sqrt(point.x*point.x + point.y*point.y);
        if((condition > 0. && (r > 700.)) || (condition < 0. && (r<700.))) {
            istate = 2;
            if(wafer.type == 6) istate = 1;
        } else istate = 0;
    } else istate = 0;
    
    return istate;

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

- (int) waferFromDetId:(int *) aDetId {
    
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

#pragma mark - PDF

- (void) savePDF:(NSString *)path With:(NSString *)summary {
    
    [self setStandardTextAttributes];
        
    showtext = YES;
    string0 = summary;
    
    NSData * data;
    NSRect b = [self bounds];
    NSRect f = [self frame];
    f.origin = b.origin; // Strange but true...
    f.size.width *= 1.414;
    
    data = [self dataWithPDFInsideRect:f];

    [data writeToFile:path options:0 error:nil];

    //---- Back to normal after writing the file
    showtext = NO;
    
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

- (void) setStandardTextAttributes {
    
    t0point.x =  2400.0 * _magnify;
    t0point.y =  1400.0 * _magnify;
    t1point.x =  2500.0 * _magnify;
    t1point.y = -2130.0 * _magnify;
    fsize = 64.0;
    fontName = @"Lucida Grande";
    font = [NSFont fontWithName:fontName size:fsize];
    
    textAttributes =  [NSMutableDictionary
                       dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:fsize],NSFontAttributeName,
                       [NSColor blackColor],NSForegroundColorAttributeName,
                       [NSColor whiteColor],NSBackgroundColorAttributeName, nil];
    [textAttributes setObject:font
                       forKey:NSFontAttributeName];

}

- (void) setSpecialTextAttributes {
    
    t0point.x = 1320.0;
    t0point.y = 1550.0;
    t1point.x = 2700.0;
    t1point.y = -2100.0;
    fsize = 80.0;
    fontName = @"Lucida Grande";
    font = [NSFont fontWithName:fontName size:fsize];
    
    textAttributes =  [NSMutableDictionary
                       dictionaryWithObjectsAndKeys:
                       [NSFont systemFontOfSize:fsize],NSFontAttributeName,
                       [NSColor blackColor],NSForegroundColorAttributeName, nil];
    [textAttributes setObject:font
                       forKey:NSFontAttributeName];
        
}

#pragma mark - mouse stuff

- (void) mouseMoved:(NSEvent *)theEvent {
    
    [self mouseMovedToPoint:[theEvent locationInWindow]];

}
    
- (void) mouseMovedToPoint:(NSPoint) point {
    
    if(!_showcoords && !_showfileline) return;
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
    infield = YES;

    mousePoint = [self convertPoint:point fromView: nil];
    if(zoom) {
        mousePoint = [inverseZoomTransform transformPoint:mousePoint];
    }

    xp = mousePoint.x;
    yp = mousePoint.y;

    double xr = xp;
    double yr = yp;
    if(_rotate30 && _rotateRotated) {
        xr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
    }

    lwafer = iwafer;
    iwafer = [self fastWaferFromPoint:NSMakePoint(xr,yr)];

    if(_showfileline && iwafer != lwafer) {
        if(iwafer >= wafers.count) _lineString = @"";
        else {
            HXGWafer * wafer = [wafers objectAtIndex:iwafer];
            if(wafer.part || wafer.whole ) {
                _lineString = [NSString stringWithFormat:@"Line %d: ",wafer.fileLine+1];
                _lineString = [_lineString stringByAppendingString:[theMapFiles getLineNumber:wafer.fileLine]];
            } else _lineString = @"";
        }
        if(!_showcoords) {
            [self setNeedsDisplay:YES];
            return;
        }
    }

    rp = sqrt(xp*xp + yp*yp);
    iRing = [theMapFiles tileRingForRadius:rp andLayer:_nLayer];
    double theta = atan2(rp,_zLayer);
    etap = -log(tan(theta*0.5));
    phip = 180.0*atan2(yp,xp)/M_PI;
    if(phip < 0.) phip = 360. + phip;
    iPhi = (int) (phip*288./360.);
    if(iRing < 0) [self waferDetIdAtPoint:NSMakePoint(xr,yr)];

    [self setNeedsDisplay:YES];
}
- (void)mouseDown:(NSEvent *)theEvent {
    
    if([theEvent clickCount] > 1 || [theEvent modifierFlags]&NSEventModifierFlagShift) {
        /*---- Old method
        NSPoint mousePoint = [theEvent locationInWindow];
        xp = (mousePoint.x - 5.0) * 2.0 * xmax/frameRect.size.width - xmax;
        yp = (mousePoint.y - 3.0) * 2.0 * ymax/frameRect.size.height - ymax;
        xp *= _magnify;
        yp *= _magnify;
        */
        
        mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
        
        if(zoom) {
            mousePoint = [inverseZoomTransform transformPoint:mousePoint];
        }
        xp = mousePoint.x;
        yp = mousePoint.y;

        double xr = xp;
        double yr = yp;
        if(_rotate30 && _rotateRotated) {
            xr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
            yr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
        }

        testpoint = NSMakePoint(xp,yp);
        if(zoom) [self zoomOnTestPoint:YES];

        double r = sqrt(xr*xr + yr*yr);
        double theta = atan2(r,_zLayer);
        etap = -log(tan(theta*0.5));
        phip = 180.0*atan2(yr,xr)/M_PI;
        
        if(!thePosition) thePosition = [HXGPositionControl sharedPositionControl];
        [thePosition setState:YES eta:etap phi:phip];
        [thePosition notify];

    } else if([theEvent modifierFlags]&NSEventModifierFlagControl) {
        
        [self inspectorRequest:(NSEvent *) theEvent];
        
    }
    
}

- (void)rightMouseDown:(NSEvent *) theEvent {
    
    [self inspectorRequest:(NSEvent *)theEvent];
}

- (void) inspectorRequest:(NSEvent *) theEvent {
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    if(zoom) mousePoint = [inverseZoomTransform transformPoint:mousePoint];

    xp = mousePoint.x;
    yp = mousePoint.y;
    
    double xr = xp;
    double yr = yp;
    if(_rotate30 && _rotateRotated) {
        xr = xp*cos(-M_PI/6.) - yp*sin(-M_PI/6.);
        yr = xp*sin(-M_PI/6.) + yp*cos(-M_PI/6.);
    }

    inwafer = [self fastWaferFromPoint:NSMakePoint(xr,yr)];
    if(inwafer < 0 || inwafer >= wafers.count) return;
    
    HXGWafer * w = [wafers objectAtIndex:inwafer];
    
    if(!theInspector) theInspector = [HXGWaferInspectorControl sharedInspectorControl];
    theInspector.mousePoint = [theEvent locationInWindow];
    [theInspector showWindow:nil];
    theInspector.inspectorView.rotated = _rotate30;
    theInspector.inspectorView.rotateRotated = _rotateRotated;
    [theInspector showSpecsForWafer:w];


}
#pragma mark - catch keyboard events

- (void) keyDown:(NSEvent *) theEvent {
    
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    unichar const cup    = 0xf700;
    unichar const cdown  = 0xf701;
    unichar const cleft  = 0xf702;
    unichar const cright = 0xf703;
    
    NSUInteger modifiers = ([NSEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask);
    
    if (modifiers == NSEventModifierFlagShift) {
        //NSLog(@"Shift with code %0x",code);
        if(code == 0x5f) _magnify = MIN(_magnify*1.12,1.2544);
        else if(code == 0x2b) _magnify = MAX(_magnify/1.12,0.7117802478);
        
        [self drawHexGrid];
    }

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

- (void)drawRect:(NSRect)dirtyRect        //-----     drawRect
{
    [self setFrame:frameRect];
    
    if(zoom) [zoomTransform concat];
    
    if(_rotate30 && _rotateRotated) [thirtyTransform concat];
    
    double w = 1.0;
    [[NSColor blackColor] set];

    //---- Draw the grid -----------------------------------------
    if(_showGrid && !(_rotate30 && _rotateRotated)) {
        for (int i = 0; i<nhex; i++) {
            NSBezierPath * path = [wholes objectAtIndex:i];
            [path setLineWidth:w];
            [path stroke];
        }
    }
  
    //---- Draw the tiles -----------------------------------------
    if([theMapFiles layerOfTiles]) {
        [[NSColor fadedBlue] set];
        [[theMapFiles tileBodyBez] fill];
        
        if (_numberWafers) { // Special coloured rings for numbering
            [[NSColor pastelBlue]set];
            [[theMapFiles tensTileRingsBez] fill];
            [[NSColor paleBlue] set];
            [[theMapFiles fivesTileRingsBez] fill];
        }

        [[NSColor blackColor] set];
        [[theMapFiles tileBodyOutlineBez] setLineWidth:4.0];
        [[theMapFiles tileBodyOutlineBez] stroke];
        
        [[NSColor fadedBlue] set];
        [[theMapFiles incompleteTileRingsBez] fill];
        [[NSColor blackColor] set];
        [[theMapFiles incompleteTileRingsBez] setLineWidth:4.0];
        [[theMapFiles incompleteTileRingsBez] stroke];
    }

    //---- Draw the wafers --------------------------------------------
    w = 3.0;
    [NSBezierPath setDefaultLineWidth:w];
    for (int i = 0; i<nhex; i++) {
        HXGWafer * wafer = [wafers objectAtIndex:i];
        if(wafer.whole || wafer.part) {
            NSBezierPath * path = wafer.bezier;
            NSColor * col = [waferThicknessColors objectAtIndex:wafer.thickflag];
            [col set];
            [path fill];
            if(_markZero && _useV17 && wafer.whole) {
                if(_markTypeOne) {
                    [[NSColor redColor] set];
                    [wafer.zeroBezier fill];
                    [[NSColor blackColor] set];
                    [wafer.zeroBezier stroke];
                } else {
                    [[NSColor coolGrey] set];
                    [wafer.barBezier fill];
                }
            }
            [[NSColor blackColor] set];
            [path setLineWidth:w];
            [path stroke];
        }
    }
    
    //---- Spot marking (0,0): the beam line
    [[NSColor blackColor] set];
    [beam fill];
    
    //---- Mark the cassette boundaries
    if(_useV17 && _showCassettes) {
        [[NSColor ivoryWhite] set];
        [cassetteBezier stroke];
    }
  
    //---- Draw u,v axes ---------------------------------------------
    if(_showaxes) {
        double fsize = 160.;
        if(showtext) {
            fsize = 320;
            [uaxis setLineWidth: 18.];
            [vaxis setLineWidth: 18.];
        }
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
        [str drawAtPoint:uaxlabel];
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

    //---- Rotation of rotated layers (end it here)
    if(_rotateRotated && _rotate30) {
        [thirtyTransform invert];
        [thirtyTransform concat];
        [thirtyTransform invert];
    }
    //---- Draw x,y axes ---------------------------------------------
    if(_showaxes) {
        double fsize = 160.;
        if(showtext) {
            fsize = 320;
            [minusxaxis setLineWidth: 18.];
            [plusxaxis setLineWidth: 18.];
            [yaxis setLineWidth: 18.];
            xmaxlabel.y = 20.;
            xpaxlabel.y = - fsize - 20.;
        }
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
        [str drawAtPoint:yaxlabel];
    }

    //---- Wafer numbering --------------------------------------------------
    int * did;
    if(_numberWafers) {
        for (int i = 0; i<nhex; i++) {
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
            if((wafer.whole || wafer.part)&&([theMapFiles innerRingRadiusForLayer:_nLayer] > wafer.rc)) {
                double xd = wafer.xc;
                double yd = wafer.yc;
                if(_rotate30 && _rotateRotated) {
                    xd = wafer.xc * cos(M_PI/6.) - wafer.yc * sin(M_PI/6.);
                    yd = wafer.xc * sin(M_PI/6.) + wafer.yc * cos(M_PI/6.);
                }
                [str drawAtPoint:NSMakePoint(xd - 0.5*str.size.width,yd-0.5*str.size.height)];
            }
        }
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

    //---- phi spokes --------------------------------------
    if(drawSpokes) {
        double dphi = M_PI/18.;
        double phi = 0.;
        double r0 = 100.;
        double r1 = 2000.;
        [[NSColor blueColor] set];
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
    
    //---- eta rings -----------------------------------------------------------
    if(netarings > 0) {
        [self makeRings];
        for (int i=0; i<netarings; i++) {
            [[NSColor redColor] set];
            [etaRingBezier[i] setLineWidth:6.0];
            [etaRingBezier[i] stroke];
            NSString * etastr = [NSString stringWithFormat:@"η = %.2f",etaRings[i]];
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:etastr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:52]
                        range:NSMakeRange(0,str.length)];
            NSRect etaRect;
            etaRect.size.width = [str size].width + 18.0;
            etaRect.size.height = [str size].height + 10.0;
            etaRect.origin.x = - 0.5*etaRect.size.width;
            etaRect.origin.y = yeta[i] - 0.5*etaRect.size.height + 4.;
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:etaRect];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:2.0];
            [NSBezierPath strokeRect:etaRect];
            [str drawAtPoint:NSMakePoint(etaRect.origin.x+9.,etaRect.origin.y+8.)];
       }
    }
    
    
    if(_showtestspot && !showtext) {
        testspot = [NSBezierPath crossHairsAt:testpoint withRadius:50.];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:testpoint radius:50. startAngle:0.0 endAngle:360.0];
        [[NSColor blackColor] set];
        [circle setLineWidth:10.];
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

    if(zoom) [inverseZoomTransform concat]; //------ END THE ZOOM --------------------
    
    //---- Show coordinates of mouse position ----------------------------
    BOOL showiuiviw = NO;
    BOOL showirow = NO;
    BOOL showiwaf = YES;
    if (_showcoords && infield && !showtext) {
        NSString * xystr;
        if(iRing > 0) {
            xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, phi = %.1fº\niRing = %d, iPhi = %d",xp,yp,rp,etap,phip,iRing,iPhi];
        } else if([theMapFiles layerOfTiles] && rp > [theMapFiles innerRingRadiusForLayer:_nLayer]) {
                xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, phi = %.1fº",xp,yp,rp,etap,phip];
        } else {
            xystr = [NSString stringWithFormat:@"(x, y) = (%.1f, %.1f); r = %.1f\nη = %.3f, phi = %.1fº\ndetId: %d %d",xp,yp,rp,etap,phip,detId[0],detId[1]];
        }
        if(showiwaf) xystr = [xystr stringByAppendingFormat:@"\nWafer = %d",iwafer];
        if(showiuiviw) xystr = [xystr stringByAppendingFormat:@"\niu, iv, iw: %d %d %d",iu,iv,iw];
        if(showirow) xystr = [xystr stringByAppendingFormat:@"; irow = %d",irow];

        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:52*_magnify]
                    range:NSMakeRange(0,str.length)];
        
        cRect = NSMakeRect(1300.0*_magnify,(ymax-150.-str.size.height)*_magnify,str.size.width,str.size.height);
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 8.; bRect.origin.y -= 8.;
        bRect.size.width += 16.; bRect.size.height += 16.;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];
    }
    
    //------- Show flat-file line -----------------------------------
    if(_showfileline && _lineString.length > 0) {
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:_lineString];
        [str addAttribute:NSFontAttributeName
//                    value:[NSFont systemFontOfSize:80*_magnify]
                    value:[NSFont fontWithName:@"Menlo" size:80*_magnify]
                    range:NSMakeRange(0,str.length)];
        
        cRect = NSMakeRect((-ymax+200.)*_magnify,(ymax-50.-str.size.height)*_magnify,str.size.width,str.size.height);
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 16.; bRect.origin.y -= 10.;
        bRect.size.width += 32.; bRect.size.height += 20.;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];
    }

    if (showtext)    {
        //[string0 drawAtPoint:t0point withAttributes:textAttributes];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:string0];
        [str addAttributes:textAttributes range:NSMakeRange(0,str.length)];
        cRect = NSMakeRect(t0point.x,t0point.y,str.size.width,str.size.height);
        [[NSColor whiteColor] set];
        NSRect bRect = cRect;
        bRect.origin.x -= 16.; bRect.origin.y -= 10.;
        bRect.size.width += 32.; bRect.size.height += 20.;
        [NSBezierPath fillRect:bRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:2.0];
        [NSBezierPath strokeRect:bRect];
        [str drawInRect:cRect];

        float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
        int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        
        NSString * vstamp = [NSString stringWithFormat:@"Hex version %.1f(%d), ",version,build];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MMM-Y"];
        vstamp = [vstamp stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
        [vstamp drawAtPoint:t1point withAttributes:textAttributes];
    }
}

@end
