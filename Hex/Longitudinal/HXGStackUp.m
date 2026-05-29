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

const int siOdd = 11;
const int siEven = 17;

const int siCEH = 7;

@implementation HXGStackUp

+ (id) sharedStackUp {
    
    static dispatch_once_t pred;
    static HXGStackUp * theStackUp = nil;
    
    dispatch_once(&pred, ^{ theStackUp = [[self alloc] init]; });
    return theStackUp;

}

- (id)init {
    
    materialmodel = @"//    (20240712_PARAMETER_DRAWING_VER_2.1 model used\n//    i.e. v19 material strata)";
    
    _ncassette = 2.;
    [self makeBareModule];
    [self makestrataCEE];
    [self makestrataCEHsi];
    [self makestrataCEHscint];
    [self makeVaryThicknesses];
    [self sumThickness];
    [self sumCEHFineAndCoarse];

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
    HXGStratum * s11 = bareModuleStrata[2];      // i.e. const int siOdd = 11;
    HXGStratum * s12 = bareModuleStrata[3];
    HXGStratum * s13 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    
    HXGStratum * s14 = [HXGStratum stratumUsing:@[@"Cu",@6.050]];
    
    HXGStratum * s15 = [HXGStratum stratumUsing:@[@"WCu",@1.400]];
    HXGStratum * s16 = bareModuleStrata[3];
    HXGStratum * s17 = bareModuleStrata[2];   // i.e. const int siEven = 17;
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


    HXGStratum * s9 = [HXGStratum stratumUsing:@[@"Ti",@1.05]];  // Changed to Ti (22 Oct 2024)
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

- (void) sumCEHFineAndCoarse {

    /*   ------------------------------------------------------------
         These sums do NOT include Si thickness (unlike SumThickness)
         ------------------------------------------------------------ */

    int i = 1; // Typical CEH fine layer
    _x0CEHcasFine = [_varyAbsorberCEH[i] doubleValue]*0.1/[materials x0For:@"inox"];
    _lambdaCEHcasFine = [_varyAbsorberCEH[i] doubleValue]*0.1/[materials lambdaFor:@"inox"];
    _dEdxCEHcasFine = [_varyAbsorberCEH[i] doubleValue]*0.1*[materials dEdxFor:@"inox"];
    
    i = (int)_varyAbsorberCEH.count - 1; // Typical CEH coarse layer
    _x0CEHcasCoarse = [_varyAbsorberCEH[i] doubleValue]*0.1/[materials x0For:@"inox"];
    _lambdaCEHcasCoarse = [_varyAbsorberCEH[i] doubleValue]*0.1/[materials lambdaFor:@"inox"];
    _dEdxCEHcasCoarse = [_varyAbsorberCEH[i] doubleValue]*0.1*[materials dEdxFor:@"inox"];

    double x0 = 0.;
    double lam = 0.;
    double dEdx = 0.;
    for(int j=1; j<_strataCEHsi.count;j++) {
        if(j == siCEH) continue;                  // --- Don't include Si
        HXGStratum * s = _strataCEHsi[j];
        x0 += s.thickness*0.1/[materials x0For:s.material];
        lam += s.thickness*0.1/[materials lambdaFor:s.material];
        dEdx += s.thickness*0.1*[materials dEdxFor:s.material];
    }
    
    _x0CEHcasFine += x0;
    _lambdaCEHcasFine += lam;
    _dEdxCEHcasFine += dEdx;
    _x0CEHcasCoarse += x0;
    _lambdaCEHcasCoarse += lam;
    _dEdxCEHcasCoarse += dEdx;

}

- (void) sumOddEvenCassette {
   
/*   ------------------------------------------------------------
     These sums do NOT include Si thickness (unlike SumThickness)
     ------------------------------------------------------------ */
    
    _x0Odd = 0.;
    _x0Even = 0.;
    _dEdxOdd = 0.;
    _dEdxEven = 0.;
    
    for (int i=0; i<siOdd; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[_ncassette-1] doubleValue];
        if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[_ncassette-1] doubleValue];
        _x0Odd += x*0.1/[materials x0For:s.material];
        _dEdxOdd += x*0.1*[materials dEdxFor:s.material];
    }
    if(_ncassette != 1) {
        for (int i=siEven+1; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Odd += x*0.1/[materials x0For:s.material];
            _dEdxOdd += x*0.1*[materials dEdxFor:s.material];
        }
    }
    
    for (int i=siOdd+1; i<siEven; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        _x0Even += x*0.1/[materials x0For:s.material];
        _dEdxEven += x*0.1*[materials dEdxFor:s.material];
    }

}


#pragma mark - Terminal display calls

- (void) layerdEdx {

    double dEdxLayer[47];
   
    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        //[theTerminal clearString];
    }
    [theTerminal setDarkBackground:YES];
    [theTerminal makeWindowBig];
    theTerminal.suggestedName = @"layerdEdx";

#ifdef DEBUG
    [theTerminal displayString:@"FULL DEBUG LISTING\n\n"];
    for (int i=0; i<_strataCEE.count; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
        [theTerminal displayString:[NSString stringWithFormat:@"strataCEE: %d %.3f %@\n",i,x,s.material]];
    }
    [theTerminal displayString:@"\n\n"];
#endif

    //------ loop over CEE cassettes
    for (int icas=0; icas<13; icas++) {
        //--- Odd cassettes
        dEdxLayer[2*icas] = 0.;
        for (int i=0; i<siOdd; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[_ncassette-1] doubleValue];
            dEdxLayer[2*icas] += x*0.1*[materials dEdxFor:s.material];
#ifdef DEBUG
            if(icas == 0) [theTerminal displayString:[NSString stringWithFormat:@"Odd layers: %.3f %.3f %@ - FIRST LAYER\n",x,[materials dEdxFor:s.material],s.material]];
#endif
        }
        //--- add on the "after the second wafer" for all except 1st cassette
        if(icas > 0) {
            for (int i=siEven+1; i<_strataCEE.count; i++) {
                HXGStratum * s = _strataCEE[i];
                double x = s.thickness;
                dEdxLayer[2*icas] += x*0.1*[materials dEdxFor:s.material];
#ifdef DEBUG
                if(icas == 1) [theTerminal displayString:[NSString stringWithFormat:@"Odd layers: %.3f %@\n",x,s.material]];
#endif
            }
        }
#ifdef DEBUG
        [theTerminal displayString:@"\n\n"];
#endif
        //--- Even cassettes
        dEdxLayer[2*icas+1] = 0.;
        for (int i=siOdd+1; i<siEven; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            _x0Even += x*0.1/[materials x0For:s.material];
            dEdxLayer[2*icas+1] += x*0.1*[materials dEdxFor:s.material];
#ifdef DEBUG
            if(icas == 1) [theTerminal displayString:[NSString stringWithFormat:@"Even layers: %.3f %@\n",x,s.material]];
#endif
        }
    }

    [theTerminal displayString:@"\n\n"];

#ifdef DEBUG
            [theTerminal displayString:@"\nStrata for Layer 27:\n"];
#endif

    //---- Layer 27: first layer of CEH
    //--- "after the second wafer" of the last CEE layer
    dEdxLayer[26] = 0.;
    for (int i=siEven+1; i<_strataCEE.count; i++) {
        HXGStratum * s = _strataCEE[i];
        double x = s.thickness;
#ifdef DEBUG
            [theTerminal displayString:[NSString stringWithFormat:@"%@ %5.3f\n",s.material,x]];
#endif
        dEdxLayer[26] += x*0.1*[materials dEdxFor:s.material];
    }

    //--- Add the first CEH up to the Si
    double x = [_varyAbsorberCEH[0] doubleValue];
    dEdxLayer[26] += x*0.1*[materials dEdxFor:@"inox"];
#ifdef DEBUG
            [theTerminal displayString:[NSString stringWithFormat:@"inox %5.3f\n",x]];
#endif
    for (int i=1; i<7; i++) {
        HXGStratum * s = _strataCEHsi[i];
        double x = s.thickness;
        dEdxLayer[26] += x*0.1*[materials dEdxFor:s.material];
#ifdef DEBUG
            [theTerminal displayString:[NSString stringWithFormat:@"%@ %5.3f\n",s.material,x]];
#endif
    }
             
#ifdef DEBUG
            [theTerminal displayString:@"\n--------------------\n"];
#endif

    //------ CEH loop
    for (int ic=1; ic<21; ic++) {
        int layer = ic + 26;
        dEdxLayer[layer] = 0.;
        //--- The absorber
        dEdxLayer[layer] += [_varyAbsorberCEH[ic] doubleValue]*0.1*[materials dEdxFor:@"inox"];
        //--- Up to Si in this layer; plus "after the wafer" of the previous layer
        //    equivalent to everything except 0=absorber, and 8=wafer
        for (int i=1; i<_strataCEHsi.count; i++) {
            if(i != 7) {
                HXGStratum * s = _strataCEHsi[i];
                double x = s.thickness;
                dEdxLayer[layer] += x*0.1*[materials dEdxFor:s.material];
            }
        }
    }
  
    // ---- Now format it in a string (and in DEBUG mode list line by line)
    NSString * textstring = [NSString stringWithFormat:@"\n//--- Integrated dEdx in front of sensor\n%@\ndouble layerdEdx[47] = {",materialmodel];

#ifdef DEBUG
        [theTerminal displayString:@"weightsPerLayer_V19 = cms.vdouble(dummy_weight,\n"];
#endif

    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%5.2f,",dEdxLayer[i]];
#ifdef DEBUG
        [theTerminal displayString:[NSString stringWithFormat:@"                                  %5.2f,\n",dEdxLayer[i]]];
#endif
    }
    textstring = [textstring stringByAppendingFormat:@"%5.2f}; // (MeV)\n",dEdxLayer[46]];
#ifdef DEBUG
        [theTerminal displayString:[NSString stringWithFormat:@"                                  %5.2f)\n\n\n",dEdxLayer[46]]];
#endif

    theTerminal.suggestedName = @"LayerDeDx";

    [theTerminal showWindow:self];
    [theTerminal displayString:textstring];
    [theTerminal scrollToBottom];

}

- (void) sensorZ {

    double siZ[47];
    double z = 0;
    int l = 0;
    
    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        //[theTerminal clearString];
    }
    [theTerminal setDarkBackground:YES];
    [theTerminal makeWindowBig];
    theTerminal.suggestedName = @"SensorFrontZ";

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
    
    NSString * textstring = [NSString stringWithFormat:@"\n//--- Si sensor z position (front from front HGCAL z = %.1f)\n%@\ndouble sensorZ[47] = {",z0,materialmodel];

    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",siZ[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f}; // (mm)\n",siZ[46]];


    [theTerminal displayString:textstring];
    
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal thickness = %8.3f\nPoint 6 to point 62 on 20240712_PARAMETER_DRAWING_VER_2.1 Layers Cross Section\n",z]];
    [theTerminal scrollToBottom];

}

- (void) absorberFronts {

    double frontCEE[13];
    double frontCEH[21];
    double z = 0;
    double z0 = 3210.5;

    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        //[theTerminal clearString];
    }
    [theTerminal setDarkBackground:YES];
    [theTerminal makeWindowBig];
    theTerminal.suggestedName = @"AbsorberFrontZ";

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
   
    NSString * textstring = [NSString stringWithFormat:@"\n//--- Front face of CEE cassettes\n//    Checked against 20240712_PARAMETER_DRAWING_VER_2.1\n%@\ndouble frontCEE[13] = {",materialmodel];

    for (int i=0; i<12; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",frontCEE[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f} // (mm)\n",frontCEE[12]];

    textstring = [textstring stringByAppendingFormat:@"\n//--- Front face of CEH cassettes\n//    Checked against 20240712_PARAMETER_DRAWING_VER_2.1\n%@\ndouble frontCEH[21] {",materialmodel];

    for (int i=0; i<20; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",frontCEH[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"\n%7.2f}; // (mm)\n",frontCEH[20]];

    [theTerminal displayString:textstring];
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal thickness = %8.3f\n",z]];
    [theTerminal scrollToBottom];

}

- (void) frontBackCEECu {

    double frontCu[13];
    double backCu[13];
    double z = 0;
    double z0 = 3210.5;
    double backZ = 3620.96;
    
    totVolume = 0.;
    
    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        //[theTerminal clearString];
    }
    [theTerminal setDarkBackground:YES];
    [theTerminal makeWindowBig];
    theTerminal.suggestedName = @"CEE Cu cooling plates";

    //------ loop over CEE cassettes
    z = z0;
    for (int icas=0; icas<13; icas++) {
        for (int i=0; i<_strataCEE.count; i++) {
            HXGStratum * s = _strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [_varyAbsorberCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Air"]) x = [_varyAirTolCEE[icas] doubleValue];
            if([s.material isEqualToString:@"Cu"]) frontCu[icas] = z;
            z += x;
            if([s.material isEqualToString:@"Cu"]) backCu[icas] = z;
       }
    }
   
    NSString * textstring = [NSString stringWithFormat:@"\nFront/back of Zbar pieces\n//    Checked against 20240712_PARAMETER_DRAWING_VER_2.1\n%@\n",materialmodel];
    BOOL blocksWithClearance = YES;
    double clearZ = 0.;
    if(blocksWithClearance) {
        clearZ = 0.1;
        textstring = [NSString stringWithFormat:@"\nFront/back of Zbar pieces\nclearZ = %.3f\n",clearZ];
    }

    //textstring = [textstring stringByAppendingFormat:@"\n 0 %8.3f %8.3f",z0,frontCu[0]-clearZ];
    textstring = [textstring stringByAppendingString:[self textForBar:0 andZ1:z0 andZ2:frontCu[0]-clearZ]];
    for (int i=0; i<12; i++) {
        //textstring = [textstring stringByAppendingFormat:@"\n%2d %8.3f %8.3f",i+1,backCu[i]+clearZ,frontCu[i+1]-clearZ];
        textstring = [textstring stringByAppendingString:[self textForBar:i+1 andZ1:backCu[i]+clearZ andZ2:frontCu[i+1]-clearZ]];
    }
    textstring = [textstring stringByAppendingString:[self textForBar:13 andZ1:backCu[12]+clearZ andZ2:backZ-clearZ]];

    [theTerminal displayString:textstring];
    
    double mass = totVolume*8.02*1.E-3;
    [theTerminal displayString:[NSString stringWithFormat:@"\nTotal volume = %6.2f cm3; %6.2fkg (mass includes sunk in base volume)",totVolume,mass]];
    [theTerminal scrollToBottom];
    
    NSString * tr1 = @"\n\n double r1[14] = {";
    NSString * tr2 = @"\n\n double r2[14] = {";
    NSString * tz1 = @"\n\n double z1[14] = {";
    NSString * tz2 = @"\n\n double z2[14] = {";
    for (int i=0; i<13; i++) {
        tr1 = [tr1 stringByAppendingFormat:@"%.1f,",storeR1[i]];
        tr2 = [tr2 stringByAppendingFormat:@"%.1f,",storeR2[i]];
        tz1 = [tz1 stringByAppendingFormat:@"%.3f,",storeZ1[i]];
        tz2 = [tz2 stringByAppendingFormat:@"%.3f,",storeZ2[i]];
        if(i == 6) {
            tr1 = [tr1 stringByAppendingString:@"\n                  "];
            tr2 = [tr2 stringByAppendingString:@"\n                  "];
            tz1 = [tz1 stringByAppendingString:@"\n                  "];
            tz2 = [tz2 stringByAppendingString:@"\n                  "];
        }
    }
    tr1 = [tr1 stringByAppendingFormat:@"%.1f};",storeR1[13]];
    tr2 = [tr2 stringByAppendingFormat:@"%.1f};",storeR2[13]];
    tz1 = [tz1 stringByAppendingFormat:@"%.3f};",storeZ1[13]];
    tz2 = [tz2 stringByAppendingFormat:@"%.3f};",storeZ2[13]];

    [theTerminal displayString:tr1];
    [theTerminal displayString:tr2];
    [theTerminal displayString:tz1];
    [theTerminal displayString:tz2];

    [theZbarControl showWindow:self];

}

- (NSString *) textForBar: (int) i andZ1: (double) z1 andZ2: (double) z2 {

    storeZ1[i] = z1;
    storeZ2[i] = z2;
    
    double extra[14] = {15.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,6.,20.,38.};
    double tan175 = tan(17.5*M_PI/180.);
    double tan152 = tan(15.2*M_PI/180.);
    double rlen = 67.;
    double wid = 70.;
    double r0base = 1658.8;
    double backZ = 3620.96;
    double sunkInBase = 10.9;
    
    double zmid = (z1 + z2)*0.5;
    double r1 = r0base - (backZ - zmid)*tan175;
    double r2 = r0base - rlen - (backZ - zmid)*tan152;
    r1 += extra[i];
    
    r1 = ((double) ((int)(10.*r1)))*0.1;
    r2 = ((double) ((int)(10.*r2)))*0.1;
    
    storeR1[i] = r1;
    storeR2[i] = r2;


    double volume = (r1-r2)*(z2-z1)*wid*1.E-3;
    if(i == 13) volume *= (z2+sunkInBase-z1)/(z2-z1);
    totVolume += volume;

    NSString * text = [NSString stringWithFormat:@"\n%2d %8.3f %8.3f %6.1f %6.1f (v = %8.2f)",i,z1,z2,r1,r2,volume];
    
    theZbarControl = [HXGZbarControl sharedZbarControl];
    [theZbarControl addZbrick:NSMakeRect(-r1,-z2,r1-r2,z2-z1) index:i];

    return text;
}

@end
