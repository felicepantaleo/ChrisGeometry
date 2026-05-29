//
//  HXGInspectorView.h
//  Hex
//
//  Created by Chris Seez on 28/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "CSColours.h"
#import "HXGWafer.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGInspectorView : NSView {
    
    NSMutableAttributedString * specString;
    NSBezierPath * waferBezier;
    NSBezierPath * bezier;
    NSBezierPath * zeroMarkBezier;
    
    NSAffineTransform * thirtyTransform;
    
    double margin,buttonSpace;
    BOOL instantiated;
    
}

@property HXGWafer * wafer;
@property BOOL rotated;
@property BOOL rotateRotated;


- (NSSize) setUpTheInspectorDisplay;
@end

NS_ASSUME_NONNULL_END
