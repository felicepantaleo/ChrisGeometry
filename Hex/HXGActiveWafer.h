//
//  HXGActiveWafer.h
//  Hex
//
//  Created by Chris Seez on 05/06/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGActiveWafer : NSObject {
    
    NSPoint LDzoltanA,LDzoltanB,LDzoltanC,LDzoltanD,LDzoltanE,LDzoltanF,LDzoltanG,LDzoltanH;
    NSPoint HDzoltanA,HDzoltanB,HDzoltanC,HDzoltanD,HDzoltanE,HDzoltanF,HDzoltanG;
    
    NSPoint activeWafer[2][6];
    
    double sqrt3;
    double sine[6],cosine[6];
    
    NSPoint LDdicingPoint[3][4];
    NSPoint HDdicingPoint[3][4];

}

+ (id) sharedActiveWafer;

- (NSPoint) dicingLine: (int) line Point: (int) ipnt Dense: (BOOL) HD Hardware: (BOOL) hard;
- (NSPoint) LDdiceLine: (int) line Point: (int) ipnt;
- (NSPoint) HDdiceLine: (int) line Point: (int) ipnt;

- (NSPoint) mouseBitePoint: (int) ipnt Seq: (int) iv Hardware: (BOOL) hard;
- (NSPoint) mbPnt: (int) ipnt Seq: (int) iv;

- (NSPoint) rotate: (NSPoint) pnt bySixtyTimes: (int) n;
- (NSPoint) fromHardware: (NSPoint) pnt;
- (NSPoint)   toHardware: (NSPoint) pnt;

@end

NS_ASSUME_NONNULL_END
