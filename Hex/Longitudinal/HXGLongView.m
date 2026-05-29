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

- (id) initWithFrame:(NSRect)fRect {
    
    self = [super initWithFrame:fRect];
    
    vRect = fRect;
    frameRect = fRect;
    
    thePreferences = [HXGPreferenceControl sharedPreferences];
    
    colorOption[0] = thePreferences.zoneColor1;
    colorOption[1] = thePreferences.zoneColor2;
    colorOption[2] = thePreferences.zoneColor3;
    colorOption[3] = thePreferences.zoneColor4;
    colorOption[4] = thePreferences.zoneColor5;
    
    _scrollmag = 1.0;

    return self;
}

- (void) setLongViewFrame:(NSRect)fRect {
    
    frameRect = fRect;
    
    if(_scrolling) {
        [_scrollView reflectScrolledClipView:_scrollView.contentView];
        [_scrollView setDrawsBackground:NO];
    }

    
    [self setViewBounds];

    [self setNeedsDisplay:YES];

}
- (void) loadDiagram {
    
    BOOL pdfType = NO;
    
    NSString *  fileType = @"png";
    if(pdfType) fileType = @"pdf";
    
    NSString * imageFile = [[NSBundle mainBundle]
                            pathForResource:_fileName ofType:fileType];
    
    if(pdfType) { // Haven't found a way to get something good...
        NSData * pdfData = [NSData dataWithContentsOfFile:imageFile];
        pdfRep = [NSPDFImageRep imageRepWithData:pdfData];
        edmsImage = [[NSImage alloc] init];
        [edmsImage addRepresentation:pdfRep];
    } else edmsImage = [[NSImage alloc] initWithContentsOfFile:imageFile];
    
    
    
    //---- Set up the coordinate system
    [self setViewBounds];
    _showcoords = YES;
    
}

- (void) setViewBounds {
   
    self.frame = frameRect;

    if(_calibrationMode) {
        [self setBounds:vRect];
    } else {
        double w = self.frame.size.width*_scale/_scrollmag;
        double h = self.frame.size.height*_scale/_scrollmag;
        NSRect bnew = NSMakeRect(_zLow,_rLow,w,h);
        [self setBounds:bnew];
    }
}

- (void) centreLongViewAt:(NSPoint) centre {

    if(!_scrolling) return;
    
    NSRect ff = self.frame;
    NSRect vis = _scrollView.documentVisibleRect;
    NSPoint newcentre = NSMakePoint(vis.origin.x+vis.size.width*0.5,vis.origin.y+vis.size.height*0.5);
    double dx = (newcentre.x - centre.x)*self.frame.size.width/self.bounds.size.width;
    double dy = (newcentre.y - centre.y)*self.frame.size.height/self.bounds.size.height;
    ff.origin.x += dx;
    ff.origin.y += dy;
    frameRect = ff;
    self.frame = frameRect;
    [_scrollView reflectScrolledClipView:_scrollView.contentView];
    [_scrollView setDrawsBackground:NO];
    //[self drawHexGrid];

}

- (void) setZone: (int) izone colorTo: (int) icol {
    
    iZoneCol[izone] = icol;
    
}

- (void) setColorFor:(int) iCol To:(NSColor *) col {
    
    colorOption[iCol] = col;
    [self setNeedsDisplay:YES];

    
}

- (NSColor *) getColor: (int) icol {
    
    return colorOption[icol];
}

- (void)mouseDown:(NSEvent *)theEvent {

    NSPoint mousePoint;
    BOOL newcrosshairs = NO;
    
    if([theEvent clickCount] > 1) {
        theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp];
        newcrosshairs = YES;
    }   else if([theEvent modifierFlags]&NSEventModifierFlagShift) newcrosshairs = YES;
    if(newcrosshairs) {
        NSPoint mpoint = [theEvent locationInWindow];
        
        mpoint = [self convertPoint:mpoint fromView:nil];

        _crossHairs = mpoint;
        _showcoords = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewCrossHairsNotification object:self];
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(!_showcoords) return;
    BOOL tracking = YES;
    NSTimeInterval tstart = [NSDate timeIntervalSinceReferenceDate];

    [NSCursor hide];

    while (tracking) {

        theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp |
                    NSEventMaskLeftMouseDragged];
        mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
/* --- Seems totally unnecessary - and it degrades performance
        double r2 = ((mousePoint.x -_crossHairs.x)*(mousePoint.x -_crossHairs.x) + (mousePoint.y -_crossHairs.y)*(mousePoint.y -_crossHairs.y));
        BOOL isInside = r2 < 25000.;
        
        if(!isInside) {
            [NSCursor unhide];
            return;
        }
*/
        switch ([theEvent type]) {

            case NSEventTypeLeftMouseDragged:
                _crossHairs = mousePoint;
                NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
                if(tnow - tstart > 0.1) {
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

- (NSString *) stringForWindowToViewOf:(NSPoint) pnt {
    
    NSString * resultString = @"Convert from window to view\n";
    NSPoint vpnt = [self convertPoint:pnt toView:nil];
    resultString = [resultString stringByAppendingFormat:@"(%.1f,%.1f) -> (%.1f,%.1f)",pnt.x,pnt.y,vpnt.x,vpnt.y];
    
    resultString = [resultString stringByAppendingString:@"\nBackcheck:\n"];
    NSPoint tpnt = [self convertPoint:vpnt fromView:nil];
    resultString = [resultString stringByAppendingFormat:@"(%.1f,%.1f) -> (%.1f,%.1f)",vpnt.x,vpnt.y,tpnt.x,tpnt.y];

    return resultString;
}

- (NSString *) stringForViewToWindowOf:(NSPoint) pnt {
    
    NSString * resultString = @"Convert from view to window\n";
    NSPoint wpnt = [self convertPoint:pnt fromView:nil];
    resultString = [resultString stringByAppendingFormat:@"(%.1f,%.1f) -> (%.1f,%.1f)",pnt.x,pnt.y,wpnt.x,wpnt.y];

    return resultString;
}


- (void) addEtaLine:(double) eta {
    
    if(_nlines > 4) return;
    
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

- (void) addEtaZoneFrom:(double) eta1 To:(double) eta2 Button:(int) ibut {
    
    if(_nzones > 4) return;
    
    etaZone[_nzones] = [NSBezierPath bezierPath];
    double theta1 = 2.*atan2(exp(-eta1),1.);
    double theta2 = 2.*atan2(exp(-eta2),1.);

    [etaZone[_nzones] moveToPoint:NSMakePoint(_zLow,_zLow*tan(theta1))];
    double z = _zLow + self.bounds.size.width;
    [etaZone[_nzones] lineToPoint:NSMakePoint(z,z*tan(theta1))];
    [etaZone[_nzones] lineToPoint:NSMakePoint(z,z*tan(theta2))];
    [etaZone[_nzones] lineToPoint:NSMakePoint(_zLow,_zLow*tan(theta2))];
    [etaZone[_nzones] closePath];
    iZoneButton[_nzones] = ibut;


    _nzones++;
}


- (void) savePDF:(NSString *)path {
    
    pdf = YES;

    NSRect b = [self bounds];
    NSRect f = [self frame];
    if(_scrolling) {
        [_scrollView reflectScrolledClipView:_scrollView.contentView];
        [_scrollView setDrawsBackground:NO];
        b = _scrollView.documentVisibleRect;
        f = _scrollView.contentView.frame;
    }
    if(!_calibrationMode && _scrollmag < 1.5) {
        b.origin.x +=40.; // Weird fudge... that works...
        b.origin.y +=40.; //
    }

    NSRect dRect = f;
    dRect.origin = b.origin; // Strange but true...
    
    /*
    if(!_calibrationMode && !_scrolling) {
        //dRect = b;
        //dRect.size = f.size;
    }
    
    NSLog(@"PDF: frame  %.1f %.1f %.1f %.1f",f.origin.x,f.origin.y,f.size.width,f.size.height);
    NSLog(@"PDF: bounds %.1f %.1f %.1f %.1f",b.origin.x,b.origin.y,b.size.width,b.size.height);
    NSLog(@"PDF: dRect  %.1f %.1f %.1f %.1f",dRect.origin.x,dRect.origin.y,dRect.size.width,dRect.size.height);
    */
    
    NSData * data = [self dataWithPDFInsideRect:dRect];
    [data writeToFile:path options:0 error:nil];
    pdf = NO;
    
}

- (void)drawRect:(NSRect)dirtyRect {
    
    //if(pdf) NSLog(@"PDF dirtyRect: %.0f %.0f %.0f %.0f",dirtyRect.origin.x,dirtyRect.origin.y,dirtyRect.size.width,dirtyRect.size.height);
    [super drawRect:dirtyRect];
    [self setClipsToBounds:YES];

    [edmsImage drawInRect:self.bounds];

    if(_showcoords) {
        double len = 60.;
        if(_calibrationMode) len /= _scale;
        NSBezierPath * cross = [NSBezierPath crossHairsAt:_crossHairs withRadius:len];
        NSBezierPath * circle = [NSBezierPath bezierPath];
        [circle appendBezierPathWithArcWithCenter:_crossHairs radius:len startAngle:0.0 endAngle:360.0];

        if(_calibrationMode) {
            [circle setLineWidth:1.];
            [cross setLineWidth: 0.25];
        }
        else {
            [circle setLineWidth:5.];
            [cross setLineWidth: 1.25];
        }
        [[NSColor blackColor] set];
        [cross stroke];
        [circle stroke];
        
        if(pdf) {
            NSString * xystr;
            double s = _scale/_scrollmag;
            if(_calibrationMode) {
                s = 1./_scrollmag;
                xystr = [NSString stringWithFormat:@"Cross hairs (calibration mode)\n(x, y) = (%.2f, %.2f)",_crossHairs.x,_crossHairs.y];
            } else xystr = [NSString stringWithFormat:@"Cross hairs\n(z, r) = (%.1f, %.1f)",_crossHairs.x,_crossHairs.y];
            
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
            [str addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:16.*s]
                        range:NSMakeRange(0,str.length)];
            [str addAttribute:NSForegroundColorAttributeName
                        value:[NSColor blackColor]
                        range:NSMakeRange(0,str.length)];
            NSRect cRect;
            NSRect r = self.bounds;
            if(_scrolling) r = _scrollView.documentVisibleRect;
            cRect.origin = NSMakePoint(r.origin.x + 16.*s, r.origin.y + r.size.height - str.size.height - 16.*s);
            cRect.size = NSMakeSize(str.size.width,str.size.height);
            
            NSRect bRect = cRect;
            bRect.origin.x -= 4.*s; bRect.origin.y -= 4.*s;
            bRect.size.width += 8.*s; bRect.size.height += 8.*s;
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:bRect];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:0.5*s];
            [NSBezierPath strokeRect:bRect];
            [str drawInRect:cRect];
        }

    }
    
    for(int i=0; i<_nzones; i++) {
        [colorOption[iZoneCol[iZoneButton[i]]] set];
        [etaZone[i] fill];
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
