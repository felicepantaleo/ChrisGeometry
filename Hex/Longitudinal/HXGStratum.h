//
//  HXGStratum.h
//  Hex
//
//  Created by Chris Seez on 01/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGStratum : NSObject 

@property (readonly) NSString * material;
@property (readonly) double thickness;

+ (id) stratumUsing: (NSArray *) s;
@end

NS_ASSUME_NONNULL_END
