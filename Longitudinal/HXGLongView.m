//
//  HXGLongView.m
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGLongView.h"
NSString * const HXGNewCrossHairsNotification = @"HXGNewCrossHairs";

@implementation HXGLongView

- (void) loadDiagram {
    
    BOOL pdfType = NO;
    NSString * imageFile = [[NSBundle mainBundle]
                        pathForResource:_fileName ofType:@"png"];
    
    //NSLog(@"imageFile = %@",imageFile);
    
    if(pdfType) {
        NSData * pdfData = [NSData dataWithContentsOfFile:imageFile];
        NSPDFImageRep * pdfImageRep = [NSPDFImageRep imageRepWithData:pdfData];
        edmsImage = [[NSImage alloc] init];
        [edmsImage addRepresentation:pdfImageRep];
    } else edmsImage = [[NSImage alloc] initWithContentsOfFile:imageFile];
    
    //---- Set up the coordinate system
    double w = (self.frame.size.width + self.frame.origin.x)*_scale;
    double h = (self.frame.size.height + self.frame.origin.y)*_scale;
    NSRect bounds = NSMakeRect(_zLow,_rLow,w,h);
    [self setBounds:bounds];
    _crossHairs.x = bounds.origin.x + 0.5*bounds.size.width;
    _crossHairs.y = bounds.origin.y + 0.5*bounds.size.height;
    _showcoords = YES;
}

- (void) setViewBounds {
   
    NSRect bounds;
    if(_calibrationMode) {
        double w = (self.frame.size.width + self.frame.origin.x);
        double h = (self.frame.size.height + self.frame.origin.y);
        NSPoint o = self.frame.origin;
        bounds = NSMakeRect(o.x,o.y,w,h);
        [self setBounds:bounds];
    } else {
        double w = (self.frame.size.width + self.frame.origin.x)*_scale;
        double h = (self.frame.size.height + self.frame.origin.y)*_scale;
        bounds = NSMakeRect(_zLow,_rLow,w,h);
        [self setBounds:bounds];
    }

    _crossHairs.x = bounds.origin.x + 0.5*bounds.size.width;
    _crossHairs.y = bounds.origin.y + 0.5*bounds.size.height;
}

- (void)mouseDown:(NSEvent *)theEvent {

    NSPoint mousePoint;

    if([theEvent clickCount] > 1) {
        theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp];
        _crossHairs = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        _showcoords = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewCrossHairsNotification object:self];
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(!_showcoords) return;
    BOOL tracking = YES;
    BOOL isInside = YES;
    NSTimeInterval tstart = [NSDate timeIntervalSinceReferenceDate];

    [NSCursor hide];

    while (tracking) {

        theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp |
                    NSEventMaskLeftMouseDragged];
        mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

        double r2 = ((mousePoint.x -_crossHairs.x)*(mousePoint.x -_crossHairs.x) + (mousePoint.y -_crossHairs.y)*(mousePoint.y -_crossHairs.y));
        isInside = r2 < 4000.;
        
        if(!isInside) {
            [NSCursor unhide];
            return;
        }
        
        switch ([theEvent type]) {

            case NSEventTypeLeftMouseDragged:
                _crossHairs = mousePoint;
                NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
                if(tnow - tstart > 0.15) {
                    NSNotification * note = [NSNotification notificationWithName: HXGNewCrossHairsNotification object:self];
                    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
                    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                        postingStyle: NSPostNow
                        coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                            forModes: modes];
                    [self setNeedsDisplay:YES];
                    tstart = tnow;
                }

                break;

            case NSEventTypeLeftMouseUp:
                    tracking = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewCrossHairsNotification object:self];

                    break;

            default:

                    break;
        }
    };

    [NSCursor unhide];
    
    return;
}

- (void) addEtaLine:(double) eta {
    
    if(_nlines > 2) return;
    
    etaLine[_nlines] = [NSBezierPath bezierPath];
    double theta = 2.*atan2(exp(-eta),1.);

    [etaLine[_nlines] moveToPoint:NSMakePoint(_zLow,_zLow*tan(theta))];
    double z = _zLow + self.bounds.size.width;
    [etaLine[_nlines] lineToPoint:NSMakePoint(z,z*tan(theta))];
    [etaLine[_nlines] setLineWidth:5.];
    NSString * hstr = [NSString stringWithFormat:@"η = %.2f",eta];
    etaLabel[_nlines] = [[NSMutableAttributedString alloc] initWithString:hstr];
    [etaLabel[_nlines] addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:60]
                range:NSMakeRange(0,etaLabel[_nlines].length)];
    
    z = 5400.;
    double r = z*tan(theta);
    xform[_nlines] = [NSAffineTransform transform];
    [xform[_nlines] rotateByRadians:theta]; // counterclockwise rotation
    [xform[_nlines] translateXBy:z*cos(theta)+r*sin(theta)-z yBy:r*cos(theta)-z*sin(theta)-r];
    z -= 0.5*etaLabel[_nlines].size.width;
    r -= 0.5*etaLabel[_nlines].size.height;
    labelRect[_nlines] = NSMakeRect(z,r,etaLabel[_nlines].size.width,etaLabel[_nlines].size.height);
    labelBox[_nlines] = NSMakeRect(z-10.,r-5.,etaLabel[_nlines].size.width+20.,etaLabel[_nlines].size.height+2.);


    _nlines++;
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [edmsImage drawInRect:self.bounds
           fromRect:NSZeroRect
          operation:NSCompositingOperationCopy
                  fraction:1.];
    
    if(_showcoords) {
        double len = 60.;
        if(_calibrationMode) len = 13.7;
        NSBezierPath * cross = [NSBezierPath crossHairsAt:_crossHairs withRadius:len];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:_crossHairs radius:len startAngle:0.0 endAngle:360.0];

        if(_calibrationMode) {
            [circle setLineWidth:2.];
            [cross setLineWidth: 0.25];
        }
        else {
            [circle setLineWidth:5.];
            [cross setLineWidth: 1.25];
        }
        [[NSColor blackColor] set];
        [cross stroke];
        [circle stroke];
    }
    
    for(int i=0; i<_nlines; i++) {
        [[NSColor blackColor] set];
        [etaLine[i] stroke];
        [xform[i] concat];
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:labelBox[i]];
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:labelBox[i]];
        [etaLabel[i] drawInRect:labelRect[i]];
        [xform[i] invert];
        [xform[i] concat];
        [xform[i] invert];
    }

}

@end
