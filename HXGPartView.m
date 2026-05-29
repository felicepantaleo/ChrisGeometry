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

- (void) setColors:(NSArray *) hexcols;
{
    col0 = [hexcols objectAtIndex:0];
    col1 = [hexcols objectAtIndex:1];
    col2 = [hexcols objectAtIndex:2];
    col3 = [hexcols objectAtIndex:3];
    
    cola = [NSColor paleBlue];
    colb = [NSColor peachOrange];
}

- (void) makeParts50 {
    _partType = 50;
    
    wafers = [NSMutableArray array];
    wholes = [NSMutableArray array];
    parts = [NSMutableArray array];
    bisections = [NSMutableArray array];
    
    //int bisected[10] = {1,2,2,2,0,0,1,1,0,0};
    
    double width = [self frame].size.width;
    //double height = [self frame].size.height;
    double x0 = [self frame].origin.x;
    double y0 = [self frame].origin.y;
    //NSLog(@"width = %.1f, height = %.1f, x0 = %.1f, y0 = %.1f",width,height,x0,y0);
    
    double full = width/6.5;
    double rt3 = sqrt(3.0);
    
    int dummy[2]; // dummy detId
    for (int i=0; i<10; i++)
    {
        int ih = i%4;
        double x = x0+full+ih*full*1.5;
        int iv = 1-i/4;
        double y = y0 + 215.0 + iv*full*1.55;
        HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:full/rt3 ID:1000+i andDetId:dummy];
        [wafers addObject:w];
        [wholes addObject:[w waferBezier]];
        [parts addObject:[w partBezier:i]];
        textloc[i] = NSMakePoint(x,y-full/rt3-25.0);
    }

    
    text = [NSArray arrayWithObjects:@"(a) half",@"(b) five",@"(c) three",@"(d) semi",@"(e) 3/4 five",@"(f) 1/4 five",@"(g) choptwo",@"(h) chopfour",@"(i) 3 1/2",@"(j) 4 1/2",nil];
    
    [self setNeedsDisplay:YES];
}

- (void) makeParts47 {
    
    _partType = 47;
    
    wafers = [NSMutableArray array];    
    
    double width = [self frame].size.width;
    double x0 = [self frame].origin.x;
    double y0 = [self frame].origin.y;
    
    double distance[14] = {0.4,-0.4, -0.5,0.5, -0.2,0.7, -0.5,0.7, 0.6,-0.3, -0.6,0.6, -0.3,0.6};
    int dir [7] = {1,0,0,0,1,0,0};
    
    full = width/6.5;
    side = full/sqrt(3.0);
    
    int dummy[2]; // dummy detId

    for (int i=0; i<7; i++) {
        int ih = i%4;
        double x = x0+full+ih*full*1.5;
        int iv = 1-i/4;
        double y = y0 + 150.0 + iv*full*2.0;
        HXGWafer * w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+3*i andDetId:dummy];
        [wafers addObject:w];
        [w wholeBezier];

        w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+3*i+1 andDetId:dummy];
        [wafers addObject:w];
        [w part47Bezier:2*i];
        w = [HXGWafer waferWithX:x Y:y Side:side ID:1000+3*i+2 andDetId:dummy];
        [wafers addObject:w];
        [w part47Bezier:2*i+1];
        if(i<4) textloc[i] = NSMakePoint(x,y-side-45.0);
        else textloc[i] = NSMakePoint(x,y-side-25.0);
        id47loc[2*i] = [self moveBy:distance[2*i] From:NSMakePoint(x,y) inDirection:dir[i]];
        id47loc[2*i+1] = [self moveBy:distance[2*i+1] From:NSMakePoint(x,y) inDirection:dir[i]];
    }

    
    text = [NSArray arrayWithObjects:@"LD 1, 2 = a\n(half)",@"LD 3, 4 = d\n(semi)",@"LD 5, 6 = b, c\n(five, three)",@"LD 3, 6 = d, c\n(semi, three)",@"HD 1, 2",@"HD 3, 4",@"HD 5, 4",nil];
    
    name = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"3",@"6",@"1",@"2",@"3",@"4",@"5",@"4",nil];
    
    tableText = @"LD 1 = Top\nLD 2 = Bottom\nLD 3 = Left\nLD 4 = Right\nLD 5 = Five\nLD 6 = Three\n\nHD 1 = Top\nHD 2 = Bottom\nHD 3 = Left\nHD 4 = Right\nHD 5 = Five";
    
    tableLoc = NSMakePoint(x0+full+3.*full*1.4-25.,y0 + 140.0 - 1.5*full);
    
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

- (void) savePDF:(NSString *)path
{
    pdf = YES;
    NSData * data = [self dataWithPDFInsideRect:frameRect];
    [data writeToFile:path options:0 error:nil];
    pdf = NO;
}



- (void)drawRect:(NSRect)dirtyRect
{
    
    //if([wholes count] < 1) return;
    if(pdf) [self setFrame:NSMakeRect(frameRect.origin.x, frameRect.origin.y + 10.0, frameRect.size.width,frameRect.size.height*1.40)];
    else [self setFrame:frameRect];
    
    if(_partType == 50) [self draw50];
    else if(_partType == 47) [self draw47];

}

- (void) draw50 {
    
    double w = 1.0;
    [[NSColor blackColor] set];
    
    for (int i = 0; i<wholes.count; i++) {
        w=2.0;
        NSBezierPath * path = [wholes objectAtIndex:i];
        [path setLineWidth:w];
        [path stroke];
        path = [parts objectAtIndex:i];
        w=4.0;
        [path setLineWidth:w];
        if(i<3)[col0 set];
        else if(i==3) [col1 set];
        else if(i<6) [col2 set];
        else [col3 set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];
        
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:[text objectAtIndex:i]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:18]
                    range:NSMakeRange(0,str.length)];
        NSPoint tpnt = NSMakePoint(textloc[i].x - 0.5 * [str size].width,textloc[i].y);
        [str drawAtPoint:tpnt];
    }

    
}

- (void) draw47 {

    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];
    
    double w = 1.0;
    [[NSColor blackColor] set];

    
    for (int i = 0; i<7; i++) {
        w=1.0;
        HXGWafer * waf = [wafers objectAtIndex:3*i];
        NSBezierPath * path = waf.bezier;
        [path setLineWidth:w];
        [path stroke];
        waf = [wafers objectAtIndex:3*i+1];
        path = waf.bezier;
        w=2.0;
        [path setLineWidth:w];
        [cola set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];

        waf = [wafers objectAtIndex:3*i+2];
        path = waf.bezier;
        w=2.0;
        [path setLineWidth:w];
        [colb set];
        [path fill];
        [[NSColor blackColor] set];
        [path stroke];

        /*
        if(parts.count > 2*i+1) {
            path = [parts objectAtIndex:2*i];
            w=2.0;
            [path setLineWidth:w];
            [cola set];
            [path fill];
            [[NSColor blackColor] set];
            [path stroke];
            
            path = [parts objectAtIndex:2*i+1];
            w=2.0;
            [path setLineWidth:w];
            [colb set];
            [path fill];
            [[NSColor blackColor] set];
            [path stroke];
         } */
        
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:[text objectAtIndex:i]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:18]
                    range:NSMakeRange(0,str.length)];
        [str setAlignment:+1 range:NSMakeRange(0,str.length)];
        NSPoint tpnt = NSMakePoint(textloc[i].x - 0.5 * [str size].width,textloc[i].y);
        [str drawAtPoint:tpnt];
        
        str = [str initWithString:[name objectAtIndex:2*i]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:16]
                    range:NSMakeRange(0,str.length)];
        NSPoint pnt = NSMakePoint(id47loc[2*i].x - 0.5*str.size.width,id47loc[2*i].y-0.5*str.size.height);
        [str drawAtPoint:pnt];
        
        str = [str initWithString:[name objectAtIndex:2*i+1]];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:16]
                    range:NSMakeRange(0,str.length)];
        pnt = NSMakePoint(id47loc[2*i+1].x - 0.5*str.size.width,id47loc[2*i+1].y-0.5*str.size.height);
        [str drawAtPoint:pnt];
    }
    
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:tableText];
    [str addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:18]
                range:NSMakeRange(0,str.length)];
    [str drawAtPoint:tableLoc];
    
    NSBezierPath * tableRect = [NSBezierPath bezierPathWithRect:NSMakeRect(tableLoc.x-5.,tableLoc.y-5.,str.size.width+10.,str.size.height+10.)] ;
    [[NSColor blackColor] set];
    [tableRect setLineWidth:1.];
    [tableRect stroke];
    
    str = [[NSMutableAttributedString alloc] initWithString:@"Reference rotation position: channel #1 at bottom"];
    [str addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:22]
                range:NSMakeRange(0,str.length)];

    [str drawAtPoint:NSMakePoint(50., 10.)];


}

@end
