//
//  HXGCellIndex.h
//  Hex
//
//  Created by Chris Seez on 28/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGCellIndex : NSObject {
    
}

@property (readonly) int iu;
@property (readonly) int iv;

+ (id) cellWithU:(int) u andV:(int) v;
@end

NS_ASSUME_NONNULL_END
