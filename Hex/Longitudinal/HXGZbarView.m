//
//  HXGZbarView.m
//  Hex
//
//  Created by Chris Seez on 05/03/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import "HXGZbarView.h"

@implementation HXGZbarView

- (void) drawBricks: (NSRect *) zb {
    
    for(int i=0; i<14; i++) {
        zBricks[i] = zb[i];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    for(int i=0; i<14; i++) {
        [[NSColor greyBlue] set];
        [NSBezierPath fillRect:zBricks[i]];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:0.5];
        [NSBezierPath strokeRect:zBricks[i]];
    }
    
    NSPoint p1 = NSMakePoint(zBricks[4].origin.x,zBricks[4].origin.y+zBricks[4].size.height*0.5);
    NSPoint p2 = NSMakePoint(zBricks[4].origin.x+zBricks[4].size.width,                 zBricks[4].origin.y+zBricks[4].size.height*0.5);
    double bottom = self.bounds.origin.y;
    double top = bottom + self.bounds.size.height;
    double tan175 = tan(17.5*M_PI/180.);
    double tan152 = tan(15.2*M_PI/180.);

    NSPoint t1 = NSMakePoint(p1.x+tan175*(top-p1.y),top);
    NSPoint t2 = NSMakePoint(p2.x+tan152*(top-p2.y),top);
    NSPoint b1 = NSMakePoint(p1.x-tan175*(p1.y-bottom),bottom);
    NSPoint b2 = NSMakePoint(p2.x-tan152*(p2.y-bottom),bottom);

    NSBezierPath * l1 = [NSBezierPath bezierPath];
    [l1 moveToPoint:t1];
    [l1 lineToPoint:b1];
    NSBezierPath * l2 = [NSBezierPath bezierPath];
    [l2 moveToPoint:t2];
    [l2 lineToPoint:b2];
    [l1 setLineWidth:0.25];
    [l2 setLineWidth:0.25];
    [l1 stroke];
    [l2 stroke];

}

@end
