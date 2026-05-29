//
//  CSGraphPaper.m
//  Hex
//
//  Created by Chris Seez on 09/11/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "CSGraphPaper.h"

@implementation CSGraphPaper

+ (id) squarePaperFor:(NSRect) brect AtLeastNxDivs:(int) mindiv {
    
    CSGraphPaper * thisPaper = [[self alloc] init];
    
    [thisPaper squareFor:brect delta:brect.size.width/(double)mindiv];

    return thisPaper;
}
+ (id) squarePaperFor:(NSRect) brect AtLeastNyDivs:(int) mindiv {
    
    CSGraphPaper * thisPaper = [[self alloc] init];
    
    [thisPaper squareFor:brect delta:brect.size.height/(double)mindiv];
    
    return thisPaper;
}

- (void) squareFor:(NSRect) brect delta:(double) delta {
    
    boundsRect = brect;
    
    power = 1.;
    for (int i=0; i<50; i++) {
        if(delta > 10.) {
            power *= 10.;
            delta *= 0.1;
        } else if(delta < 1.) {
            power *= 0.1;
            delta *= 10.;
        } else break;
    }
    
    mantissa = 1.;
    if(delta > 2.) mantissa = 2.;
    if(delta > 5.) mantissa = 5.;
    
    tenDeltax = power*mantissa;
    fiveDeltax = tenDeltax*0.5;
    oneDeltax = tenDeltax*0.1;
    tenDeltay = tenDeltax;
    fiveDeltay = fiveDeltax;
    oneDeltay = oneDeltax;
    
    NSLog(@"Bounds = %.1f %.1f %.1f %.1f",boundsRect.origin.x,boundsRect.origin.y,boundsRect.size.width,boundsRect.size.height);
    NSLog(@"Divisions: %.1f %.1f %.1f",tenDeltax,fiveDeltax,oneDeltax);
    
    baseColor = [NSColor blackColor];
    thicknessMultiplier = 1.;
    alpha = 0.6;
    _fontSize = 2.*oneDeltay;
    _fontName = @"Helvetica";
    
    [self makeBeziers];
    [self setGraphics];
}


- (void) makeAxisLeft:(BOOL)l right:(BOOL)r top:(BOOL)t bottom:(BOOL)b {
    
    axisLeft = l;
    axisRight = r;
    axisTop = t;
    axisBottom = b;
    
    [self constructAxes];
    
}

- (void) setTicksInsideX:(BOOL)x andY:(BOOL)y {
    
    ticksInsideX = x;
    ticksInsideY = y;
}

- (void) setColor:(NSColor *) col transparency:(double) a andThickness: (double) t {
    
    baseColor = col;
    alpha = a;
    thicknessMultiplier = t;
    
    [self setGraphics];
}

#pragma mark - private methods

- (void) makeBeziers {
    
    // -------- tenLines
    tenLines = [NSBezierPath bezierPath];
    
    double xstart = (double)((int)(boundsRect.origin.x/tenDeltax + 0.5))*tenDeltax;
    xFirst = xstart;
    if(xFirst < boundsRect.origin.x + 3.*oneDeltax) xFirst += tenDeltax;
    NSLog(@"xFirst = %.1f",xFirst);
    
    double x = xstart;
    while (x < boundsRect.origin.x + boundsRect.size.width) {
        [tenLines moveToPoint:NSMakePoint(x,boundsRect.origin.y)];
        [tenLines lineToPoint:NSMakePoint(x,boundsRect.origin.y+boundsRect.size.height)];
        xLast = x;
        x+=tenDeltax;
    }
    double ystart = (double)((int)(boundsRect.origin.y/tenDeltay + 0.5))*tenDeltay;
    yFirst = ystart;
    if(yFirst < boundsRect.origin.y + 3.*oneDeltay) yFirst += tenDeltay;
    NSLog(@"ystart = %.1f; yFirst = %.1f; comparison %.1f",ystart,yFirst,boundsRect.origin.y + 3.*oneDeltay);
    
    double y = ystart;
    while (y < boundsRect.origin.y + boundsRect.size.height) {
        [tenLines moveToPoint:NSMakePoint(boundsRect.origin.x,y)];
        [tenLines lineToPoint:NSMakePoint(boundsRect.origin.x+boundsRect.size.width,y)];
        yLast = y;
        y+=tenDeltay;
    }
    
    // -------- fiveLines
    fiveLines = [NSBezierPath bezierPath];
    
    x = xstart;
    while (x < boundsRect.origin.x + boundsRect.size.width) {
        [fiveLines moveToPoint:NSMakePoint(x,boundsRect.origin.y)];
        [fiveLines lineToPoint:NSMakePoint(x,boundsRect.origin.y+boundsRect.size.height)];
        x+=fiveDeltax;
    }
    
    y = ystart;
    while (y < boundsRect.origin.y + boundsRect.size.height) {
        [fiveLines moveToPoint:NSMakePoint(boundsRect.origin.x,y)];
        [fiveLines lineToPoint:NSMakePoint(boundsRect.origin.x+boundsRect.size.width,y)];
        y+=fiveDeltay;
    }
    
    // -------- oneLines
    oneLines = [NSBezierPath bezierPath];
    
    x = xstart;
    while (x < boundsRect.origin.x + boundsRect.size.width) {
        [oneLines moveToPoint:NSMakePoint(x,boundsRect.origin.y)];
        [oneLines lineToPoint:NSMakePoint(x,boundsRect.origin.y+boundsRect.size.height)];
        x+=oneDeltax;
    }
    
    y = ystart;
    while (y < boundsRect.origin.y + boundsRect.size.height) {
        [oneLines moveToPoint:NSMakePoint(boundsRect.origin.x,y)];
        [oneLines lineToPoint:NSMakePoint(boundsRect.origin.x+boundsRect.size.width,y)];
        y+=oneDeltay;
    }
    
}

- (void) setGraphics {
    
    graphColor = [baseColor colorWithAlphaComponent:alpha];
    
    wOne = tenDeltax*0.001*thicknessMultiplier;
    wFive = wOne*2.*thicknessMultiplier;
    wTen = wOne*5.*thicknessMultiplier;
    
}

- (void) constructAxes {
    
    axesBezier = [NSBezierPath bezierPath];
    

    if(axisLeft) {
        double ticksize = -oneDeltax;
        if(ticksInsideY) ticksize = oneDeltax;
        [axesBezier moveToPoint:NSMakePoint(xFirst, boundsRect.origin.y)];
        [axesBezier lineToPoint:NSMakePoint(xFirst, boundsRect.origin.y+boundsRect.size.height)];
        double yt = yFirst;
        if(axisBottom) yt+=tenDeltay;
        while (yt < boundsRect.origin.y+boundsRect.size.height) {
            [axesBezier moveToPoint:NSMakePoint(xFirst, yt)];
            [axesBezier lineToPoint:NSMakePoint(xFirst+ticksize, yt)];
            yt += 2.*tenDeltay;
        }
    }
    
    if(axisRight) {
        double ticksize = oneDeltax;
        if(ticksInsideY) ticksize = -oneDeltax;
        [axesBezier moveToPoint:NSMakePoint(xLast, boundsRect.origin.y)];
        [axesBezier lineToPoint:NSMakePoint(xLast, boundsRect.origin.y+boundsRect.size.height)];
        double yt = yFirst;
        if(axisBottom) yt+=tenDeltay;
        while (yt < boundsRect.origin.y+boundsRect.size.height) {
            [axesBezier moveToPoint:NSMakePoint(xLast, yt)];
            [axesBezier lineToPoint:NSMakePoint(xLast+ticksize, yt)];
            yt += 2.*tenDeltay;
        }
    }


    if(axisBottom) {
        double ticksize = -oneDeltay;
        if(ticksInsideX) ticksize = oneDeltay;
        [axesBezier moveToPoint:NSMakePoint(boundsRect.origin.x, yFirst)];
        [axesBezier lineToPoint:NSMakePoint(boundsRect.origin.x+boundsRect.size.width, yFirst)];
        double xt = xFirst;
        if(axisLeft) xt += tenDeltax;
        while (xt < boundsRect.origin.x+boundsRect.size.width) {
            [axesBezier moveToPoint:NSMakePoint(xt, yFirst)];
            [axesBezier lineToPoint:NSMakePoint(xt, yFirst+ticksize)];
            xt += 2.*tenDeltax;
        }
    }

    if(axisTop) {
        double ticksize = oneDeltay;
        if(ticksInsideX) ticksize = -oneDeltay;
        [axesBezier moveToPoint:NSMakePoint(boundsRect.origin.x, yLast)];
        [axesBezier lineToPoint:NSMakePoint(boundsRect.origin.x+boundsRect.size.width, yLast)];
        double xt = xFirst;
        if(axisLeft) xt += tenDeltax;
        while (xt < boundsRect.origin.x+boundsRect.size.width) {
            [axesBezier moveToPoint:NSMakePoint(xt, yLast)];
            [axesBezier lineToPoint:NSMakePoint(xt, yLast+ticksize)];
            xt += 2.*tenDeltax;
        }
    }

}

#pragma mark - the drawing

- (void) draw {
    
    [graphColor set];
    
    [oneLines setLineWidth:wOne];
    [oneLines stroke];

    [fiveLines setLineWidth:wFive];
    [fiveLines stroke];

    [tenLines setLineWidth:wTen];
    [tenLines stroke];
    
    [[NSColor blackColor] set];
    [axesBezier setLineWidth:wTen*4.];
    [axesBezier stroke];
 
    // -------------- now the axis labels
    NSString * numStr;
    NSMutableAttributedString * str;
    
    double xlim = xLast;
    if(!axisRight) xlim = boundsRect.origin.x + boundsRect.size.width;
    
    if(axisTop) {
        double xt = xFirst;
        if(axisLeft) xt += tenDeltax;
        while (xt < xlim) {
            numStr = [NSString stringWithFormat:@"%g",xt];
            str = [[NSMutableAttributedString alloc] initWithString:numStr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont fontWithName:_fontName size:_fontSize]
                        range:NSMakeRange(0,str.length)];
            NSSize sz = [str size];
            double ticksize = oneDeltay;
            if(ticksInsideX) ticksize = -oneDeltay-sz.height;
            [str drawAtPoint:NSMakePoint(xt-0.5*sz.width,yLast+ticksize)];
            xt += 2.*tenDeltax;
        }
    }
    if(axisBottom) {
        double xt = xFirst;
        if(axisLeft) xt += tenDeltax;
        while (xt < xlim) {
            numStr = [NSString stringWithFormat:@"%g",xt];
            str = [[NSMutableAttributedString alloc] initWithString:numStr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont fontWithName:_fontName size:_fontSize]
                        range:NSMakeRange(0,str.length)];
            NSSize sz = [str size];
            double ticksize = -oneDeltay-sz.height;
            if(ticksInsideX) ticksize = oneDeltay;
            [str drawAtPoint:NSMakePoint(xt-0.5*sz.width,yFirst+ticksize)];
            xt += 2.*tenDeltax;
        }
    }
    
    double ylim = yLast;
    if(!axisTop) ylim = boundsRect.origin.y + boundsRect.size.height;
    
    if(axisLeft) {
        double yt = yFirst;
        if(axisBottom) yt+=tenDeltay;
        while (yt < ylim) {
            numStr = [NSString stringWithFormat:@"%g",yt];
            str = [[NSMutableAttributedString alloc] initWithString:numStr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont fontWithName:_fontName size:_fontSize]
                        range:NSMakeRange(0,str.length)];
            NSSize sz = [str size];
            double xpos = xFirst-oneDeltax-sz.width;
            if(ticksInsideY) xpos = xFirst+oneDeltax;
            [str drawAtPoint:NSMakePoint(xpos,yt-0.5*sz.height)];
            yt += 2.*tenDeltay;
        }
    }
    if(axisRight) {
        double yt = yFirst;
        if(axisBottom) yt+=tenDeltay;
        while (yt < ylim) {
            numStr = [NSString stringWithFormat:@"%g",yt];
            str = [[NSMutableAttributedString alloc] initWithString:numStr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont fontWithName:_fontName size:_fontSize]
                        range:NSMakeRange(0,str.length)];
            NSSize sz = [str size];
            double xpos = xLast+oneDeltax;
            if(ticksInsideY) xpos = xLast-oneDeltax-sz.width;
            [str drawAtPoint:NSMakePoint(xpos,yt-0.5*sz.height)];
            yt += 2.*tenDeltay;
        }
    }

    

}

@end
