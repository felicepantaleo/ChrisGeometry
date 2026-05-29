//
//  HXGCEHspacers.m
//  Hex
//
//  Created by Chris Seez on 04/12/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGCEHspacers.h"

//#pragma GCC diagnostic ignored "-Wgnu-folding-constant"

static int const nCEH = 21;
static double const radius[21] = {1665,1665,1665,1665,1665,1780,1860,1940,2020,2106,2186.5,               2275,2383,2492,2575,2575,2575,2575,2575,2575,2575};
static int const cehOffset = 26;
static double const rspacer = 75.*0.5;
static int const nspacer = 12;


@implementation HXGCEHspacers

+ (id) sharedCEHspacers {
    
    static dispatch_once_t pred;
    static HXGCEHspacers * theSpacers = nil;
    
    dispatch_once(&pred, ^{ theSpacers = [[self alloc] init]; });
    return theSpacers;
    
}

- (id)init {
    
    return self;
}

- (NSBezierPath *) spacerBezierForLayer: (int) layer {
    
    NSBezierPath * spacerBezier = [NSBezierPath bezierPath];
    
    int l = layer - cehOffset;
    if(!(l < 0 || l >= nCEH)) {
        double phi = 0.;
        double dphi = M_PI/6.;
        for(int i=0; i<nspacer; i++) {
            NSPoint centre = NSMakePoint(radius[l]*sin(phi),radius[l]*cos(phi));
            NSBezierPath * circle = [NSBezierPath bezierPath];
            [circle appendBezierPathWithArcWithCenter:centre radius:rspacer startAngle:0. endAngle:360.];
            [spacerBezier appendBezierPath:circle];
            [spacerBezier closePath];
            phi += dphi;
        }
        [spacerBezier setLineWidth:5.0];

    }
    
    
    return spacerBezier;
}
@end
