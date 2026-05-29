//
//  HXGInspectorView.m
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGInspectorView.h"

@implementation HXGInspectorView

- (NSSize) setUpWaferInspectorDisplay {

    if(!thePreferences) thePreferences = [HXGPreferenceControl sharedPreferences];
    
    NSArray * hexcols = [thePreferences getColors];
    NSColor * col0 = [hexcols objectAtIndex:0];
    NSColor * col1 = [hexcols objectAtIndex:1];
    NSColor * col2 = [hexcols objectAtIndex:2];
    NSColor * col3 = [hexcols objectAtIndex:3];
    
    waferThicknessColors = [NSArray arrayWithObjects:col0,col1,col2,col3,nil];
    
    if(_rotated) {
        thirtyTransform = [[NSAffineTransform alloc] init];
        [thirtyTransform rotateByDegrees:30.];
    }
        
    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    NSPoint retVec = NSZeroPoint;
    if(_retractedValues && !_alreadyRetracted) retVec = [theMapFiles getRetVecForCEtype:_CEtype andCassette:_wafer.cassette];

    NSString * typeCode[6] = {@"F",@"T",@"B",@"L",@"R",@"5"};
    NSString * density = @"HD";
    if(_wafer.LD) density = @"LD";
    int thick[4] = {120,200,200,300};
    NSString * name[7] = {@"Full",@"Top",@"Bottom",@"Left",@"Right",@"Five",@"Three"};
    NSString * refCode = @"ML-";
    if(!_wafer.LD) refCode = @"MH-";
    if(_wafer.type > 5) refCode = @"Obsolete";
    else refCode = [refCode stringByAppendingString:typeCode[_wafer.type]];

    _tString = [NSString stringWithFormat:@"%@ %d = %@  (%@)  %dµm\n",density,_wafer.type,name[_wafer.type],refCode,thick[_wafer.thickflag]];
    _tString = [_tString stringByAppendingFormat:@"Layer %d, Cassette %d, ",_nlayer+1,_wafer.cassette];
    
    _tString = [_tString stringByAppendingFormat:@"DetId = (%d, %d)\n",_wafer.detId[0],_wafer.detId[1]];

    if(_retractedValues || _alreadyRetracted) _tString = [_tString stringByAppendingString:@"\nRetracted positions\n"];
    _tString = [_tString stringByAppendingFormat:@"Centre: (%.3f, %.3f)",_wafer.xc+retVec.x,_wafer.yc+retVec.y];
    //NSLog(@"wafer (xc,yc) = (%.3f, %.3f)",_wafer.xc,_wafer.yc);
    //NSLog(@"retVec (%.3f, %.3f)",retVec.x,+retVec.y);
    
    
    if(_rotated) {
        double xx = _wafer.xc;
        double yy = _wafer.yc;
        if(_retractedValues) {
            xx += retVec.x;
            yy += retVec.y;
        }
        double xr = xx*cos(M_PI/6.) - yy*sin(M_PI/6.);
        double yr = xx*sin(M_PI/6.) + yy*cos(M_PI/6.);
        _tString = [_tString stringByAppendingFormat:@"\nRotated centre: (%.2f, %.2f)",xr,yr];

    }
    NSString * cornerString = @"\nCorners:";
    if(_rotatedValues) cornerString = @"\nRotated corners:";
    _tString = [_tString stringByAppendingString:cornerString];
    for(int i=0;i<6;i++) {
        double x = _wafer.corner[i].x;
        double y = _wafer.corner[i].y;
        if(_retractedValues) {
            x += retVec.x;
            y += retVec.y;
        }
        double r = sqrt(x*x + y*y);
        if(_rotatedValues) {
            double xx = x;
            double yy = y;
            x = xx*cos(M_PI/6.) - yy*sin(M_PI/6.);
            y = xx*sin(M_PI/6.) + yy*cos(M_PI/6.);
        }
        _tString = [_tString stringByAppendingFormat:@"\n%4d: r = %.1f (%.2f, %.2f)",i,r,x,y];
    }
    
    double x = _wafer.maxcorner.x;
    double y = _wafer.maxcorner.y;
    if(_retractedValues) {
        x += retVec.x;
        y += retVec.y;
    }
    if(_rotatedValues) {
        double xx = x;
        double yy = y;
        x = xx*cos(M_PI/6.) - yy*sin(M_PI/6.);
        y = xx*sin(M_PI/6.) + yy*cos(M_PI/6.);
    }

    double r = sqrt(x*x + y*y);
    if(r > 10.) { // _wafer.maxcorner not setup if we are show active only
        _tString = [_tString stringByAppendingFormat:@"\n\nLargest radius corner r = %.2f\n(x,y) = (%.2f, %.2f)",r,x,y];
        if(_rotatedValues) _tString = [_tString stringByAppendingString:@" (rotated)"];
    }
    
    specString = [[NSMutableAttributedString alloc] initWithString:_tString];
    [specString addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:14.]
                range:NSMakeRange(0,specString.length)];

    side = 48.;
    margin = 24.;
    buttonSpace = 24.;
    if(_rotated && _rotateRotated) buttonSpace += 15.;
    double width = specString.size.width + 2.*margin;
    double height = specString.size.height + 2.*side + 3.*margin + buttonSpace;
    
    NSSize viewSize = NSMakeSize(width,height);
    
    x = 0.5*width;
    y = height - (side+margin);
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
    //w.v17 = _wafer.v17;
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

    if(viewSize.width < 260.) viewSize.width = 260.;

    return viewSize;
}

- (NSSize) setUpTileInspectorDisplay {
    
    tileColor = [NSColor fadedBlue];
    
    if(!theMapFiles) theMapFiles = [HXGLayerMapFiles sharedLayerMapFiles];
    double * tileSpec = [theMapFiles tileSpecFor:_iRing];
    
    _tString = [NSString stringWithFormat:@"Layer %d, tile ring = %d, iphi = %d\n",_nlayer+1,_iRing,_iphi];
    _tString = [_tString stringByAppendingFormat:@"h = %.2f; b = %.2f\na = %.2f",tileSpec[2],tileSpec[2],tileSpec[3]];
    
    if(_beyondV17) {
        _tString = [_tString stringByAppendingFormat:@"\n\nInner radius = %.1f (%.1f retracted)\nOuter radius = %.1f (%.1f retracted)",tileSpec[0],tileSpec[0]+_retract,tileSpec[1],tileSpec[1]+_retract];
    } else {
        _tString = [_tString stringByAppendingFormat:@"\n\nInner radius = %.1f\nOuter radius = %.1f",tileSpec[0],tileSpec[1]];
    }

    specString = [[NSMutableAttributedString alloc] initWithString:_tString];
    [specString addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:14.]
                range:NSMakeRange(0,specString.length)];

    side = 60.;
    margin = 24.;
    buttonSpace = 24.;
    double off = 12.;
    
    double width = specString.size.width + 2.*margin;
    double height = specString.size.height + 2.*side + 5.*margin + buttonSpace;

    if(width < 240.) width = 240.;

    NSSize viewSize = NSMakeSize(width,height);

    double x = 0.5*width;
    double y = height - (side+1.5*margin);

    double ang = 2.*M_PI*((double)_iphi+0.5)/(double)_ntiles - 0.5*M_PI;
    tileRot = [NSAffineTransform transform];
    [tileRot translateXBy:x yBy:y];
    [tileRot rotateByRadians:ang];
    [tileRot translateXBy:-x yBy:-y];
    inverseTileRot = [NSAffineTransform transform];
    inverseTileRot = [inverseTileRot initWithTransform:tileRot];
    [inverseTileRot invert];
    
    double nRotDir = -0.5;
    if(ang > M_PI || ang < 0.) nRotDir = 0.5;
    ninetyRot = [NSAffineTransform transform];
    [ninetyRot translateXBy:x yBy:y];
    [ninetyRot rotateByRadians:nRotDir*M_PI];
    [ninetyRot translateXBy:-x yBy:-y];
    inverseNinetyRot = [NSAffineTransform transform];
    inverseNinetyRot = [inverseNinetyRot initWithTransform:ninetyRot];
    [inverseNinetyRot invert];
    
    double flipAng = 0.;
    if(ang > 0.5*M_PI) flipAng = M_PI;
    aFlip = [NSAffineTransform transform];
    [aFlip translateXBy:x yBy:y-side-off];
    [aFlip rotateByRadians:flipAng];
    [aFlip translateXBy:-x yBy:-y+side+off];
    inverseaFlip = [NSAffineTransform transform];
    inverseaFlip = [inverseaFlip initWithTransform:aFlip];
    [inverseaFlip invert];
    
    bFlip = [NSAffineTransform transform];
    [bFlip translateXBy:x yBy:y+side+off];
    [bFlip rotateByRadians:flipAng];
    [bFlip translateXBy:-x yBy:-y-side-off];
    inversebFlip = [NSAffineTransform transform];
    inversebFlip = [inversebFlip initWithTransform:bFlip];
    [inversebFlip invert];

    double rhomb = 0.95*side;
    
    bezier = [NSBezierPath bezierPath];
    [bezier moveToPoint:NSMakePoint(x-side,y+side)];
    [bezier lineToPoint:NSMakePoint(x+side,y+side)];
    [bezier lineToPoint:NSMakePoint(x+rhomb,y-side)];
    [bezier lineToPoint:NSMakePoint(x-rhomb,y-side)];
    [bezier closePath];
    
    double sfrac = 0.2*side;
    double head = 5.;
    
    arrowBezier[0] = [NSBezierPath arrowFrom:NSMakePoint(x-sfrac,y+side+off) To:NSMakePoint(x-side,y+side+off) headSize:head];
    
    arrowBezier[1] = [NSBezierPath arrowFrom:NSMakePoint(x+sfrac,y+side+off) To:NSMakePoint(x+side,y+side+off) headSize:head];
    
    arrowBezier[2] = [NSBezierPath arrowFrom:NSMakePoint(x-sfrac,y-side-off) To:NSMakePoint(x-rhomb,y-side-off) headSize:head];

    arrowBezier[3] = [NSBezierPath arrowFrom:NSMakePoint(x+sfrac,y-side-off) To:NSMakePoint(x+rhomb,y-side-off) headSize:head];
    
    arrowBezier[4] = [NSBezierPath arrowFrom:NSMakePoint(x,y+sfrac) To:NSMakePoint(x,y+side) headSize:head];
    
    arrowBezier[5] = [NSBezierPath arrowFrom:NSMakePoint(x,y-sfrac) To:NSMakePoint(x,y-side) headSize:head];
    
    aAS = [[NSMutableAttributedString alloc] initWithString:@"a"];
    [aAS addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:@"Helvetica" size:18.]
                range:NSMakeRange(0,aAS.length)];

    bAS = [[NSMutableAttributedString alloc] initWithString:@"b"];
    [bAS addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:@"Helvetica" size:18.]
                range:NSMakeRange(0,bAS.length)];

    hAS = [[NSMutableAttributedString alloc] initWithString:@"h"];
    [hAS addAttribute:NSFontAttributeName
                value:[NSFont fontWithName:@"Helvetica" size:18.]
                range:NSMakeRange(0,hAS.length)];
    
    NSSize siz = aAS.size;
    siz.width *= 0.5;
    siz.height *= 0.5;
    aBox = NSMakeRect(x-siz.width,y-side-off-siz.height,aAS.size.width,aAS.size.height);
    
    siz = bAS.size;
    siz.width *= 0.5;
    siz.height *= 0.5;
    bBox = NSMakeRect(x-siz.width,y+side+off-siz.height,bAS.size.width,bAS.size.height);

    siz = hAS.size;
    siz.width *= 0.5;
    siz.height *= 0.5;
    hBox = NSMakeRect(x-siz.width,y-siz.height,hAS.size.width,hAS.size.height);

    return viewSize;
}

- (void) savePDF:(NSString *) path {
    
    // pdf = YES;

    NSRect b = [self bounds];
    NSRect f = [self frame];

    NSRect dRect = f;
    dRect.origin = b.origin; // Strange but true...
    
    
    NSData * data = [self dataWithPDFInsideRect:dRect];
    [data writeToFile:path options:0 error:nil];
    // pdf = NO;
    
}

#pragma - mark drawRect

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
   
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];

    if(_isWafer) {                                              // For the wafer
        if(_rotated && _rotateRotated) [thirtyTransform concat];
        
        NSColor * col = waferThicknessColors[_wafer.thickflag];
        [col set];
        
        [bezier fill];
        
        [[NSColor redColor] set];
        [zeroMarkBezier fill];
        [[NSColor blackColor] set];
        [zeroMarkBezier setLineWidth:1.];
        [zeroMarkBezier stroke];
        if(_wafer.whole) {
            [[NSColor coolGrey] set];
            [barBezier fill];
        }
        
        [bezier setLineWidth:1.];
        [bezier stroke];
        
        [waferBezier setLineWidth:0.5];
        [waferBezier stroke];
        
        //---- Number the points
        
        for(int i=0; i<6; i++) {
            int num = i;
            if(_wafer.seenFromBack) num = (6-i)%6;
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
        
    } else {
        [tileRot concat];
        
        [tileColor set];
        [bezier fill];
        [[NSColor blackColor] set];
        [bezier setLineWidth:1.];
        [bezier stroke];
        
        for(int i=0; i<6; i++) {
            [[NSColor blackColor] set];
            [arrowBezier[i] setLineWidth:2.];
            [arrowBezier[i] stroke];
            [arrowBezier[i] fill];
        }
        
        [aFlip concat];
        [aAS drawInRect:aBox];
        [inverseaFlip concat];
        
        [bFlip concat];
        [bAS drawInRect:bBox];
        [inversebFlip concat];

        [ninetyRot concat];
        [hAS drawInRect:hBox];
        [inverseNinetyRot concat];


        [inverseTileRot concat];
    }

    [specString drawAtPoint:NSMakePoint(margin,margin+buttonSpace)];



}

@end
