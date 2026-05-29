//
//  HXGStackUp.h
//  Hex
//
//  Created by Chris Seez on 01/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStratum.h"
#import "HGCMaterials.h"
#import "HGCTerminalControl.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGStackUp : NSObject {
    HGCMaterials * materials;
    HGCTerminalControl * theTerminal;
}

@property (readonly) NSArray * strataCEE;
@property (readonly) NSArray * extraStrataCEE;
@property (readonly) NSArray * strataCEHsi;
@property (readonly) NSArray * strataCEHscint;
@property (readonly) HXGStratum * backDisk;

@property (readonly) NSArray * varyAbsorberCEE;
@property (readonly) NSArray * varyAbsorberCEH;

@property (readonly) double zCEE;
@property (readonly) double zCEH;

@property (readonly) double x0CEE;
@property (readonly) double x0CEH;
@property (readonly) double lambdaCEE;
@property (readonly) double lambdaCEH;
@property (readonly) double lambdaBackDisk;

@property (readonly) double x0Odd;
@property (readonly) double x0Even;
@property (readonly) double dEdxOdd;
@property (readonly) double dEdxEven;

@property int ncassette;


+ (id) sharedStackUp;

- (void) sumThickness;

- (void) sumOddEvenCassette;

- (void) layerdEdx;

- (void) sensorZ;

- (void) absorberFronts;

@end

NS_ASSUME_NONNULL_END
