//
//  HXGStructuredWafer.h
//  Hex
//
//  Created by Chris Seez on 15/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXGHardwareConstants.h"
#import "HXGrawDataMapControl.h"
#import "HXGStructuredCell.h"
#import "HXGWafer.h"
#import "HXGNeighbourFinder.h"
#import "HXGDetIdInterface.h"
#import "HXGCellIndex.h"
#import "HGCTerminalControl.h"
#import "CSColours.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGStructuredWafer : NSObject {
    
    HXGHardwareConstants * theHardwareConstants;
    HXGrawDataMapControl * theRawDataMap;
    HXGNeighbourFinder * theNeighbourFinder;
    HXGDetIdInterface * theDetInterface;
    HGCTerminalControl * theTerminal;

    
    double waferSide;
    double cellSideLD;
    double cellWidthLD;
    double cellSideHD;
    double cellWidthHD;
    double activeWidth;
    double mouseBitePerp;
    double halfDiceWidth;

    
    NSBezierPath * waferLayoutHexagon;
    NSBezierPath * physicalWafer;
    NSBezierPath * hardXyAxes;
    
    double diceVert1LD;
    double diceVert2LD;
    double diceHorzLD;
    double diceVert1HD;
    double diceVert2HD;
    double diceHorzHD;
    
    NSPoint dicePntVert1LD[4];
    NSPoint dicePntVert2LD[4];
    NSPoint dicePntHorzLD[4];
    NSPoint dicePntVert1HD[4];
    NSPoint dicePntVert2HD[4];
    NSPoint dicePntHorzHD[4];
    
    int edgeLD[6][8];
    int edgeHD[6][12];
    int cornerLD[6][2];
    int cornerHD[6][3];
    
    NSPoint offsetLD[6];
    NSPoint offsetHD[6];
    
    NSAffineTransform * rot60[6];
    NSAffineTransform * flipX;
    NSAffineTransform * flipY;
    NSAffineTransform * hardToReference;
    NSAffineTransform * referenceToHard;
    
    NSArray * cellsArrayLD;
    NSArray * cellsArrayHD;
    NSArray * partialCellsArrayLD[6];
    NSArray * partialCellsArrayHD[5];
    NSArray * gridToCellMap;
    
    
    NSColor * cellColor[4];
    
    NSPoint LDzoltanA,LDzoltanB,LDzoltanC,LDzoltanD,LDzoltanE,LDzoltanF,LDzoltanG,LDzoltanH;
    NSPoint HDzoltanA,HDzoltanB,HDzoltanC,HDzoltanD,HDzoltanE,HDzoltanF,HDzoltanG;
    
    int iuivId[3];
    
    HXGStructuredCell * chosenCell;
    NSPoint chosenCellGridCentre;
    
    NSPoint activeWaferPoint[11][12];
    int nAWpnts[10];
    
    int trgCells[936];
    NSColor * trgColor[6];
    
    NSBezierPath * cellBez;
    NSBezierPath * calibBez;
    BOOL calibHighlighted;
    BOOL highlightNeighbours;
    NSArray * neighbourList;
    
}

@property BOOL trigger;
@property BOOL debugPolyContain;



+ (id) sharedStructuredWafer;

- (void) drawCellsForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored;

- (NSPoint) centroidOfCellUvid: (int *) iuiv inWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored;

- (HXGStructuredCell *) getChosenCell;
- (NSPoint) getChosenCellGridCentre;

- (NSPoint) convertPoint:(NSPoint) pnt toReferenceFromRotated:(int) irot;
- (NSPoint) convertPoint:(NSPoint) pnt toRotatedFromReference:(int) irot;
- (NSPoint) convertPoint:(NSPoint) pnt toRotated:(int) irot fromRotated:(int) jrot;

- (HXGStructuredCell *) cellAtPoint:(NSPoint) point Dense:(BOOL) HD Partial:(BOOL) partial;
- (void) makeGridToCellMapForDense:(BOOL) HD Partial:(int) ipart;
- (double) getCalibAreaForDense:(BOOL) HD;
- (double) getCellSideForDense:(BOOL) HD;

- (NSString *) triggerAndRocTextForCell:(HXGStructuredCell *) cs inPartial:(int) pType;

- (void) setNeighbourList: (NSArray *) narray;
- (void) drawCellsDense:(BOOL) HD;
- (void) drawCellsDense:(BOOL) HD Rotated:(int) irot;
- (void) drawCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot;
- (void) drawCellsDense:(BOOL) HD Rotated:(int) irot At: (NSPoint) point;

- (void) drawPartialCellsDense:(BOOL) HD;
- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart;
- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot;
- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt;

- (void) drawWaferLayoutHexagon:(int) irot;
- (void) drawHardXyAxes:(int) irot;
- (void) drawPhysicalWafer:(int) irot;
- (void) highlightCell:(HXGStructuredCell *) cs Rotated:(int) irot isPartial:(BOOL) partial;
- (void) outlineHighlightCell:(BOOL) thick;

- (void) drawGridDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot;
 
- (void) drawLabelsForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored;
- (void) drawEdgeIndexForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored;

- (void) drawLabelsUvDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot;
- (void) drawLabelsUvDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt;

- (void) drawLabelsHardDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot;
- (void) drawLabelsHardDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt;

- (void) drawLabelsGridCountDense:(BOOL) HD Rotation:(int) irot;
- (void) drawLabelsEdgeIndexDense:(BOOL) HD ForPartial:(int) ipart Rotation:(int) irot;

@end

NS_ASSUME_NONNULL_END
