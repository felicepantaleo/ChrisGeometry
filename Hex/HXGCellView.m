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

#ifdef DEBUG
    debugCellAreas = NO;
    if(debugCellAreas) {
        theCellAreas = [HXGCellAreas sharedCellAreas];
        [theCellAreas calculateCellAreas];
    }
#endif
    
    xmax = 0.9*110.;
    ymax = 110.;
    
    sin60 = sqrt(3)/2.;
    cos60 = 0.5;
    
    _showCellPoint = NO;
    _mirror = NO;
    mirrorTransform = [[NSAffineTransform alloc] init];
    [mirrorTransform scaleXBy:-1. yBy:1.];
    
    rot210Transform = [[NSAffineTransform alloc] init];
    [rot210Transform rotateByDegrees:210.];
    inverse210Transform = [[NSAffineTransform alloc] init];
    [rot210Transform invert];
    inverse210Transform = [inverse210Transform initWithTransform: rot210Transform];
    [rot210Transform invert];
    
    //[self defineActiveArea];
    theActiveWafer = [HXGActiveWafer sharedActiveWafer];


    cellLabels = [NSMutableArray array];
    iplacement = 0;
    /*
     + (NSColor *) paleCream;
     + (NSColor *) ivoryWhite;
     + (NSColor *) coolGrey;
     + (NSColor *) paleGrey;
     + (NSColor *) fadedBlue;
     + (NSColor *) paleBlue;
     + (NSColor *) pastelBlue;
     + (NSColor *) greyBlue;
     + (NSColor *) indigoBlue;
     + (NSColor *) purpleHaze;
     + (NSColor *) grassGreen;
     + (NSColor *) seaGreen;
     + (NSColor *) sageGreen;
     + (NSColor *) greyGreen;
     + (NSColor *) kharkiBrown;
     + (NSColor *) orchidPink;
     + (NSColor *) dullRed;
     + (NSColor *) driedBlood;
     + (NSColor *) raspberryRed;
     + (NSColor *) strawberryRed;
     + (NSColor *) peachOrange;

     */
    _cPalette = @[ [NSColor whiteColor],[NSColor paleCream], [NSColor ivoryWhite], [NSColor paleGrey], [NSColor coolGrey], [NSColor fadedBlue], [NSColor paleBlue], [NSColor greyBlue], [NSColor pastelBlue], [NSColor indigoBlue], [NSColor wildViolet], [NSColor purpleHaze], [NSColor tameViolet], [NSColor seaGreen], [NSColor grassGreen], [NSColor sageGreen], [NSColor greyGreen], [NSColor kharkiBrown], [NSColor orchidPink], [NSColor dullRed],  [NSColor driedBlood], [NSColor raspberryRed], [NSColor strawberryRed], [NSColor peachOrange], [NSColor redColor], [NSColor blueColor], [NSColor greenColor] ];
 
    _cNames = @[ @"whiteColor",@"paleCream", @"ivoryWhite", @"paleGrey", @"coolGrey", @"fadedBlue", @"paleBlue", @"greyBlue", @"pastelBlue", @"indigoBlue", @"wildViolet", @"purpleHaze", @"tameViolet", @"seaGreen", @"grassGreen", @"sageGreen", @"greyGreen", @"kharkiBrown", @"orchidPink", @"dullRed",  @"driedBlood", @"raspberryRed", @"strawberryRed", @"peachOrange", @"redColor", @"blueColor", @"greenColor" ];
 
    return self;
}

- (void) defineActiveArea {
   
    theActiveWafer = [HXGActiveWafer sharedActiveWafer];
/*
    NSPoint p1,p2;
    for (int i=0; i<6; i++) {
        p1 = [theActiveWafer mouseBitePoint: i Seq: 0 Hardware:NO];
        p2 = [theActiveWafer mouseBitePoint: i Seq: 1 Hardware:NO];
        mouseBitePnt[i][0] = p1;
        mouseBitePnt[i][2] = p2;
        mouseBitePnt[i][1] = NSMakePoint(0.5*(p1.x+p2.x),0.5*(p1.y+p2.y));
   }

    NSPoint zoltanF = NSMakePoint(-51.8958,74.95);  // in fact reflected on y-axis
    NSPoint zoltanC = NSMakePoint(-38.9787,82.3869);

    NSPoint p2 = [inverse210Transform transformPoint: zoltanF];
    NSPoint p1 = [inverse210Transform transformPoint: zoltanC];
    
    mouseBitePnt[0][0] = p1;
    mouseBitePnt[0][2] = p2;
    mouseBitePnt[0][1] = NSMakePoint(0.5*(p1.x+p2.x),0.5*(p1.y+p2.y));

    NSAffineTransform * rot60 = [[NSAffineTransform alloc] init];
    [rot60 rotateByDegrees:60.];

    for (int i=1; i<6; i++) {
        p1 = [rot60 transformPoint:p1];
        p2 = [rot60 transformPoint:p2];
        mouseBitePnt[i][0] = p1;
        mouseBitePnt[i][2] = p2;
        mouseBitePnt[i][1] = NSMakePoint(0.5*(p1.x+p2.x),0.5*(p1.y+p2.y));
    }
 */
}

#pragma mark - other stuff

- (void) setViewFrame:(NSRect)fRect {
    frameRect = fRect;
    incFrameRect = fRect;
    incFrameRect.origin.y = fRect.origin.y - 18.;
    incFrameRect.size.height = fRect.size.height + 18.;
}

- (void) drawCells:(NSArray *) g forWafer:(NSPoint *) w{ // ? rename?

    [self setFrame:frameRect];
    
    double xmx = xmax;
    double ymx = ymax;
    if(_inclusionRadii) {
        xmx -= _cside;
        ymx -= _cside;
        //iplacement = 0;
    }
    
    NSRect bounds = NSMakeRect(-xmax,-0.97*ymx,xmx+xmax,ymx+ymax);
    [self setBounds:bounds];
    
    waferBezier = [NSBezierPath bezierPath];
    [waferBezier moveToPoint:w[5]];
    for(int i=0; i<6; i++) {waferPoint[i] = w[i];[waferBezier lineToPoint:waferPoint[i]];}
    [waferBezier closePath];
    /*
    waferBezier = [NSBezierPath bezierPath];
    [waferBezier moveToPoint:waferPoint[5]];
    //double ang = 0.;
    //double len = waferSide*0.05*sqrt(3.);
    for (int i=0; i<6; i++) {
        [waferBezier lineToPoint:waferPoint[i]];
        
        NSPoint pnt = NSMakePoint(0.95*waferPoint[i].x,0.95*waferPoint[i].y);
        mouseBitePnt[i][1] = pnt;
        pnt.x -= len*cos(ang);
        pnt.y -= len*sin(ang);
        mouseBitePnt[i][0] = pnt;
        pnt.x += 2.*len*cos(ang);
        pnt.y += 2.*len*sin(ang);
        mouseBitePnt[i][2] = pnt;
        ang += M_PI/3.;
         
    }
*/
    activeBezier = [NSBezierPath bezierPath];
    [activeBezier moveToPoint:[theActiveWafer mbPnt:0 Seq:0]];
    [activeBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
    for (int i=1; i<6; i++) {
        [activeBezier lineToPoint:[theActiveWafer mbPnt:i Seq:0]];
        [activeBezier lineToPoint:[theActiveWafer mbPnt:i Seq:1]];
    }
    [activeBezier closePath];
    /*
    [activeBezier moveToPoint:mouseBitePnt[5][2]];
    for (int i=0; i<6; i++) {
        for (int j=0; j<3; j++) {
            [activeBezier lineToPoint:mouseBitePnt[i][j]];
        }
    }
     */
    
    
    
    killBiteBezier = [NSBezierPath bezierPath];
    [killBiteBezier moveToPoint:[theActiveWafer mbPnt:5 Seq:1]];
    [killBiteBezier appendBezierPath:activeBezier];
    [killBiteBezier moveToPoint:NSMakePoint(waferSide*1.05,0.)];
    [killBiteBezier appendBezierPathWithArcWithCenter:NSZeroPoint radius:waferSide*1.05 startAngle:0.0 endAngle:360.0];
    [killBiteBezier moveToPoint:[theActiveWafer mbPnt:5 Seq:1]];
    [killBiteBezier setWindingRule: NSWindingRuleEvenOdd];


    
    
    

    gridCells = g;
        
    centre = [NSBezierPath bezierPath];
    [centre moveToPoint:NSMakePoint(5.,0.)];
    [centre lineToPoint:NSMakePoint(-5.,0.)];
    [centre moveToPoint:NSMakePoint(0.,5.)];
    [centre lineToPoint:NSMakePoint(0.,-5.)];

    [self setupPlacement:iplacement];

}

- (void) initializePlacementIndex: (int) ip {

    _ispartial = _partial != 0;
    iplacement = ip;
    _mirror = ((ip < 6 && ip%2 == 1) || (ip > 5 && ip%2 == 0));

}
- (void) setPlacementIndex: (int) ip {
    
    _ispartial = NO;
    iplacement = ip;
    _mirror = ((ip < 6 && ip%2 == 1) || (ip > 5 && ip%2 == 0));
    
}
- (void) setupPlacement: (int) ip {
    
    _ispartial = _partial != 0;
    iplacement = ip;
    _mirror = ((ip < 6 && ip%2 == 1) || (ip > 5 && ip%2 == 0));
    [self mapCellLabels];
    [self makeChanUVmap];
    [self makeAxes];
    if(_ispartial || _wholePartial) [self setUpPartials];

    [self setNeedsDisplay:YES];

}

- (void) mapCellLabels {
    
    [cellLabels removeAllObjects];
    
    for(int ju=0; ju<2*_count; ju++) {
        for(int jv=0; jv<2*_count; jv++) {
            if(jv > ju+_count-1) break;
            if(ju > jv+_count) continue;
            NSPoint pnt = [self pointAtU:ju andV:jv];
            HXGCellLabel * c = [HXGCellLabel cellLabelForU:ju andV:jv at:pnt];
            indexInCellLabels[ju][jv] = (int) cellLabels.count;
            [cellLabels addObject:c];
        }
    }
    

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
    
    /* --------- special stuff for _hardwareOrientation
     NSBezierPath * specialAxes;
     NSBezierPath * specialUarw;
     NSBezierPath * specialVarw;
     NSPoint specialUPoint;
     NSPoint specialVPoint;
     */
    origin.y -= 2.*side;
    origin.x += 0.5*side;
    umax.x = origin.x + cos(M_PI/6.)*waferSide*0.6;
    umax.y = origin.y + sin(M_PI/6.)*waferSide*0.6;
    vmax.x = origin.x - cos(M_PI/6.)*waferSide*0.6;
    vmax.y = origin.y + sin(M_PI/6.)*waferSide*0.6;
 
    specialAxes = [NSBezierPath bezierPath];
    
    [specialAxes moveToPoint:origin];
    [specialAxes lineToPoint:umax];

    [specialAxes moveToPoint:origin];
    [specialAxes lineToPoint:vmax];

    umax.x += 0.01*(umax.x - origin.x);
    umax.y += 0.01*(umax.y - origin.y);
    vmax.x += 0.01*(vmax.x - origin.x);
    vmax.y += 0.01*(vmax.y - origin.y);

    specialUarw = [NSBezierPath bezierPath];
    utheta = atan2(umax.y - origin.y,umax.x - origin.x);
    alpha = utheta - 3.5*M_PI/3.;
    beta = utheta - 2.5*M_PI/3.;
    [specialUarw moveToPoint:umax];
    [specialUarw lineToPoint:NSMakePoint(umax.x+al*cos(alpha),umax.y+al*sin(alpha))];
    [specialUarw lineToPoint:NSMakePoint(umax.x+al*cos(beta),umax.y+al*sin(beta))];
    [specialUarw closePath];

    specialVarw = [NSBezierPath bezierPath];
    vtheta = atan2(vmax.y - origin.y,vmax.x - origin.x);
    alpha = vtheta - 3.5*M_PI/3.;
    beta = vtheta - 2.5*M_PI/3.;
    [specialVarw moveToPoint:vmax];
    [specialVarw lineToPoint:NSMakePoint(vmax.x+al*cos(alpha),vmax.y+al*sin(alpha))];
    [specialVarw lineToPoint:NSMakePoint(vmax.x+al*cos(beta),vmax.y+al*sin(beta))];
    [specialVarw closePath];
    
    //---- Now the label points
    umax.x -= 0.06*(umax.x - origin.x);
    umax.y -= 0.06*(umax.y - origin.y);
    vmax.x -= 0.08*(vmax.x - origin.x);
    vmax.y -= 0.08*(vmax.y - origin.y);
    
    alpha = utheta - M_PI*0.5;
    beta  = vtheta + M_PI*0.5;

    specialUPoint = NSMakePoint(umax.x+dl*cos(alpha),umax.y+dl*sin(alpha));
    specialVPoint = NSMakePoint(vmax.x+dl*cos(beta),vmax.y+dl*sin(beta));
    
    specialAxes = [rot210Transform transformBezierPath:specialAxes];
    specialUarw = [rot210Transform transformBezierPath:specialUarw];
    specialVarw = [rot210Transform transformBezierPath:specialVarw];
    specialUPoint = [rot210Transform transformPoint:specialUPoint];
    specialVPoint = [rot210Transform transformPoint:specialVPoint];
    
}

- (void) setRadii: (double *) r {

    for (int i=0; i<5; i++){
        radius[i] = r[i];
    }
}

- (void) setUpPartials {
    
    _ispartial = _partial != 0 || _wholePartial;
    NSPoint wPnt[6];
    
    //int j = (12-iplacement)%6;
    int j = 0;
    /*
    wPnt[(0+j)%6] = NSMakePoint(0.,-waferSide);
    wPnt[(1+j)%6] = NSMakePoint(+0.5*waferWidth,-0.5*waferSide);
    wPnt[(2+j)%6] = NSMakePoint(+0.5*waferWidth,+0.5*waferSide);
    wPnt[(3+j)%6] = NSMakePoint(0.,+waferSide);
    wPnt[(4+j)%6] = NSMakePoint(-0.5*waferWidth,+0.5*waferSide);
    wPnt[(5+j)%6] = NSMakePoint(-0.5*waferWidth,-0.5*waferSide);
*/
    for(int i=0; i<6; i++) { wPnt[(i+j)%6] = waferPoint[i];}
    
    // ---- construct the appropriate partial beziers
    activePartialBezier = [NSBezierPath bezierPath];
    partialBezier = [NSBezierPath bezierPath];
    testBezier = [NSBezierPath bezierPath];     // for split testing
    NSBezierPath * notestBezier = [NSBezierPath bezierPath];
    auxBezier = [NSBezierPath bezierPath];
    killBezier = [NSBezierPath bezierPath];
    /*
    NSAffineTransform * rot150Transform = [[NSAffineTransform alloc] init];
    [rot150Transform rotateByDegrees:150.];
*/
    if(_HD) {
        /*
        NSPoint xPnt[8];
        double u1 = 5./24.;
        double u2 = 1. - u1;
        xPnt[0] = NSMakePoint(u2*wPnt[5].x+u1*wPnt[0].x,u2*wPnt[5].y+u1*wPnt[0].y);
        xPnt[1] = NSMakePoint(u1*wPnt[5].x+u2*wPnt[0].x,u1*wPnt[5].y+u2*wPnt[0].y);
        xPnt[2] = NSMakePoint(u1*wPnt[3].x+u2*wPnt[2].x,u1*wPnt[3].y+u2*wPnt[2].y);
        xPnt[3] = NSMakePoint(u2*wPnt[3].x+u1*wPnt[2].x,u2*wPnt[3].y+u1*wPnt[2].y);

        NSPoint zoltanE = NSMakePoint(85.2148,17.1775);
        NSPoint zoltanF = NSMakePoint(86.2523,15.3805);
        NSPoint zoltanEm = NSMakePoint(-85.2148,17.1775);
        NSPoint zoltanFm = NSMakePoint(-86.2523,15.3805);
        zoltanE = [rot150Transform transformPoint:zoltanE];
        zoltanF = [rot150Transform transformPoint:zoltanF];
        zoltanEm = [rot150Transform transformPoint:zoltanEm];
        zoltanFm = [rot150Transform transformPoint:zoltanFm];
        xPnt[4] = NSMakePoint(0.5*(zoltanE.x+zoltanF.x),0.5*(zoltanE.y+zoltanF.y));
        xPnt[5] = NSMakePoint(0.5*(zoltanEm.x+zoltanFm.x),0.5*(zoltanEm.y+zoltanFm.y));
         */

/*
        double r1 = 7./36.;
        double r2 = 1. - r1;
        xPnt[4] = NSMakePoint(r1*wPnt[5].x+r2*wPnt[4].x,r1*wPnt[5].y+r2*wPnt[4].y);
        xPnt[5] = NSMakePoint(r1*wPnt[0].x+r2*wPnt[1].x,r1*wPnt[0].y+r2*wPnt[1].y);
*/
        /*
        double r1 = 29./72.;
        double r2 = 1. - r1;
        xPnt[6] = NSMakePoint(r1*xPnt[3].x+r2*xPnt[0].x,r1*xPnt[3].y+r2*xPnt[0].y);
        xPnt[7] = NSMakePoint(r1*xPnt[2].x+r2*xPnt[1].x,r1*xPnt[2].y+r2*xPnt[1].y);
        */

        for (int i=0; i<3; i++) {
            dicingBezier[i] = [NSBezierPath bezierPath];
            [dicingBezier[i] moveToPoint:[theActiveWafer HDdiceLine:i Point:0]];
            [dicingBezier[i] lineToPoint:[theActiveWafer HDdiceLine:i Point:1]];
            [dicingBezier[i] lineToPoint:[theActiveWafer HDdiceLine:i Point:2]];
            [dicingBezier[i] lineToPoint:[theActiveWafer HDdiceLine:i Point:3]];
            [dicingBezier[i] closePath];
        }
                
        //[testBezier appendBezierPath:[self doubleLineFrom:xPnt[3] To:xPnt[0]]];
        //[testBezier appendBezierPath:[self doubleLineFrom:xPnt[1] To:xPnt[2]]];
        //[notestBezier appendBezierPath:[self doubleLineFrom:xPnt[4] To:xPnt[5]]];
        [notestBezier appendBezierPath: dicingBezier[0]];
        [testBezier appendBezierPath: dicingBezier[1]];
        [testBezier appendBezierPath: dicingBezier[2]];
        if(_wholePartial) {
            [auxBezier appendBezierPath:testBezier];
            [auxBezier appendBezierPath:notestBezier];
        }

        if(_partial == 1) {
            [partialBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:2]];
            [partialBezier lineToPoint:wPnt[5]];
            [partialBezier lineToPoint:wPnt[0]];
            [partialBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:1]];
            [partialBezier closePath];
                        
            [activePartialBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:3]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:0]];
            [activePartialBezier closePath];

            [killBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:3]];
            [killBezier lineToPoint:wPnt[4]];
            [killBezier lineToPoint:wPnt[3]];
            [killBezier lineToPoint:wPnt[2]];
            [killBezier lineToPoint:wPnt[1]];
            [killBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:0]];
            [killBezier closePath];

            //[auxBezier appendBezierPath:[self doubleLineFrom:xPnt[0] To:xPnt[6]]];
            //[auxBezier appendBezierPath:[self doubleLineFrom:xPnt[1] To:xPnt[7]]];
            [auxBezier appendBezierPath:dicingBezier[1]];
            [auxBezier appendBezierPath:dicingBezier[2]];

       } else if(_partial == 2) {
           [partialBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:3]];
           [partialBezier lineToPoint:wPnt[4]];
           [partialBezier lineToPoint:wPnt[3]];
           [partialBezier lineToPoint:wPnt[2]];
           [partialBezier lineToPoint:wPnt[1]];
           [partialBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:0]];
           [partialBezier closePath];
           
           [activePartialBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:2]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:1]];
           [activePartialBezier closePath];
           
           [killBezier moveToPoint:[theActiveWafer HDdiceLine:0 Point:2]];
           [killBezier lineToPoint:wPnt[5]];
           [killBezier lineToPoint:wPnt[0]];
           [killBezier lineToPoint:[theActiveWafer HDdiceLine:0 Point:1]];
           [killBezier closePath];

           [auxBezier appendBezierPath:dicingBezier[1]];
           [auxBezier appendBezierPath:dicingBezier[2]];

           //[auxBezier appendBezierPath:[self doubleLineFrom:xPnt[3] To:xPnt[6]]];
           //[auxBezier appendBezierPath:[self doubleLineFrom:xPnt[2] To:xPnt[7]]];
           
      } else if(_partial == 3) {
          [partialBezier moveToPoint:[theActiveWafer HDdiceLine:1 Point:2]];
          [partialBezier lineToPoint:wPnt[0]];
          [partialBezier lineToPoint:wPnt[1]];
          [partialBezier lineToPoint:wPnt[2]];
          [partialBezier lineToPoint:[theActiveWafer HDdiceLine:1 Point:1]];
          [partialBezier closePath];
  
          /*
          NSPoint p1 = NSMakePoint(-zoltanB.x,zoltanB.y);
          NSPoint p2 = NSMakePoint(-zoltanB.x,-zoltanB.y);
          p1 = [rot150Transform transformPoint:p1];
          p2 = [rot150Transform transformPoint:p2];
           */
          [activePartialBezier moveToPoint:[theActiveWafer HDdiceLine:1 Point:3]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer HDdiceLine:1 Point:0]];
          [activePartialBezier closePath];
          
          [auxBezier appendBezierPath:dicingBezier[0]];

          [killBezier moveToPoint:[theActiveWafer HDdiceLine:1 Point:0]];
          [killBezier lineToPoint:wPnt[3]];
          [killBezier lineToPoint:wPnt[4]];
          [killBezier lineToPoint:wPnt[5]];
          [killBezier lineToPoint:[theActiveWafer HDdiceLine:1 Point:3]];
          [killBezier closePath];
      } else if(_partial == 4) {
          
          /*
          NSPoint p1 = NSMakePoint(zoltanA.x,-zoltanA.y);
          NSPoint p2 = NSMakePoint(zoltanA.x,zoltanA.y);
          p1 = [rot150Transform transformPoint:p1];
          p2 = [rot150Transform transformPoint:p2];
          */
          
          [partialBezier moveToPoint:[theActiveWafer HDdiceLine:2 Point:0]];
          [partialBezier lineToPoint:wPnt[3]];
          [partialBezier lineToPoint:wPnt[4]];
          [partialBezier lineToPoint:wPnt[5]];
          [partialBezier lineToPoint:[theActiveWafer HDdiceLine:2 Point:3]];
          [partialBezier closePath];
  /*
          p1 = NSMakePoint(zoltanB.x,-zoltanB.y);
          p2 = NSMakePoint(zoltanB.x,zoltanB.y);
          p1 = [rot150Transform transformPoint:p1];
          p2 = [rot150Transform transformPoint:p2];
*/
          [activePartialBezier moveToPoint:[theActiveWafer HDdiceLine:2 Point:1]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:0]];
          [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:1]];
          [activePartialBezier lineToPoint:[theActiveWafer HDdiceLine:2 Point:2]];
          [activePartialBezier closePath];
          
          [auxBezier appendBezierPath:dicingBezier[0]];

          [killBezier moveToPoint:[theActiveWafer HDdiceLine:2 Point:2]];
          [killBezier lineToPoint:wPnt[0]];
          [killBezier lineToPoint:wPnt[1]];
          [killBezier lineToPoint:wPnt[2]];
          [killBezier lineToPoint:[theActiveWafer HDdiceLine:2 Point:1]];
          [killBezier closePath];
      }

    } else { // --------------- LD ---------------------------------
        /*
        NSPoint pnt = NSMakePoint(0.5*wPnt[4].x,0.5*wPnt[4].y);
        NSPoint qnt = NSMakePoint(0.5*(wPnt[5].x+wPnt[0].x),0.5*(wPnt[5].y+wPnt[0].y));
        NSPoint rnt = NSMakePoint(0.5*(wPnt[3].x+wPnt[2].x),0.5*(wPnt[3].y+wPnt[2].y));
        */
        for (int i=0; i<3; i++) {
            dicingBezier[i] = [NSBezierPath bezierPath];
            [dicingBezier[i] moveToPoint:[theActiveWafer LDdiceLine:i Point:0]];
            [dicingBezier[i] lineToPoint:[theActiveWafer LDdiceLine:i Point:1]];
            [dicingBezier[i] lineToPoint:[theActiveWafer LDdiceLine:i Point:2]];
            [dicingBezier[i] lineToPoint:[theActiveWafer LDdiceLine:i Point:3]];
            [dicingBezier[i] closePath];
        }

        
        //[notestBezier appendBezierPath:[self doubleLineFrom:wPnt[1] To:wPnt[4]]];
        //[testBezier appendBezierPath:[self doubleLineFrom:wPnt[3] To:wPnt[5]]];
        //[testBezier appendBezierPath:[self doubleLineFrom:qnt To:rnt]];
        [notestBezier appendBezierPath:dicingBezier[0]];
        [testBezier appendBezierPath:dicingBezier[1]];
        [testBezier appendBezierPath:dicingBezier[2]];

        if(_wholePartial) {
            [auxBezier appendBezierPath:testBezier];
            [auxBezier appendBezierPath:notestBezier];
        }
        
        if(_partial == 1) {
            [partialBezier moveToPoint:wPnt[1]];
            [partialBezier lineToPoint:wPnt[4]];
            [partialBezier lineToPoint:wPnt[5]];
            [partialBezier lineToPoint:wPnt[0]];
            [partialBezier closePath];
            
            [activePartialBezier moveToPoint:[theActiveWafer mbPnt:1 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:0]];
            [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:3]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
            [activePartialBezier closePath];
            
            [killBezier moveToPoint:[theActiveWafer LDdiceLine:0 Point:0]];
            [killBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:3]];
            [killBezier lineToPoint:wPnt[4]];
            [killBezier lineToPoint:wPnt[3]];
            [killBezier lineToPoint:wPnt[2]];
            [killBezier lineToPoint:wPnt[1]];
            [killBezier closePath];

            [auxBezier appendBezierPath:dicingBezier[1]];
            [auxBezier appendBezierPath:dicingBezier[2]];
        } else if(_partial == 2) {
            [partialBezier moveToPoint:wPnt[1]];
            [partialBezier lineToPoint:wPnt[2]];
            [partialBezier lineToPoint:wPnt[3]];
            [partialBezier lineToPoint:wPnt[4]];
            [partialBezier closePath];
            
            [activePartialBezier moveToPoint:[theActiveWafer mbPnt:4 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:2]];
            [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:1]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:0]];
            [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:1]];
            [activePartialBezier closePath];
            
            [killBezier moveToPoint:[theActiveWafer LDdiceLine:0 Point:2]];
            [killBezier lineToPoint:[theActiveWafer LDdiceLine:0 Point:1]];
            [killBezier lineToPoint:wPnt[1]];
            [killBezier lineToPoint:wPnt[0]];
            [killBezier lineToPoint:wPnt[5]];
            [killBezier lineToPoint:wPnt[4]];
            [killBezier closePath];

            [auxBezier appendBezierPath:dicingBezier[1]];
            [auxBezier appendBezierPath:dicingBezier[2]];
       } else if(_partial == 3) {
           [partialBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:2]];
           [partialBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:1]];
           [partialBezier lineToPoint:wPnt[2]];
           [partialBezier lineToPoint:wPnt[1]];
           [partialBezier lineToPoint:wPnt[0]];
           [partialBezier closePath];
           
           [activePartialBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:0]];
           [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:3]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:1]];
           [activePartialBezier closePath];
       
           [auxBezier appendBezierPath:dicingBezier[0]];

           [killBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:3]];
           [killBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:0]];
           [killBezier lineToPoint:wPnt[3]];
           [killBezier lineToPoint:wPnt[4]];
           [killBezier lineToPoint:wPnt[5]];
           [killBezier closePath];
       } else if(_partial == 4) {
           [partialBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:0]];
           [partialBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:3]];
           [partialBezier lineToPoint:wPnt[5]];
           [partialBezier lineToPoint:wPnt[4]];
           [partialBezier lineToPoint:wPnt[3]];
           [partialBezier closePath];
           
           [activePartialBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:1]];
           [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:2]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:4 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:0]];
           [activePartialBezier closePath];
       
           [auxBezier appendBezierPath:dicingBezier[0]];

           [killBezier moveToPoint:[theActiveWafer LDdiceLine:1 Point:2]];
           [killBezier lineToPoint:[theActiveWafer LDdiceLine:1 Point:1]];
           [killBezier lineToPoint:wPnt[2]];
           [killBezier lineToPoint:wPnt[1]];
           [killBezier lineToPoint:wPnt[0]];
           [killBezier closePath];
       } else if(_partial == 5) {
           [partialBezier moveToPoint:[theActiveWafer LDdiceLine:2 Point:1]];
           [partialBezier lineToPoint:[theActiveWafer LDdiceLine:2 Point:2]];
           [partialBezier lineToPoint:wPnt[5]];
           [partialBezier lineToPoint:wPnt[0]];
           [partialBezier lineToPoint:wPnt[1]];
           [partialBezier lineToPoint:wPnt[2]];
           [partialBezier lineToPoint:wPnt[3]];
           [partialBezier closePath];
           
           [activePartialBezier moveToPoint:[theActiveWafer LDdiceLine:2 Point:0]];
           [activePartialBezier lineToPoint:[theActiveWafer LDdiceLine:2 Point:3]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:5 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:0 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:1 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:0]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:2 Seq:1]];
           [activePartialBezier lineToPoint:[theActiveWafer mbPnt:3 Seq:0]];
           [activePartialBezier closePath];
       
           [auxBezier appendBezierPath:dicingBezier[0]];
           [auxBezier appendBezierPath:dicingBezier[1]];

           [killBezier moveToPoint:[theActiveWafer LDdiceLine:2 Point:0]];
           [killBezier lineToPoint:[theActiveWafer LDdiceLine:2 Point:3]];
           [killBezier lineToPoint:wPnt[5]];
           [killBezier lineToPoint:wPnt[4]];
           [killBezier lineToPoint:wPnt[3]];
           [killBezier closePath];
       }
    }

    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        if(c.inside) {
            NSPoint pnt = c.centre;
            if(_mirror) pnt.x = -pnt.x;
            [self cellDetIdAtPoint:pnt];
            HXGCellLabel * cl = [cellLabels objectAtIndex:indexInCellLabels[idetId[0]][idetId[1]]];
            c.inpartial = [partialBezier containsPoint:pnt];
            cl.labelpart = c.inpartial;
        }
    }

    [self makeChanUVmap];

}
/*
- (void) guardRingInFor:(NSPoint) p1 To: (NSPoint) p2 {
    
    double delta = 0.8985;
    double alpha = atan2(p1.y-p2.y,p1.x-p2.x) + M_PI_2;

    altPnt1 = NSMakePoint(p1.x - delta*cos(alpha),p1.y - delta*sin(alpha));
    altPnt2 = NSMakePoint(p2.x - delta*cos(alpha),p2.y - delta*sin(alpha));

}
- (NSBezierPath *) doubleLineFrom: (NSPoint) p1 To: (NSPoint) p2 {
    
    NSBezierPath * doubleLine = [NSBezierPath bezierPath];
   
    double delta = 0.8985; //0.5;
    double alpha = atan2(p1.y-p2.y,p1.x-p2.x) + M_PI_2;
    NSPoint q1 = NSMakePoint(p1.x - delta*cos(alpha),p1.y - delta*sin(alpha));
    NSPoint r1 = NSMakePoint(p1.x + delta*cos(alpha),p1.y + delta*sin(alpha));
    NSPoint q2 = NSMakePoint(p2.x - delta*cos(alpha),p2.y - delta*sin(alpha));
    NSPoint r2 = NSMakePoint(p2.x + delta*cos(alpha),p2.y + delta*sin(alpha));
    
    [doubleLine moveToPoint:q1];
    [doubleLine lineToPoint:q2];
    [doubleLine lineToPoint:r2];
    [doubleLine lineToPoint:r1];
    [doubleLine closePath];

    return doubleLine;
}
*/
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
#pragma mark - colour clicking games

- (void) setColSelRect {
    
    double rat = self.bounds.size.width/self.frame.size.width;
    
    pRect.size.width = _paletteRect.size.width*rat;
    pRect.size.height = _paletteRect.size.height*rat;
    
    pRect.origin.x = self.bounds.origin.x - (self.frame.origin.x -_paletteRect.origin.x)*rat;
    pRect.origin.y = self.bounds.origin.y - (self.frame.origin.y -_paletteRect.origin.y)*rat;

    xp0 = pRect.origin.x;
    pstep = pRect.size.width + 3.*rat;
    _icsel = 6.;

}

#pragma mark - mouse tracking

- (void)mouseDown:(NSEvent *)theEvent {

    if(debugCellAreas && _wholePartial && !(_colorCells == 2)) {
        drawProblemCell = YES;
        [self setNeedsDisplay:YES];
        return;
    }
    
    if(_colorCells != 2) return;

    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    NSPoint p = mousePoint;

    if(_hardwareOrientation) p = [inverse210Transform transformPoint:mousePoint];
    [self cellDetIdAtPoint:p];

    int icell = indexInCells[idetId[0]][idetId[1]];
    HXGCell * c = [gridCells objectAtIndex:icell];
    
    if(_ispartial || _wholePartial) {   //----- Special points in partials
        if(gridCells.count < 400) {     //------------ LD
            if(idetId[0] == 1 && idetId[1] == 8) {
                int icx = indexInCells[2][9];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) c = cx;
            } else if(idetId[0] == 15 && idetId[1] == 15) {
                int icx = indexInCells[14][15];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) c = cx;
            } else if(idetId[0] == 8 && idetId[1] == 0) {
                int icx = indexInCells[7][0];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) c = cx;
            } else if(idetId[0] == 8){
                int icx = indexInCells[7][idetId[1]];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) c = cx;
                else {
                    icx = indexInCells[7][idetId[1]-1];
                    cx = [gridCells objectAtIndex:icx];
                    if([cx.partialCell containsPoint:p]) c = cx;
                }
            }
        } else {                              //----------------- HD
            if(idetId[0] == 9){
                int icx = indexInCells[10][idetId[1]];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) c = cx;
                else {
                    icx = indexInCells[10][idetId[1]+1];
                    cx = [gridCells objectAtIndex:icx];
                    if([cx.partialCell containsPoint:p]) c = cx;
                }
            }
        }
    }

    c.clickColor = _icsel;

    [self setNeedsDisplay:YES];

}


- (void) mouseMoved:(NSEvent *)theEvent {

    if(!_showCoords) return;
    NSTimeInterval tnow = [NSDate timeIntervalSinceReferenceDate];
    if(tnow - tstart < 0.1) return;
    tstart = tnow;
    
    mousePoint = [self convertPoint:[theEvent locationInWindow] fromView: nil];
    NSPoint p = mousePoint;
    if(_hardwareOrientation) p = [inverse210Transform transformPoint:mousePoint];
    [self cellDetIdAtPoint: p];
    
    if(_ispartial || _wholePartial) {   //----- Special points in partials

        if(gridCells.count < 400) {     //------------ LD
            if(idetId[0] == 1 && idetId[1] == 8) {
                int icx = indexInCells[2][9];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) {
                    idetId[0] = 2; idetId[1] = 9;
                }
            } else if(idetId[0] == 15 && idetId[1] == 15) {
                int icx = indexInCells[14][15];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) {
                    idetId[0] = 14;
                }
            } else if(idetId[0] == 8 && idetId[1] == 0) {
                int icx = indexInCells[7][0];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) {
                    idetId[0] = 7;
                }
            } else if(idetId[0] == 8){
                int icx = indexInCells[7][idetId[1]];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) {
                    idetId[0] = 7;
                } else {
                    icx = indexInCells[7][idetId[1]-1];
                    cx = [gridCells objectAtIndex:icx];
                    if([cx.partialCell containsPoint:p]) {
                        idetId[0] = 7; idetId[1] -= 1;
                    }
                }
            }
        } else {                              //----------------- HD
            if(idetId[0] == 9){
                int icx = indexInCells[10][idetId[1]];
                HXGCell * cx = [gridCells objectAtIndex:icx];
                if([cx.partialCell containsPoint:p]) {
                    idetId[0] = 10;
                } else {
                    icx = indexInCells[10][idetId[1]+1];
                    cx = [gridCells objectAtIndex:icx];
                    if([cx.partialCell containsPoint:p]) {
                        idetId[0] = 10; idetId[1] += 1;
                    }
                }
            }
        }
    }


    [self setNeedsDisplay:YES];
}

#pragma mark - geometrical details

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
   

    if(waferBezier && ![waferBezier containsPoint:point]) { // Check point is in waferBezier
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

- (void) makeChanUVmap {
   
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        [self cellDetIdAtPoint:c.centre];
        if(idetId[2]) {
            c.iup = idetId[0];
            c.ivp = idetId[1];
            indexInCells[c.iup][c.ivp] = i;
        }
    }
    
    BOOL * split;
    int * cCell;
    if(_ispartial || _wholePartial) cCell = theRawDataMap.LDPcCell;
    else cCell = theRawDataMap.LD0cCell;
    split = LDsplit;
    BOOL dense = NO;
    int ncalib = 6;
    if(_count == 12) {
        if(_ispartial || _wholePartial) cCell = theRawDataMap.HDPcCell;
        else cCell = theRawDataMap.HD0cCell;
        ncalib = 12;
        dense = YES;
        split = HDsplit;
    }

    int nloop = 2*_count;

   // ichan = hardware cell number minus one
     
    int ichan = 0;
    for(int iu=0; iu<nloop; iu++) {
        for(int iv=0; iv<nloop; iv++) {
            NSPoint pnt = [self pointAtU:iu andV:iv];
            [self cellDetIdAtPoint:pnt];
            if(idetId[2]) {
                [self cellLabeledU: iu andV: iv isCalib:NO isSplit: NO andChannel:ichan+1];
                U[ichan] = idetId[0];
                V[ichan] = idetId[1];
                cFlag[ichan] = NO;
                split[ichan] = NO;
                ichan++;
                HXGCell * c = gridCells[indexInCells[iu][iv]];
                if(_wholePartial || _ispartial) {
                    if(dense) {
                        if(iu == 9 || iu == 10) [c makePartialMods:iu];
                    } else {
                        if(iu == 7 || iu == 8)        [c makePartialMods:iu-7];
                        else if(iu == 1 && iv == 8)   [c makePartialMods:2];
                        else if(iu == 2 && iv == 9)   [c makePartialMods:3];
                        else if(iu == 15 && iv == 15) [c makePartialMods:4];
                        else if(iu == 14 && iv == 15) [c makePartialMods:5];
                    }
                }
                c.split = (_ispartial || _wholePartial) && ([testBezier containsPoint:c.centre] && !c.corner && !c.notSplit);

                if(c.split) {
                    [self cellLabeledU: iu andV: iv isCalib:NO isSplit:YES andChannel:ichan+1];
                    split[ichan] = YES;
                    split[ichan+1] = NO;
                    U[ichan] = idetId[0];
                    V[ichan] = idetId[1];
                    ichan++;
                }
                for(int i=0; i<ncalib; i++){
                    if(ichan == cCell[i]-1) {
                        U[ichan] = idetId[0];
                        V[ichan] = idetId[1];
                        cFlag[ichan] = YES;
                        [self cellLabeledU: iu andV: iv isCalib:YES isSplit:NO andChannel:ichan+1];
                        ichan++;
                    }
                }
            }
        }
    }
    
//    [theRawDataMap loadU: U andV: V andCalFlag: cFlag forDensity: dense andPartial:_partial || _wholePartial];

//    if((_ispartial || _wholePartial)) {   // && ichan > 0 ????
//        if(dense) theRawDataMap.HDsplit = HDsplit;
//        else theRawDataMap.LDsplit = LDsplit;
//    }
}

- (void) cellLabeledU:(int) iu andV:(int) iv isCalib:(BOOL) calib isSplit: (BOOL) split andChannel:(int) ich {
     
    HXGCellLabel * cl = [cellLabels objectAtIndex:indexInCellLabels[iu][iv]];
    cl.calib = calib;
    cl.split = split;
    cl.chan = ich;
    
    return;
}

- (NSPoint) pointAtU:(int) iu andV:(int) iv {
    
    double NN = (double) _count;    // _count = 8 for LD; = 12 for HD
    double RR = waferWidth/(3.*NN); // Cell side; waferWidth = 167.441
    double rr = RR*sin(M_PI/3.);    // Cell half-width
    
    double x = (1.5 * (double)(iu-iv) - 0.5) * RR;
    double y = ((double)(iu+iv) - 2.*NN + 1.) * rr;
    
    double rot = (double)(iplacement%6);
    double theta = rot * (M_PI/3.);
    NSPoint pnt;
    pnt.x = x*cos(theta) - y*sin(theta);
    pnt.y = x*sin(theta) + y*cos(theta);
    if(iplacement > 5) pnt.x = -pnt.x;
    
    return pnt;
}

#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    if(pdf) [pdftransform concat];
    else {
        [[NSColor whiteColor] set];
        NSRectFill([self bounds]);
    }
        
    if(_inclusionRadii) {
        //iplacement = 0;
        [self illustrateInclusionRadii];
        return;
    }
    
    NSColor * triggerColor[3];
    triggerColor[0] = [NSColor sageGreen];
    triggerColor[1] = [NSColor orchidPink];
    triggerColor[2] = [NSColor paleBlue];
    
    //---------------------------------------------------
    if(_mirror) [mirrorTransform concat];
    if(_hardwareOrientation)[rot210Transform concat];
 
    double calcellrad;
    for (int i=0;i<gridCells.count;i++) {
        HXGCell * c = [gridCells objectAtIndex:i];
        if(i == 0) calcellrad = c.side*0.4;
        if((_ispartial || _wholePartial) && (c.modifiedPartial && (_partial == 0 || c.inpartial))) {
            if(_colorCells == 1) {
                [c.partialColor set];
            }
            else {
                [[NSColor fadedBlue] set];
                if(_colorCells == 2) {
                    NSColor * col = _cPalette[c.clickColor];
                    [col set];
                }
            }
            [c.partialCell fill];
            [[NSColor blackColor] set];
            [c.partialCell setLineWidth:0.3];
            [c.partialCell stroke];
        } else if(c.whole && (_partial == 0 || c.inpartial)) {
            if(_colorCells == 2) {
                NSColor * col = _cPalette[c.clickColor];
                [col set];
            }
                //[triggerColor[c.itc] set];
            else if(_colorCells == 1) {
                [c.cellColor set];
            } else {
                [[NSColor fadedBlue] set];
            }
            [c.wholeCell fill];
            [[NSColor blackColor] set];
            [c.wholeCell setLineWidth:0.3];
            [c.wholeCell stroke];
        } else if(c.inside && (_partial == 0 || c.inpartial)) {
            if(_colorCells == 2) {
                NSColor * col = _cPalette[c.clickColor];
                [col set];
            }
            else if(_colorCells == 1) {
                if(_hyperBright && !c.corner) {
                    if(c.small) [[NSColor redColor] set];
                    else [[NSColor greenColor] set];
                } else [c.cellColor set];
            } else [[NSColor fadedBlue] set];
            if(c.iup == 0 && c.ivp == 0) [[NSColor redColor] set]; // Doesn't work well !!!
            [c.edgeCell fill];
            [[NSColor blackColor] set];
            [c.edgeCell setLineWidth:0.3];
            [c.edgeCell stroke];
        }
    }
    
    
    if(_mirror) {
        [mirrorTransform invert];
        [mirrorTransform concat];
        [mirrorTransform invert];
    }
    
    if(_wholePartial || _ispartial) {
        [[NSColor coolGrey] set];
        [auxBezier fill];
        [[NSColor blackColor] set];
        [auxBezier setLineWidth:0.1];
        [auxBezier stroke];
        /*
         for(int i=0; i<3; i++) {
             [[NSColor redColor] set];
             [dicingBezier[i] fill];
             [[NSColor blackColor] set];
             [dicingBezier[i] setLineWidth:0.15];
             [dicingBezier[i] stroke];
         }
         [[NSColor redColor] set];
         [testBezier fill];
         [[NSColor blackColor] set];
         [testBezier setLineWidth:0.15];
         [testBezier stroke];
        */
    }
    
    [[NSColor whiteColor] set];
    [killBiteBezier fill];
  
    if(_showOutline) {
        [[NSColor blackColor] set];
        [waferBezier setLineWidth:0.15];
        [waferBezier stroke];
        [[NSColor blueColor] set];
        [centre setLineWidth:0.5];
        [centre stroke];
    }

    
    if(_ispartial && !_wholePartial) { // ------------------- Draw the partial outline
        [[NSColor whiteColor] set];
        //[killBezier setLineWidth:0.3];
        //[killBezier stroke];
        [killBezier fill];
        [[NSColor blackColor] set];
        [activePartialBezier setLineWidth:0.3];
        [activePartialBezier stroke];
    } else {
        [[NSColor blackColor] set];
        [activeBezier setLineWidth:0.3];
        [activeBezier stroke];
    }
    
    if(_showGrid) {
        for (int i=0;i<gridCells.count;i++) {
            HXGCell * c = [gridCells objectAtIndex:i];
            [[NSColor grayColor] set];
            if(_mirror) {
                NSBezierPath * cell = [NSBezierPath bezierPath];
                cell = [mirrorTransform transformBezierPath:c.gridCell];
                [cell setLineWidth:0.1];
                [cell stroke];
            } else {
                [c.gridCell setLineWidth:0.1];
                [c.gridCell stroke];
            }
        }
    }


    if(_hardwareOrientation) {
        [rot210Transform invert];
        [rot210Transform concat];
        [rot210Transform invert];
    }
    //------------------------------------------
    int cellcount = 0;
    
    for (int i = 0; i<cellLabels.count; i++) {
        HXGCellLabel * c = [cellLabels objectAtIndex:i];
        if(_ispartial && !_wholePartial && !c.labelpart) continue;
        
        // Cell counting -------------
        cellcount++;
        
        NSPoint point = c.point;
        if(_hardwareOrientation) point = [rot210Transform transformPoint:point];
        /*        if(_hardwareOrientation) {
         NSLog(@"%3d (iu,iv) = (%2d,%2d); (x,y) = (%6.2f,%6.2f)",c.chan,c.iu,c.iv,c.point.x,c.point.y);
         NSPoint qoint = [self pointAtU:c.iu andV:c.iv];
         NSLog(@"%3d (iu,iv) = (%2d,%2d); (x,y) = (%6.2f,%6.2f)",c.chan,c.iu,c.iv,qoint.x,qoint.y);
         } */
        if(c.calib) {
            NSBezierPath * calcell = [NSBezierPath bezierPath];
            [calcell appendBezierPathWithArcWithCenter:point radius:calcellrad startAngle:0.0 endAngle:360.0];
            [[NSColor fadedBlue] set];
            [calcell fill];
            [[NSColor blackColor] set];
            [calcell setLineWidth:0.1];
            [calcell stroke];
        }
      
        if(_numberCells) {
            NSString * label = c.label;
            
            if(_hardwareOrientation || _allLabels) {
                if(c.calib || c.split) label = [NSString stringWithFormat:@" %02d:%02d\n%3d %3d",c.iu,c.iv,c.chan-1,c.chan];
                else label = [label stringByAppendingFormat:@"\n%4d ",c.chan];
            }
                NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:label];
                [str addAttribute:NSFontAttributeName
                            value:[NSFont systemFontOfSize:4.0 - _count*0.18]
                            range:NSMakeRange(0,str.length)];
            if(_hardwareOrientation || _allLabels) {
                NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
                [style setLineHeightMultiple:0.8];
                [str addAttribute:NSParagraphStyleAttributeName
                                  value:style
                                  range:NSMakeRange(0, str.length)];
            }
                [str drawAtPoint:NSMakePoint(point.x - 0.5*str.size.width,point.y-0.6*str.size.height)];
        }
    }
/* --------- cellcount output
    NSString * density = @"LD";
    if(_HD) density = @"HD";
    NSLog(@"%@ %d cell count = %d",density,_partial,cellcount);
   ---------       */
    
    if(drawProblemCell) {
        
        NSBezierPath * problemCell = theCellAreas.problemCell;

        [[NSColor redColor] set];
        [problemCell fill];
        [[NSColor blackColor] set];
        [problemCell setLineWidth:0.1];
        [problemCell stroke];
        drawProblemCell = NO;
    }
    
    if(_showAxes) {
        [[NSColor blackColor] set];
        if(_hardwareOrientation) {
            [specialAxes setLineWidth:0.4];
            [specialAxes stroke];
            [specialUarw fill];
            [specialVarw fill];
        } else {
            [uvAxes setLineWidth:0.4];
            [uvAxes stroke];
            [uarrow fill];
            [varrow fill];
        }
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"u"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:10.]
                    range:NSMakeRange(0,str.length)];
        NSPoint ulp = uLabelPoint;
        NSPoint vlp = vLabelPoint;
        if(_hardwareOrientation) {
            ulp = specialUPoint;
            vlp = specialVPoint;
        }
        NSPoint ul = NSMakePoint(ulp.x-0.5*str.size.width,ulp.y-0.5*str.size.height);
        [str drawAtPoint:ul];
        str = [[NSMutableAttributedString alloc] initWithString:@"v"];
        [str addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:10.]
                    range:NSMakeRange(0,str.length)];
        NSPoint vl = NSMakePoint(vlp.x-0.5*str.size.width,vlp.y-0.5*str.size.height);
        [str drawAtPoint:vl];
    }
    
    //---- placement index (if pdf)
    if(pdf && !_hardwareOrientation && !_wholePartial && !_ispartial && !(iplacement == 0)) {
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
    if (_showCoords && !pdf ) { // && !_hardwareOrientation
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
    
    if(_colorCells == 2 && !pdf) {
        [[NSColor blackColor] set];
        [NSBezierPath setDefaultLineWidth:0.5];
        double x = xp0;
        for(int i=0;i<_cPalette.count;i++) {
            pRect.origin.x = x;
            [NSBezierPath strokeRect:pRect];
            x += pstep;
        }
        pRect.origin.x = xp0 + _icsel*pstep;
        [NSBezierPath setDefaultLineWidth:1.2];
        [NSBezierPath strokeRect:pRect];
    }

    if(pdf) {
        [pdftransform invert];
        [pdftransform concat];
    }

}

- (void) illustrateInclusionRadii {
        
    NSColor * irCol[10];
    irCol[0] = [NSColor whiteColor];
    irCol[1] = [NSColor yellowColor];
    irCol[2] = [NSColor sageGreen];
    irCol[3] = [NSColor fadedBlue];
    irCol[4] = [NSColor pastelBlue];
    irCol[5] = [NSColor strawberryRed];
    irCol[6] = [NSColor redColor];
    irCol[7] = [NSColor greyGreen];
    irCol[8] = [NSColor kharkiBrown];
    irCol[9] = [NSColor greyBlue];

    [self setFrame:incFrameRect];
    
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
    
    NSRect bottomBar = [self bounds];
    bottomBar.size.height = 20.;
    bottomBar.size.width += 1.;
    bottomBar.origin.y = - ymax - 2.;

    [[[NSColor paleGrey] blendedColorWithFraction:0.8
                                           ofColor:[NSColor whiteColor]] set];
    [NSBezierPath fillRect:bottomBar];

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
