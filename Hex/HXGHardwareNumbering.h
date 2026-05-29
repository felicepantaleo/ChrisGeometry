//
//  HXGHardwareNumbering.h
//  Hex
//
//  Created by Chris Seez on 15/04/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGConstants.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGHardwareNumbering : NSObject {
    
    NSString * hexDirectory;
    int LDUbase[198],LDVbase[198];
    int LDPUbase[212],LDPVbase[212];
    int HDUbase[444],HDVbase[444];
    int HDPUbase[468],HDPVbase[468];
    
    BOOL LDcbase[198];
    BOOL LDPcbase[212];
    BOOL HDcbase[444];
    BOOL HDPcbase[468];
    
    BOOL LDsplitBase[212];
    BOOL HDsplitBase[468];

}

@property (readonly) NSArray * LDmap;
@property (readonly) NSArray * HDmap;
@property (readonly) NSArray * LDPmap;
@property (readonly) NSArray * HDPmap;
@property (readonly) int * LDU;
@property (readonly) int * HDU;
@property (readonly) int * LDPU;
@property (readonly) int * HDPU;
@property (readonly) int * LDV;
@property (readonly) int * HDV;
@property (readonly) int * LDPV;
@property (readonly) int * HDPV;

@property (readonly) BOOL * LDcFlag;
@property (readonly) BOOL * HDcFlag;
@property (readonly) BOOL * LDPcFlag;
@property (readonly) BOOL * HDPcFlag;

@property (readonly) BOOL * LDsplit;
@property (readonly) BOOL * HDsplit;


+ (id) sharedHardwareNumbering;

- (void) storeMap: (NSMutableArray *) map forDens:(BOOL) dens andPartial: (BOOL) part;

@end

NS_ASSUME_NONNULL_END
