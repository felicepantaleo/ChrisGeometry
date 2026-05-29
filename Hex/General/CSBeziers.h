//
//  CSBeziers.h
//  Hex
//
//  Created by Chris Seez on 08/03/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (CSBeziers)

+ (NSBezierPath *) crossHairsAt: (NSPoint) point withRadius: (double) rad;

+ (NSBezierPath *) arrowFrom:(NSPoint) s To:(NSPoint) e headSize:(double) h;

@end

NS_ASSUME_NONNULL_END
