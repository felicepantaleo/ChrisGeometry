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

const double z0 = 3210.5;

@implementation HXGStackUp

+ (id) sharedStackUp {
    
    static dispatch_once_t pred;
    static HXGStackUp * theStackUp = nil;
    
    dispatch_once(&pred, ^{ theStackUp = [[self alloc] init]; });
    return theStackUp;

}

- (id)init {
    
    _ncassette = 2.;
    [self makeBareModule];
    [self makestrataCEE];
    [self makestrataCEHsi];
    [self makestrataCEHscint];
    [self makeVaryThicknesses];
    [self sumThickness];

    return self;
}

#pragma mark - make stack structures

- (void) makeBareModule {
    
    HXGStratum * s0 = [HXGStratum stratumUsing:@[@"Hexaboard",@1.300]];
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"epoxy",@0.125]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"Si",@0.300]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"Kapton composite",@0.300]];

    bareModuleStrata = @[s0,s1,s2,s3];

}

- (void) makestrataCEE {
    
    HXGStratum * s0 = [HXGStratum stratumUsing:@[@"Cu",@0.000]];
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"inox",@0.300]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"epoxy",@0.100]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"Pb",@0.0]]; // set by varyAbsorberCEE
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"epoxy",@0.100]];
    HXGStratum * s5 = [HXGStratum stratumUsing:@[@"inox",@0.300]];
    HXGStratum * s6 = [HXGStratum stratumUsing:@[@"Cu",@0.000]];
    
    HXGStratum * s7 = [HXGStratum stratumUsing:@[@"Air",@0.000]]; // set by varyAirTolCEE
    
    HXGStratum * s8 = [HXGStratum stratumUsing:@[@"Si services",@5.060]];
    
    HXGStratum * s9 = bareModuleStrata[0];
    HXGStratum * s10 = bareModuleStrata[1];
    HXGStratum * s11 = bareModuleStrata[2];
    HXGStratum * s12 = bareModuleStrata[3];
    HXGStratum * s13 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    
    HXGStratum * s14 = [HXGStratum stratumUsing:@[@"Cu",@6.050]];
    
    HXGStratum * s15 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    HXGStratum * s16 = bareModuleStrata[3];
    HXGStratum * s17 = bareModuleStrata[2];
    HXGStratum * s18 = bareModuleStrata[1];
    HXGStratum * s19 = bareModuleStrata[0];
    
    HXGStratum * s20 = [HXGStratum stratumUsing:@[@"Si services",@5.060]];
    HXGStratum * s21 = [HXGStratum stratumUsing:@[@"Air",@0.000]]; // set by varyAirTolCEE
    
    _strataCEE = @[s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,
    s15,s16,s17,s18,s19,s20,s21];
    
    HXGStratum * extra = [HXGStratum stratumUsing:@[@"Air",@1.75]];
    _extraStrataCEE = @[extra];
}
// ---- COULD ADD CEH BACK DISK
- (void) makestrataCEHsi {
    
    HXGStratum * s0 = [HXGStratum stratumUsing:@[@"inox",@0.00]]; // set by varyAbsorberCEH
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"Air",@4.02]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"inox",@2.000]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"Air",@1.045]];
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"Si services",@5.060]];
    
    HXGStratum * s5 = bareModuleStrata[0];
    HXGStratum * s6 = bareModuleStrata[1];
    HXGStratum * s7 = bareModuleStrata[2];
    HXGStratum * s8 = bareModuleStrata[3];


    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"Cfibre",@1.05]];  // CFibre
    HXGStratum * s10 = [HXGStratum stratumUsing:@[@"Cu",@6.350]];
    
    _strataCEHsi = @[s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10];
    
    _backDisk = [HXGStratum stratumUsing:@[@"inox",@95.4]];

}

- (void) makestrataCEHscint {
    
    HXGStratum * s0 = [HXGStratum stratumUsing:@[@"inox",@0.00]]; // set by varyAbsorberCEH
    HXGStratum * s1 = [HXGStratum stratumUsing:@[@"Air",@4.02]];
    HXGStratum * s2 = [HXGStratum stratumUsing:@[@"inox",@2.000]];
    HXGStratum * s3 = [HXGStratum stratumUsing:@[@"Air",@1.045]];
    HXGStratum * s4 = [HXGStratum stratumUsing:@[@"Tile services",@2.835]]; // -> Tile services
    HXGStratum * s5 = [HXGStratum stratumUsing:@[@"PCB",@0.200]];
    HXGStratum * s6 = [HXGStratum stratumUsing:@[@"foil",@0.250]];
    HXGStratum * s7 = [HXGStratum stratumUsing:@[@"Scintillator",@3.000]];
    HXGStratum * s8 = [HXGStratum stratumUsing:@[@"foil",@0.250]];
    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"PCB",@1.600]];
    HXGStratum * s10 = [HXGStratum stratumUsing:@[@"Cu",@6.350]];

    _strataCEHscint = @[s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10];

}

- (void) makeVaryThicknesses {
    
    _varyAbsorberCEE = @[@2.30,@4.00,@4.00,@4.00,@4.00,@4.00,@4.00,@4.00,@4.00,@7.30,@7.30,@7.30,@7.30];
    _varyAirTolCEE = @[@1.375,@1.375,@1.375,@1.375,@1.375,@1.375,@1.375,@1.375,@1.375,@1.35,@1.35,@1.35,@1.35];
    //NSLog(@"varyAbsorberCEE has %ld entries",_varyAbsorberCEE.count);
    _varyAbsorberCEH = @[@45.,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,@41.5,
                          @60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7,@60.7];
    //NSLog(@"varyAbsorberCEH has %ld entries",_varyAbsorberCEH.count);
    
}
#pragma mark - sums and totals

- (void) sumThickness {
  
    if(!materials) materials = [HGCMaterialProperties sharedMaterials];
    
    _zCEE = 0.;
    _x0CEE = 0.;
    _dEdxCEE = 0.;
    _lambdaCEE = 0.;
    for(int i=0; i<_varyAbsorberCEE.count; i++) {
        for (int j=0; j<_strataCEE.count; j++) {
            HXGStratum * s = _strataCEE[j];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[i] doubleValue];
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[i] doubleValue];
            _zCEE += x;
            _x0CEE += x*0.1/[materials x0For:s.material];
            _lambdaCEE += x*0.1/[materials lambdaFor:s.material];
            _dEdxCEE += x*0.1*[materials dEdxFor:s.material];
        }
    }
    //-- Add back cover on last cassette, and the air gap
        for (int i=0; i<_extraStrataCEE.count; i++) {
            HXGStratum * s = _extraStrataCEE[i];
            _zCEE += s.thickness;
            _x0CEE += s.thickness*0.1/[materials x0For:s.material];
            _lambdaCEE += s.thickness*0.1/[materials lambdaFor:s.material];
            _dEdxCEE += s.thickness*0.1*[materials dEdxFor:s.material];
            //NSLog(@"CEE extraStratum %d is %.1f thick",i,s.thickness);
            //NSLog(@"Made of material %@ and has λ = %.2f\n-----",s.material,s.thickness/[materials lambdaFor:s.material]);
        }

    _zCEH = 0.;
    _x0CEH = 0.;
    _lambdaCEH = 0.;
    _dEdxCEH = 0.;
    for(int i=0; i<_varyAbsorberCEH.count; i++) {
        _zCEH += [_varyAbsorberCEH[i] doubleValue];
        _x0CEH += [_varyAbsorberCEH[i] doubleValue]*0.1/[materials x0For:@"inox"];
        _lambdaCEH += [_varyAbsorberCEH[i] doubleValue]*0.1/[materials lambdaFor:@"inox"];
        _dEdxCEH += [_varyAbsorberCEH[i] doubleValue]*0.1*[materials dEdxFor:@"inox"];
       for(int j=1; j<_strataCEHsi.count;j++) {
            HXGStratum * s = _strataCEHsi[j];
           _zCEH += s.thickness;
           _x0CEH += s.thickness*0.1/[materials x0For:s.material];
           _lambdaCEH += s.thickness*0.1/[materials lambdaFor:s.material];
           _dEdxCEH += s.thickness*0.1*[materials dEdxFor:s.material];
        }
    }
    
    _lambdaBackDisk = _backDisk.thickness*0.1/[materials lambdaFor:_backDisk.material];
    
    //NSLog(@"lambda back disk = %f",_lambdaBackDisk);
    
    //NSLog(@"zCEE = %.2f, zCEH = %.2f, TOTAL = %.2f",_zCEE,_zCEH,_zCEE+_zCEH);
    //NSLog(@"x0CEE = %.2f, x0CEH = %.2f, TOTAL X0 = %.2f",_x0CEE,_x0CEH,_x0CEE+_x0CEH);
    //NSLog(@"lambdaCEE = %.2f, lambdaCEH = %.2f, TOTAL Λ = %.2f",_lambdaCEE,_lambdaCEH,_lambdaCEE+_lambdaCEH);
    
    //NSLog(@"dEdxCEE = %.2f MeV",_dEdxCEE);

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
        if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[_ncassette-1] doubleValue];
        _x0Odd += x*0.1/[materials x0For:s.material];
        _dEdxOdd += x*0.1*[materials dEdxFor:s.material];
    }
    if(_ncassette != 1) {
        for (int i=23; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Odd += x*0.1/[materials x0For:s.material];
            _dEdxOdd += x*0.1*[materials dEdxFor:s.material];
        }
    }
    
    for (int i=13; i<22; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        _x0Even += x*0.1/[materials x0For:s.material];
        _dEdxEven += x*0.1*[materials dEdxFor:s.material];
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
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[_ncassette-1] doubleValue];
            dEdxLayer[2*icas] += x*0.1*[materials dEdxFor:s.material];
        }
        //--- add on the "after the second wafer" for all except 1st cassette
        if(icas > 0) {
            for (int i=23; i<_strataCEE.count; i++) {
                HXGStratum * s = _strataCEE[i];
                double x = s.thickness;
                dEdxLayer[2*icas] += x*0.1*[materials dEdxFor:s.material];
            }
        }
        //--- Even cassettes
        dEdxLayer[2*icas+1] = 0.;
        for (int i=13; i<22; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Even += x*0.1/[materials x0For:s.material];
            dEdxLayer[2*icas+1] += x*0.1*[materials dEdxFor:s.material];
        }
    }
    
    //---- Layer 26: first layer of CEH
    //--- "after the second wafer" of the last CEE layer
    dEdxLayer[26] = 0.;
    for (int i=23; i<_strataCEE.count; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        dEdxLayer[26] += x*0.1*[materials dEdxFor:s.material];
    }
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    double x = s.thickness;
    dEdxLayer[26] += x*0.1*[materials dEdxFor:s.material];
    //s = _extraStrataCEE[1];
    //x = s.thickness;
    //dEdxLayer[26] += x*[materials dEdxFor:s.material];
    //--- Add the first CEH up to the Si
    x = [_varyAbsorberCEH[0] doubleValue];
    dEdxLayer[26] += x*0.1*[materials dEdxFor:@"inox"];
    for (int i=1; i<8; i++) {
        HXGStratum * s = _strataCEHsi[i];
        double x = s.thickness;
        dEdxLayer[26] += x*0.1*[materials dEdxFor:s.material];
    }
    
    //------ CEH loop
    for (int ic=1; ic<21; ic++) {
        int layer = ic + 26;
        dEdxLayer[layer] = 0.;
        //--- The absorber
        dEdxLayer[layer] += [_varyAbsorberCEH[ic] doubleValue]*0.1*[materials dEdxFor:@"inox"];
        //--- Up to Si in this layer; plus "after the wafer" of the previous layer
        //    equivalent to everything except 0=absorber, and 8=wafer
        for (int i=1; i<_strataCEHsi.count; i++) {
            if(i != 8) {
                HXGStratum * s = _strataCEHsi[i];
                double x = s.thickness;
                dEdxLayer[layer] += x*0.1*[materials dEdxFor:s.material];
            }
        }
    }
  
    // ---- Now format it in a string
    NSString * textstring = @"\n//--- Integrated dEdx in front of sensor\ndouble layerdEdx[47] = {";
    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%5.2f,",dEdxLayer[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%5.2f}; // (MeV)\n",dEdxLayer[46]];

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal showWindow:self];
    [theTerminal makeWindowWide];
    [theTerminal displayString:textstring];
    
}

- (void) sensorZ {

    double siZ[47];
    double z = 0;
    int l = 0;
    
    //------ loop over CEE cassettes
    for (int icas=0; icas<13; icas++) {
        for (int i=0; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Si"]) siZ[l++] = z + z0;
            z += x;
        }
    }
    
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    z += s.thickness;
    //s = _extraStrataCEE[1];
    //z += s.thickness;
    
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
    
    NSString * textstring = [   NSString stringWithFormat:@"\n//--- Si sensor z position (front from front HGCAL z = %.1f)\ndouble sensorZ[47] = {",z0];
    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",siZ[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f}; // (mm)\n",siZ[46]];

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal makeWindowWide];
    [theTerminal displayString:textstring];
    
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
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[icas] doubleValue];
            z += x;
        }
    }
    
    //--- Back cover and air
    HXGStratum * s = _extraStrataCEE[0];
    z += s.thickness;
    //s = _extraStrataCEE[1];
    //z += s.thickness;
    
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
   
    NSString * textstring = @"\n//--- Front face of CEE cassettes\ndouble frontCEE[13] = {";
    for (int i=0; i<12; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",frontCEE[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f} // (mm)\n",frontCEE[12]];

    textstring = [textstring stringByAppendingString:@"\n//--- Front face of CEH absorbers\ndouble frontCEH[21] {"];
    for (int i=0; i<20; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",frontCEH[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f}; // (mm)\n",frontCEH[20]];

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal makeWindowWide];
    [theTerminal displayString:textstring];
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal thickness = %f\n",z]];

}

@end
