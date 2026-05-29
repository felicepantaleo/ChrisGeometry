//
//  HXGHardwareNumbering.m
//  Hex
//
//  Created by Chris Seez on 15/04/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGHardwareNumbering.h"

NSString * const fileLD = @"/LDhardwareMap.dat";
NSString * const fileHD = @"/HDhardwareMap.dat";
NSString * const fileLDP = @"/LDPhardwareMap.dat";
NSString * const fileHDP = @"/HDPhardwareMap.dat";

@implementation HXGHardwareNumbering

+ (id) sharedHardwareNumbering {
    
    static dispatch_once_t pred;
    static HXGHardwareNumbering * theHardwareNumbering = nil;
    
    dispatch_once(&pred, ^{theHardwareNumbering = [[self alloc] init]; });
    return theHardwareNumbering;
    
}

- (id)init {
  
    BOOL diskMaps = NO;
    
    self = [super init];

    hexDirectory = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:hexHome];
    //NSLog(@"HXGHardwareNumbering init: directory is %@",hexDirectory);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm changeCurrentDirectoryPath:hexDirectory]) {
        NSLog(@"HXGHardwareNumbering storeMapForDens: directory problem...");
    }
    
    _LDU  = LDUbase;
    _LDV  = LDVbase;
    _LDPU = LDPUbase;
    _LDPV = LDPVbase;
    _HDU  = HDUbase;
    _HDV  = HDVbase;
    _HDPU = HDPUbase;
    _HDPV = HDPVbase;
    _LDcFlag  = LDcbase;
    _LDPcFlag = LDPcbase;
    _HDcFlag  = HDcbase;
    _HDPcFlag = HDPcbase;
    _LDsplit = LDsplitBase;
    _HDsplit = HDsplitBase;

    if(diskMaps) [self retrieveMapsFromDisk];
    else [self retrieveMaps];
    
    [self unpackMaps];
    
    return self;
}

- (void) retrieveMaps {
  
    NSString * file;
    NSString * path;
    NSError * err;
    NSURL * arrayURL;

    file = [fileLD substringFromIndex:1];
    file = [file substringToIndex:file.length-4];
    path = [[NSBundle mainBundle] pathForResource:file ofType:@"dat"];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _LDmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileLD,err);

    file = [fileHD substringFromIndex:1];
    file = [file substringToIndex:file.length-4];
    path = [[NSBundle mainBundle] pathForResource:file ofType:@"dat"];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _HDmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileHD,err);

    file = [fileLDP substringFromIndex:1];
    file = [file substringToIndex:file.length-4];
    path = [[NSBundle mainBundle] pathForResource:file ofType:@"dat"];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _LDPmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileLDP,err);

    file = [fileHDP substringFromIndex:1];
    file = [file substringToIndex:file.length-4];
    path = [[NSBundle mainBundle] pathForResource:file ofType:@"dat"];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _HDPmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileHDP,err);

}

- (void) retrieveMapsFromDisk {

    
    NSString * path;
    NSError * err;
    NSURL * arrayURL;
    
    path = [hexDirectory stringByAppendingString:fileHDP];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _HDPmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileHDP,err);
    //else NSLog(@"Read %ld from file %@",_HDPmap.count,fileHDP);
    
    path = [hexDirectory stringByAppendingString:fileHD];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _HDmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileHD,err);
    //else NSLog(@"Read %ld from file %@",_HDmap.count,fileHD);

    path = [hexDirectory stringByAppendingString:fileLDP];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _LDPmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileLDP,err);
    //else NSLog(@"Read %ld from file %@",_LDPmap.count,fileLDP);

    path = [hexDirectory stringByAppendingString:fileLD];
    arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    _LDmap = [NSArray arrayWithContentsOfURL:arrayURL error:&err];
    if(err) NSLog(@"Error reading %@: %@",fileLD,err);
    //else NSLog(@"Read %ld from file %@",_LDmap.count,fileLD);

}

- (void) unpackMaps {
    
    NSString * previous = @"";
    
    for (int i=0; i<_LDmap.count; i++) {
        _LDcFlag[i] = NO;
        _LDU[i] = [[_LDmap[i] substringToIndex:2] intValue];
        _LDV[i] = [[_LDmap[i] substringFromIndex:2] intValue];
        if([_LDmap[i] isEqualToString:previous]) _LDcFlag[i] = YES;
        previous = [NSString stringWithString:_LDmap[i]];
    }
    
    for (int i=0; i<_LDPmap.count; i++) {
        _LDPcFlag[i] = NO;
        _LDPU[i] = [[_LDPmap[i] substringToIndex:2] intValue];
        _LDPV[i] = [[_LDPmap[i] substringFromIndex:2] intValue];
        if([_LDPmap[i] isEqualToString:previous]) _LDPcFlag[i] = YES;
        previous = [NSString stringWithString:_LDPmap[i]];
    }
    
    for (int i=0; i<_HDmap.count; i++) {
        _HDcFlag[i] = NO;
        _HDU[i] = [[_HDmap[i] substringToIndex:2] intValue];
        _HDV[i] = [[_HDmap[i] substringFromIndex:2] intValue];
        if([_HDmap[i] isEqualToString:previous])  _HDcFlag[i] = YES;
        previous = [NSString stringWithString:_HDmap[i]];
    }

    for (int i=0; i<_HDPmap.count; i++) {
        _HDPcFlag[i] = NO;
        _HDPU[i] = [[_HDPmap[i] substringToIndex:2] intValue];
        _HDPV[i] = [[_HDPmap[i] substringFromIndex:2] intValue];
        if([_HDPmap[i] isEqualToString:previous])  _HDPcFlag[i] = YES;
        previous = [NSString stringWithString:_HDPmap[i]];
    }

    int ldpartialcalib[6] = {13,65,90,149,160,169};
    int hdpartialcalib[12] = {31,39,114,139, 146,221,253,306, 335,385,426,433};

    _LDsplit = LDsplitBase;
    for (int i=0; i<212; i++) {
        _LDsplit[i] = NO;
        if(_LDPcFlag[i]) {
            BOOL listed = NO;
            for (int j=0; j<6; j++) {
                if(ldpartialcalib[j] == i+1) listed = YES;
            }
            if(!listed) {
                _LDPcFlag[i] = NO;
                _LDsplit[i] = YES;
            }
        }
    }

    _HDsplit = HDsplitBase;
    for (int i=0; i<468; i++) {
        _HDsplit[i] = NO;
        if(_HDPcFlag[i]) {
            BOOL listed = NO;
            for (int j=0; j<12; j++) {
                if(hdpartialcalib[j] == i+1) listed = YES;
            }
            if(!listed) {
                _HDPcFlag[i] = NO;
                _HDsplit[i] = YES;
            }
        }
    }


}
- (void) storeMap: (NSMutableArray *) map forDens:(BOOL) dens andPartial: (BOOL) part {
 
    NSString * path;
    NSArray * array;
    if(dens) {
        if(part) {
            path = [hexDirectory stringByAppendingString:fileHDP];
            _HDPmap = [NSArray arrayWithArray:map];
            array = _HDPmap;
        } else {
            path = [hexDirectory stringByAppendingString:fileHD];
            _HDmap = [NSArray arrayWithArray:map];
            array = _HDmap;
        }
    } else {
        if(part) {
            path = [hexDirectory stringByAppendingString:fileLDP];
            _LDPmap = [NSArray arrayWithArray:map];
            array = _LDPmap;
        } else {
            path = [hexDirectory stringByAppendingString:fileLD];
            _LDmap = [NSArray arrayWithArray:map];
            array = _LDmap;
        }
    }
    
    NSLog(@"Writing hardware map to: %@",path);
    
    NSError * err;
    NSURL * arrayURL = [NSURL URLWithString:[@"file://" stringByAppendingString:path]];
    [array writeToURL:arrayURL error:&err];
    if(err) NSLog(@"Error writing: %@",err);

    

}

@end
