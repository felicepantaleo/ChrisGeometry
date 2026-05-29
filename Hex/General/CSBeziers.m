//
//  CSBeziers.m
//  Hex
//
//  Created by Chris Seez on 01/12/2023.
//  Copyright © 2023 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSBeziers.h"

@implementation NSBezierPath (CSBeziers);

+ (NSBezierPath *) crossHairsAt: (NSPoint) point withRadius: (double) rad {
    
    NSBezierPath * bez = [NSBezierPath bezierPath];
    [bez moveToPoint:NSMakePoint(point.x-rad, point.y)];
    [bez lineToPoint:NSMakePoint(point.x+rad, point.y)];
    [bez moveToPoint:NSMakePoint(point.x, point.y-rad)];
    [bez lineToPoint:NSMakePoint(point.x, point.y+rad)];
    
    return bez;
}

+ (NSBezierPath *) arrowFrom:(NSPoint) s To:(NSPoint) e headSize:(double) h {

    NSBezierPath * bez = [NSBezierPath bezierPath];
    
    bez = [NSBezierPath bezierPath];
    [bez moveToPoint:s];
    [bez lineToPoint:e];
    double phi = atan2(e.y-s.y,e.x-s.x);
    double ang = phi + 0.35;
    NSPoint tail = NSMakePoint(e.x - h*cos(ang),e.y - h*sin(ang));
    [bez lineToPoint:tail];
    ang = phi - 0.35;
    tail = NSMakePoint(e.x - h*cos(ang),e.y - h*sin(ang));
    [bez lineToPoint:tail];
    [bez lineToPoint:e];
    [bez setMiterLimit:h];
    

    return bez;

}
@end
