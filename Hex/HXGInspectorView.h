//
//  HXGInspectorView.h
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "CSColours.h"
#import "HXGWafer.h"
#import "HXGPreferenceControl.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGInspectorView : NSView {
    
    HXGPreferenceControl * thePreferences;
    
    NSArray * waferThicknessColors;
    
    NSMutableAttributedString * specString;
    NSBezierPath * waferBezier;
    NSBezierPath * bezier;
    NSBezierPath * zeroMarkBezier;
    NSBezierPath * barBezier;

    NSAffineTransform * thirtyTransform;

    double margin,buttonSpace;
    double side;
    NSPoint hexCentre;
    BOOL instantiated;
    
}

@property HXGWafer * wafer;
@property BOOL rotated;
@property BOOL rotateRotated;
@property BOOL mirror;


- (NSSize) setUpTheInspectorDisplay;
@end

NS_ASSUME_NONNULL_END
