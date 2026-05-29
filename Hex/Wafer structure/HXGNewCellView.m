//
//  HXGNewCellView.m
//  Hex
//
//  Created by Chris Seez on 26/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGNewCellView.h"

const double halfmax = 97.;

NSString * const HXGNewCellInfoNotification = @"HXGNewCellInfo";


@implementation HXGNewCellView
- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    
    tstart = 0.;
    
    return self;
}

- (void) setViewFrame:(NSRect) fR {

    frameRect = fR;
    frameRect.size.width = fR.size.width;
    frameRect.size.height = fR.size.height;

    [self setFrame:frameRect];

    _magnification = 1.;
    double ysize = 2.*halfmax*(frameRect.size.height/frameRect.size.width);
    NSRect bR = NSMakeRect(-halfmax, -halfmax, 2.*halfmax, ysize);
    [self setBounds:bR];
    [self setClipsToBounds:YES];
    
    theStructuredWafer = [HXGStructuredWafer sharedStructuredWafer];
    [self setNeedsDisplay:YES];

}

- (void) setViewBounds {
  
    NSPoint centre = NSZeroPoint;
    if(_magnification != 1.) {
        NSPoint bOrig = self.bounds.origin;
        NSSize bSiz = self.bounds.size;
        centre = NSMakePoint(bOrig.x+0.5*bSiz.width,bOrig.y+0.5*bSiz.width);
    }
    double newOrigX = centre.x - halfmax/_magnification;
    double newOrigY = centre.y - halfmax/_magnification;
    double ysize = 2.*halfmax*(frameRect.size.height/frameRect.size.width);
    NSRect bR = NSMakeRect(newOrigX, newOrigY, 2.*halfmax/_magnification, ysize/_magnification);
    [self setBounds:bR];
    [self setClipsToBounds:YES];

}

- (void) savePDF:(NSString *)path {
    
    pdf = YES;

    NSRect b = [self bounds];
    NSRect f = [self frame];
    
    if(_pdfNoTitle) {
        f.size.height = f.size.width;
        [self setFrame:f];
    }
    
    NSRect dRect = f;
    dRect.origin = b.origin; // Strange but true...
        
    NSData * data = [self dataWithPDFInsideRect:dRect];
    [data writeToFile:path options:0 error:nil];
    
    [self setFrame:frameRect];

    pdf = NO;
    
}


#pragma mark - Event handling

- (void)mouseDown:(NSEvent *)theEvent {
    
    _mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    if(!dragging) {
        dragging = YES;
        dragFromPoint = _mousePoint;
    }
    
    if([theEvent clickCount] > 1 || [theEvent modifierFlags]&NSEventModifierFlagShift) {
        
        _cellDebug = ([theEvent modifierFlags]&NSEventModifierFlagOption);

        _mousePoint = [theStructuredWafer convertPoint:_mousePoint toReferenceFromRotated:_irot];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewCellInfoNotification object:nil];
    }

}

- (void) mouseDragged:(NSEvent *)theEvent {
    
    if(!dragging || _magnification == 1.) return;
    
    [[NSCursor closedHandCursor] set];
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.01) return;
    tstart = tnow;
    
    NSPoint pnt = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    
    NSRect bR = self.bounds;
    bR.origin.x += dragFromPoint.x - pnt.x;
    bR.origin.y += dragFromPoint.y - pnt.y;
    [self setBounds:bR];
    //dragFromPoint = pnt;

}

- (void)mouseUp:(NSEvent *)theEvent {
    
    dragging = NO;
    [[NSCursor arrowCursor] set];
    
}


- (void)scrollWheel:(NSEvent *)theEvent {
    
    if(_magnification == 1.) return;
    
    NSRect bR = self.bounds;
    bR.origin.x -= [theEvent deltaX];
    bR.origin.y += [theEvent deltaY];
    [self setBounds:bR];

}

- (void) keyDown:(NSEvent *) theEvent {
    
    NSString *  const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    unichar const cup    = 0xf700;
    unichar const cdown  = 0xf701;
    unichar const cleft  = 0xf702;
    unichar const cright = 0xf703;
    
  //  NSUInteger modifiers = ([NSEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask);


    if(_magnification == 1.) return;
    
    NSRect bR = self.bounds;
    double delta = bR.size.width*0.002;
    
    if(code == cleft) {
        bR.origin.x -= delta;
    } else if(code == cright) {
        bR.origin.x += delta;
    } else if(code == cup) {
        bR.origin.y += delta;
    } else if(code == cdown) {
        bR.origin.y -= delta;
    }
    
    [self setBounds:bR];

}

- (void) animateHighlight:(NSTimer *) aTimer {
    
    highlightCount = (highlightCount+1)%5;
    
    noHighlight = (highlightCount == 0);
    [self setNeedsDisplay:YES];
}

- (void) killHighlight {
    
    if(highlightTimer != nil) [highlightTimer invalidate];
    highlightTimer = nil;
    
}

#pragma mark - drawRect
- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    
    theStructuredWafer.trigger = _trigger;
    
    if(!pdf || !_pdfNoBackground) [NSBezierPath fillRect:self.bounds];
    
    if(_showLayoutHexagon) [theStructuredWafer drawWaferLayoutHexagon:_irot];
    if(_showPhysicalWafer) [theStructuredWafer drawPhysicalWafer:_irot];

    int ipart = _partialType;
    if(!_partial) ipart = -1;
    if(_drawCells) [theStructuredWafer drawCellsDense:_HD ForPartial:ipart Rotated:_irot];
    if(_highlight) {
        if(highlightTimer == nil || _highlightChanged) {
            if(highlightTimer != nil) {
                [highlightTimer invalidate];
                highlightTimer = nil;
                _highlightChanged = NO;
            }
            [theStructuredWafer highlightCell:_highlightCell Rotated:_irot isPartial:_partial];
            highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(animateHighlight:) userInfo:nil repeats:YES];
            noHighlight = YES;
            highlightCount = 0;
        } else {
            if(pdf) noHighlight = YES;
            [theStructuredWafer outlineHighlightCell:noHighlight];
        }
    } else if(highlightTimer != nil) {
        [highlightTimer invalidate];
        highlightTimer = nil;
        _highlightChanged = NO;
    }

    if(_showEdgeIndex)  [theStructuredWafer drawLabelsEdgeIndexDense:_HD ForPartial:ipart Rotation:_irot];
    else if(_showGridCount) [theStructuredWafer drawLabelsGridCountDense:_HD Rotation:_irot];
    else {
        if(_showDetId) [theStructuredWafer drawLabelsUvDense:_HD ForPartial:ipart Rotated:_irot];
        if(_showHard) [theStructuredWafer drawLabelsHardDense:_HD ForPartial:ipart Rotated:_irot];
    }
    
    if(_showGrid) [theStructuredWafer drawGridDense:_HD ForPartial:ipart Rotated:_irot];
    if(_showCentre) [theStructuredWafer drawHardXyAxes:_irot];

    
    if(!pdf || !_pdfNoTitle) {
        NSRect whiteRect = self.bounds;
        whiteRect.origin.y = self.bounds.origin.y + self.bounds.size.width;
        whiteRect.size.height = self.bounds.size.height - self.bounds.size.width;
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:whiteRect];
        
        
        NSFont * font = [NSFont fontWithName:@"Helvetica" size:8./_magnification];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:_waferDescription];
        [str addAttribute:NSFontAttributeName
                    value:font
                    range:NSMakeRange(0,str.length)];
        
        double x = whiteRect.origin.x + 0.5*whiteRect.size.width - 0.5*str.size.width;
        double y = whiteRect.origin.y + 0.5*whiteRect.size.height - 0.7*str.size.height;
        NSRect bRect = NSMakeRect(x,y,str.size.width,str.size.height);
        [[NSColor blackColor] set];
        [str drawInRect:bRect];
    }

    if(_markCentroid) {
        NSPoint centr = [theStructuredWafer convertPoint:_centroid toRotatedFromReference:_irot];
        double side = [theStructuredWafer getCellSideForDense:_HD];
        NSBezierPath * centreHairs = [NSBezierPath crossHairsAt:centr withRadius:side];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:centr radius:side startAngle:0.0 endAngle:360.0];
        [[[NSColor blackColor] colorWithAlphaComponent:0.5] set];
        [circle setLineWidth:1.];
        [centreHairs setLineWidth:0.1];
        [centreHairs stroke];
        [circle stroke];
    }


    [theStructuredWafer makeGridToCellMapForDense:_HD Partial:ipart];
    
}

@end
