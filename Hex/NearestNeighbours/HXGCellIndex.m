//
//  HXGCellIndex.m
//  Hex
//
//  Created by Chris Seez on 28/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGCellIndex.h"

@implementation HXGCellIndex

+ (id) cellWithU:(int) u andV:(int) v {
    
    HXGCellIndex * cellIndex = [[self alloc] initWithU:u andV:v];
    
    
    return cellIndex;
}

- (id)initWithU:(int) u andV:(int) v {
    
    self = [super init];
    _iu = u;
    _iv = v;

    return self;
}

@end
