//
//  HXGInspectorView.h
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "CSColours.h"
#import "HXGWafer.h"
#import "HXGLayerMapFiles.h"
#import "HXGPreferenceControl.h"
#import "CSBeziers.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGInspectorView : NSView {
    
    HXGPreferenceControl * thePreferences;
    HXGLayerMapFiles * theMapFiles;
    
    NSArray * waferThicknessColors;
    NSColor * tileColor;
    
    NSMutableAttributedString * specString;
    NSMutableAttributedString * aAS;
    NSMutableAttributedString * bAS;
    NSMutableAttributedString * hAS;
    
    NSRect aBox;
    NSRect bBox;
    NSRect hBox;

    
    NSBezierPath * waferBezier;
    NSBezierPath * bezier;
    NSBezierPath * zeroMarkBezier;
    NSBezierPath * barBezier;
    NSBezierPath * arrowBezier[6];

    NSAffineTransform * thirtyTransform;
    NSAffineTransform * tileRot;
    NSAffineTransform * inverseTileRot;
    NSAffineTransform * ninetyRot;
    NSAffineTransform * inverseNinetyRot;
    NSAffineTransform * aFlip;
    NSAffineTransform * bFlip;
    NSAffineTransform * inverseaFlip;
    NSAffineTransform * inversebFlip;

    double margin,buttonSpace;
    double side;
    NSPoint hexCentre;
}

@property int nlayer; // zero counted
@property HXGWafer * wafer;
@property BOOL isWafer;
@property int iRing;
@property int iphi;
@property BOOL rotated;
@property BOOL rotateRotated;
@property BOOL mirror;
@property BOOL retractedValues;
@property BOOL alreadyRetracted;
@property BOOL rotatedValues;
@property BOOL beyondV17;
@property int CEtype;
@property int ntiles;
@property double retract;
@property NSString * tString;


- (NSSize) setUpWaferInspectorDisplay;

- (NSSize) setUpTileInspectorDisplay;

- (void) savePDF:(NSString *) path;

@end

NS_ASSUME_NONNULL_END
