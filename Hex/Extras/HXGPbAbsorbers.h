//
//  HXGPbAbsorbers.h
//  Hex
//
//  Created by Chris Seez on 16/10/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "HGCTerminalControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGPbAbsorbers : NSObject {

    HGCTerminalControl * theTerminal;
    
    NSArray * leadAbsorberAx[13];
    NSArray * leadAbsorberAy[13];
    NSArray * leadAbsorberBx[13];
    NSArray * leadAbsorberBy[13];

}

+ (id) sharedPbAbsorbers;
- (void) listPolygons;
- (NSBezierPath *) bezierAforCassetteLayer: (int) clayer;
- (NSBezierPath *) bezierBforCassetteLayer: (int) clayer;

@end

NS_ASSUME_NONNULL_END
