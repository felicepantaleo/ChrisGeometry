//
//  HXGStructuredCell.h
//  Hex
//
//  Created by Chris Seez on 15/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface HXGStructuredCell : NSObject {
    
    NSPoint gridCorner[6];
    NSPoint cellCorner[6];
    
    int presenceFlags;
    
    int uvIdRef[2];

}

@property (readonly) NSPoint centre;

@property (readonly) NSBezierPath * gridBezier;
@property (readonly) NSBezierPath * cellBezier;
@property (readonly) NSBezierPath * calibBezier;
@property (readonly) HXGStructuredCell * siblingCell;

@property (readonly) BOOL HD;
@property (readonly) int * uvId;
@property (readonly) int hard;
@property (readonly) int partialHard;
@property (readonly) int type;
@property (readonly) BOOL whole;
@property (readonly) BOOL edge;
@property (readonly) BOOL corner;
@property (readonly) BOOL calib;
@property (readonly) BOOL partialCalib;
@property (readonly) BOOL split;
@property (readonly) BOOL special;

@property (readonly) int gridCount;
@property (readonly) int edgeIndex;



+ (id) cellDense:(BOOL) HD withCentre:(NSPoint) cntr;
+ (id) cellWithCell:(HXGStructuredCell *) cx;
+ (id) nullCell;

- (void) setPresentInType:(int) pType;
- (BOOL) isPresentInType:(int) pType;

- (int) trgRegion;
- (int) trgCellColorIndex;
- (int) anomalousColorIndexForPartial:(int) ipart;

- (void) setType:(int) ityp;
- (void) setSiblingCell:(HXGStructuredCell *) cs;
- (void) setGridCount:(int) ig;
- (void) setEdgeIndex:(int) ei;

- (void) setGridCorner:(int) i To: (NSPoint) pnt;
- (NSPoint) getGridCorner: (int) i;
- (void) setCellCorner:(int) i To: (NSPoint) pnt;
- (NSPoint) getCellCorner: (int) i;
- (void) setIdU:(int) iu andV:(int) iv;
- (void) setCalibWithRadius:(double) r;
- (void) setPartialCalibWithRadius:(double) r;
- (void) setHardwareChan:(int) ihard;
- (void) setPartialHardwareChan:(int) ihard;
- (void) setSplit:(BOOL) isSplit;
- (void) setSpecial:(BOOL) isSpecial;

- (double) getCellArea;
- (NSPoint) getCellCentroid;

- (void) makeGridBezier;
- (void) makeCellBezier;
@end


NS_ASSUME_NONNULL_END
