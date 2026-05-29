//
//  HGCMaterialProerties.m
//  Lambda
//
//  Created by Chris Seez on 21/05/2018.
//  Adapted/revised/renamed 30/08/2024
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "HGCMaterialProperties.h"

@interface HGCMaterialProperties ()

@end

@implementation HGCMaterialProperties

+ (id) sharedMaterials {
    
    static dispatch_once_t pred;
    static HGCMaterialProperties * theMaterials = nil;
    
    dispatch_once(&pred, ^{ theMaterials = [[self alloc] init]; });
    return theMaterials;

}

- (id)init {
    
    textstring = @"";
    [self buildDatabase];
    //if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];

    return self;
}

- (void) showMaterials {
    
    textstring = @"-----------------------------------------------------\n";
    textstring = [textstring stringByAppendingString:
                 @"                 M A T E R I A L S                   \n"];
    textstring = [textstring stringByAppendingString:
                 @"-----------------------------------------------------\n\n"];
    textstring = [textstring stringByAppendingString:
                 @"        Material        X0         λ     dE/dx  CMSSWname\n"];
    
    for (int i=0; i<material.count; i++) {
        NSString * matStr = material[i];
        NSString * cmsStr = @"";
        if(i<cmsswname.count) cmsStr = cmsswname[i];
        if([self rhoFor:matStr] < 1.E-9) continue;
        double x0 = [self x0For:matStr];
        double lam = [self lambdaFor:matStr];
        double dedx = [self dEdxFor:matStr];
        int npad = 16 - (int) [matStr length];
        NSString * pad = @"";
        for (int j=0; j<npad; j++) { pad = [pad stringByAppendingString:@" "];}
        textstring = [textstring stringByAppendingFormat:@"%@%@ %9.4g %9.4g %9.5g  %@\n",pad,matStr,x0,lam,dedx,cmsStr];
    }
    textstring = [textstring stringByAppendingString:@"\nUnits: cm and MeV"];
    textstring = [textstring stringByAppendingString:
                  @"\n\n----------------------------------------------------------------------"];

    // ---- Then do a comlete raw data dump ---
    textstring = [textstring stringByAppendingString:@"\n\nComplete raw data as X0*ρ and λ*ρ and dEdx/ρ (i.e. g/cm2 and MeV cm/g)"];

    textstring = [textstring stringByAppendingString:@"\n\n        Material       X0        λ    dE/dx        ρ\n"];
    
    for (int i=0; i<material.count; i++) {
        NSString * matStr = material[i];
        double x0 = [X0[i] doubleValue];
        double lam = [lambda[i] doubleValue];
        double dedx = [dEdx[i] doubleValue];;
        double dens = [rho[i] doubleValue];;
        int npad = 16 - (int) [matStr length];
        NSString * pad = @"";
        NSString * strDens = [NSString stringWithFormat:@"%8.4g",dens];
        if(dens == 0) strDens = @"       -";
        for (int j=0; j<npad; j++) { pad = [pad stringByAppendingString:@" "];}
        textstring = [textstring stringByAppendingFormat:@"%@%@ %8.4g %8.4g %8.4g %@\n",pad,matStr,x0,lam,dedx,strDens];
    }

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"MaterialProperties";

    [theTerminal showWindow:self];
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal displayString:textstring];
    
}
#pragma mark - principal acessors

- (double) x0For:(NSString *) mat {
 
    if([material indexOfObject:mat] > material.count) {
        NSLog(@"Materialroperties.x0For: %@ does not exist",mat);
        return 1.E9;
    }
    
    int i = (int) [material indexOfObject:mat];
    if([rho[i] doubleValue] < 1.E-9) return 1.E6;
    
    return [X0[i] doubleValue]/[rho[i] doubleValue];
}

- (double) lambdaFor:(NSString *) mat {
 
    if([material indexOfObject:mat] > material.count) {
        NSLog(@"Materialroperties.lambdaFor: %@ does not exist",mat);
        return 1.E9;
    }
    
    int i = (int) [material indexOfObject:mat];
    if([rho[i] doubleValue] < 1.E-9) return 1.E6;
    
    return [lambda[i] doubleValue]/[rho[i] doubleValue];
}

- (double) dEdxFor:(NSString *) mat {
 
    if([material indexOfObject:mat] > material.count) {
        NSLog(@"Materialroperties.dEdxFor: %@ does not exist",mat);
        return 1.E9;
    }
    
    int i = (int) [material indexOfObject:mat];
    if([rho[i] doubleValue] < 1.E-9) return 1.E6;
    
    return [dEdx[i] doubleValue]*[rho[i] doubleValue];
}

- (double) rhoFor:(NSString *) mat {
 
    if([material indexOfObject:mat] > material.count) {
        NSLog(@"Materialroperties.dEdxFor: %@ does not exist",mat);
        return 1.E9;
    }
    
    int i = (int) [material indexOfObject:mat];
    
    return [rho[i] doubleValue];
}

#pragma mark - private methods

- (void) buildDatabase {
    
    material  = [NSMutableArray arrayWithCapacity:20];
    X0        = [NSMutableArray arrayWithCapacity:20];
    lambda    = [NSMutableArray arrayWithCapacity:20];
    dEdx      = [NSMutableArray arrayWithCapacity:20];
    rho       = [NSMutableArray arrayWithCapacity:20];
    cmsswname = [NSMutableArray arrayWithCapacity:20];

    /* -----------------------------------------------------------------------------------
       4 Oct 2024: New setup. Units are MeV, cm, g
       First define the base materials available from PDG 2022
       Materials not directly used assigned 0 value for density
       Values are X0*ρ, λ*ρ, dE/dx/ρ
       ----------------------------------------------------------------------------------- */
    
    //      0    1    2    3    4     5     6     7     8     9     10    11    12    13   14
    [material addObjectsFromArray: @[@"H",@"C",@"N",@"O",@"Si",@"Cl",@"Ti",@"Cr",@"Mn",@"Fe",@"Ni",@"Cu",@"Br",@"W",@"Pb"]];
    
    //      0    1    2    3    4     5     6     7     8     9     10    11    12    13   14
    [X0 addObjectsFromArray:
        @[@63.04,@42.70,@37.99,@34.24,@21.82,@19.28,@16.16,@14.94,@14.64,@13.84,@12.68,
          @12.86,@11.42,@6.76 ,@6.37 ]];
    [lambda addObjectsFromArray: @[@52.00,@85.80,@89.70,@90.20,@108.4,@115.7, @126.2,@129.3,@131.4,@132.1,@134.1,
          @137.3,@147.2,@191.9,@199.6]];
    [dEdx addObjectsFromArray:
        @[@4.034,@1.749,@1.825,@1.801,@1.664,@1.630,@1.477,@1.456,@1.428,@1.451,@1.468,
          @1.403,@1.380,@1.145,@1.122]];
    [rho addObjectsFromArray:
        @[@0    ,@0    ,@0    ,@0    ,@2.329,@0    ,@4.540,@0    ,@0    ,@0    ,@0    ,
          @8.960,@0    ,@0    ,@11.35]];
    [cmsswname addObjectsFromArray: @[@"Hydrogen",@"Carbon",@"Nitrogen",@"Oxygen",@"Silicon",@"Chlorine",@"Titanium",@"Chromium",@"Manganese",@"Iron",@"Nickel",@"Copper",@"Bromine",@"Tungsten",@"Lead"]];

    // --- inox ---
    NSArray * comps = @[@"Fe",@"Cr",@"Ni",@"Mn"];
    NSArray * fracs  = @[@0.70,@0.19,@0.10,@0.01];
    [self addComposite:@"inox;StainlesSteel" withComponents: comps inFractions: fracs andDensity:8.02];
    /*
     This is not, in fact, exactly what is in GEANT, but sufficiently similar to give ~identical result
     GEANT:
     </CompositeMaterial>
     <CompositeMaterial name="StainlessSteel" density="8.02*g/cm3" symbol=" " method="mixture by weight">
      <MaterialFraction fraction="0.6996">
       <rMaterial name="materials:Iron"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.0004">
       <rMaterial name="materials:Carbon"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.01">
       <rMaterial name="materials:Manganese"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.19">
       <rMaterial name="materials:Chromium"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.1">
       <rMaterial name="materials:Nickel"/>
      </MaterialFraction>
     </CompositeMaterial>
     */
    
    // --- WCu ---
    comps = @[@"W" ,@"Cu"];
    fracs = @[@0.75,@0.25];
    [self addComposite:@"WCu;WCu" withComponents: comps inFractions: fracs andDensity:14.98];
    
    // --- PCB --- (M_NEMA FR4 plate)
    comps = @[@"Si" ,@"O"  ,@"C"  ,@"H"  ,@"Br" ];
    fracs = @[@0.181,@0.406,@0.278,@0.068,@0.067];
    [self addComposite:@"PCB;HGC_G10-FR4" withComponents: comps inFractions: fracs andDensity:1.7];
    
    // --- epoxy ---
    comps = @[@"O"  ,@"C"  ,@"H"  ];
    fracs = @[@0.333,@0.535,@0.132];
    [self addComposite:@"epoxy;Epoxy" withComponents: comps inFractions: fracs andDensity:1.3];

    // --- Kapton ---
    comps = @[@"H",@"C",@"N",@"O"];
    fracs = @[@0.026362,@0.691133,@0.073270,@0.209235]; // polyimide PDG values
    [self addComposite:@"Kapton;HGC_Kapton_PDG" withComponents: comps inFractions: fracs andDensity:1.42];
    
    // --- Kapton composite ---
    comps = @[@"Kapton",@"Cu",@"epoxy"];
    fracs = @[@0.422,@0.320,@0.258];
    [self addComposite:@"Kapton composite;HGC_Kapton" withComponents: comps inFractions: fracs andDensity:1.681];
    
    // --- Hexaboard ---
    comps = @[@"PCB",@"Cu"];
    fracs = @[@0.581,@0.419];
    [self addComposite:@"Hexaboard;HGC_Hexaboard" withComponents: comps inFractions: fracs andDensity:2.432];
    
    // --- Polystyrene --- (PDG polystyrene)
    comps = @[@"H",@"C"];
    fracs = @[@0.077,@0.923];
    [self addComposite:@"polystyrene;Polystyrene" withComponents: comps inFractions: fracs andDensity:1.06];
    
    // --- Scintillator --- (PDG polyvinyltoluene [PVT] in GEANT)
    // cast = PVT, moulded = PS; cast are front and centre; moulded are back and large r
    comps = @[@"H",@"C"];
    fracs = @[@0.0848789,@0.91512]; // From Geometry/CMSCommonData/data/materials.xml (!= PDG)
    [self addComposite:@"scintillator;H_Scintillator" withComponents: comps inFractions: fracs andDensity:1.032];

    // --- foil ---
    // foil = PDG polyethelene (NB: Sunanda uses polystyrene for the foil!!
    comps = @[@"H",@"C"];
    fracs = @[@0.144,@0.856];
    [self addComposite:@"foil;Not used" withComponents: comps inFractions: fracs andDensity:0.89];
/*
    // --- Cfibre ---
    //https://indico.cern.ch/event/1373673/contributions/5773709/attachments/2787963/4861245/News26Jan24.pdf
    comps = @[@"epoxy",@"C"];
    fracs = @[@0.5,@0.5];
    [self addComposite:@"Cfibre;Not used" withComponents: comps inFractions: fracs andDensity:1.55];

    // --- dry ice ---
    comps = @[@"C",@"O"];
    fracs = @[@0.272916,@0.727084];
    [self addComposite:@"dry ice;Test" withComponents: comps inFractions: fracs andDensity:1.563];
*/

    // !!!! Make a fakes with density ~ 0 !!!!
    [self addNullMaterial:@"Air"];
    [self addNullMaterial:@"Si services"];
    [self addNullMaterial:@"Tile services"];

}

- (void) addComposite:(NSString *) name withComponents: (NSArray *) comps inFractions: (NSArray *) fracs andDensity: (double) density {
  
    NSArray * names = [name componentsSeparatedByCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@";"]];
    [material addObject:names[0]];
    [cmsswname addObject:names[1]];

    if(density < 1.E-6) {                               // approximately nothing
        [X0 addObject:[NSNumber numberWithDouble:1.E3]];
        [lambda addObject:[NSNumber numberWithDouble:1.E3]];
        [dEdx addObject:[NSNumber numberWithDouble:1.E-3]];
        [rho addObject:[NSNumber numberWithDouble:0.]];
        return;
    }

    double invLen = 0.;
    for (int i=0; i<comps.count; i++) {
        int j = (int)[material indexOfObject:comps[i]];
        if([material indexOfObject:comps[i]] > material.count) {
            NSLog(@"addComposite %@; %d material %@ not found",name,i,comps[i]);
            [self dieGracefully:[NSString stringWithFormat:@"addComposite %@; %d material %@ not found",name,i,comps[i]]];
        }
        invLen += [fracs[i] doubleValue]/[X0[j] doubleValue];
    }
    [X0 addObject:[NSNumber numberWithDouble:1./invLen]];
    
    invLen = 0.;
    for (int i=0; i<comps.count; i++) {
        int j = (int) [material indexOfObject:comps[i]];
        invLen += [fracs[i] doubleValue]/[lambda[j] doubleValue];
    }
    [lambda addObject:[NSNumber numberWithDouble:1./invLen]];
    
    double E = 0.;
    for (int i=0; i<comps.count; i++) {
        int j = (int)[material indexOfObject:comps[i]];
        E += [fracs[i] doubleValue]*[dEdx[j] doubleValue];
    }
    [dEdx addObject:[NSNumber numberWithDouble:E]];
    
    [rho addObject:[NSNumber numberWithDouble:density]];

}

- (void) addNullMaterial: (NSString *) name {
    
    [material addObject:name];
    [X0 addObject:[NSNumber numberWithDouble:1.E3]];
    [lambda addObject:[NSNumber numberWithDouble:1.E3]];
    [dEdx addObject:[NSNumber numberWithDouble:1.E-3]];
    [rho addObject:[NSNumber numberWithDouble:1.E-3]];
    
}
- (void) dieGracefully: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setInformativeText:@"Bailing out - this shouldn't happen..."];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];

}


@end
