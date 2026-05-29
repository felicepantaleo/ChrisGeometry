//
//  HXGStackUp.m
//  Hex
//
//  Created by Chris Seez on 01/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackUp.h"

@interface HXGStackUp ()

@end

@implementation HXGStackUp

+ (id) sharedStackUp {
    
    static dispatch_once_t pred;
    static HXGStackUp * theStackUp = nil;
    
    dispatch_once(&pred, ^{ theStackUp = [[self alloc] init]; });
    return theStackUp;

}

- (id)init {
    
    _ncassette = 2.;
    [self makestrataCEE];
    [self makestrataCEHsi];
    [self makestrataCEHscint];
    [self makeAbsorberThicknesses];
    [self sumThickness];

    return self;
}

#pragma mark - make stack structures

- (void) makestrataCEE {
    
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"Cu",@0.100]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"inox",@0.300]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"epoxy",@0.050]];
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"Pb",@4.970]];
    HXGStratum * s5 = [HXGStratum stratumUsing:@[@"epoxy",@0.050]];
    HXGStratum * s6 = [HXGStratum stratumUsing:@[@"inox",@0.300]];
    HXGStratum * s7 = [HXGStratum stratumUsing:@[@"Cu",@0.100]];
    HXGStratum * s8 = [HXGStratum stratumUsing:@[@"Air",@0.225]];
    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s10 = [HXGStratum stratumUsing:@[@"Air",@3.730]];
    HXGStratum * s11 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s12 = [HXGStratum stratumUsing:@[@"epoxy",@0.075]];
    HXGStratum * s13 = [HXGStratum stratumUsing:@[@"Si",@0.300]];
    HXGStratum * s14 = [HXGStratum stratumUsing:@[@"epoxy",@0.065]];
    HXGStratum * s15 = [HXGStratum stratumUsing:@[@"kapton",@0.265]];
    HXGStratum * s16 = [HXGStratum stratumUsing:@[@"epoxy",@0.065]];
    HXGStratum * s17 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    HXGStratum * s18 = [HXGStratum stratumUsing:@[@"Cu",@6.050]];
    HXGStratum * s19 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    HXGStratum * s20 = [HXGStratum stratumUsing:@[@"epoxy",@0.065]];
    HXGStratum * s21 = [HXGStratum stratumUsing:@[@"kapton",@0.265]];
    HXGStratum * s22 = [HXGStratum stratumUsing:@[@"epoxy",@0.065]];
    HXGStratum * s23 = [HXGStratum stratumUsing:@[@"Si",@0.300]];
    HXGStratum * s24 = [HXGStratum stratumUsing:@[@"epoxy",@0.075]];
    HXGStratum * s25 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s26 = [HXGStratum stratumUsing:@[@"Air",@3.730]];
    HXGStratum * s27 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s28 = [HXGStratum stratumUsing:@[@"Air",@0.225]];
    
    _strataCEE = @[s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,
    s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28];
    
    HXGStratum * e1 = [HXGStratum stratumUsing:@[@"inox",@1.0]];
    HXGStratum * e2 = [HXGStratum stratumUsing:@[@"Air",@1.25]];
    _extraStrataCEE = @[e1,e2];
}
// ---- COULD ADD CEH BACK DISK
- (void) makestrataCEHsi {
    
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"inox",@41.500]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"Air",@4.000]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"inox",@2.500]];
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"Air",@0.400]];
    HXGStratum * s5 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s6 = [HXGStratum stratumUsing:@[@"Air",@3.475]];
    HXGStratum * s7 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s8 = [HXGStratum stratumUsing:@[@"epoxy",@0.075]];
    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"Si",@0.300]];
    HXGStratum * s10 = [HXGStratum stratumUsing:@[@"epoxy",@0.075]];
    HXGStratum * s11 = [HXGStratum stratumUsing:@[@"kapton",@0.100]];
    HXGStratum * s12 = [HXGStratum stratumUsing:@[@"epoxy",@0.075]];
    HXGStratum * s13 = [HXGStratum stratumUsing:@[@"PCB",@1.000]];
    HXGStratum * s14 = [HXGStratum stratumUsing:@[@"Cu",@6.350]];
    
    _strataCEHsi = @[s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14];
    
    _backDisk = [HXGStratum stratumUsing:@[@"inox",@95.4]];

}

- (void) makestrataCEHscint {
    
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"inox",@41.500]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"Air",@4.000]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"inox",@2.500]];
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"Air",@0.400]];
    HXGStratum * s5 = [HXGStratum stratumUsing:@[@"Air",@3.000]];
    HXGStratum * s6 = [HXGStratum stratumUsing:@[@"PCB",@0.200]];
    HXGStratum * s7 = [HXGStratum stratumUsing:@[@"foil",@0.250]];
    HXGStratum * s8 = [HXGStratum stratumUsing:@[@"Scintillator",@3.000]];
    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"foil",@0.250]];
    HXGStratum * s10 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s11 = [HXGStratum stratumUsing:@[@"Cu",@6.350]];

    _strataCEHscint = @[s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11];

}

- (void) makeAbsorberThicknesses {
    
    _varyAbsorberCEE = @[@2.77,@4.97,@4.97,@4.97,@4.97,@4.97,@4.97,@4.97,@4.97,@8.22,@8.22,@8.22,@8.22];
    //NSLog(@"varyAbsorberCEE has %ld entries",_varyAbsorberCEE.count);
    _varyAbsorberCEH = @[@45.,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,
                          @60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7];
    //NSLog(@"varyAbsorberCEH has %ld entries",_varyAbsorberCEH.count);
    
}
#pragma mark - sums and totals

- (void) sumThickness {
  
    if(!materials) materials = [HGCMaterials sharedMaterials];
    
    _zCEE = 0.;
    _x0CEE = 0.;
    _lambdaCEE = 0.;
    for(int i=0; i<_varyAbsorberCEE.count; i++) {
        for (int j=0; j<_strataCEE.count; j++) {
            HXGStratum * s = _strataCEE[j];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[i] doubleValue];
            _zCEE += x;
            _x0CEE += x/[materials x0For:s.material];
            _lambdaCEE += x/[materials lambdaFor:s.material];
        }
    }
    //-- Add back cover on last cassette, and the air gap
        for (int i=0; i<_extraStrataCEE.count; i++) {
            HXGStratum * s = _extraStrataCEE[i];
            _zCEE += s.thickness;
            _x0CEE += s.thickness/[materials x0For:s.material];
            _lambdaCEE += s.thickness/[materials lambdaFor:s.material];
        }

    _zCEH = 0.;
    _x0CEH = 0.;
    _lambdaCEH = 0.;
    for(int i=0; i<_varyAbsorberCEH.count; i++) {
        _zCEH += [_varyAbsorberCEH[i] doubleValue];
        _x0CEH += [_varyAbsorberCEH[i] doubleValue]/[materials x0For:@"inox"];
        _lambdaCEH += [_varyAbsorberCEH[i] doubleValue]/[materials lambdaFor:@"inox"];
       for(int j=1; j<_strataCEHsi.count;j++) {
            HXGStratum * s = _strataCEHsi[j];
            _zCEH += s.thickness;
           _x0CEH += s.thickness/[materials x0For:s.material];
           _lambdaCEH += s.thickness/[materials lambdaFor:s.material];
        }
    }
    
    _lambdaBackDisk = _backDisk.thickness/[materials lambdaFor:_backDisk.material];
    
    //NSLog(@"lambda back disk = %f",_lambdaBackDisk);
    
    //NSLog(@"zCEE = %.2f, zCEH = %.2f, TOTAL = %.2f",_zCEE,_zCEH,_zCEE+_zCEH);
    //NSLog(@"x0CEE = %.2f, x0CEH = %.2f, TOTAL X0 = %.2f",_x0CEE,_x0CEH,_x0CEE+_x0CEH);
    //NSLog(@"lambdaCEE = %.2f, lambdaCEH = %.2f, TOTAL Λ = %.2f",_lambdaCEE,_lambdaCEH,_lambdaCEE+_lambdaCEH);

}

- (void) sumOddEvenCassette {
    
    _x0Odd = 0.;
    _x0Even = 0.;
    _dEdxOdd = 0.;
    _dEdxEven = 0.;
    
    for (int i=0; i<12; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[_ncassette-1] doubleValue];
        _x0Odd += x/[materials x0For:s.material];
        _dEdxOdd += x*[materials dEdxFor:s.material];
    }
    if(_ncassette != 1) {
        for (int i=23; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Odd += x/[materials x0For:s.material];
            _dEdxOdd += x*[materials dEdxFor:s.material];
        }
    }
    
    for (int i=13; i<22; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        _x0Even += x/[materials x0For:s.material];
        _dEdxEven += x*[materials dEdxFor:s.material];
    }

}


#pragma mark - Terminal display calls

- (void) layerdEdx {

    double dEdxLayer[47];
    
    //------ loop over CEE cassettes
    for (int icas=0; icas<13; icas++) {
        //--- Odd cassettes
        dEdxLayer[2*icas] = 0.;
        for (int i=0; i<12; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            dEdxLayer[2*icas] += x*[materials dEdxFor:s.material];
        }
        //--- add on the "after the second wafer" for all except 1st cassette
        if(icas > 0) {
            for (int i=23; i<_strataCEE.count; i++) {
                HXGStratum * s = _strataCEE[i];
                double x = s.thickness;
                dEdxLayer[2*icas] += x*[materials dEdxFor:s.material];
            }
        }
        //--- Even cassettes
        dEdxLayer[2*icas+1] = 0.;
        for (int i=13; i<22; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Even += x/[materials x0For:s.material];
            dEdxLayer[2*icas+1] += x*[materials dEdxFor:s.material];
        }
    }
    
    //---- Layer 26: first layer of CEH
    //--- "after the second wafer" of the last CEE layer
    dEdxLayer[26] = 0.;
    for (int i=23; i<_strataCEE.count; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        dEdxLayer[26] += x*[materials dEdxFor:s.material];
    }
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    double x = s.thickness;
    dEdxLayer[26] += x*[materials dEdxFor:s.material];
    s = _extraStrataCEE[1];
    x = s.thickness;
    dEdxLayer[26] += x*[materials dEdxFor:s.material];
    //--- Add the first CEH up to the Si
    x = [_varyAbsorberCEH[0] doubleValue];
    dEdxLayer[26] += x*[materials dEdxFor:@"inox"];
    for (int i=1; i<8; i++) {
        HXGStratum * s = _strataCEHsi[i];
        double x = s.thickness;
        dEdxLayer[26] += x*[materials dEdxFor:s.material];
    }
    
    //------ CEH loop
    for (int ic=1; ic<21; ic++) {
        int layer = ic + 26;
        dEdxLayer[layer] = 0.;
        //--- The absorber
        dEdxLayer[layer] += [_varyAbsorberCEH[ic] doubleValue]*[materials dEdxFor:@"inox"];
        //--- Up to Si in this layer; plus "after the wafer" of the previous layer
        //    equivalent to everything except 0=absorber, and 8=wafer
        for (int i=1; i<_strataCEHsi.count; i++) {
            if(i != 8) {
                HXGStratum * s = _strataCEHsi[i];
                double x = s.thickness;
                dEdxLayer[layer] += x*[materials dEdxFor:s.material];
            }
        }
    }
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal displayLayerdEdx:dEdxLayer];
    
}

- (void) sensorZ {

    double siZ[47];
    double z = 0;
    double z0 = 3210.5;
    int l = 0;
    
    //------ loop over CEE cassettes
    for (int icas=0; icas<13; icas++) {
        for (int i=0; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Si"]) siZ[l++] = z + z0;
            z += x;
        }
    }
    
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    z += s.thickness;
    s = _extraStrataCEE[1];
    z += s.thickness;
    
    //------ CEH loop
    for (int ic=0; ic<21; ic++) {
        //--- The absorber
        z += [_varyAbsorberCEH[ic] doubleValue];
        for (int i=1; i<_strataCEHsi.count; i++) {
            HXGStratum * s = _strataCEHsi[i];
            if([s.material isEqualToString:@"Si"]) siZ[l++] = z + z0;
            z += s.thickness;
        }
    }
    
    
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal displaySensorZ:siZ];
    
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal thickness = %f\n",z]];
    
}

- (void) absorberFronts {

    double frontCEE[13];
    double frontCEH[21];
    double z = 0;
    double z0 = 3210.5;
    
    //------ loop over CEE cassettes
    for (int icas=0; icas<13; icas++) {
        frontCEE[icas] = z + z0;
        for (int i=0; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            z += x;
        }
    }
    
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    z += s.thickness;
    s = _extraStrataCEE[1];
    z += s.thickness;
    
    //------ CEH loop
    for (int ic=0; ic<21; ic++) {
        frontCEH[ic] = z + z0;
        //--- The absorber
        z += [_varyAbsorberCEH[ic] doubleValue];
        for (int i=1; i<_strataCEHsi.count; i++) {
            HXGStratum * s = _strataCEHsi[i];
            z += s.thickness;
        }
    }
        
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal displaySFrontCEE:frontCEE andCEH:frontCEH];
    
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal thickness = %f\n",z]];

}

@end
