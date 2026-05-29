//
//  HXGCellLabel.m
//  Hex
//
//  Created by Chris Seez on 24/01/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGCellLabel.h"

@implementation HXGCellLabel

+ (id) cellLabel: (NSString *) string at: (NSPoint) pnt {
   
    HXGCellLabel * slf = [[HXGCellLabel  alloc] init];
    
    [slf setUpWithLabel:string at:pnt];
    
    return slf;

}

- (void) setUpWithLabel:(NSString *) string at: (NSPoint) pnt {
    
    _label = string;
    _point = pnt;
}

@end
