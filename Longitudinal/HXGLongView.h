//
//  HXGLongView.h
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "CSBeziers.h"
#import "HXGNotifications.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGLongView : NSView {
   
    NSImage * edmsImage;
    NSBezierPath * etaLine[3];
    NSMutableAttributedString * etaLabel[3];
    NSRect labelRect[3];
    NSRect labelBox[3];
    NSAffineTransform * xform[3];
}

@property NSPoint crossHairs;
@property BOOL showcoords;
@property BOOL calibrationMode;
@property int nlines;
@property double zLow;
@property double rLow;
@property double scale;
@property NSString * fileName;

- (void) loadDiagram;
- (void) setViewBounds;
- (void) addEtaLine:(double) eta;
- (void) mouseDown:(NSEvent *)theEvent;

@end

NS_ASSUME_NONNULL_END
