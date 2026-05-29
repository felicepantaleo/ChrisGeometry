//
//  HXGInspectorView.m
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGInspectorView.h"

@implementation HXGInspectorView

- (NSSize) setUpTheInspectorDisplay {


    instantiated = _wafer.whole || _wafer.part;
    
    if(_rotated) {
        thirtyTransform = [[NSAffineTransform alloc] init];
        [thirtyTransform rotateByDegrees:30.];
    }
    
    NSString * description;

    //--- to do: rotated layers; show line
    if(instantiated) {
        NSString * density = @"HD";
        if(_wafer.LD) density = @"LD";
        int thick[3] = {120,200,300};
        NSString * name[12] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
        description = [NSString stringWithFormat:@"%@ %d = %@\n%dµm",density,_wafer.type,name[_wafer.type],thick[_wafer.thickflag]];
        description = [description stringByAppendingFormat:@", Cassette %d\n",_wafer.cassette];
    } else description = @"Empty\n";
    description = [description stringByAppendingFormat:@"detId = (%d,%d)\n",_wafer.detId[0],_wafer.detId[1]];
    description = [description stringByAppendingFormat:@"Hex number %d\n",_wafer.ID];
    description = [description stringByAppendingFormat:@"Centre: (%.3f,%.3f)",_wafer.xc,_wafer.yc];
    if(_rotated) {
        double xx = _wafer.xc;
        double yy = _wafer.yc;
        double xr = xx*cos(M_PI/6.) - yy*sin(M_PI/6.);
        double yr = xx*sin(M_PI/6.) + yy*cos(M_PI/6.);
        description = [description stringByAppendingFormat:@"\nRotated centre: (%.1f,%.1f)",xr,yr];

    }
    description = [description stringByAppendingFormat:@"\nCorners:\n(%.1f,%.1f) (%.1f,%.1f)\n(%.1f,%.1f) (%.1f,%.1f)\n(%.1f,%.1f) (%.1f,%.1f)",_wafer.corner[0].x,_wafer.corner[0].y,_wafer.corner[1].x,_wafer.corner[1].y,_wafer.corner[2].x,_wafer.corner[2].y,_wafer.corner[3].x,_wafer.corner[3].y,_wafer.corner[4].x,_wafer.corner[4].y,_wafer.corner[5].x,_wafer.corner[5].y];
    
    specString = [[NSMutableAttributedString alloc] initWithString:description];
    [specString addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:14.]
                range:NSMakeRange(0,specString.length)];

    margin = 10.;
    buttonSpace = 24.;
    double width = specString.size.width + 2.*margin;
    double side = 36.;
    double height = specString.size.height + 2.*side + 3.*margin + buttonSpace;

    NSSize viewSize = NSMakeSize(width,height);
    
    double x = 0.5*width;
    double y = height - (side+margin);
    if(_rotated && _rotateRotated) {
        double xx = x;
        double yy = y;
        x = xx*cos(-M_PI/6.) - yy*sin(-M_PI/6.);
        y = xx*sin(-M_PI/6.) + yy*cos(-M_PI/6.);
    }

    int dummy[2];
    HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:1000 andDetId:dummy];
    w.type = _wafer.type;
    w.LD = _wafer.LD;
    w.v17 = _wafer.v17;
    w.channelZero = _wafer.channelZero;
    [w constructWaferBezier];
    [w markerBezier];
    bezier = w.bezier;
    waferBezier = [w waferBezier];
    zeroMarkBezier = w.zeroBezier;
    
    return viewSize;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
   
    [[NSColor paleCream] set];
    [NSBezierPath fillRect:self.bounds];

    if(_rotated && _rotateRotated) [thirtyTransform concat];

    if(_wafer.part) {
        if(_wafer.type%2 == 1) [[NSColor greyBlue] set];
        else [[NSColor peachOrange] set];
    } else [[NSColor orchidPink]  set];

    if(instantiated) [bezier fill];
    
    [[NSColor blackColor] set];
    if(_wafer.v17 && instantiated) {
        [[NSColor redColor] set];
        [zeroMarkBezier fill];
        [[NSColor blackColor] set];
        [zeroMarkBezier setLineWidth:1.];
        [zeroMarkBezier stroke];
    }
    [bezier setLineWidth:1.];
    [bezier stroke];

    [waferBezier setLineWidth:0.5];
    [waferBezier stroke];
    
    if(_rotateRotated && _rotated) {
        [thirtyTransform invert];
        [thirtyTransform concat];
        [thirtyTransform invert];
    }

    [specString drawAtPoint:NSMakePoint(margin,margin+buttonSpace)];



}

@end
