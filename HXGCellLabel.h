//
//  HXGCellLabel.h
//  Hex
//
//  Created by Chris Seez on 24/01/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGCellLabel : NSObject

@property (readonly) NSString * label;
@property (readonly) NSPoint point;


+ (id) cellLabel: (NSString *) string at: (NSPoint) pnt;

@end

NS_ASSUME_NONNULL_END
