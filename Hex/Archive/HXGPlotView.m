//
//  HXGPlotView.m
//  Hex
//
//  Created by Chris Seez on 16/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGPlotView.h"

NSString * const HXGdragUpdateNotification = @"HXGdragUpdate";



@implementation HXGPlotView

- (id)initWithFrame:(NSRect)frame
{
    NSRect games = frame;
    games.origin = NSZeroPoint;
    self = [super initWithFrame:games];
    
    if (self) {

        frameRect = frame;
        pdf = NO;
        twenty = NO;
        sliceactive = NO;
        makingprofile = NO;
        dragging = NO;
        newplotimage = YES;
        
        nstart = 8;
        nrot = 4;
        nrollup = 30;
        if(_xslice < 1.) _xslice = 0.3*frameRect.size.width;
        
        NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(dragUpdate:)
                   name:HXGdragUpdateNotification
                 object:nil];
    }
    
    return self;
}

- (void) changeColors {
    [colorControl showWindow:nil];
}
- (void) setPlotFrame:(NSRect)fRect { // ********* UNUSED **************
    
    //------ treating this as the init
    frameRect = fRect;
    pdf = NO;
    twenty = NO;
    sliceactive = NO;
    makingprofile = NO;
    dragging = NO;
    newplotimage = YES;
    
    nstart = 8;
    nrot = 4;
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(dragUpdate:)
               name:HXGdragUpdateNotification
             object:nil];

} // ***********************************************************************

- (void) setShortTitle:(NSString *) s {
    shorttitle = s;
}

- (void) setPlotParams: (int) nbinx and: (int) nbiny scale: (double) scale {
    nx = nbinx;
    ny = nbiny;
    bscl = scale;
    plotwidth = (double) nx * scale;
    plotheight = (double) ny * scale;
}

- (void) setPlotDimensions: (double) bsz xlow: (double) x0 ylow: (double) y0 {
    binsize = bsz;
    xlow = x0;
    ylow = y0;
}

- (double) loadPlotData: (double *) d and: (double *) e{
    
    scalemaxDat = 0.;
    scalemaxDep = 0.;
    plotdata = d;
    depthdata = e;
    for (int i=0; i<nx*ny; i++) {
        if(plotdata[i] > scalemaxDat) scalemaxDat = plotdata[i];
        if(depthdata[i] > scalemaxDep) scalemaxDep = depthdata[i];
    }
    
    /*scalemaxDat = 10. * (double) ((int)(scalemaxDat*0.1));
    scalemaxDep = 10. * (double) ((int)(scalemaxDep*0.1));
    scalemaxDat = MAX(scalemaxDat,10.);
    scalemaxDep = MAX(scalemaxDep,10.); */
    
    scalemaxDat *= 0.9;
    scalemaxDep *= 0.9;
    
    double values[10] = {1.,2.,5.,10.,20.,25.,30.,40.,50.,60.};
    int idat=0;
    int idep=0;
    for (int i=0;i<10;i++) {
        if(scalemaxDat > values[i]) idat = i;
        if(scalemaxDep > values[i]) idep = i;
    }
    
    scalemaxDat = values[idat];
    scalemaxDep = values[idep];

    scalemax = scalemaxDat;

    _showDepth = NO;
    
    // setup the scales
    
    xscale = [NSBezierPath bezierPath];
    axiswidth = 24.;
    urmargin = 4.;
    loPoint = NSMakePoint(axiswidth,axiswidth);
    hiPoint = NSMakePoint(axiswidth+plotwidth,axiswidth+plotheight);
    axisRect = NSMakeRect(axiswidth,axiswidth,plotwidth,plotheight);
    //_xslice = axiswidth + 220.;

    double bigtick = 9.;
    double tick = 7.;
    double tinytick = 4.;
    double x = axiswidth;
    double y = axiswidth;
    double ymaj = y + bigtick;
    double ymin = y + tick;
    double ytin = y + tinytick;
    double xedge = axiswidth + plotwidth;
    double yedge = axiswidth + plotheight;

    double phi = 120.;
    double phistep = 10.;
    double philast = (xlow + (double)nx*binsize)*180./M_PI;
    double bpsize = fabs(binsize*180./M_PI);
    nxtext = 0;
    while (phi > philast) {
        [xscale moveToPoint:NSMakePoint(x,y)];
        [xscale lineToPoint:NSMakePoint(x,ymaj)];
        xtext[nxtext] = x - 7.0;
        if(phi > 99.) xtext[nxtext] = x - 11.;
        xval[nxtext] = phi;
        double xx;
        for (int j=1; j<10; j++)
        {
            xx = x + (double)j*phistep*0.1/bpsize;
            if(xx > xedge) break;
            [xscale moveToPoint:NSMakePoint(xx,y)];
            [xscale lineToPoint:NSMakePoint(xx,ytin)];
        }
        xx = x + phistep*0.5/bpsize;
        if(xx > xedge) break;
        [xscale moveToPoint:NSMakePoint(xx,y)];
        [xscale lineToPoint:NSMakePoint(xx,ymin)];
        phi=phi-phistep;
        x+=phistep/bpsize;
        nxtext++;
    }
 
    yscale = [NSBezierPath bezierPath];
    x = axiswidth;
    y = axiswidth;
    double xmaj = x + bigtick;
    double xmin = x + tick;
    double xtin = x + tinytick;
    
    double eta = (double)((int)(ylow*10.+0.001))/10.;
    double etastep = 0.1;
    double etalast = ylow + (double)ny*binsize;
    double besize = fabs(binsize);
    nytext = 0;
    while (eta > etalast) {
        [yscale moveToPoint:NSMakePoint(x,y)];
        [yscale lineToPoint:NSMakePoint(xmaj,y)];
        ytext[nytext] = y - 7.0;
        yval[nytext] = eta;
        double yy;
        for (int j=1; j<10; j++)
        {
            yy = y + (double)j*etastep*0.1/besize;
            if(yy > yedge) break;
            [xscale moveToPoint:NSMakePoint(x,yy)];
            [xscale lineToPoint:NSMakePoint(xtin,yy)];
        }
        yy = y + etastep*0.5/besize;
        if(yy > yedge) break;
        [yscale moveToPoint:NSMakePoint(x,yy)];
        [yscale lineToPoint:NSMakePoint(xmin,yy)];
        eta=eta-etastep;
        y+=etastep/besize;
        nytext++;
    }
    
    //--------- 20x20 path
    /*
    double zcross = 3560.; // test of size of 20x20mm in bins...
    double etacross = 1.52;
    double theta = 2.*atan2(exp(-etacross),1.);
    double radius = tan(theta)*zcross;
    double rlow = radius - 10.;
    double rhigh = radius + 10.;
    double halfangle = 0.5 * atan2(rlow,zcross);
    double etalow = -log(tan(halfangle));
    double deta = (etalow - etacross)/binsize;
    halfangle = 0.5 * atan2(rhigh,zcross);
    double etahigh = -log(tan(halfangle));
    double deta1 = (etahigh - etacross)/binsize;
    NSLog(@"deta = %.2f, deta1 = %.2f",deta,deta1); */
    
    path20x20 = [NSBezierPath bezierPath];

    x = axiswidth + 0.5*plotwidth;
    y = axiswidth + 0.5*plotheight;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x+10.,y)];
    y -= 5.;
    x += 5.;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x,y+10.)];
    x -=2.;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x+4.,y)];
    y+=10.;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x+4.,y)];
    y-=7.;
    x-=3.;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x,y+4.)];
    x+=10.;
    [path20x20 moveToPoint:NSMakePoint(x,y)];
    [path20x20 lineToPoint:NSMakePoint(x,y+4.)];

    newplotimage = YES;
    [self setNeedsDisplay:YES];
    
    return scalemax;
}

- (void) setScaleMax: (double) s {
    scalemax = s;
    newplotimage = YES;
    [self setNeedsDisplay:YES];
}

- (void) showTwenty:(BOOL) t {
    twenty = t;
    newplotimage = YES;
    [self setNeedsDisplay:YES];
}

- (void) showSlice:(BOOL)active {
    
    if(active) {
        [self cacheImage];
        newplotimage = NO;
    } else newplotimage = YES;
    
    sliceactive = active;
    
    if(sliceactive) {
        ycentre = axiswidth + 0.5*plotheight;
        halflength = 0.5*plotheight;
        clocktick = 0;
        pdf = NO;
        
        [self makeSliceIndicator];

        if(timer == nil) {
            timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animate:) userInfo:nil repeats:YES];
        } else {
            [timer invalidate];
            timer = nil;
            NSLog(@"showSlice - Not happy about being here...");
        }

    } else {
        rotated = NO;
        endrotation = NO;
        makingprofile = NO;
        [self setNeedsDisplay:YES];
    }
}

- (void) rotateSlice:(BOOL)rot {
    endrotation = rotated;
    rotated = rot;
    rotcount = 0;
    if(rotated) _yslice = ycentre;
}

- (void) animate:(NSTimer *) aTimer {
    
    if(makingprofile) {
        if(clocktick < nrollup) {
            double ylen = plotheight - plotheight*(double)(clocktick+1)/(double)nrollup;
            end = [NSBezierPath bezierPath];
            [end moveToPoint:NSMakePoint(_xslice,axiswidth)];
            [end lineToPoint:NSMakePoint(_xslice,axiswidth+ylen)];
            
            [end moveToPoint:NSMakePoint(_xslice-4.,axiswidth)];
            [end lineToPoint:NSMakePoint(_xslice,axiswidth+5.)];
            [end lineToPoint:NSMakePoint(_xslice+4.,axiswidth)];
            [end lineToPoint:NSMakePoint(_xslice-4.,axiswidth)];
            
            [end moveToPoint:NSMakePoint(_xslice-4.,axiswidth+ylen)];
            [end lineToPoint:NSMakePoint(_xslice,axiswidth+ylen-5.)];
            [end lineToPoint:NSMakePoint(_xslice+4.,axiswidth+ylen)];
            [end lineToPoint:NSMakePoint(_xslice-4.,axiswidth+ylen)];
        } else {
            if(clocktick > nrollup+6) {
                sliceactive = NO;
                makingprofile = NO;
                [timer invalidate];
                timer = nil;
                [self displayProfile];
            }
            double r = 3. * (double)((clocktick-nrollup+1)*(clocktick-nrollup+1));
            end = [NSBezierPath bezierPath];
            NSPoint fin = NSMakePoint(_xslice,axiswidth);
            [end appendBezierPathWithArcWithCenter:fin radius:r startAngle:0.0 endAngle:360.0];
            double explode[2];
            explode[0] = (double)(clocktick-nrollup+5); explode[1] = 6.*(double)(clocktick-nrollup+5);
            [end setLineDash:explode count:2 phase:17.*(double)(clocktick-nrollup)];
        }

        clocktick++;
        [self setNeedsDisplay:YES];
        return;
    }
    if(sliceactive) {
        if(clocktick < nstart+1) {
            lineColor = [NSColor blackColor];
            double ahalf = halflength * (double)clocktick/(double)nstart;
            double theta = M_PI * (double)clocktick/(double)nstart - 0.5*M_PI;
            double dx = ahalf * cos(theta);
            double dy = ahalf * sin(theta);
            double x = _xslice - dx;
            double y = ycentre + dy;
            line = [NSBezierPath bezierPath];
            [line moveToPoint:NSMakePoint(x,y)];
            x = _xslice + dx;
            y = ycentre - dy;
            [line lineToPoint:NSMakePoint(x,y)];
        }
        clocktick++;
        [self setNeedsDisplay:YES];
    }
    else {
        [timer invalidate];
        timer = nil;
    }
}

- (void) makeSliceIndicator {
    
    double pseudo_xslice = _xslice;
    if(rotated) pseudo_xslice = _xslice - (_yslice - 0.5*plotheight - axiswidth);
    
    upperTriangle = [NSBezierPath bezierPath];
    double x = pseudo_xslice;
    double y = axiswidth + plotheight-5.;
    [upperTriangle moveToPoint:NSMakePoint(x,y)];
    x -= 4.; y += 5.;
    [upperTriangle lineToPoint:NSMakePoint(x,y)];
    x += 8.;
    [upperTriangle lineToPoint:NSMakePoint(x,y)];
    [upperTriangle closePath];
    
    lowerTriangle = [NSBezierPath bezierPath];
    x = pseudo_xslice;
    y = axiswidth + 5.;
    [lowerTriangle moveToPoint:NSMakePoint(x,y)];
    x -= 4.; y -= 5.;
    [lowerTriangle lineToPoint:NSMakePoint(x,y)];
    x += 8.;
    [lowerTriangle lineToPoint:NSMakePoint(x,y)];
    [lowerTriangle closePath];
    
    dline[0] = 4.;
    dline[1] = 16.;
    linup = [NSBezierPath bezierPath];
    x = pseudo_xslice; y = ycentre;
    [linup moveToPoint:NSMakePoint(x,y+plotheight*0.5)];
    [linup lineToPoint:NSMakePoint(x,y)];
    lindn = [NSBezierPath bezierPath];
    [lindn moveToPoint:NSMakePoint(x,y-plotheight*0.5)];
    [lindn lineToPoint:NSMakePoint(x,y)];
    
    line = [NSBezierPath bezierPath];
    x = pseudo_xslice; y = axiswidth;
    double vlen = plotheight;
    if(dragging) { y = axiswidth + 5.; vlen = plotheight-10.;}
    [line moveToPoint:NSMakePoint(x,y)];
    [line lineToPoint:NSMakePoint(x,y+vlen)];
    
}

- (void) makeProfile {
    
    //--- end animation
    //NSBundle * myBundle = [NSBundle mainBundle];
    //NSString * path = [myBundle pathForResource:@"Morph" ofType:@"aif"];
    //NSLog(@"Path is %@",path);
    //NSSound * sound = [[NSSound alloc] initWithContentsOfFile:aiffile byReference:YES];
    //[sound play];
    [[NSSound soundNamed:@"Space_Ship.aif"] play];

    clocktick = 0;
    sliceactive = NO;
    makingprofile = YES;
}

- (void) displayProfile {
    
    int iphibin = (int)(_xslice - axiswidth + 0.5);
    int ietabin = (int)(_yslice - axiswidth + 0.5);
    double phivalue = ((double)iphibin*binsize + xlow)*180./M_PI;
    double etavalue = ((double)ietabin*binsize + ylow);
    
    double * dat;
    if(_showDepth) dat = depthdata;
    else dat = plotdata;
    
    if(rotated) {
        for (int i=0;i<ny;i++) {
            profile[ny-1-i] = dat[i+nx*ietabin];
        }
    } else {
        for (int i=0;i<ny;i++) {
            profile[ny-1-i] = dat[i*nx+iphibin];
        }
    }
    
    if(!theHist) theHist = [HistViewControl sharedHistViewControl];
    NSPoint orig = NSMakePoint([[NSScreen mainScreen] frame].size.width - 700.,[[NSScreen mainScreen] frame].size.height-700.);
    NSString * tit;
    if(rotated) tit = [NSString stringWithFormat:@"Profile at η = %.3f",etavalue];
    else tit = [NSString stringWithFormat:@"Profile at φ = %.1fº",phivalue];
    [theHist showWindowAt:orig withTitle:tit forPlotSize:NSMakeSize(480.,400.)];

    if(rotated) [theHist axisTitles:@"φ (º)" And:shorttitle];
    else [theHist axisTitles:@"η" And:shorttitle];
    
    double eta0 = ylow + plotheight*binsize;
    double phi0 = phivalue + 0.5*plotheight*binsize*180./M_PI; //(!! to be fixed !!) seems to be OK: 2 May
    //if(rotated) NSLog(@"displayProfile: phi0 = %.3f",phi0);
    if(rotated)[theHist drawHistogram:profile Bins:ny Xlow:phi0 Dx:-binsize*180./M_PI Title:@"Histo title"];
    else [theHist drawHistogram:profile Bins:ny Xlow:eta0 Dx:-binsize Title:@"Histo title"];
    
    rotated = NO;

}

- (void) savePDF:(NSString *) path withTitle:(NSString *) title {
    
    pdf = YES;
    sliceactive = NO;
    makingprofile = NO;
    titlestring = title;
    
    NSRect pdfrect;
    double hgt = frameRect.size.height + 140.;
    double wid = frameRect.size.width;
    pdfrect.origin = NSMakePoint(0.,frameRect.size.height-hgt + 10.);
    pdfrect.size = NSMakeSize(wid + 8.,hgt);
    
    NSRect fRect = NSMakeRect(0.,0.,276.,60.);
    HTDFadeView * fview = [[HTDFadeView alloc] initWithFrame:fRect];
    [fview drawHorizontalScale:scalemax];
    [fview setNeedsDisplay:YES];
    scaleImage = [[NSImage alloc] initWithData:[fview dataWithPDFInsideRect:fRect]];
    
    NSData * data = [self dataWithPDFInsideRect:pdfrect];
    [data writeToFile:path options:0 error:nil];
    pdf = NO;
}

- (double) setDataDepth:(BOOL) dd {
    
    _showDepth = dd;
    if(_showDepth) scalemax = scalemaxDep;
    else scalemax = scalemaxDat;
    
    newplotimage = YES;
    [self setNeedsDisplay:YES];
    
    return scalemax;

}

#pragma mark - mouse stuff

- (void)mouseDown:(NSEvent *)theEvent {
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    if(!dragging) {
        if(rotated) {
            if(fabs(mousePoint.y-_yslice) < 3. && mousePoint.x > _xslice-0.5*plotheight && mousePoint.x < _xslice+0.5*plotheight) {
                dragging = YES;
                refPoint = mousePoint;
                refPoint.x -= _xslice;
                lineColor = [NSColor redColor];
                [self setNeedsDisplay:YES];
            }
        } else {
            if(fabs(mousePoint.x-_xslice) < 3. && mousePoint.y > loPoint.y && mousePoint.y < hiPoint.y) {
                dragging = YES;
                lineColor = [NSColor redColor];
                [self setNeedsDisplay:YES];
            }
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {

    if(dragging) {
        if(rotated) {
            mousePoint =  [self convertPoint:[theEvent locationInWindow] fromView: nil];
            if(mousePoint.y > loPoint.y && mousePoint.y < hiPoint.y) {
                _yslice = mousePoint.y;
                _xslice = (mousePoint.x - refPoint.x);
                if(_xslice < loPoint.x + 0.5*plotheight) {
                    _xslice = loPoint.x + 0.5*plotheight;
                    refPoint.x = mousePoint.x - _xslice;
                }
                if(_xslice > hiPoint.x - 0.5*plotheight) {
                    _xslice = hiPoint.x - 0.5*plotheight;
                    refPoint.x = mousePoint.x - _xslice;
                }
            }
        } else {
            mousePoint =  [self convertPoint:[theEvent locationInWindow] fromView: nil];
            if(mousePoint.x > loPoint.x && mousePoint.x < hiPoint.x)
                _xslice = mousePoint.x;
        }
        
        NSNotification * note = [NSNotification notificationWithName: HXGdragUpdateNotification object: self];
        NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
        [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                                   postingStyle: NSPostNow
                                                   coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                       forModes: modes];

    }
    
}

- (void) mouseUp:(NSEvent *)theEvent {
    dragging = NO;
    lineColor = [NSColor blackColor];
}


#pragma mark - notifications
- (void) dragUpdate:(NSNotification *) note {
    [self makeSliceIndicator];
    [self setNeedsDisplay:YES];
}

- (void) cacheImage{
    
    /*NSLog(@"cacheImage with image = %d",!(!plotImage));
    NSLog(@"frameRect: %.1f %.1f %.1f %.1f",frameRect.origin.x,frameRect.origin.y,frameRect.size.width,frameRect.size.height);
    NSLog(@"self.bounds: %.1f %.1f %.1f %.1f",self.bounds.origin.x,self.bounds.origin.y,self.bounds.size.width,self.bounds.size.height); */

    NSSize imgSize = self.bounds.size;
    NSBitmapImageRep * bir = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [bir setSize:imgSize];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bir];
    plotImage = [[NSImage alloc] initWithSize:imgSize];
    [plotImage addRepresentation:bir];

}


#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [self setFrame:frameRect];
    
    if(!colorControl) colorControl = [HTDColorControl sharedColors];
    NSArray * colorArray = [colorControl colorArray];
    
    int ncols = (int) [colorArray count];
    double csize = scalemax/(double)(ncols-1);
    
    NSMutableAttributedString * str;
    
    if(newplotimage) {
        int is=0;
        for (int iy=0; iy<ny; iy++) {
            double y = (double) iy * bscl + axiswidth;
            for (int ix=0; ix<nx; ix++) {
                NSRect bin;
                double x = (double) ix * bscl + axiswidth;
                bin.origin = NSMakePoint(x,y);
                bin.size = NSMakeSize(bscl,bscl);
                int icol = 0;
                if(_showDepth) {if(depthdata[is] > 0.) icol = depthdata[is]/csize + 1;}
                else {if(plotdata[is] > 0.) icol = plotdata[is]/csize + 1;}
                icol = MIN(ncols-1,icol);
                NSColor * bincolor = [colorArray objectAtIndex:icol];
                [bincolor set];
                NSRectFill(bin);
                is++;
            }
        }
        
        [NSBezierPath setDefaultLineWidth:1.0];
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:axisRect];
        
        // Now draw the axes...
        [[NSColor blackColor] set];
        [xscale setLineWidth:1.0];
        [xscale stroke];
        double yt = 1.;
        for (int i=0; i<nxtext;i++) {
            NSString * xystr = [NSString stringWithFormat:@"%.0f",xval[i]];
            str = [[NSMutableAttributedString alloc] initWithString:xystr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:13]
                        range:NSMakeRange(0,str.length)];
            
            [str drawAtPoint:NSMakePoint(xtext[i],yt)];
        }
        str = [[NSMutableAttributedString alloc] initWithString:@"φ (º)"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:18]
                    range:NSMakeRange(0,str.length)];
        
        [str drawAtPoint:NSMakePoint(plotwidth-20.,0.)];
        
        [[NSColor blackColor] set];
        [yscale setLineWidth:1.0];
        [yscale stroke];
        
        double xt = 1.;
        for (int i=0; i<nytext;i++) {
            NSString * xystr = [NSString stringWithFormat:@"%.1f",yval[i]];
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:13]
                        range:NSMakeRange(0,str.length)];
            
            [str drawAtPoint:NSMakePoint(xt,ytext[i])];
        }
        str = [[NSMutableAttributedString alloc] initWithString:@"η"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:18]
                    range:NSMakeRange(0,str.length)];
        
        [str drawAtPoint:NSMakePoint(2.,plotheight+4.)];
        
        if(twenty) {
            [[NSColor whiteColor] set];
            [path20x20 setLineWidth:1.0];
            [path20x20 stroke];
        }
        
    } else {
        [self setFrame:self.bounds];
        [plotImage drawInRect:self.bounds
                     fromRect:self.bounds
                    operation:NSCompositingOperationCopy fraction:1.0];// NSCompositeSourceOver NSCompositingOperationSourceOver
        [self setFrame:frameRect];
    }


    if(makingprofile) {          //------------- the roll-up
        [[NSColor blackColor] set];
        [end setLineWidth:1.];
        if(rotated) {
            NSAffineTransform * xform = [NSAffineTransform transform];
            [xform rotateByDegrees:-90.0]; // clockwise rotation
            [xform translateXBy:-_xslice-_yslice yBy:_xslice-_yslice];
            [xform concat];
            end = [xform transformBezierPath:end];
            [xform invert];
            [xform concat];
        }
        
        
        //if(clocktick == nrollup+2) [[NSSound soundNamed:@"Pop"] play];
        if(clocktick == nrollup+1 || clocktick == nrollup+3) [end fill];
        else [end stroke];
        return;
    }

    if(sliceactive) { //-------------------- slice behaviour
 
        NSAffineTransform * xform = [NSAffineTransform transform];

        if(endrotation) {
            if(rotcount < nrot) {
                rotcount++;
                double rotfrac = rotcount/(double)(nrot+1);
                double theta = (rotfrac - 1.) * M_PI * 0.5;
                double diff = ycentre-_yslice;
                double yc = ycentre; //_yslice + rotfrac*diff;
                double xc = _xslice - rotfrac*diff;
                [xform rotateByRadians:theta];
                [xform translateXBy:xc*cos(theta)+yc*sin(theta)-_xslice yBy:yc*cos(theta)-xc*sin(theta)-yc];
                [xform concat];
            } else {
                _yslice = ycentre;
                endrotation = NO;
                [self makeSliceIndicator];
            }
        }

        if(rotated) {
            if(rotcount < nrot) {
                rotcount++;
                double theta = - (double) (rotcount) * M_PI * 0.5 / (double)(nrot+1);
                [xform rotateByRadians:theta]; // clockwise rotation
                [xform translateXBy:_xslice*cos(theta)+ycentre*sin(theta)-_xslice yBy:ycentre*cos(theta)-_xslice*sin(theta)-ycentre];
            } else {
                [xform rotateByDegrees:-90.0]; // clockwise rotation
                [xform translateXBy:-_xslice-ycentre yBy:_xslice-ycentre]; /// full formula above
            }
            [xform concat];
            //NSPoint p = NSMakePoint(_xslice,ycentre);
            //NSPoint q = [xform transformPoint:p];
            //NSLog(@"After all: p = %.0f %.0f; q = %.0f %.0f",p.x,p.y,q.x,q.y);
        }
        
        [lineColor set];
        [line setLineWidth:1.0];
        [line stroke];
        
        if(dragging) {
            [[NSColor blackColor] set];
            [upperTriangle stroke];
            [lowerTriangle stroke];
        } else {
            if(clocktick > nstart) {
                phase = (double) (clocktick%20)*2.+3.;
                [[NSColor yellowColor] set];
                [linup setLineDash:dline count:2 phase:phase];
                [linup stroke];
                [linup setLineDash:nil count:0 phase:0];
                [lindn setLineDash:dline count:2 phase:phase];
                [lindn stroke];
                [lindn setLineDash:nil count:0 phase:0];
            }
            if(clocktick > nstart - 3) {
                [[NSColor blackColor] set];
                if(clocktick%10 == 9) [[NSColor redColor] set];
                [upperTriangle fill];
                [lowerTriangle fill];
                if(clocktick%10 == 9) {
                    [[NSColor blackColor] set];
                    [upperTriangle stroke];
                    [lowerTriangle stroke];
                }
            }
        }
        if(rotated || endrotation) {
            [xform invert];
            [xform concat];
        }
    }
    
    if(pdf) {                       //----------- pdf only ---------------------------------
        NSRect imageRect;
        imageRect.origin = NSZeroPoint;
        imageRect.size = [scaleImage size];
        NSSize isize = [scaleImage size];
        [scaleImage drawInRect:NSMakeRect(plotwidth+20.-isize.width,-isize.height-10.,isize.width,isize.height)
                      fromRect:imageRect
                     operation:NSCompositingOperationSourceOver fraction:1.0];
        
        str = [[NSMutableAttributedString alloc] initWithString:titlestring];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:18]
                    range:NSMakeRange(0,str.length)];
        
        [str drawAtPoint:NSMakePoint(20.,-75.)];


    }
    
}

@end
