//
//  HTDFadeView.h
//
//  Created by seez on 19/05/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HTDFadeView : NSView
{
    uint8_t * plook;
    
    NSArray * colorArray;
    
    double emax;
    int nlk;
    double xstart;
    double ystart;
    double ystep;
    double hwid;
    
    NSBezierPath * scale;
    int nmaj;
    int nmin;
    double deltaE;
    double dpix;
    double xtext;
    double ytext[6];
    double sval[6];
    NSString * scaleFormat;
    
    BOOL horizontal;
    double yhtext;
    double xhtext[6];
    double xhstart;
    double yhstart;
    double xhstep;
    double vwid;
    
}

- (void) drawEnergyScale:(double)e;
- (void) drawHorizontalScale:(double) vmax;
- (void) drawColorScale;

@end
