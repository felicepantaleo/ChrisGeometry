//
//  HistView.m
//  Hex
//
//  Created by Chris Seez on 25/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HistView.h"

@implementation HistView

- (void) setPlotFrame:(NSRect)fRect {
    
    xlomarg = 48.;
    ylomarg = 48.;
    xhimarg = 16.;
    yhimarg = 40.;
    
    fname = @"Helvetica";
    fsize = 16;
    
    frameRect = fRect;
    axisRect = NSMakeRect(xlomarg,ylomarg,frameRect.size.width-xlomarg-xhimarg,frameRect.size.height-ylomarg-yhimarg);
    titleRect = NSMakeRect(4.,2.,frameRect.size.width-50.,20.);
    xtitRect = NSMakeRect(frameRect.size.width-150.,4.,146.,18.);
    ytitRect = NSMakeRect(4.,frameRect.size.height-150.,18.,146.);
    
    pdfrect.origin = NSMakePoint(0.,5.);
    pdfrect.size = frameRect.size;

    
    // --- Colour for the histo
    histFillColor[0] = [NSColor greyBlue];
    histFillColor[1] = [NSColor fadedBlue];
    histFillColor[2] = [NSColor pastelBlue];
    histFillColor[3] = [NSColor sageGreen];
    histFillColor[4] = [NSColor grassGreen];
    histFillColor[5] = [NSColor peachOrange];
    histFillColor[6] = [NSColor orchidPink];
    histFillColor[7] = [NSColor raspberryRed];
    histFillColor[8] = [NSColor paleCream];
    histFillColor[9] = [NSColor indigoBlue];
    
}

- (void) addLabel:(NSString *) label at:(NSPoint) p {
    
    labelString = label;
    labelPoint = p;
    drawLabel = YES;
    [self setNeedsDisplay:YES];
    
}

- (void) setFillColor:(NSColor *) col For: (int) n {
    histFillColor[n] = col;
}

- (void) setUpHist {
    
    [self setUpAxes];
    [self makeHistoBezier];
    
}
    
- (void) setUpAxes {
    
    int values[11]       = {10,12,15,20,25,30,40,50,60,80,100};
    int nmajinterval[11] = { 5, 3, 5, 4, 5, 3, 4, 5, 3, 4, 5};
    int nmininterval[11] = { 2, 4, 3, 5, 5, 5, 5, 5,10, 4, 2};

    // --------------------------- the y-axis
    double contentMax = 0.0;
    for (int i=0; i<_nbin; i++) {
        if(_contents[i] > contentMax) contentMax = _contents[i];
    }
    
    if(_fixedYmax == 0) {
        if(contentMax == 0.) contentMax = 0.9;
        else contentMax *= 1.05;
    } else contentMax = _fixedYmax;

    int pten = (int)(log10(contentMax) + 50.) - 50;

    int twodigits = (int)(contentMax*pow(10.,1-pten));
    //NSLog(@"pten %d, twodigits %d",pten,twodigits);
    int ival = 10;
    for (int i=0;i<10;i++) {
        if(twodigits <= values[i]) {
            ival = i;
            break;
        }
    }
    
    scaleMax = (double) values[ival] * pow(10.,pten-1);
    if(_fixedYmax != 0) scaleMax = _fixedYmax;
    _fixedYmax = 0;

    ypower = pten - 1;
    yformatStr = @"%.0f";
    if(ypower < 0) {
        ypower+=1;
        yformatStr = @"%.1f";
    }
    if(ypower*ypower == 1) ypower = 0; /// was just -1
    
    //NSLog(@"pten, twodigits, ypower, ival, scaleMax: %d %d %d %d %.1f",pten, twodigits, ypower, ival, scaleMax);
    
    yaxisBez = [NSBezierPath bezierPath];
    double x = axisRect.origin.x;
    double xmajtick = x + 7.;
    double xmintick = x + 4.;
    double y = axisRect.origin.y;
    double dpymin = axisRect.size.height/(double)(nmajinterval[ival]*nmininterval[ival]);
    double yval = 0.;
    double dyval = pow(10.,-ypower)*scaleMax/(double)(nmajinterval[ival]);
    
    for (int i=0;i<nmajinterval[ival];i++) {
        for (int j=0;j<nmininterval[ival];j++) {
            y+=dpymin;
            [yaxisBez moveToPoint:NSMakePoint(x,y)];
            [yaxisBez lineToPoint:NSMakePoint(xmintick,y)];
        }
        [yaxisBez moveToPoint:NSMakePoint(x,y)];
        [yaxisBez lineToPoint:NSMakePoint(xmajtick,y)];
        yval+=dyval;
        ymajnum[i] = yval;
        yvlab[i] = y;
    }
    xvlab = x - 2.;
    nymaj = nmajinterval[ival] - 1;
    
    if(ypower != 0) {
        fname = @"Helvetica";
        NSString * sy = @"x10";
        int nindex = 1;
        if(ypower < 0) nindex = 2;
        if(ypower != 1) sy = [sy stringByAppendingFormat:@"%d",ypower];
        powerstring = [[NSMutableAttributedString alloc] initWithString:sy];
        [powerstring addAttribute:NSFontAttributeName
                            value:[NSFont fontWithName:fname size:fsize]
                            range:NSMakeRange(0,3)];
        if(ypower != 1) {
            [powerstring addAttribute:NSSuperscriptAttributeName
                                value:[NSNumber numberWithInt:+1]
                                range:NSMakeRange(3,nindex)];
            [powerstring addAttribute:NSFontAttributeName
                                value:[NSFont fontWithName:fname size:fsize-3]
                                range:NSMakeRange(3,nindex)];
        }
    }
    
    //------------- The x-axis
    
    xaxisBez = [NSBezierPath bezierPath];

    double nstep[10] = {2,4,3,4,5,3,7,4,3};
    double delta = (double)_nbin*_deltax;
    pten = (int)(log10(delta) + 50.) - 50;
    int onedigit = (int)(delta*pow(10.,-pten));
    double xvmaj = pow(10.,pten)*(double)onedigit/(double)nstep[onedigit-1];
    int ifirst = (int) (_xlo/xvmaj);
    double firstmaj = (double) (ifirst) * xvmaj;
    
    int nd = 1-pten;
    if(pten < 0) pten = 0;
    xformatStr = @"%";
    xformatStr = [xformatStr stringByAppendingFormat:@".%1df",nd];
    
    double valueToX = axisRect.size.width/delta;
    xmintick = xvmaj*valueToX/5.;
    
    y = axisRect.origin.y;
    double ymajtick = y + 7.;
    double ymintick = x + 4.;
    x = axisRect.origin.x + (firstmaj-_xlo)*valueToX;
    double xval = firstmaj;
    double xlim = axisRect.origin.x + axisRect.size.width;
    yhlab = y;
    
    nxmaj = 0;
    for (;;) {
        for (int i=0; i<4; i++) {
            x+=xmintick;
            if(x > axisRect.origin.x && x < xlim) {
                [xaxisBez moveToPoint:NSMakePoint(x,y)];
                [xaxisBez lineToPoint:NSMakePoint(x,ymintick)];
            }
        }
        x+=xmintick;
        if(x > xlim) break;
        xval+=xvmaj;
        [xaxisBez moveToPoint:NSMakePoint(x,y)];
        [xaxisBez lineToPoint:NSMakePoint(x,ymajtick)];
        xhlab[nxmaj] = x;
        xmajnum[nxmaj] = xval;
        nxmaj++;
    }

}

- (void) makeHistoBezier {
    
    yValueToCoord = axisRect.size.height/scaleMax;
    double xstep = axisRect.size.width/(double)_nbin;
    xValueToCoord = axisRect.size.width/((double)_nbin*_deltax);
    
    double x,y;
    
    histoBez[_nstacked] = [NSBezierPath bezierPath];
    x = axisRect.origin.x;
    y = axisRect.origin.y;
    [histoBez[_nstacked] moveToPoint:NSMakePoint(x,y)];
    for (int i=0;i<_nbin;i++) {
        y = axisRect.origin.y + _contents[i]*yValueToCoord;
        [histoBez[_nstacked] lineToPoint:NSMakePoint(x,y)];
        x+=xstep;
        [histoBez[_nstacked] lineToPoint:NSMakePoint(x,y)];
        if(_binDividers) {
            [histoBez[_nstacked] lineToPoint:NSMakePoint(x,axisRect.origin.y)];
            [histoBez[_nstacked] lineToPoint:NSMakePoint(x,y)];
        }
    }
    y = axisRect.origin.y;
    [histoBez[_nstacked] lineToPoint:NSMakePoint(x,y)];
    [histoBez[_nstacked] closePath];



    //-------------------------------------------------------------

}

- (void) savePDF:(NSString *) path {
    
    //NSLog(@"frameRect origin %.0f %.0f",frameRect.origin.x,frameRect.origin.y);
    
    NSData * data = [self dataWithPDFInsideRect:pdfrect];
    [data writeToFile:path options:0 error:nil];
}

#pragma mark - *drawRect*

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [self setFrame:frameRect];
    
    [[NSColor whiteColor] set];
    NSRectFill(pdfrect);

    
    // ----------- First the histo
    
    for (int ih=0; ih<_nstacked+1; ih++) {
        [histFillColor[ih] set];
        [histoBez[ih] fill];
        [histoBez[ih] setLineWidth:1.0];
        [[NSColor blackColor] set];
        [histoBez[ih] stroke];
    }

    // Now draw the y-axis...
    [[NSColor blackColor] set];
    [yaxisBez setLineWidth:1.0];
    [yaxisBez stroke];
    for (int i=0; i<nymaj;i++) {
        NSString * xystr = [NSString stringWithFormat:yformatStr,ymajnum[i]];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont fontWithName:fname size:fsize]
                    range:NSMakeRange(0,str.length)];
        
        NSSize sz = [str size];
        double x = xvlab-sz.width;
        double y = yvlab[i]-sz.height*0.5+1.;
        [str drawAtPoint:NSMakePoint(x,y)];
    }
    
    NSSize sz;
    double x,y;
    
    // ---- The x10^n label
    if(ypower != 0) {
        sz = [powerstring size];
        x = xvlab-sz.width;
        y = axisRect.origin.y + axisRect.size.height - sz.height + 16.;
        [powerstring drawAtPoint:NSMakePoint(x,y)];
    }
    
    // y-axis title ------------------
    NSAffineTransform * xform = [NSAffineTransform transform];
    [xform rotateByDegrees:90.0]; // counterclockwise rotation
    [xform concat];
    
    sz = [_ytit size];
    x = axisRect.origin.y + axisRect.size.height - sz.width - 10.;
    y = - sz.height;
    [_ytit drawAtPoint:NSMakePoint(x,y)];

    [xform invert];
    [xform concat];
    
    // ------------- Now draw the x-axis...
    [[NSColor blackColor] set];
    [xaxisBez setLineWidth:1.0];
    if(!_binDividers) [xaxisBez stroke];
    for (int i=0; i<nxmaj;i++) {
        NSString * xystr = [NSString stringWithFormat:xformatStr,xmajnum[i]];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont fontWithName:fname size:fsize]
                    range:NSMakeRange(0,str.length)];
        
        NSSize sz = [str size];
        double x = xhlab[i]-sz.width*0.5;
        double y = yhlab-sz.height;
        [str drawAtPoint:NSMakePoint(x,y)];
    }

    // x-axis title ------------------
    
    sz = [_xtit size];
    x = axisRect.origin.x + axisRect.size.width - sz.width;
    y = axisRect.origin.y - sz.height - 16.;
    [_xtit drawAtPoint:NSMakePoint(x,y)];


    // --- The axis frame
    [NSBezierPath setDefaultLineWidth:1.0];
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect:axisRect];
    
    if(drawLabel) {
        fname = @"Helvetica";
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:labelString];
        [str addAttribute:NSFontAttributeName
                            value:[NSFont fontWithName:fname size:fsize]
                            range:NSMakeRange(0,str.length)];
        NSPoint pnt = NSMakePoint(axisRect.origin.x + (labelPoint.x-_xlo)*xValueToCoord,axisRect.origin.y + labelPoint.y*yValueToCoord);

        [str drawAtPoint:pnt];
    }
    
    //---- Title
    fname = @"Helvetica";
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:_title];
    [str addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:fname size:fsize]
                range:NSMakeRange(0,str.length)];
    
    sz = [str size];
    x = (axisRect.origin.x + axisRect.size.width - sz.width)*0.5;
    y = axisRect.origin.y + axisRect.size.height + 0.1*sz.height;
    [str drawAtPoint:NSMakePoint(x,y)];

}

@end
