//
//  HGCMaterials.m
//  Lambda
//
//  Created by Chris Seez on 21/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "HGCMaterials.h"

@interface HGCMaterials ()

@end

@implementation HGCMaterials

+ (id) sharedMaterials {
    
    static dispatch_once_t pred;
    static HGCMaterials * theMaterials = nil;
    
    dispatch_once(&pred, ^{ theMaterials = [[self alloc] init]; });
    return theMaterials;

}

- (id)init {
    
    self=[super initWithWindowNibName: @"HGCMaterials"];
    textstring = @"";
    [self buildDictionary];

    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
}

- (IBAction) showWindow:(id)sender {
    
    [super showWindow:self];
    
    [_textview setFont:[NSFont fontWithName:@"Menlo" size:11]];
    [_textview setDrawsBackground:YES];
    indigoColor = [NSColor indigoBlue];
    ivoryColor = [NSColor ivoryWhite];

    [_textview setBackgroundColor:ivoryColor];
    [_textview setTextColor:indigoColor];
    
    [_textview setString:textstring];
    
    [_textview setNeedsDisplay:YES];

}


- (void) showMaterials {
    
    NSArray * keys = [dic allKeys];
    int n = (int) [keys count];
    
    // -------- Order by X0 ------------------------------
    int map[15] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14};
    for (int ii=0; ii<n; ii++) {
        for (int i=0; i<n; i++) {
            NSString * matStr = [keys objectAtIndex:map[i]];
            NSArray * a = [dic objectForKey:matStr];
            double X0 = [a[0] doubleValue];
            for (int j=i+1; j<n; j++) {
                matStr = [keys objectAtIndex:map[j]];
                a = [dic objectForKey:matStr];
                double X01 = [a[0] doubleValue];
                if(X01 < X0) {
                    int m = map[i];
                    map[i] = map[j];
                    map[j] = m;
                }
            }
        }
    }
    
    textstring = @"    Material       X0        λ    dE/dx\n";

    for (int i=0; i<n; i++) {
        NSString * matStr = [keys objectAtIndex:map[i]];
        NSArray * a = [dic objectForKey:matStr];
        double X0 = [a[0] doubleValue];
        double lambda = [a[1] doubleValue];
        double dEdx = [a[2] doubleValue];
        int npad = 12 - (int) [matStr length];
        NSString * pad = @"";
        for (int j=0; j<npad; j++) { pad = [pad stringByAppendingString:@" "];}
        textstring = [textstring stringByAppendingFormat:@"%@%@ %8.4g %8.4g %8.3g\n",pad,matStr,X0,lambda,dEdx];
    }
    textstring = [textstring stringByAppendingString:@"\nUnits: mm and MeV"];
    
    [self showWindow:self];
    
}

- (IBAction) printMaterials:(id)sender {
    
    NSPrintOperation *printOperation;
    NSTextView *printview = [[NSTextView alloc] initWithFrame:NSMakeRect(0., 0., 500., 300.)];
    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
    
    NSString * vstamp = [NSString stringWithFormat:@"Hex version %.2f(%d), ",version,build];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-Y"];
    vstamp = [vstamp stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
    vstamp = [vstamp stringByAppendingString:@"\n\n\n"];

    [[[printview textStorage] mutableString] appendString:vstamp];
    [[[printview textStorage] mutableString] appendString:textstring];
    [printview setFont:[NSFont fontWithName:@"Menlo" size:11]];
    //NSRange range = NSMakeRange( 0, [[printview string] length]);
    //[printview setSelectedRange:range];

    printOperation = [NSPrintOperation printOperationWithView:printview];
    
    [printOperation runOperation];

}

#pragma mark - principal acessors

- (double) x0For:(NSString *) material {
    return [self value:0 For:material];
}

- (double) lambdaFor:(NSString *) material {
    return [self value:1 For:material];
}

- (double) dEdxFor:(NSString *) material {
    return [self value:2 For:material];
}

#pragma mark - private methods

- (void) buildDictionary {
    
    mat = @[@"WCu",@"Pb",@"Cu",@"inox",@"Si",@"scintillator",
            @"PCB",@"Air",@"foil",@"epoxy",@"kapton"];
    double X0[11] =   {5.122,5.612,14.36,17.35,93.66,413.1,175.0,3.E5,503.1,1.E6,1.E6};
    double lam[11] =  {119.9,182.6,155.1,166.0,457.5,770.7,484.2,7.E5,881.8,1.E6,1.E6};
    double dEdx[11] = {1.812,1.274,1.257,1.143,0.388,0.205,0.318, 0.0,0.185,0.00,0.00};
    
    // foil = polyethelene

    // Replace with PCB calculation of FR4 from element fractions;  AND fraction by volume Cu layers...
    
    double fraction = 0.0;
    [self calculatePCBwithCu:fraction];
    X0[6]   = PCB[0];
    lam[6]  = PCB[1];
    dEdx[6] = PCB[2];
    
    // Also calculate epoxy and kapton
    [self calculateEpoxy];
    [self calculateKapton];
    X0[9]   = epoxy[0];
    lam[9]  = epoxy[1];
    dEdx[9] = epoxy[2];
    X0[10]   = kapton[0];
    lam[10]  = kapton[1];
    dEdx[10] = kapton[2];

    dic = [NSMutableDictionary dictionaryWithCapacity:10];
    for (int i=0; i<11; i++) {
        NSArray * a = @[@(X0[i]),@(lam[i]),@(dEdx[i])];
        [dic setObject:a forKey:[mat objectAtIndex:i]];
    }
}

- (void) calculateEpoxy {
    /*
     https://github.com/cms-sw/cmssw/blob/master/Geometry/CMSCommonData/data/materials.xml
     
     <CompositeMaterial name="Epoxy" density="1.3*g/cm3" symbol=" " method="mixture by weight">
      <MaterialFraction fraction="0.53539691">
       <rMaterial name="materials:Carbon"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.13179314">
       <rMaterial name="materials:Hydrogen"/>
      </MaterialFraction>
      <MaterialFraction fraction="0.33280996">
       <rMaterial name="materials:Oxygen"/>

     */
      
      double density = 1.3 ; // g/cm3
      
      //NSString * element[5] = {  @"O",  @"C",  @"H"};
      double frac[3]          = {0.3328,0.5354,0.1318};
      // dE/dx, X0, and λ all in cm, from PDG 2018
      double dedxtimes[3]     = { 1.788, 1.742, 4.034};
      double X0per[3]         = { 34.24, 42.70, 92.32};
      double lamper[3]        = {  90.2,  85.8,  71.0};

      double rdE = 0.;
      double x0 = 0.;
      double lam = 0.;
      for (int i=0;i<3;i++) {
          rdE += frac[i]/dedxtimes[i];
          x0  += X0per[i]*frac[i];
          lam += lamper[i]*frac[i];
      }
      
      epoxy[0] = 10.*x0/density;  // NB: convert cm to mm
      epoxy[1] = 10.*lam/density;
      epoxy[2] = 0.1*density/rdE;

}

- (void) calculateKapton {
  /*
   https://github.com/cms-sw/cmssw/blob/master/Geometry/CMSCommonData/data/materials.xml
   
   <CompositeMaterial name="Kapton" density="1.11*g/cm3" symbol=" " method="mixture by weight">
     <MaterialFraction fraction="0.59985105">
      <rMaterial name="materials:Carbon"/>
     </MaterialFraction>
     <MaterialFraction fraction="0.080541353">
      <rMaterial name="materials:Hydrogen"/>
     </MaterialFraction>
     <MaterialFraction fraction="0.31960759">
      <rMaterial name="materials:Oxygen"/>

   */
    
    double density = 1.11 ; // g/cm3
    
    //NSString * element[5] = {  @"O",  @"C",  @"H"};
    double frac[3]          = {0.3196,0.5999,0.0805};
    // dE/dx, X0, and λ all in cm, from PDG 2018
    double dedxtimes[3]     = { 1.788, 1.742, 4.034};
    double X0per[3]         = { 34.24, 42.70, 92.32};
    double lamper[3]        = {  90.2,  85.8,  71.0};

    double rdE = 0.;
    double x0 = 0.;
    double lam = 0.;
    for (int i=0;i<3;i++) {
        rdE += frac[i]/dedxtimes[i];
        x0  += X0per[i]*frac[i];
        lam += lamper[i]*frac[i];
    }
    
    kapton[0] = 10.*x0/density;  // NB: convert cm to mm
    kapton[1] = 10.*lam/density;
    kapton[2] = 0.1*density/rdE;

}
- (void) calculatePCBwithCu:(double)fraction {
    
    /*         NEMA G10 NEMA FR4
     Silicon   21.99    18.08
     Oxygen    41.72    40.56
     Carbon    26.82    27.80
     Hydrogen   6.60     6.85
     Chlorine   2.87
     Bromine             6.71
     See: https://github.com/cms-sw/cmssw/blob/master/Geometry/CMSCommonData/data/materials.xml#L3069-L3102
     (also see Sunanda mail, 3 Jul 18) */
    
    double density = 1.7 ; // g/cm3
    
    //NSString * element[5] = {@"Si",   @"O",  @"C",  @"H", @"Br"};
    double frac[5]          = {0.1808,0.4056,0.2780,0.0685,0.0671};
    double dedxtimes[5]     = { 1.664, 1.788, 1.742, 4.034, 1.380}; // dE/dx, X0, and λ all in cm
    double X0per[5]         = { 21.82, 34.24, 42.70, 92.32, 11.42}; // from PDG 2018
    double lamper[5]        = { 108.4,  90.2,  85.8,  71.0, 147.2};

    double rdE = 0.;
    double x0 = 0.;
    double lam = 0.;
    for (int i=0;i<5;i++) {
        rdE += frac[i]/dedxtimes[i];     // This formula implemented 29 Aug 2018 in version 4.6 (3)
        x0  += X0per[i]*frac[i];
        lam += lamper[i]*frac[i];
    }
    
    double values[3];
    values[0] = 10.*x0/density;  // NB: convert cm to mm
    values[1] = 10.*lam/density;
    values[2] = 0.1*density/rdE;
    
    //NSLog(@"FR4 calculated X0 = %.2f, lambda = %.2f, dE/dx = %.3f",values[0],values[1],values[2]);
    
    // Now make PCB: fraction by volume Cu, 90% FR4
    double Cu[3] = {14.36,153.2,1.257};
    
    for (int i=0;i<2;i++) {
        PCB[i] = 1./(fraction/Cu[i] + (1.-fraction)/values[i]);
    }
    PCB[2] = fraction*Cu[2] + (1.-fraction)*values[2];

}

/* - (double) calculateFR4dEdx {
    
/@         NEMA G10 NEMA FR4
    Silicon   21.99    18.08
    Oxygen    41.72    40.56
    Carbon    26.82    27.80
    Hydrogen   6.60     6.85
    Chlorine   2.87
    Bromine             6.71
 See: https://github.com/cms-sw/cmssw/blob/master/Geometry/CMSCommonData/data/materials.xml#L3069-L3102
 (also see Sunanda mail, 3 Jul 18) @/
    
    double density = 1.7 ; // g/cm3
    
    //NSString * element[5] = {@"Si",   @"O",  @"C",  @"H", @"Cl"};
    double frac[5]        = {0.2199,0.4172,0.2682,0.0660,0.0287};   // GEANT NEMA FR4
    //double A[5]           = {28.086,15.999,12.011, 1.009,35.453};
    //double density[5]     = { 2.329, 1.141,  2.21, 0.071, 1.574};
    double dedxtimes[5]     = { 1.664, 1.788, 1.742, 4.034, 1.608};
    double X0per[5]         = { 21.82, 34.24, 42.70, 92.32, 19.28};
    double lamper[5]        = { 108.4,  90.2,  85.8,  71.0, 115.7};
    
    double rdE = 0.;
    double x0 = 0.;
    double lam = 0.;
    for (int i=0;i<5;i++) {
        rdE += frac[i]/dedxtimes[i];     // This formula implemented 29 Aug 2018 in version 4.6 (3)
        x0  += X0per[i]*frac[i];
        lam += lamper[i]*frac[i];
    }
    double calcval = density*0.1/rdE;
    NSLog(@"FR4 calcval = %.3f MeV/mm",calcval);
    NSLog(@"Calculated X0per = %.2f, lambdaper = %.2f",x0,lam);
    NSLog(@"Calculated X0 = %.2f, lambda = %.2f",x0/1.7,lam/1.7);

    return calcval;
    
} */


- (double) value:(int) i For:(NSString *) material {
    
    NSArray * a = [dic objectForKey:material];
    return [[a objectAtIndex:i] doubleValue];
}


@end
