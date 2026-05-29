//
//  HXGDetIdInterface.h
//  Hex
//
//  Created by Chris Seez on 27/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGWafer.h"
#import "HXGStructuredCell.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGDetIdInterface : NSObject {

    NSArray * wafers;
    int wuv[2];
    int cuv[2];
    int cwuv[4];
    
    NSArray * cellsArrayLD;
    NSArray * cellsArrayHD;
    NSArray * partialCellsArrayLD[6];
    NSArray * partialCellsArrayHD[5];


}

extern const int    iuMask;
extern const int    ivMask;
extern const int waferMask;
extern const int signMask;
extern const int layerMask;

extern const int waferShift;
extern const int ivShift;

+ (id) sharedDetInterface;

- (void) setWaferArray:(NSArray *) warray;
- (void) setCellsArrays:(NSArray *) arrayOfArrays;

- (int *) cellAndWaferUVFromDetId:(int) DetId;
- (BOOL) cellWithU:(int) iu andV:(int) iv existsInDense:(BOOL) HD Partial:(int) ipart;
- (int *) waferUVFromDetId:(int) DetId;

- (int) DetIdWithWafer:(int *) wuv andCell:(int *) cuv inLayer: (int) layer;
- (HXGWafer *) waferWithU:(int) u andV:(int) v;


- (BOOL) waferExists: (int) DetId;
- (BOOL) waferIsHD: (int) DetId;
- (BOOL) waferPartial: (int) DetId;
- (BOOL) DetIdExists: (int) DetId;
- (int) placementIndexForWafer: (int) DetId;

@end

NS_ASSUME_NONNULL_END
