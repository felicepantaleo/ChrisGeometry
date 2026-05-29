//
//  HXGHardwareConstants.h
//  Hex
//
//  Created by Chris Seez on 02/06/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGCTerminalControl.h"


NS_ASSUME_NONNULL_BEGIN

@interface HXGHardwareConstants : NSObject {

    HGCTerminalControl * theTerminal;
 
    NSAffineTransform * rot60[6];
    NSAffineTransform * flipX;
    NSAffineTransform * hardToReference;

    double physicalWaferWidth;
    
    NSPoint activeWaferPoint[11][12];
    int nAWpnts[10];

}

extern const int NLHGCAL;

extern const double layoutHexagonWidth;
extern const double moduleSpacing;

extern const int NLD;
extern const int NHD;
extern const double radiusCalibLD;
extern const double radiusCalibHD;


@property (readonly) NSPoint LDzoltanA;
@property (readonly) NSPoint LDzoltanB;
@property (readonly) NSPoint LDzoltanC;
@property (readonly) NSPoint LDzoltanD;
@property (readonly) NSPoint LDzoltanE;
@property (readonly) NSPoint LDzoltanF;
@property (readonly) NSPoint LDzoltanG;
@property (readonly) NSPoint LDzoltanH;

@property (readonly) NSPoint HDzoltanA;
@property (readonly) NSPoint HDzoltanB;
@property (readonly) NSPoint HDzoltanC;
@property (readonly) NSPoint HDzoltanD;
@property (readonly) NSPoint HDzoltanE;
@property (readonly) NSPoint HDzoltanF;
@property (readonly) NSPoint HDzoltanG;

@property (readonly) double mouseBitePerp;
@property (readonly) double halfDiceWidth;
@property (readonly) double activeWidth;



+ (id) sharedHardwareConstants;
- (id) init;
- (NSBezierPath *) bezierForActiveAt:(NSPoint) pnt forType:(int) ityp andRotation:(int)jrot;
- (void) writeConstantsToTerminal;
@end

NS_ASSUME_NONNULL_END
