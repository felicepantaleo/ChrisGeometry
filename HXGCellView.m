//
//  HXGCellView.m
//  Hex
//
//  Created by Chris Seez on 02/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGCellView.h"

@implementation HXGCellView
- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    
    xmax = 0.9*110.;
    ymax = 110.;
    
    sin60 = sqrt(3)/2.;
    cos60 = 0.5;
    
    _showCellPoint = NO;
    _mirror = NO;
    mirrorTransform = [[NSAffineTransform alloc] init];
    [mirrorTransform scaleXBy:-1. yBy:1.];
    
    cellLabels = [NSMutableArray array];
    iplacement = 0;


    return self;
}

- (void) setViewFrame:(NSRect)fRect {
    frameRect = fRect;
}

- (void) setPlacementIndex: (int) ip {
    
    iplacement = ip;
    _mirror = ((ip < 6 && ip%2 == 1) || (ip > 5 && ip%2 == 0));
    
    [cellLabels removeAllObjects];
    
    for(int ju=0; ju<2*_count; ju++) {
        for(int jv=0; jv<2*_count; jv++) {
            if(jv > ju+_count-1) break;
            if(ju > jv+_count) continue;
            NSPoint pnt = [self pointAtU:ju andV:jv];
            NSString * lab = [NSString stringWithFormat:@"%02d:%02d",ju,jv];
            HXGCellLabel * c = [HXGCellLabel cellLabel:lab at:pnt];
            [cellLabels addObject:c];
        }
    }

    [self makeAxes];
    [self setNeedsDisplay:YES];
}

- (void) setWaferSide:(double) s cellCount:(int) c {
    
    waferSide = s;
    waferWidth = sqrt(3.) * waferSide;
    _count = c;
    side = waferWidth/(3.*(double) _count);
    hWidth = side * sqrt(3.) * 0.5;

    cRect = NSMakeRect(0.25*waferWidth,-1.05*waferSide,40.,20.);
    tstart = [NSDate timeIntervalSinceReferenceDate];
    [[self window] setAcceptsMouseMovedEvents:YES];

}

- (void) makeAxes {
    
    NSPoint origin = [self pointAtU:0 andV:0];
    NSPoint umax = [self pointAtU:_count andV:0];
    NSPoint vmax = [self pointAtU:0 andV:_count-1];
    umax.x += 0.16*(umax.x - origin.x);
    umax.y += 0.16*(umax.y - origin.y);
    vmax.x += 0.22*(vmax.x - origin.x);
    vmax.y += 0.22*(vmax.y - origin.y);
    
    
    uvAxes = [NSBezierPath bezierPath];
    
    [uvAxes moveToPoint:origin];
    [uvAxes lineToPoint:umax];

    [uvAxes moveToPoint:origin];
    [uvAxes lineToPoint:vmax];
    
    //---- Now the arrow heads

    umax.x += 0.01*(umax.x - origin.x);
    umax.y += 0.01*(umax.y - origin.y);
    vmax.x += 0.01*(vmax.x - origin.x);
    vmax.y += 0.01*(vmax.y - origin.y);

    uarrow = [NSBezierPath bezierPath];
    double al = 3.; // Arrow length

    double utheta = atan2(umax.y - origin.y,umax.x - origin.x);
    double alpha = utheta - 3.5*M_PI/3.;
    double beta = utheta - 2.5*M_PI/3.;
    [uarrow moveToPoint:umax];
    [uarrow lineToPoint:NSMakePoint(umax.x+al*cos(alpha),umax.y+al*sin(alpha))];
    [uarrow lineToPoint:NSMakePoint(umax.x+al*cos(beta),umax.y+al*sin(beta))];
    [uarrow closePath];

    varrow = [NSBezierPath bezierPath];
    double vtheta = atan2(vmax.y - origin.y,vmax.x - origin.x);
    alpha = vtheta - 3.5*M_PI/3.;
    beta = vtheta - 2.5*M_PI/3.;
    [varrow moveToPoint:vmax];
    [varrow lineToPoint:NSMakePoint(vmax.x+al*cos(alpha),vmax.y+al*sin(alpha))];
    [varrow lineToPoint:NSMakePoint(vmax.x+al*cos(beta),vmax.y+al*sin(beta))];
    [varrow closePath];
    
    //---- Now the label points
    umax.x -= 0.06*(umax.x - origin.x);
    umax.y -= 0.06*(umax.y - origin.y);
    vmax.x -= 0.08*(vmax.x - origin.x);
    vmax.y -= 0.08*(vmax.y - origin.y);
    
    double dl = 6.;

    double sign = 1.;
    if(iplacement > 5) sign = -1.;
    alpha = utheta - sign*M_PI*0.5;
    beta  = vtheta + sign*M_PI*0.5;
    
    uLabelPoint = NSMakePoint(umax.x+dl*cos(alpha),umax.y+dl*sin(alpha));
    vLabelPoint = NSMakePoint(vmax.x+dl*cos(beta),vmax.y+dl*sin(beta));
}

- (void) setRadii: (double *) r {

    for (int i=0; i<5; i++){
        radius[i] = r[i];
    }
}

- (void) markPoint:(NSPoint) offset {
    
    _showCellPoint = YES;
    NSRect br = [self bounds];
    debugMarker = [NSBezierPath bezierPath];
    [debugMarker moveToPoint:NSMakePoint(0.45*br.size.width,offset.y)];
    [debugMarker lineToPoint:NSMakePoint(-0.45*br.size.width,offset.y)];
    [debugMarker moveToPoint:NSMakePoint(offset.x,0.45*br.size.height)];
    [debugMarker lineToPoint:NSMakePoint(offset.x,-0.45*br.size.height)];

    [self setNeedsDisplay:YES];

}

- (BOOL) acceptsFirstResponder {
    
    return YES;
    
}

- (void) savePDF:(NSString *)path {
    
    NSData * data;
    pdf = YES;
    
    NSRect b = [self bounds];
    /*b.size.width = 2.1*waferWidth;
    b.size.height = b.size.width/0.9;
    b.origin.x = -0.5*b.size.width;
    b.origin.y = -0.5*b.size.height; */
    NSRect f = [self frame];
    double scale = b.size.height / f.size.height;
    pdftransform = [[NSAffineTransform alloc] init];
    [pdftransform translateXBy:(1.-scale)*b.origin.x yBy:(1.-scale)*b.origin.y];
    [pdftransform scaleBy:scale];
    data = [self dataWithPDFInsideRect:b];

    [data writeToFile:path options:0 error:nil];
    pdf = NO;
}

- (void) mouseMoved:(NSEvent *)theEvent {

    if(!_showCoords) return;
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.1) return;
    tstart = tnow;
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];

    [self cellDetIdAtPoint:mousePoint];
    
    [self setNeedsDisplay:YES];
}
/*
- (int *) cellDetIdAtPoint:(NSPoint) point {
    
    if(_newUv) {
        return [self newCellDetIdAtPoint:point];
    }
    // -------------------------------
    // point is the x, y coordinates of a point relative to the wafer centre
    //
    // Uses the constants:
    // count - characteristic number of the wafer (8 for large cells, 12 for
    // small cells)
    // waferWidth - flat-to-flat wafer tessalation hexagon size
    // waferSide - side of tessalation hexagon = waferWidth/sqrt(3)
    // hWidth - half the flat-to-flat cell hexagon size
    // -----------------------------------
    
    if(wafer && ![wafer containsPoint:point]) {
        idetId[2] = 0;
        return idetId;
    }
    
    idetId[2] = 1;
    double x = point.x + 0.5*waferWidth;
    double y = point.y + waferSide;
    
    double u = y;
    double v = x*sin60 + y*cos60;
    double w = x*sin60 - y*cos60 + 50.*hWidth; // avoid casting integer on a negative number
    
    iu = (int) (u/hWidth) + 1 - _count;
    iv = (int) (v/hWidth) - _count/2;
    iw = (int) (w/hWidth) - 50 + _count/2;
        
    idetId[1] = (iv + iw)/3;         // Sunanda's v index
    idetId[0] = (iu + idetId[1])/2;  // Sunanda's u index
    
    // Now deal with the special large cells
    if(idetId[1]-(_count-1) > idetId[0]) {
        if(iv%2 == 1) idetId[0] += 1;
        else idetId[1] -= 1;
    } else if(idetId[0] > 2*_count-1) {
        idetId[0] -= 1;
        if(iw%2 == 0) idetId[1] -= 1;
    }
    
    return idetId;
}
*/
/*- (int *) cellDetIdAtPoint:(NSPoint) point {
 // -------------------------------
 // point is the x, y coordinates of a point relative to the wafer centre
     
 // Uses the constants:
 // count - characteristic number of the wafer (8 for large cells, 12 for small cells)
 // waferWidth - flat-to-flat wafer tessalation hexagon size
 // waferSide - side of tessalation hexagon = waferWidth/sqrt(3)
 // hWidth - half the flat-to-flat cell hexagon size
 //----------------------------------- //
    
    if(wafer && ![wafer containsPoint:point]) {
        idetId[2] = 0;
        return idetId;
    }
    
    //---- Reverse transform if placement index ≠ 0
   
    int ip = iplacement;
    if(ip != 0) {
        if(ip > 5) point.x *= -1.;
        double rot = (double)(ip%6);
        double theta = - rot * (M_PI/3.);
        
        double xprime = point.x*cos(theta) - point.y*sin(theta);
        double yprime = point.x*sin(theta) + point.y*cos(theta);
        
        point.x = xprime;
        point.y = yprime;
    }
    
    idetId[2] = 1;
    double x = point.x + 0.5*waferWidth;
    double y = point.y + waferSide;
    
    double u = x*sin60 + y*cos60 + 100.*hWidth;  // avoid casting integer on a negative number
    double v = -x*sin60 + y*cos60 + 100.*hWidth;
    double w = y + 100.*hWidth;
    
    iu = (int) (u/hWidth) - _count - 96;
    iv = (int) (v/hWidth) - _count/2 - 75;
    iw = (int) (w/hWidth) + _count/2 - 104;
    
    idetId[0] = (iu + (iv + iw)/3)/2 - 5; // Sunanda's u index
    idetId[1] = (iv + iw)/3 + _count/2 - 7; // Sunanda's v index
    
    // Now deal with the special large cells (9/2/22 Needs more work!!)
    if(idetId[0] > _count*2 - 1) {
        idetId[0] -= 1;
        if(iv%2 == 1) idetId[1] -= 1;
    } else if(idetId[1] < 0) {
        idetId[1] = 0;
        if(iu%2 == 0) idetId[0] += 1;
    }
    
    cellCentre = [self pointAtU:idetId[0] andV:idetId[1]];

    return idetId;
}
*/
- (int *) cellDetIdAtPoint:(NSPoint) point {
    /* -------------------------------
     Method calculates cell u,v detId indices from the struct "point", which
     contains the x, y coordinates of a point relative to the wafer centre
     
     Uses the constants:
     _count - characteristic number of the wafer (8 for LD wafers, 12 for HD wafers)
     side   - side of cell = cell width/sqrt(3)
     hWidth - half cell width
     ----------------------------------- */
    
    if(wafer && ![wafer containsPoint:point]) { //--- Check that point is in wafer
        idetId[2] = 0;
        return idetId;
    }
    idetId[2] = 1;

    //---- Reverse transform to placement=0, if placement index ≠ 0
    int ip = iplacement;
    if(ip != 0) {
        if(ip > 5) point.x *= -1.;
        double rot = (double)(ip%6);
        double theta = - rot * (M_PI/3.);
        
        double xprime = point.x*cos(theta) - point.y*sin(theta);
        double yprime = point.x*sin(theta) + point.y*cos(theta);
        
        point.x = xprime;
        point.y = yprime;
    }
    
    //--- Shift x,y axes origin to centre of cell (0,0)
    double x = point.x + 0.5*side;
    double y = point.y + (double)(2*_count-1)*hWidth;
    
    //--- Calculate coordinates in u,v,w system
    double u =  x*sin60 + y*cos60 + 100.*hWidth; // Add 100.*hWidth to avoid
    double v = -x*sin60 + y*cos60 + 100.*hWidth; // casting integer on a negative number
    double w =  y + 100.*hWidth;                 // in the subsequent step

    //---- Set it so that iu and iv run from 0 to 4*N-1 (counting cell half widths)
    //     and iw runs from -N to +3*N-1
    iu = (int) (u/hWidth) - 100 + _count + 1;
    iv = (int) (v/hWidth) - 100 + _count + 1;
    iw = (int) (w/hWidth) - 100 - _count + 1;
    
    idetId[0] = (iu + iw)/3; // Sunanda's u index
    idetId[1] = (iv + iw)/3; // Sunanda's v index
    
    // Now deal with the large cells (which include more area than the standard hex cell)
    if(iv+iw < 0) {                             // bottom-right cells
        idetId[0] = (iu+iw+1)/3;
    } else if(idetId[1]-idetId[0] > _count-1) { // left-side cells
        idetId[0] = (iu+iw+1)/3;
        idetId[1] = (iv+iw-1)/3;
    } else if(idetId[0] > 2*_count-1) {         // top-right cells
        idetId[0] = 2*_count-1;
        idetId[1] = (iv+iw-1)/3;
    }
        
    return idetId;
}

- (NSPoint) pointAtU:(int) u andV:(int) v {
    
    double NN = (double) _count;
    double RR = waferWidth/(3.*NN);
    double rr = RR*sin(M_PI/3.);
    
    double xprime = (1.5 * (double)(u-v) - 0.5) * RR;
    double yprime = ((double)(u+v) - 2.*NN + 1.) * rr;
    
    double rot = (double)(iplacement%6);
    double theta = rot * (M_PI/3.);
    NSPoint pnt;
    pnt.x = xprime*cos(theta) - yprime*sin(theta);
    pnt.y = xprime*sin(theta) + yprime*cos(theta);
    if(iplacement > 5) pnt.x = -pnt.x;
    
    return pnt;
}

- (void) drawCells:(NSArray *) g forWafer:(NSBezierPath *) q{

    [self setFrame:frameRect];
    
    double xmx = xmax;
    double ymx = ymax;
    if(_inclusionRadii) {
        xmx -= _cside;
        ymx -= _cside;
        iplacement = 2;
    }
    
    NSRect bounds = NSMakeRect(-xmax,-0.97*ymx,xmx+xmax,ymx+ymax);
    [self setBounds:bounds];
    wafer = q;
    gridCells = g;
    
    centre = [NSBezierPath bezierPath];
    [centre moveToPoint:NSMakePoint(5.,0.)];
    [centre lineToPoint:NSMakePoint(-5.,0.)];
    [centre moveToPoint:NSMakePoint(0.,5.)];
    [centre lineToPoint:NSMakePoint(0.,-5.)];

    //[centre appendBezierPathWithArcWithCenter:NSZeroPoint radius:1. startAngle:0.0 endAngle:360.0];

    [self setPlacementIndex:iplacement];

    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];

    if(pdf) [pdftransform concat];
    else {
        [[NSColor whiteColor] set];
        NSRectFill([self bounds]);
    }
        
    if(_inclusionRadii) {
        [self illustrateInclusionRadii];
        iplacement = 2;
        return;
    }
    
    NSColor * triggerColor[3];
    triggerColor[0] = [NSColor sageGreen];
    triggerColor[1] = [NSColor orchidPink];
    triggerColor[2] = [NSColor paleBlue];
    
    //---------------------------------------------------
    if(_mirror) [mirrorTransform concat];
    
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        if(c.whole) {
            if(_colorCells == 2) [triggerColor[c.itc] set];
            else if(_colorCells == 1)[c.cellColor set];
            else [[NSColor fadedBlue] set];
            [c.wholeCell fill];
            [[NSColor blackColor] set];
            [c.wholeCell setLineWidth:0.3];
            [c.wholeCell stroke];
        } else if(c.inside) {
            if(_colorCells == 2) [triggerColor[c.itc] set];
            else if(_colorCells == 1) {
                if(_hyperBright && !c.corner) {
                    if(c.small) [[NSColor redColor] set];
                    else [[NSColor greenColor] set];
                } else [c.cellColor set];
            } else [[NSColor fadedBlue] set];
            [c.edgeCell fill];
            [[NSColor blackColor] set];
            [c.edgeCell setLineWidth:0.3];
            [c.edgeCell stroke];
        }
    }
   
    if(_showGrid) {
        for (int i=0;i<gridCells.count;i++) {
            HXGCell * c = [gridCells objectAtIndex:i];
            [[NSColor grayColor] set];
            [c.gridCell setLineWidth:0.1];
            [c.gridCell stroke];
        }
    }

    if(_showOutline) {
        [[NSColor blueColor] set];
        [wafer setLineWidth:0.5];
        [wafer stroke];
        [[NSColor blueColor] set];
        [centre setLineWidth:0.5];
        [centre stroke];
    }
    
    if(_mirror) {
        [mirrorTransform invert];
        [mirrorTransform concat];
        [mirrorTransform invert];
    }
    //------------------------------------------
    
    if(_numberCells) {
        for (int i = 0; i<cellLabels.count; i++)
        {
            HXGCellLabel * c = [cellLabels objectAtIndex:i];
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:c.label];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:4.0 - _count*0.15]
                            range:NSMakeRange(0,str.length)];
                [str drawAtPoint:NSMakePoint(c.point.x - 0.5*str.size.width,c.point.y-0.4*str.size.height)];
        }
    }

    if(_showAxes) {
        [[NSColor blackColor] set];
        [uvAxes setLineWidth:0.4];
        [uvAxes stroke];
        [uarrow fill];
        [varrow fill];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"u"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:10.]
                    range:NSMakeRange(0,str.length)];
        NSPoint ul = NSMakePoint(uLabelPoint.x-0.5*str.size.width,uLabelPoint.y-0.5*str.size.height);
        [str drawAtPoint:ul];
        str = [[NSMutableAttributedString alloc] initWithString:@"v"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:10.]
                    range:NSMakeRange(0,str.length)];
        NSPoint vl = NSMakePoint(vLabelPoint.x-0.5*str.size.width,vLabelPoint.y-0.5*str.size.height);
        [str drawAtPoint:vl];
    }
    
    //---- placement index (if pdf)
    if(pdf) {
        NSString * plstr = [NSString stringWithFormat:@"Placement index = %d",iplacement];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:plstr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:8.]
                    range:NSMakeRange(0,str.length)];
        [str drawAtPoint:NSMakePoint(-0.5*str.size.width,waferSide+0.6*str.size.height)];

    }
    
    if(_triggerId) {
        for (int i = 0; i<gridCells.count; i++)
        {
            HXGCell * c = [gridCells objectAtIndex:i];
            if(c.inside && c.keycell) {
                NSString * xystr = [NSString stringWithFormat:@"%02d:%02d",c.iut,c.ivt];
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:6.0 - _count*0.15]
                            range:NSMakeRange(0,str.length)];
                NSRect tRect = NSMakeRect(c.centre.x - 0.5*str.size.width + 8.,c.centre.y-0.25*str.size.height,str.size.width*1.1,str.size.height*0.9);
                [[NSColor whiteColor] set];
                [NSBezierPath fillRect:tRect];
                [NSBezierPath setDefaultLineWidth:0.15];
                [[NSColor blackColor] set];
                [NSBezierPath strokeRect:tRect];
                tRect.origin.x += 0.05*str.size.width;
                tRect.origin.y += 0.1*str.size.height;
                [str drawInRect:tRect];
                //[str drawAtPoint:NSMakePoint(c.centre.x - 0.5*str.size.width + 7.,c.centre.y-0.4*str.size.height)];
            }
        }
    }
    
    if(_showCellPoint) {
        [[NSColor blueColor] set];
        [debugMarker setLineWidth:0.5];
        [debugMarker stroke];
    }
    
    BOOL sunandaCentre = NO;
    if (_showCoords && !pdf) {
        NSString * xystr = [NSString stringWithFormat:@"x = %.1f, y =%.1f",mousePoint.x,mousePoint.y];
        if(idetId[2]) {
            xystr = [xystr stringByAppendingFormat:@"\nidetId: %d, %d\niu,iv,iw: %d,%d,%d",idetId[0],idetId[1],iu,iv,iw];
        } else xystr = [xystr stringByAppendingString:@"\niu,iv,iw:\nidetId:"];
        if(sunandaCentre) xystr = [xystr stringByAppendingFormat:@"\nSctre: %.2f,%.2f",cellCentre.x,cellCentre.y];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:3.5]
                    range:NSMakeRange(0,str.length)];
        
        cRect.size.width = 45.; //str.size.width*1.4;
        cRect.size.height = str.size.height*1.2;
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:cRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:0.3];
        [NSBezierPath strokeRect:cRect];
        NSRect dRect = cRect;
        dRect.origin.x += 0.05 * dRect.size.width;
        dRect.origin.y += 0.1 * dRect.size.height;
        dRect.size.width *= 0.8;
        dRect.size.height = str.size.height;
        [str drawInRect:dRect];
    }
    
    if(_showDimensions) {
        NSString * xystr = [NSString stringWithFormat:@"Cell side = %.2fmm\nCell flat-to-flat = %.2fmm",side,2.*hWidth];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:4.5]
                    range:NSMakeRange(0,str.length)];
        
        [[NSColor blackColor] set];
        NSRect dRect;
        dRect.origin.x = self.bounds.origin.x + 15.;
        dRect.origin.y = self.bounds.origin.y + 5.;
        dRect.size.width = str.size.width*1.4;
        dRect.size.height = str.size.height;
        [str drawInRect:dRect];
    }

    if(pdf) {
        [pdftransform invert];
        [pdftransform concat];
    }

}

- (void) illustrateInclusionRadii {
        
    NSColor * irCol[7];
    irCol[0] = [NSColor whiteColor];
    irCol[1] = [NSColor peachOrange];
    irCol[2] = [NSColor sageGreen];
    irCol[3] = [NSColor pastelBlue];
    irCol[4] = [NSColor orchidPink];
    irCol[5] = [NSColor fadedBlue];
    irCol[6] = [NSColor greyGreen];

    
    NSPoint centrePoint;
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        if(c.irColor > 0) {
            if(c.irColor == 1) {
                centrePoint=c.centre;
            }
            [irCol[c.irColor] set];
            [c.wholeCell fill];
        }
        [[NSColor blackColor] set];
        [c.gridCell setLineWidth:0.2];
        [c.gridCell stroke];
        NSBezierPath * spot = [NSBezierPath bezierPath];
        [spot appendBezierPathWithArcWithCenter:c.centre radius:1. startAngle:0.0 endAngle:360.0];
        [spot fill];
    }
    
    [[NSColor blackColor] set];
    [NSBezierPath setDefaultLineWidth:0.4];

    if(_showCircles) {
        int ncell[5] = {7,13,19,31,37};
        for (int i=0; i<5; i++) {
            NSBezierPath * circ = [NSBezierPath bezierPath];
            [circ appendBezierPathWithArcWithCenter:centrePoint radius:radius[i] startAngle:0.0 endAngle:360.0];
            [circ stroke];
            NSString * str = [NSString stringWithFormat:@"%d",ncell[i]];
            NSMutableAttributedString * astr = [[NSMutableAttributedString alloc] initWithString:str];
            [astr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:6]
                        range:NSMakeRange(0,str.length)];
            NSRect cRect;
            cRect.size.width = [astr size].width;
            cRect.size.height = [astr size].height;
            cRect.origin.x = centrePoint.x - 0.5*cRect.size.width;
            cRect.origin.y = centrePoint.y + radius[i] - 0.5*cRect.size.height;
            [[NSColor whiteColor] set];
            [NSBezierPath fillRect:cRect];
            [[NSColor blackColor] set];
            [NSBezierPath setDefaultLineWidth:0.4];
            //[NSBezierPath strokeRect:cRect];
            [astr drawAtPoint:NSMakePoint(cRect.origin.x,cRect.origin.y)];
        }
    }

    if (_showCoords && !pdf) {
        double scaleLD = 0.5;
        double scaleHD = 1./3.;
        double x = (mousePoint.x - centrePoint.x);
        double y = (mousePoint.y - centrePoint.y);
        double rLD = scaleLD*sqrt(x*x + y*y);
        double rHD = scaleHD*sqrt(x*x + y*y);
        NSString * xystr = [NSString stringWithFormat:@"LD radius = %.1f mm\nHD radius = %.1f mm",rLD,rHD];
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:xystr];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:3.5]
                    range:NSMakeRange(0,str.length)];
        
        cRect.origin.x = self.bounds.origin.x + 15.;
        cRect.origin.y = self.bounds.origin.y + 5.;
        cRect.size.width = str.size.width*1.25;
        cRect.size.height = str.size.height*1.2;
        [[NSColor whiteColor] set];
        [NSBezierPath fillRect:cRect];
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:0.3];
        [NSBezierPath strokeRect:cRect];
        NSRect dRect = cRect;
        dRect.origin.x += 0.05 * dRect.size.width;
        dRect.origin.y += 0.1 * dRect.size.height;
        dRect.size.width *= 0.8;
        dRect.size.height = str.size.height;
        [str drawInRect:dRect];
    }

}
@end
