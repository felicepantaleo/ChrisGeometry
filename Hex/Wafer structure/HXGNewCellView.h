//
//  HXGNewCellView.h
//  Hex
//
//  Created by Chris Seez on 26/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGStructuredWafer.h"
#import "HXGNotifications.h"
#import "CSBeziers.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGNewCellView : NSView {

    HXGStructuredWafer * theStructuredWafer;
    
    NSRect frameRect;
    
    BOOL pdf;
    
    BOOL dragging;
    NSPoint dragFromPoint;
    NSTimeInterval tstart;
    
    NSTimer * highlightTimer;
    BOOL noHighlight;
    int highlightCount;
    
}

@property BOOL HD;
@property BOOL partial;
@property int partialType;
@property int irot;

@property BOOL highlight;
@property BOOL highlightChanged;
@property HXGStructuredCell * highlightCell;
@property NSString * waferDescription;

@property BOOL drawCells;
@property BOOL showDetId;
@property BOOL showHard;
@property BOOL showLayoutHexagon;
@property BOOL showPhysicalWafer;
@property BOOL showCentre;
@property BOOL showGrid;
@property BOOL showGridCount;
@property BOOL showEdgeIndex;
@property BOOL markCentroid;

@property BOOL pdfNoTitle;
@property BOOL pdfNoBackground;

@property double magnification;

@property (readonly) BOOL cellDebug;
@property (readonly) NSPoint mousePoint;
@property NSPoint centroid;

@property BOOL trigger;


- (void) setViewFrame:(NSRect) vRect;
- (void) setViewBounds;
- (void) savePDF:(NSString *) path;

- (void) animateHighlight:(NSTimer *) aTimer;


//- (void)scrollWheel:(NSEvent *)theEvent;
@end

NS_ASSUME_NONNULL_END
