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

    if(!thePreferences) thePreferences = [HXGPreferenceControl sharedPreferences];
    
    NSArray * hexcols = [thePreferences getColors];
    NSColor * col0 = [hexcols objectAtIndex:0];
    NSColor * col1 = [hexcols objectAtIndex:1];
    NSColor * col2 = [hexcols objectAtIndex:2];
    NSColor * col3 = [hexcols objectAtIndex:3];
    
    waferThicknessColors = [NSArray arrayWithObjects:col0,col1,col2,col3,nil];
    
    instantiated = _wafer.whole || _wafer.part;
    
    if(_rotated) {
        thirtyTransform = [[NSAffineTransform alloc] init];
        [thirtyTransform rotateByDegrees:30.];
    }
    
    NSString * description;

    //--- to do: rotated layers; show line
    NSString * typeCode[6] = {@"F",@"T",@"B",@"L",@"R",@"5"};
    if(instantiated) {
        NSString * density = @"HD";
        if(_wafer.LD) density = @"LD";
        int thick[4] = {120,200,200,300};
        NSString * name[12] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
        NSString * refCode = @"ML-";
        if(!_wafer.LD) refCode = @"MH-";
        refCode = [refCode stringByAppendingString:typeCode[_wafer.type]];


        description = [NSString stringWithFormat:@"%@ %d = %@    (%@)\n%dµm",density,_wafer.type,name[_wafer.type],refCode,thick[_wafer.thickflag]];
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
    description = [description stringByAppendingString:@"\nCorners:"];
    for(int i=0;i<6;i++) {
        double r = sqrt(_wafer.corner[i].x*_wafer.corner[i].x + _wafer.corner[i].y*_wafer.corner[i].y);
        description = [description stringByAppendingFormat:@"\n%4d: r = %.1f (%.1f,%.1f)",i,r,_wafer.corner[i].x,_wafer.corner[i].y];
    }
    
    specString = [[NSMutableAttributedString alloc] initWithString:description];
    [specString addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:14.]
                range:NSMakeRange(0,specString.length)];

    side = 48.;
    margin = 24.;
    buttonSpace = 24.;
    double width = specString.size.width + 2.*margin;
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

    hexCentre = NSMakePoint(x,y);
    
    int dummy[2];
    HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:1000 andDetId:dummy];
    w.type = _wafer.type;
    w.LD = _wafer.LD;
    w.v17 = _wafer.v17;
    w.channelZero = _wafer.channelZero;
    w.seenFromBack = _wafer.seenFromBack;
    
    w.debugPrint = YES;
    [w constructWaferBezierMirrored: _mirror];
    [w markerBezierMirrored: _mirror]; // still needs work...
    w.debugPrint = NO;
    
    bezier = w.bezier;
    waferBezier = [w waferBezier];
    zeroMarkBezier = w.zeroBezier;
    barBezier = w.barBezier;
    
    return viewSize;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
   
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];

    if(_rotated && _rotateRotated) [thirtyTransform concat];

    NSColor * col = waferThicknessColors[_wafer.thickflag];
    [col set];

    if(instantiated) [bezier fill];
    
    [[NSColor blackColor] set];
    if(_wafer.v17 && instantiated) {
        [[NSColor redColor] set];
        [zeroMarkBezier fill];
        [[NSColor blackColor] set];
        [zeroMarkBezier setLineWidth:1.];
        [zeroMarkBezier stroke];
        if(_wafer.whole) {
            [[NSColor coolGrey] set];
            [barBezier fill];
        }
    }
    [bezier setLineWidth:1.];
    [bezier stroke];

    [waferBezier setLineWidth:0.5];
    [waferBezier stroke];
  
    //---- Number the points
    
    for(int i=0; i<6; i++) {
        int num = i;
        if(_wafer.seenFromBack && _wafer.v17) num = (6-i)%6;
        if(_mirror) num = (6-i)%6;
        NSString * numstr = [NSString stringWithFormat:@"%d",num];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:numstr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont fontWithName:@"Helvetica" size:16.]
                    range:NSMakeRange(0,str.length)];
        
        double radius = side + 0.6*str.size.height;
        double angle = (double) i * M_PI/3. - M_PI*0.5;
        NSPoint dpnt = NSMakePoint(hexCentre.x + radius*cos(angle),hexCentre.y + radius*sin(angle));
        NSRect dRect = NSMakeRect(dpnt.x-0.5*str.size.width,dpnt.y-0.5*str.size.height,str.size.width,str.size.height);
        [str drawInRect:dRect];
    }
    
    if(_rotateRotated && _rotated) {
        [thirtyTransform invert];
        [thirtyTransform concat];
        [thirtyTransform invert];
    }

    [specString drawAtPoint:NSMakePoint(margin,margin+buttonSpace)];



}

@end
