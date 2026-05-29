//
//  HXGDetIdInterface.m
//  Hex
//
//  Created by Chris Seez on 27/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGDetIdInterface.h"


@implementation HXGDetIdInterface

+ (id) sharedDetInterface {

// Thread-safe instantiation of HXGNeighbourFinder as a Singleton

    static dispatch_once_t pred;
    static HXGDetIdInterface * theDetInterface = nil;
    
    dispatch_once(&pred, ^{theDetInterface = [[self alloc] init]; });
    return theDetInterface;
}

- (id)init {
    
    self = [super init];
    return self;
}

- (void) setWaferArray:(NSArray *) warray {
    
    wafers = [NSArray arrayWithArray:warray];
}

- (void) setCellsArrays:(NSArray *) arrayOfArrays {

    cellsArrayLD = [NSArray arrayWithArray:arrayOfArrays[0]];
    cellsArrayHD = [NSArray arrayWithArray:arrayOfArrays[1]];
    for(int i=0; i<6; i++) {
        partialCellsArrayLD[i] = [NSArray arrayWithArray:arrayOfArrays[i+2]];
    }
    for(int i=0; i<5; i++) {
        partialCellsArrayHD[i] = [NSArray arrayWithArray:arrayOfArrays[i+8]];
    }
        
}
#pragma mark - encoding and decoding DetIds

- (int) DetIdWithWafer:(int *) wuv andCell:(int *) cuv inLayer: (int) layer {
    
    int wuId = abs(wuv[0]);
    if(wuv[0] < 0) wuId = wuId | signMask;
    int wvId = abs(wuv[1]);
    if(wuv[1] < 0) wvId = wvId | signMask;
    int waferId = wuId | wvId << ivShift;

    int DetId = cuv[0] | (cuv[1] << ivShift) | waferId << waferShift;
    if(layer < 26) DetId = DetId | 0x80000000;
    else DetId = DetId | 0x90000000;
    
    return DetId;
}

- (HXGWafer *) waferWithU:(int) u andV:(int) v {
    
    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.detId[0] == u && w.detId[1] == v) return w;
    }
    
    return nil;

}

- (int *) waferUVFromDetId:(int) DetId {

    int waferId = (DetId & waferMask) >> waferShift;
    int iu = waferId & iuMask;
    int iv = (waferId & ivMask) >> ivShift ;

    if(iu & signMask) wuv[0] = -(iu & ~signMask);
    else wuv[0] = iu;

    if(iv & signMask) wuv[1] = -(iv & ~signMask);
    else wuv[1] = iv;

    return wuv;
}

- (int *) cellAndWaferUVFromDetId:(int) DetId {
    
    cwuv[0] = DetId & iuMask;
    cwuv[1] = (DetId & ivMask) >> ivShift ;

    int waferId = (DetId & waferMask) >> waferShift;

    int iu = waferId & iuMask;
    int iv = (waferId  & ivMask) >> ivShift  ;


    if(iu & signMask) cwuv[2] = -(iu & ~signMask);
    else cwuv[2] = iu;
    
    if(iv & signMask) cwuv[3] = -(iv & ~signMask);
    else cwuv[3] = iv;

    return cwuv;
}

#pragma mark - Cell exists check

- (BOOL) cellWithU:(int) iu andV:(int) iv existsInDense:(BOOL) HD Partial:(int) ipart {

    NSArray * cellsArray = cellsArrayLD;
    if(HD) cellsArray = cellsArrayHD;
    if(!HD && ipart > 0 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
    if( HD && ipart > 0 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];

    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        if(cs.uvId[0] == iu && cs.uvId[1] == iv) return YES;
    }

    return NO;
}

#pragma mark - pseudoCMSSW routines

- (BOOL) waferExists: (int) DetId {
    
    int * wuv = [self waferUVFromDetId: DetId];
    
    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.whole || w.part) {
            if(w.detId[0] == wuv[0] && w.detId[1] == wuv[1]) return YES;
        }
    }
    
    return NO;
}

- (BOOL) waferIsHD: (int) DetId {

    int * wuv = [self waferUVFromDetId: DetId];

    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.detId[0] == wuv[0] && w.detId[1] == wuv[1]) return !w.LD;
    }

    return NO;
}

- (BOOL) waferPartial: (int) DetId {

    int * wuv = [self waferUVFromDetId: DetId];

    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.detId[0] == wuv[0] && w.detId[1] == wuv[1]) return w.part;
    }

    return NO;
}

- (BOOL) DetIdExists: (int) DetId {
    
    int * cwuv = [self cellAndWaferUVFromDetId: DetId];
    
    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.detId[0] == cwuv[2] && w.detId[1] == cwuv[3]) {
            int ipart = w.type;
            BOOL HD = !w.LD;
            return [self cellWithU:cwuv[0] andV:cwuv[1] existsInDense:HD Partial:ipart];
        }
    }

    return NO;

}

- (int) placementIndexForWafer: (int) DetId {

    int * wuv = [self waferUVFromDetId: DetId];
    
    //NSLog(@"Placement index for wafer %d:%d",wuv[0],wuv[1]);

    int iplace;
    for(int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if(w.detId[0] == wuv[0] && w.detId[1] == wuv[1]) {
            iplace = w.channelZero;
            //NSLog(@"channelZero = %d",iplace);
            if(w.seenFromBack) iplace = 6+iplace;
            return iplace;
        }
    }

    return 0;
}

@end
