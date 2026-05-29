//
//  HXGCEHspacers.h
//  Hex
//
//  Created by Chris Seez on 04/12/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGCEHspacers : NSObject {
    
}

+ (id) sharedCEHspacers;
- (NSBezierPath *) spacerBezierForLayer: (int) layer;

@end

NS_ASSUME_NONNULL_END
