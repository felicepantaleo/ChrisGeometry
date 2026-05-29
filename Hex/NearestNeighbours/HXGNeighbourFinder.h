//
//  HXGNeighbourFinder.h
//  Hex
//
//  Created by Chris Seez on 25/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXGDetIdInterface.h"
#import "HXGWafer.h"       
#import "HGCTerminalControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGNeighbourFinder : NSObject {

    HXGDetIdInterface * theDetInterface;
    HGCTerminalControl * theTerminal;
    
    int detIdVec[8];
    
    int iuEdgeLD[45];
    int ivEdgeLD[45];
    int sideLD[45];
    
    int iuEdgeHD[69];
    int ivEdgeHD[69];
    int sideHD[69];

    // ---- not relevant for CMSSW implementation
    int combo[6][6];

}


+ (id) sharedNeighbourFinder;

- (int *) nearestNeighboursOfDetId:(int) DetId;

// The method edgeIndexForU:(int)iu andV:(int)iv density:(BOOL)HD
// should not be a Public method in the CMSSW implemention
//
- (int) edgeIndexForU:(int)iu andV:(int)iv density:(BOOL)HD;

// ---- This method is a private investigation method - not for CMSSW implementation
- (void) HDLDcomboTestWithWafers: (NSArray *) waf inLayer:(int) layer ;

@end

NS_ASSUME_NONNULL_END
