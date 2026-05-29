//
//  HXGActiveWafer.m
//  Hex
//
//  Created by Chris Seez on 05/06/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGActiveWafer.h"

@implementation HXGActiveWafer

+ (id) sharedActiveWafer {
    
    static dispatch_once_t pred;
    static HXGActiveWafer * theActiveWafer = nil;
    
    dispatch_once(&pred, ^{theActiveWafer = [[self alloc] init]; });
    return theActiveWafer;
    
}

- (id)init {
   
    self = [super init];
    
    LDzoltanA = NSMakePoint(-0.8985,82.3869);
    LDzoltanB = NSMakePoint( 0.8985,82.3869);
    LDzoltanC = NSMakePoint(38.9787,82.3869);
    LDzoltanD = NSMakePoint(47.4375,77.5032);
    LDzoltanE = NSMakePoint(49.2345,76.4657);
    LDzoltanF = NSMakePoint(51.8598,74.9500);
    LDzoltanG = NSMakePoint(90.8385, 7.4369);
    LDzoltanH = NSMakePoint(90.8385, 0.8985);

    HDzoltanA = NSMakePoint(27.2975,82.3869);
    HDzoltanB = NSMakePoint(29.0945,82.3869);
    HDzoltanC = NSMakePoint(38.9787,82.3869);
    HDzoltanD = NSMakePoint(51.8598,74.9500);
    HDzoltanE = NSMakePoint(85.2148,17.1775);
    HDzoltanF = NSMakePoint(86.2523,15.3805);
    HDzoltanG = NSMakePoint(90.8385, 7.4369);

    sqrt3 = sqrt(3.);
    
    double sixty = M_PI/3.;
    double ang = 0.;
    for (int i=0; i<6; i++) {
        sine[i] = sin(ang);
        cosine[i] = cos(ang);
        ang += sixty;
    }
    
    NSPoint pnt0 = LDzoltanC;
    NSPoint pnt1  = LDzoltanF;
    
    pnt0.x = -pnt0.x;
    pnt1.x = -pnt1.x;

    for (int i=0; i<6; i++) {
        activeWafer[0][i] = pnt0;
        activeWafer[1][i] = pnt1;
        pnt0 = [self rotate:pnt0 bySixtyTimes: 1];
        pnt1 = [self rotate:pnt1 bySixtyTimes: 1];
    }

    // --- LD dicing lines
    LDdicingPoint[0][0] = NSMakePoint(-LDzoltanH.x, LDzoltanH.y);
    LDdicingPoint[0][1] = NSMakePoint(-LDzoltanH.x,-LDzoltanH.y);
    LDdicingPoint[0][2] = NSMakePoint( LDzoltanH.x,-LDzoltanH.y);
    LDdicingPoint[0][3] = NSMakePoint( LDzoltanH.x, LDzoltanH.y);

    LDdicingPoint[1][0] = NSMakePoint(-LDzoltanB.x,-LDzoltanB.y);
    LDdicingPoint[1][1] = NSMakePoint( LDzoltanB.x,-LDzoltanB.y);
    LDdicingPoint[1][2] = NSMakePoint( LDzoltanB.x, LDzoltanB.y);
    LDdicingPoint[1][3] = NSMakePoint(-LDzoltanB.x, LDzoltanB.y);

    LDdicingPoint[2][0] = NSMakePoint( LDzoltanD.x,-LDzoltanD.y);
    LDdicingPoint[2][1] = NSMakePoint( LDzoltanE.x,-LDzoltanE.y);
    LDdicingPoint[2][2] = NSMakePoint( LDzoltanE.x, LDzoltanE.y);
    LDdicingPoint[2][3] = NSMakePoint( LDzoltanD.x, LDzoltanD.y);

    // --- HD dicing lines
    HDdicingPoint[0][0] = NSMakePoint(-HDzoltanE.x, HDzoltanE.y);
    HDdicingPoint[0][1] = NSMakePoint(-HDzoltanF.x, HDzoltanF.y);
    HDdicingPoint[0][2] = NSMakePoint( HDzoltanF.x, HDzoltanF.y);
    HDdicingPoint[0][3] = NSMakePoint( HDzoltanE.x, HDzoltanE.y);

    HDdicingPoint[1][0] = NSMakePoint(-HDzoltanB.x,-HDzoltanB.y);
    HDdicingPoint[1][1] = NSMakePoint(-HDzoltanA.x,-HDzoltanA.y);
    HDdicingPoint[1][2] = NSMakePoint(-HDzoltanA.x, HDzoltanA.y);
    HDdicingPoint[1][3] = NSMakePoint(-HDzoltanB.x, HDzoltanB.y);

    HDdicingPoint[2][0] = NSMakePoint( HDzoltanA.x,-HDzoltanA.y);
    HDdicingPoint[2][1] = NSMakePoint( HDzoltanB.x,-HDzoltanB.y);
    HDdicingPoint[2][2] = NSMakePoint( HDzoltanB.x, HDzoltanB.y);
    HDdicingPoint[2][3] = NSMakePoint( HDzoltanA.x, HDzoltanA.y);

    return self;
}

- (NSPoint) dicingLine: (int) line Point: (int) ipnt Dense: (BOOL) HD Hardware: (BOOL) hard {
    
    NSPoint pnt;
    
    if(HD) pnt = HDdicingPoint[line][ipnt];
    else pnt = LDdicingPoint[line][ipnt];
    
    if(!hard) pnt = [self fromHardware:pnt];
    
    return pnt;
}

- (NSPoint) LDdiceLine: (int) line Point: (int) ipnt {
    
    NSPoint pnt = LDdicingPoint[line][ipnt];
    return [self fromHardware:pnt];
    
}
- (NSPoint) HDdiceLine: (int) line Point: (int) ipnt {
    
    NSPoint pnt = HDdicingPoint[line][ipnt];
    return [self fromHardware:pnt];

}

- (NSPoint) mouseBitePoint: (int) ipnt Seq: (int) iv Hardware: (BOOL) hard {
 
    NSPoint pnt = activeWafer[iv][ipnt];
    
    if(!hard) pnt = [self fromHardware:pnt];
    
    return pnt;

}
- (NSPoint) mbPnt: (int) ipnt Seq: (int) iv {
   
    NSPoint pnt = activeWafer[iv][ipnt];
        
    return [self fromHardware:pnt];

}

- (NSPoint) rotate: (NSPoint) pnt bySixtyTimes: (int) n {
    
    if(n > 5 || n < 0) n = 0;
    return NSMakePoint(pnt.x*cosine[n]-pnt.y*sine[n],pnt.x*sine[n]+pnt.y*cosine[n]);
    
}
- (NSPoint) fromHardware: (NSPoint) pnt {
    
    // i.e. rotate 150 degrees
    
    return NSMakePoint(-pnt.x*0.5*sqrt3 - pnt.y*0.5, pnt.x*0.5 - pnt.y*0.5*sqrt3);
}

- (NSPoint) toHardware: (NSPoint) pnt {
    
    // i.e. rotate 210 degrees
    
    return NSMakePoint(-pnt.x*0.5*sqrt3 + pnt.y*0.5, -pnt.x*0.5 - pnt.y*0.5*sqrt3);
}

@end
