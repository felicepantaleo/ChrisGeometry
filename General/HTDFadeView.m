//
//  HTDFadeView.m
//  (from MandelbrotViewer)
//
//  Created by seez on 19/05/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HTDFadeView.h"
#import "HTDColorControl.h"
HTDColorControl * colorControl;

@implementation HTDFadeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        hwid = 40.0;
        xstart = 15.0;
        ystart = 7.0;
        colorControl = [HTDColorControl sharedColors];
        nlk = 512;
        ystep = (frame.size.height-6.0-ystart)/nlk;
        emax = -1.0;
        
        vwid = 30.0;
        xhstart = 10.;
        yhstart = 28.;
        xhstep = (frame.size.width-12.0-xhstart)/nlk;
        
        horizontal = NO;
    }
    
    return self;
}

- (void) drawEnergyScale:(double)e
{
    emax = e;
    //plook = (uint8_t *) [colorControl getLookup];
    colorArray = [colorControl colorArray];
        
    nmaj = 5;
    nmin = 5;
    deltaE = emax/(double)nmaj;
    dpix = (nlk*ystep)/(double)(nmaj*nmin);
    
    if(emax > 2.5) scaleFormat = @"%.0f";
    else if(emax > 0.25) scaleFormat = @"%.1f";
    else if(emax > 0.025) scaleFormat = @"%.2f";
    else scaleFormat = @"%.3f";
    
    
    scale = [NSBezierPath bezierPath];
    double x = xstart + hwid;
    double y = ystart;
    double xmaj = x + 9.0;
    double xmin = x + 5.0;
    xtext = xmaj + 2.0;
    
    for (int i=0; i<nmaj;i++)
    {
        [scale moveToPoint:NSMakePoint(x,y)];
        [scale lineToPoint:NSMakePoint(xmaj,y)];
        ytext[i] = y - 7.0;
        sval[i] = (double)i * deltaE;
        for (int j=1; j<nmin; j++)
        {
            y+=dpix;
            [scale moveToPoint:NSMakePoint(x,y)];
            [scale lineToPoint:NSMakePoint(xmin,y)];
        }
        y+=dpix;
    }
    [scale moveToPoint:NSMakePoint(x,y)];
    [scale lineToPoint:NSMakePoint(xmaj,y)];
    ytext[nmaj] = y - 7.0;
    sval[nmaj] = emax;
    [scale setLineWidth:2.0];
    //NSLog(@"emax = %.3f, sval: %.3f %.3f %.3f %.3f %.3f %.3f",emax,sval[0],sval[1],sval[2],sval[3],sval[4],sval[5]);
    
    
    [self setNeedsDisplay:YES];
}

- (void) drawHorizontalScale:(double) vmax {
    
    horizontal = YES;
    emax = vmax;
    //plook = (uint8_t *) [colorControl getLookup];
    colorArray = [colorControl colorArray];
    
    nmaj = 5;
    nmin = 5;
    deltaE = emax/(double)nmaj;
    dpix = (nlk*xhstep)/(double)(nmaj*nmin);
    
    if(emax > 2.5) scaleFormat = @"%.0f";
    else if(emax > 0.25) scaleFormat = @"%.1f";
    else if(emax > 0.025) scaleFormat = @"%.2f";
    else scaleFormat = @"%.3f";
    
    
    scale = [NSBezierPath bezierPath];
    double x = xhstart;
    double y = yhstart;
    double ymaj = y - 9.0;
    double ymin = y - 5.0;
    yhtext = 2.0;
    
    for (int i=0; i<nmaj;i++)
    {
        [scale moveToPoint:NSMakePoint(x,y)];
        [scale lineToPoint:NSMakePoint(x,ymaj)];
        sval[i] = (double)i * deltaE;
        if(sval[i] > 9.) xhtext[i] = x - 7.0;
        else xhtext[i] = x - 4.0;
        for (int j=1; j<nmin; j++)
        {
            x+=dpix;
            [scale moveToPoint:NSMakePoint(x,y)];
            [scale lineToPoint:NSMakePoint(x,ymin)];
        }
        x+=dpix;
    }
    [scale moveToPoint:NSMakePoint(x,y)];
    [scale lineToPoint:NSMakePoint(x,ymaj)];
    xhtext[nmaj] = x - 7.0;
    sval[nmaj] = emax;
    [scale setLineWidth:1.0];
    //NSLog(@"emax = %.3f, sval: %.3f %.3f %.3f %.3f %.3f %.3f",emax,sval[0],sval[1],sval[2],sval[3],sval[4],sval[5]);
    
    [self drawColorScale];
    [self setNeedsDisplay:YES];

}

- (void) drawColorScale
{
    colorArray = [colorControl colorArray];
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    if(!colorArray)
    {
        return;
    }
    
    
    [NSBezierPath setDefaultLineWidth:1.0];
    NSRect rect;

    if(horizontal) {
        double x = (double) xhstart + 0.5;
        double y = (double) yhstart + 0.5;
        for (int i = 0; i<nlk; i++) {
            double www = 2.0;
            if(i+1 == nlk) www = 1.0;
            rect = NSMakeRect(x,y,www,vwid);
            NSColor * col = [colorArray objectAtIndex:i];
            [col set];
            [NSBezierPath fillRect:rect];
            x+=xhstep;
        }
        rect = NSMakeRect(xhstart,yhstart,nlk*xhstep,vwid);
        [[NSColor blackColor] set];
        
        [NSBezierPath strokeRect:rect];
        
        if(emax > 0.0) {
            [scale stroke];
            for (int i=0; i<nmaj+1;i++) {
                NSString * xystr = [NSString stringWithFormat:scaleFormat,sval[i]];
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:13]
                            range:NSMakeRange(0,str.length)];
                
                [str drawAtPoint:NSMakePoint(xhtext[i],3.)];
            }
            
        }
    } else {
        double x = (double) xstart + 0.5;
        double y = (double) ystart + 0.5;
        for (int i = 0; i<nlk; i++) {
            double hgt = 2.0;
            if(i+1 == nlk) hgt = 1.0;
            rect = NSMakeRect(x,y,hwid,hgt);
            NSColor * col = [colorArray objectAtIndex:i];
            [col set];
            [NSBezierPath fillRect:rect];
            y+=ystep;
        }
        rect = NSMakeRect(xstart,ystart,hwid,nlk*ystep);
        [[NSColor blackColor] set];
        
        [NSBezierPath strokeRect:rect];
        
        if(emax > 0.0) {
            [scale stroke];
            for (int i=0; i<nmaj+1;i++) {
                NSString * xystr = [NSString stringWithFormat:scaleFormat,sval[i]];
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:13]
                            range:NSMakeRange(0,str.length)];
                
                [str drawAtPoint:NSMakePoint(xtext,ytext[i])];
            }
            
        }

    }
}

@end
