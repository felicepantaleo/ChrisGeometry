//
//  HXGStackUp.h
//  Hex
//
//  Created by Chris Seez on 01/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStratum.h"
#import "HGCMaterialProperties.h"
#import "HGCTerminalControl.h"
#import "HXGZbarControl.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGStackUp : NSObject {
    HGCMaterialProperties * materials;
    HGCTerminalControl * theTerminal;
    HXGZbarControl * theZbarControl;
    
    NSArray * bareModuleStrata;
    NSString * materialmodel;
    
    double totVolume;
    double storeZ1[14],storeZ2[14],storeR1[14],storeR2[14];
}

@property (readonly) NSArray * strataCEE;
@property (readonly) NSArray * extraStrataCEE;
@property (readonly) NSArray * strataCEHsi;
@property (readonly) NSArray * strataCEHscint;
@property (readonly) HXGStratum * backDisk;

@property (readonly) NSArray * varyAbsorberCEE;
@property (readonly) NSArray * varyAirTolCEE;
@property (readonly) NSArray * varyAbsorberCEH;

@property (readonly) double zCEE;
@property (readonly) double zCEH;

@property (readonly) double x0CEE;
@property (readonly) double x0CEH;
@property (readonly) double lambdaCEE;
@property (readonly) double lambdaCEH;
@property (readonly) double lambdaBackDisk;

@property (readonly) double dEdxCEE;
@property (readonly) double dEdxCEH;

@property (readonly) double x0Odd;
@property (readonly) double x0Even;
@property (readonly) double dEdxOdd;
@property (readonly) double dEdxEven;

@property (readonly) double x0CEHcasFine;
@property (readonly) double x0CEHcasCoarse;
@property (readonly) double lambdaCEHcasFine;
@property (readonly) double lambdaCEHcasCoarse;
@property (readonly) double dEdxCEHcasFine;
@property (readonly) double dEdxCEHcasCoarse;

@property int ncassette;


+ (id) sharedStackUp;

- (void) sumThickness;

- (void) sumOddEvenCassette;

- (void) layerdEdx;

- (void) sensorZ;

- (void) absorberFronts;

- (void) frontBackCEECu;

@end

NS_ASSUME_NONNULL_END
