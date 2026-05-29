//
//  HXGCuCoolingPlates.h
//  Hex
//
//  Created by Chris Seez on 12/11/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "HGCTerminalControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGCuCoolingPlates : NSObject {
    
    HGCTerminalControl * theTerminal;
    
    NSArray * coolingCuCEEx[13];
    NSArray * coolingCuCEEy[13];

}

+ (id) sharedCuCoolingPlates;
- (void) listPolygons;
- (NSBezierPath *) bezierCuCEEforCasLayer: (int) clayer;


@end

NS_ASSUME_NONNULL_END
