//
//  HXGStratum.m
//  Hex
//
//  Created by Chris Seez on 01/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStratum.h"

@implementation HXGStratum

+ (id) stratumUsing: (NSArray *) s {
    
    HXGStratum * slf = [[HXGStratum  alloc] init];

    NSString * mat = [s[0] copy];
    double thck = [s[1] doubleValue];
    
    [slf stratumWithMaterial:mat andThickness:thck];
    
    return slf;
}

- (void) stratumWithMaterial: (NSString *) m andThickness: (double) t {
    
    _material = m;
    _thickness = t;
    
}
@end
