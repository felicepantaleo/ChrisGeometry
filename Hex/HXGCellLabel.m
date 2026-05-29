//
//  HXGCellLabel.m
//  Hex
//
//  Created by Chris Seez on 24/01/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGCellLabel.h"

@implementation HXGCellLabel

+ (id) cellLabelForU: (int) iu andV: (int) iv at: (NSPoint) pnt; {
   
    HXGCellLabel * slf = [[HXGCellLabel  alloc] init];
    
    [slf setUpWithU: iu andV: iv at:pnt];
    
    return slf;

}

- (void) setUpWithU: (int) iu andV: (int) iv at: (NSPoint) pnt {
    
    _iu = iu;
    _iv = iv;
    NSString * lab = [NSString stringWithFormat:@"%02d:%02d",iu,iv];

    _label = lab;
    _point = pnt;
    _calib = NO;
}

@end
