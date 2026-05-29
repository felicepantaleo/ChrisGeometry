//
//  HXGCellAreas.h
//  Hex
//
//  Created by Chris Seez on 10/05/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXGPreferenceControl.h"
#import "HGCTerminalControl.h"
#import "HXGHardwareConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGCellAreas : NSObject {
   
    HXGPreferenceControl * thePreferences;
    HGCTerminalControl * theTerminal;
    HXGHardwareConstants * theHardwareConstants;
    
    double waferSize;

    double sqrt3;
    double zoltanDistanceC;
    double edgeInset;
    double activeWafer;

    double waferSide;
    double delta;
    double epsilon;
    double mouseBitePerp;
    double guardWidth;

    double fcell[2],scell[2],acell[2];
//    double whole[2];
    double extended[2], truncated[2];
    double extendedBitten[2], truncatedBitten[2];
    double corner[2];

}

@property NSBezierPath * problemCell;


+ (id) sharedCellAreas;
- (void) calculateCellAreas;
- (void) calculatePartialCellAreas;
@end

NS_ASSUME_NONNULL_END
