//
//  HXGPartView.m
//  Hex
//
//  Created by seez on 10/06/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGPartView.h"

@implementation HXGPartView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frameRect = frame;
        pdf = NO;
    }
    
    return self;
}

- (void) setPartFrame: (NSRect) fRect {
    
    frameRect = fRect;
    [self setFrame:frameRect];
    
}

- (void) setColors {
    
    cola = [NSColor paleBlue];
    colb = [NSColor peachOrange];
}

- (void) makeParts47 {
    
    wafers = [NSMutableArray array];    
    
    double width = [self frame].size.width;
    double x0 = [self frame].origin.x;
    double y0 = [self frame].origin.y;
    
    double distance[14] = {0.4,-0.4, -0.5,0.5, -0.2,0.7, -0.5,0.7, 0.6,-0.3, -0.6,0.6, -0.3,0.6};
    int dir [7] = {1,0,0,0,1,0,0};
    
    full = width/5.5;
    side = full/sqrt(3.0);
    
    int dummy[2]; // dummy detId

    for (int i=0; i<7; i++) {
        int ih = i%4;
        double x = x0+full+ih*full*1.5;
        int iv = 1-i/4;
        double y = y0 + 160.0 + iv*full*1.8;
        HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+4*i andDetId:dummy];
        [wafers addObject:w];
        [w wholeBezier];

        w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+4*i+1 andDetId:dummy];
        [wafers addObject:w];
        [w part47Bezier:2*i];
        w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+4*i+2 andDetId:dummy];
        [wafers addObject:w];
        [w part47Bezier:2*i+1];
        if(i<4) textloc[i] = NSMakePoint(x,y-side-55.0);
        else textloc[i] = NSMakePoint(x,y-side-55.0);
        id47loc[2*i] = [self moveBy:distance[2*i] From:NSMakePoint(x,y) inDirection:dir[i]];
        id47loc[2*i+1] = [self moveBy:distance[2*i+1] From:NSMakePoint(x,y) inDirection:dir[i]];
        
        w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+4*i+3 andDetId:dummy];
        [wafers addObject:w];
        [w completePartialBezierForHD:(i>3)];
    }

    
    text = [NSArray arrayWithObjects:@"LD 1, 2\n(half)",@"LD 3, 4\n(semi)",@"LD 5\n(five)",@"LD 3\n(semi)",@"HD 1, 2\n(chop4, chop2)",@"HD 3, 4\n(semi-minus)",@"HD 4\n",nil];
    
    name = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"3",@"6",@"1",@"2",@"3",@"4",@"5",@"4",nil];
    
    tableText = @"LD 1 = Top\nLD 2 = Bottom\nLD 3 = Left\nLD 4 = Right\nLD 5 = Five\n(LD 6 Three)\n\nHD 1 = Top\nHD 2 = Bottom\nHD 3 = Left\nHD 4 = Right\n(HD 5 Five)";
    
    tableLoc = NSMakePoint(x0+full+2.4*full*1.4-25.,y0 + 140.0 - 1.3*full);
    
    NSString * imageFile = [[NSBundle mainBundle]
                        pathForResource:@"partialNamesTable" ofType:@"png"];
    tableImage = [[NSImage alloc] initWithContentsOfFile:imageFile];
    
    [self setNeedsDisplay:YES];
}

- (NSPoint) moveBy: (double) d From: (NSPoint) p inDirection: (int) a {
    
    NSPoint q;
    double sin60 = sin(M_PI/3.);
    double cos60 = cos(M_PI/3.);
    double dd = d*side;
    
    if(a == 0) {
        q = NSMakePoint(p.x-sin60*dd,p.y+cos60*dd);
    } else {
        q = NSMakePoint(p.x-cos60*dd,p.y-sin60*dd);
    }
    
    
    return q;
}

- (void) savePDF:(NSString *)path {
    
    pdf = YES;
    NSData * data = [self dataWithPDFInsideRect:self.frame];
    [data writeToFile:path options:0 error:nil];
    pdf = NO;
}



- (void)drawRect:(NSRect)dirtyRect {
    
    //if([wholes count] < 1) return;
    if(pdf) [self setFrame:NSMakeRect(frameRect.origin.x, frameRect.origin.y + 10.0, frameRect.size.width,frameRect.size.height*1.40)];
    else [self setFrame:frameRect];
    
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];
    
    double w = 1.0;
    [[NSColor blackColor] set];
    
    NSAffineTransform * mirrorTransform;
    NSAffineTransform * rot210Transform;
    
    for (int i = 0; i<6; i++) {
        if(i == 3) continue;
        HXGWafer * waf = [wafers objectAtIndex:4*i];
        if(_seenFromBack) {
            mirrorTransform = [NSAffineTransform transform];
            mirrorTransform = [mirrorTransform init];
            [mirrorTransform translateXBy:waf.xc yBy:0.]; // Order of transforms seems weird...
            [mirrorTransform scaleXBy:-1. yBy:1.];
            [mirrorTransform translateXBy:-waf.xc yBy:0.];
            [mirrorTransform concat];
        }
        if(_hardwareOrientation) {
            rot210Transform = [NSAffineTransform transform];
            rot210Transform = [rot210Transform init];
            [rot210Transform translateXBy:waf.xc yBy:waf.yc]; // Order of transforms seems weird...
            [rot210Transform rotateByDegrees:210.];
            [rot210Transform translateXBy:-waf.xc yBy:-waf.yc];
            [rot210Transform concat];
        }

        waf = [wafers objectAtIndex:4*i+1];
        NSBezierPath * path = waf.bezier;
        w=1.0;
        [path setLineWidth:w];
        [cola set];
        if(i==6 && [[name objectAtIndex:2*i] isEqualToString:@"5"]) [[NSColor whiteColor] set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];

        waf = [wafers objectAtIndex:4*i+2];
        path = waf.bezier;
        w=1.0;
        [path setLineWidth:w];
        [colb set];
        if([[name objectAtIndex:2*i+1] isEqualToString:@"6"]) [[NSColor whiteColor] set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];
    
        // ---- The dicing lines game -----------------------
        if(_showDicingLines) {
            waf = [wafers objectAtIndex:4*i+3];
            path = waf.bezier;
            [path setLineWidth:w];
            [path stroke];
        }
        // --------------------------------------------------
 
        waf = [wafers objectAtIndex:4*i];
        [[NSColor blackColor] set];
        path = waf.bezier;
        w=2.0;
        [path setLineWidth:w];
        [path stroke];

        //waf.v17 = YES;
        [waf markerBezierMirrored: NO];
        [waf.zeroBezier setLineWidth:w];
        [[NSColor redColor] set];
        [waf.zeroBezier fill];
        [[NSColor blackColor] set];
        [waf.zeroBezier stroke];

        if(_hardwareOrientation) {
            [rot210Transform invert];
            [rot210Transform concat];
            [rot210Transform invert];
        }
        if(_seenFromBack) {
            [mirrorTransform invert];
            [mirrorTransform concat];
            [mirrorTransform invert];
        }

        NSMutableAttributedString * str;
            
        str = [[NSMutableAttributedString alloc] initWithString:[text objectAtIndex:i]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:22]
                    range:NSMakeRange(0,str.length)];
        [str setAlignment:+1 range:NSMakeRange(0,str.length)];
        NSPoint tpnt = NSMakePoint(textloc[i].x - 0.5 * [str size].width,textloc[i].y);
        [str drawAtPoint:tpnt];

        str = [str initWithString:[name objectAtIndex:2*i]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:16]
                    range:NSMakeRange(0,str.length)];
        NSPoint pnt = NSMakePoint(id47loc[2*i].x - 0.5*str.size.width,id47loc[2*i].y-0.5*str.size.height);
        if(_hardwareOrientation) {
            pnt = [rot210Transform transformPoint:pnt];
            pnt.y -= str.size.height;
        }
        if(_seenFromBack) pnt.x = -pnt.x + 2.*waf.xc;
        [str drawAtPoint:pnt];
        
        str = [str initWithString:[name objectAtIndex:2*i+1]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:16]
                    range:NSMakeRange(0,str.length)];
        pnt = NSMakePoint(id47loc[2*i+1].x - 0.5*str.size.width,id47loc[2*i+1].y-0.5*str.size.height);
        if(_hardwareOrientation) {
            pnt = [rot210Transform transformPoint:pnt];
            pnt.y -= str.size.height;
        }
        if(_seenFromBack) pnt.x = -pnt.x + 2.*waf.xc - str.size.width;
        if(![[name objectAtIndex:2*i+1] isEqualToString:@"6"]) [str drawAtPoint:pnt];
    }

    NSMutableAttributedString * str;
    /*
    str = [[NSMutableAttributedString alloc] initWithString:tableText];
    [str addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:18]
                range:NSMakeRange(0,str.length)];
    [str drawAtPoint:tableLoc];
    
    NSBezierPath * tableRect = [NSBezierPath bezierPathWithRect:NSMakeRect(tableLoc.x-5.,tableLoc.y-5.,str.size.width+10.,str.size.height+10.)] ;
    [[NSColor blackColor] set];
    [tableRect setLineWidth:2.];
    [tableRect stroke];
     */
    double scale = 0.3;
    NSRect tableRect = NSMakeRect(tableLoc.x-30.,tableLoc.y-10.,scale*520.,scale*886);
    [tableImage drawInRect:tableRect
           fromRect:NSZeroRect
          operation:NSCompositingOperationCopy
                  fraction:1.];

    if(!_hardwareOrientation) {
        str = [[NSMutableAttributedString alloc] initWithString:@"Channel #1, (u, v) = (0, 0) at bottom"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:24]
                    range:NSMakeRange(0,str.length)];
        [str drawAtPoint:NSMakePoint(50., 20.)];
    }
    
    NSString * frontView = @"Seen from the FRONT";
    if(_seenFromBack) frontView = @"Seen from the BACK";
    str = [[NSMutableAttributedString alloc] initWithString:frontView];
    [str addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:24]
                range:NSMakeRange(0,str.length)];
    [str drawAtPoint:NSMakePoint(50., 490.)];


}

@end
