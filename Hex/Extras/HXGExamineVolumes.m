//
//  HXGExamineVolumes.m
//  Hex
//
//  Created by Chris Seez on 16/09/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGExamineVolumes.h"

const int Nexamples = 5;

@implementation HXGExamineVolumes

+ (id) sharedVolumes {
    
    static dispatch_once_t pred;
    static HXGExamineVolumes * theVolumes = nil;
    
    dispatch_once(&pred, ^{ theVolumes = [[self alloc] init]; });
    return theVolumes;

}

- (id)init {
    
    return self;
    
}

- (void) loadFileAndDoIt: (NSWindow *) mainwindow {
    
    NSOpenPanel * import = [NSOpenPanel openPanel];
    [import setCanChooseFiles:YES];
    [import setPrompt:@"Choose file"];
    [import beginSheetModalForWindow:mainwindow completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            self->filepath = [[import URL] path];
            [self dEdxOnePass];
            //[self readFileAndAnalyse];
        }
    }];

}

#pragma mark - dEdx weights calculation in a single pass with minimal assumptions

- (void) dEdxOnePass {
 
    const double etamin = 2.3; // Minimum eta to be sure Si sensors in all layers
    
    // Define input and output files
    NSString * filein = filepath;
    //@"/Users/seez/Desktop/VolumesZPosition_V19_D120_CMSSW_16_0_0_pre2.txt";
    //NSString * fileout = @"/Users/seez/Desktop/dEdxResultNEW.txt";

    // Define lookup table of minimum ionizing dEdx values (MeV/cm)
    // Values from PDG, or calculated with PDG inputs and fraction by weight of components
    
    NSArray * materials = @[@"WCu",@"Lead",@"Copper",@"StainlessSteel",@"Titanium",@"HGC_Hexaboard",@"HGC_Kapton",@"HGC_G10-FR",@"Epoxy",@"Polystyrene",@"H_Scintillator",@"Air",@"HGC_HEServices",@"HGC_EEServices",@"HGC_TileServices"];
    NSArray * dEdxperCm = @[@18.118,@12.735,@12.571,@11.656,@6.7056,@4.0937,@2.9467,
                            @3.2052,@2.6883,@1.8495,@2.0404,@1.e-5,@1.e-5,@1.e-5,@1.e-5];
    
    NSDictionary * matDic = [NSDictionary dictionaryWithObjects:dEdxperCm forKeys:materials];


    
    // ---- Read file as a single string
    NSError * error = nil;
    NSString * fileContents = [NSString stringWithContentsOfFile:filein
                                                        encoding:NSUTF8StringEncoding error:&error];
    if(error) NSLog(@"Path = %@\nFile read error = %@",filepath,error);

    // ---- Separate lines into an array of strings
    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet newlineCharacterSet]];
    
    if(lineStrings.count < 100) {
        [self simpleAlert:[NSString stringWithFormat:@"File <%@> doesn't appear to be digestible (too few lines)",filein]];
        return;
    }
    
    // ---- Discard the single string
    fileContents = @"";
       
    NSString * outputString = [NSString stringWithFormat:@"lineStrings.count = %ld\n",lineStrings.count];

    long line = -1;
    NSArray * columns;
    NSString * matStr = @"";
 
    while (![matStr isEqualToString:@"Air"]) { // Find start of first neutrino
        line++;
        if(line >= lineStrings.count) break;
        columns = [lineStrings[line] componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        if(columns.count == 0) continue;
        matStr = columns[0];
    }
    if(line > 10) {
        [self simpleAlert:[NSString stringWithFormat:@"File <%@> doesn't appear to be digestible (can't find Air)",filein]];
        return;
    }
    
    Z0 = [columns[1] doubleValue];
    
    outputString = [outputString stringByAppendingFormat:@"Z0 = %.3f, found at line %ld\n",Z0,line];
    
    Z0 = fabs(Z0);

    double Zval;
    double prevZ = Z0;
    int nSi = 0;
    BOOL prevSi = NO;
    double dEdxSum = 0.;
    double layerDEdx[47] = {0};
    double dEdxValues[47][100] = {0};
    int nTrx = 0;
    BOOL goodeta = YES;
        
    while(line < lineStrings.count) {
        line++;
        columns = [lineStrings[line] componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        matStr = columns[0];
        Zval = fabs([columns[1] doubleValue]);
        if([matStr isEqualToString:@"Air"] && Zval == Z0) {
            // Next neutrino, so deal with current track
            if(goodeta) outputString = [outputString stringByAppendingFormat:@"Next track. Current track had %d Si\n",nSi];
            if(nSi == 47) {
                for (int i=0; i<47; i++) {
                    dEdxValues[i][nTrx] = layerDEdx[i];
                    layerDEdx[i] = 0;
                }
                nTrx++;
                if(nTrx > 49) break;
            } else {
                for (int i=0; i<47; i++) {
                    layerDEdx[i] = 0;
                }
            }
            nSi = 0;
            prevZ = Z0;
            dEdxSum = 0.;
            goodeta = YES;
            
        // --- Check eta of track, and only bother to analyse this track if it falls in the all Si region
        } else if(fabs([columns[2] doubleValue]) > etamin) {
            // Check for end of current stack of non-sensitive absorber materials
            if([matStr isEqualToString:@"Silicon"]) {
                // The prevSi test is to take account of the 120µm epitaxial sensors where
                // there is a double layer: active+substrate
                // Keep it simple: not adding the 180µm substrate to absorber material
                if(!prevSi) {
                    if(nSi < 47) layerDEdx[nSi] = dEdxSum;
                    dEdxSum = 0.;
                    nSi++;
                }
                prevSi = YES;
            } else {
                NSNumber * dv = [matDic objectForKey:columns[0]];
                double ddv = [dv doubleValue];
                dEdxSum += ddv * (Zval-prevZ) * 0.1;
                prevSi = NO;
            }
            prevZ = Zval;
        } else goodeta = NO;;
    }
        
    outputString = [outputString stringByAppendingFormat:@"\n=============================================================\n\nEnd after analysing %d good tracks with |eta| > %.3f\n\n",nTrx,etamin];
    
    /* ------------------------------------------------------------------------
       Requiring |eta| > etamin, and 47 layers of Si will avoid nearly all gaps
       But it is possible for a track to go through the gap between Pb absorber
       sectors in CE-E. So choose for each layer the max value among the 10 tracks
       ------------------------------------------------------------------------ */
  
    NSString * failStr = @"\n";
    for (int i=0; i<47; i++) {
        outputString = [outputString stringByAppendingFormat:@"\n%2d ",i+1];
        double dEdx = 0.;
        for (int j=0; j<50; j++) {
            if(j<10) outputString = [outputString stringByAppendingFormat:@"%6.3f ",dEdxValues[i][j]];
            if(j > 0 && fabs(dEdx - dEdxValues[i][j]) > 0.001) failStr = [failStr stringByAppendingFormat:@"Low value for Layer %d (%d): %.3f\n",i+1,j,dEdxValues[i][j]];
            if(dEdx < dEdxValues[i][j]) dEdx = dEdxValues[i][j];
        }
        layerDEdx[i] = dEdx;
    }
    
    outputString = [outputString stringByAppendingString:failStr];
    
    NSString * blank = @"                                  ";
    outputString = [outputString stringByAppendingString:@"\n\nweightsPerLayer_VXX = cms.vdouble(dummy_weight,\n"];
    for (int i=0; i<46; i++) {
        outputString = [outputString stringByAppendingFormat:@"%@%5.2f,\n",blank,layerDEdx[i]];
    }
    outputString = [outputString stringByAppendingFormat:@"%@%5.2f)\n",blank,layerDEdx[46]];
 /*
    [outputString writeToFile:fileout
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:&error];
*/
  
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"dEdxAnalysis";
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal showWindow:nil];
    [theTerminal displayString:outputString];
    
}
/*
#pragma mark - dEdx weights calculation

- (void) readFileAndAnalyse {
  
    // ---- Read file as a single string
    NSError * error = nil;
    NSString * fileContents = [NSString stringWithContentsOfFile:filepath
                                                        encoding:NSUTF8StringEncoding error:&error];
    if(error) NSLog(@"Path = %@\nFile read error = %@",filepath,error);

    // ---- Separate lines into an array of strings
    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet newlineCharacterSet]];
    
    // ---- Discard the single string
    fileContents = @"";
   
    // ---- Set up the output channel
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"dEdxAnalysis";
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal showWindow:nil];

    [theTerminal displayString:[NSString stringWithFormat:@"lineStrings.count = %ld\n",lineStrings.count]];

    NSString * startString = lineStrings[0];
    
    NSArray * columns = [startString componentsSeparatedByCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@" "]];
    Z0 = [columns[1] doubleValue];
    NSString * sString2 = [NSString stringWithFormat:@"%@ -%@ %@ %@ %@ %@",columns[0],columns[1],columns[2],columns[3],columns[4],columns[5]];
    
    //NSLog(@"startString %@",startString);
    //NSLog(@"sString2 %@",sString2);


    [theTerminal displayString:[NSString stringWithFormat:@"Z0 = %.3f\n",Z0]];
    
    int ngood = 0;
    int ntrk = 0;
    
    long i = 1;
    NSString * currentString;
    
    while(i < lineStrings.count) {
        currentString = lineStrings[i];
        columns = [currentString componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        double eta = fabs([columns[2] doubleValue]);
        int istart = (int) i;
        double zlast = Z0;
        double zcurrent;
        int cassette = 1;
        int nstrata = 0;
        double thick = 0;
        double dz = 0;
        double zbeforelast = 0;
        int n200 = 0;
        int nSi = 0;
        int nbad = 0;
        if(eta < 2.3) nbad = 999;    // Flag tracks in SiPM/tile region as not useful
        
      // ---- equality condition signals start of a new neutrino track
        while (!([currentString isEqualToString:startString] || [currentString isEqualToString:sString2])) {
            if(eta > 2.3) {
                columns = [lineStrings[i] componentsSeparatedByCharactersInSet:
                                     [NSCharacterSet characterSetWithCharactersInString:@" "]];
                if(columns.count < 2) {
                    NSLog(@"columns.count = %ld; i = %ld",columns.count,i);
                    break;
                }
                BOOL isSi = NO;
                if([columns[0] isEqualToString:@"Silicon"]) {
                    if([[lineStrings[i+1] substringToIndex:7] isEqualToString:@"Silicon"]) {
                        // ---- if this i represents the first of a double layer of Si
                        //      (as used for 120µm) then skip to next iteration
                        i++;
                        continue;
                    } else {
                        isSi = YES;
                        nSi++;
                    }
                }
                if(i != istart && [columns[0] isEqualToString:@"StainlessSteel"]) {
                    NSString * cstStr = [NSString stringWithFormat:@"CEE %2d",cassette];
                    BOOL nextPb = NO;
                    if(cassette > 13) cstStr = [NSString stringWithFormat:@"CEH %2d",cassette-13];
                    else nextPb =  [[lineStrings[i+2] substringToIndex:4] isEqualToString:@"Lead"];
                    // ---- stainless steel that is thick, or with Pb in the next-but-one stratum, signals
                    //      a new cassette
                    if((fabs([columns[1] doubleValue]) - zlast > 20.) || nextPb) { // --- NEW CASSETTE ---
                        int ncor = nstrata - n200;
                        if(cassette == 13) ncor -= 2;
                        if((cassette < 14 && ncor != 20) || (cassette > 13 && ncor != 11)) nbad++;
// * ------------------------------------------------------------------------------------------------
        CE-E cassettes (1-13) have 20 material strata
        CE-H cassettes have 11
        Variations on this, that require correction, are:
            a) The back CE-E cassette (13) has 2 extra material strata
            b) Each 200µm Si sensor is paired with an extra 100µm air gap
   ------------------------------------------------------------------------------------------------ * //
                        n200 = 0;
                        nstrata = 0;
                        thick = 0.;
                        cassette ++;
                    }
                }
                nstrata ++;
                zcurrent = fabs([columns[1] doubleValue]);
                dz = zcurrent - zlast;
                thick += dz;
                if(isSi && fabs(dz - 0.2) < 0.01) n200++;
                zbeforelast = zlast;
                zlast = zcurrent;
            }
            i++;
            if(i >= lineStrings.count) break;
            currentString = lineStrings[i];
        } // ------------ END OF CURRENT NEUTRINO TRACK ---------------

        if(nbad == 0 && nSi == 47) {
            if(ngood < Nexamples) {
                long nlines = i - istart + 1;
                NSArray * neutrinoStrings = [lineStrings subarrayWithRange:NSMakeRange(istart,nlines)];
                [self calculateDEdxUsing:neutrinoStrings];
            }
            ngood++;
        }
        ntrk++;
        if(ngood >= Nexamples) break;
        i++;
    }

    [theTerminal displayString:[NSString stringWithFormat:@"_______________________________________________________\n\nGood tracks = %d, from a total of %d\n",ngood,ntrk]];

}

- (void) calculateDEdxUsing: (NSArray *) neutrinoStrings {

    NSArray * materials = @[@"WCu",@"Lead",@"Copper",@"StainlessSteel",@"Titanium",@"HGC_Hexaboard",@"HGC_Kapton",@"HGC_G10-FR",@"Epoxy",@"Polystyrene",@"H_Scintillator",@"Air",@"HGC_HEServices",@"HGC_EEServices",@"HGC_TileServices"];
    NSArray * dEdxpermm = @[@18.12,@12.73,@12.57,@11.66,@6.706,@4.094,@2.947,@
                            3.205,@2.688,@2.04,@2.04,@1.e-5,@1.e-5,@1.e-5,@1.e-5];
    
    NSDictionary * matDic = [NSDictionary dictionaryWithObjects:dEdxpermm forKeys:materials];
    
    double layerWeight[47];
    double thisWeight = 0.;

    double zlast = Z0;
    double zcurrent;
    double dz = 0;
    int layerZC = 0;
    
    long i = 0;
    NSString * currentString;
        
    while(i < neutrinoStrings.count) {
        currentString = neutrinoStrings[i];
        NSArray * columns = [currentString componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        zcurrent = fabs([columns[1] doubleValue]);
        dz = zcurrent - zlast;
        zlast = zcurrent;

        if([columns[0] isEqualToString:@"Silicon"]) {
            if([[neutrinoStrings[i+1] substringToIndex:7] isEqualToString:@"Silicon"]) {
                i++;
                continue;
            } else {
                layerWeight[layerZC] = thisWeight;
                thisWeight = 0.;
                layerZC ++;
            }
        } else {
            NSNumber * dv = [matDic objectForKey:columns[0]];
            double ddv = [dv doubleValue];
            thisWeight += ddv * dz * 0.1;
        }
        i++;
    }
    
    // ---- Now format it in a string
    NSString * textstring = @"\n\n\n//--- Integrated dEdx in front of sensor\ndouble layerdEdx[47] = {";

    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%5.2f,",layerWeight[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%5.2f}; // (MeV)\n",layerWeight[46]];

    [theTerminal displayString:textstring];
    
}

#pragma mark - Original testing stuff

- (void) readVolumesFile {
  
    NSLog(@"And here filepath = <%@>",filepath);
 
    NSError * error = nil;
    NSString * fileContents = [NSString stringWithContentsOfFile:filepath
                                                        encoding:NSUTF8StringEncoding error:&error];
    if(error) NSLog(@"Path = %@\nFile read error = %@",filepath,error);

    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet newlineCharacterSet]];
    
    fileContents = @"";
    
    NSLog(@"lineStrings.count = %ld",lineStrings.count);
    
    NSString * startString = lineStrings[0];
    
    NSArray * columns = [startString componentsSeparatedByCharactersInSet:
                         [NSCharacterSet characterSetWithCharactersInString:@" "]];
    Z0 = [columns[1] doubleValue];
    NSString * sString2 = @"Air -3210.5 0 0 0 0";
    NSLog(@"Z0 = %.3f",Z0);
    
    long i = 1;
    NSString * currentString = lineStrings[i];

    for(int itrk = 0; itrk <20; itrk++) {
        NSString * lines = [NSString stringWithFormat:@"%@\n",currentString];
        columns = [currentString componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        if(columns.count < 2) {
            NSLog(@"columns.count = %ld; i = %ld",columns.count,i);
            break;
        }

        double eta = fabs([columns[2] doubleValue]);
        while (!([currentString isEqualToString:startString] || [currentString isEqualToString:sString2])) {
            i++;
            currentString = lineStrings[i];
            lines = [lines stringByAppendingFormat:@"%@\n",currentString];
        }
        
        NSLog(@"i = %ld [itrk = %d]",i,itrk);
        if(eta < 2.3) {
            itrk -= 1;
            NSLog(@"Rejecting eta = %f",eta);
        } else {
            trackVolumes[itrk] = [lines componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet newlineCharacterSet]];
            
            //long cnt = trackVolumes[itrk].count;
            //NSLog(@"trackVolumes.count = %ld",cnt);
            //NSLog(@"0: %@",trackVolumes[itrk][0]);
            //NSLog(@"trackVolumes.count-1: %@",trackVolumes[itrk][cnt-1]);
            //NSLog(@"trackVolumes.count-2: %@",trackVolumes[itrk][cnt-2]);
            //NSLog(@"trackVolumes.count-3: %@",trackVolumes[itrk][cnt-3]);
        }
        i++;
        currentString = lineStrings[i];
    }

    / *
    // --- Now count the number of tracks
    int nt = 0;
    for(i=0; i<lineStrings.count; i++) {
        if([lineStrings[i] isEqualToString:startString]) nt++;
    }
    
    lineStrings = nil;
* /
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"The trackVolumes array has been constructed"];
    //[alert setInformativeText:[NSString stringWithFormat:@"There were %d tracks in the file",nt]];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];

}

- (void) analyseVolumesNew {
 
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"TrackListing";
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal showWindow:nil];
    
    int trackFlag[20];
    
    for (int itrk = 0; itrk<20; itrk++) {
        
        int j = (int) trackVolumes[itrk].count - 2;
        
        [theTerminal displayString:[NSString stringWithFormat:@"================> Track number %d <================\n\n",itrk]];

        double zlast = Z0;
        double zcurrent;
        //int layer = 1;
        int cassette = 1;
        //BOOL newlayer = NO;
        int nstrata = 0;
        double thick = 0;
        double dz = 0;
        double zbeforelast = 0;
        int n200 = 0;
        
        int nbad = 0;
        
        for(int i=0; i<j; i++) {
            NSArray * columns = [trackVolumes[itrk][i] componentsSeparatedByCharactersInSet:
                                 [NSCharacterSet characterSetWithCharactersInString:@" "]];
            BOOL isSi = NO;
            if([columns[0] isEqualToString:@"Silicon"]) {
                if([[trackVolumes[itrk][i+1] substringToIndex:7] isEqualToString:@"Silicon"]) {
                    //NSLog(@"Silicon double at i = %d",i);
                    continue;
                } else isSi = YES;
            }
            if(i != 0 && [columns[0] isEqualToString:@"StainlessSteel"]) {
                NSString * cstStr = [NSString stringWithFormat:@"CEE %2d",cassette];
                BOOL nextPb = NO;
                if(cassette > 13) cstStr = [NSString stringWithFormat:@"CEH %2d",cassette-13];
                else nextPb =  [[trackVolumes[itrk][i+2] substringToIndex:4] isEqualToString:@"Lead"];
                if((fabs([columns[1] doubleValue]) - zlast > 40.) || nextPb) {
                    int ncor = nstrata - n200;
                    if(cassette == 13) ncor -= 2;
                    [theTerminal displayString:[NSString stringWithFormat:@"  ------> E N D   O F   C A S S E T T E   %@ <-----\n     %d material strata with total thickness = %.2f\n     Corrected strata = %d\n\n",cstStr,nstrata,thick,ncor]];
                    if((cassette < 14 && ncor != 20) || (cassette > 13 && ncor != 11)) {
                        [theTerminal displayString:[NSString stringWithFormat:@" !!!! BAD corrected strata %d (cassette %@, track %d) !!!!\n\n\n",ncor,cstStr,itrk]];
                        nbad++;
                    }
                    
                    
                    n200 = 0;
                    nstrata = 0;
                    thick = 0.;
                    cassette ++;
                }
            }
            nstrata ++;
            NSString * material = [columns[0] stringByPaddingToLength:16 withString:@" " startingAtIndex:0];
            zcurrent = fabs([columns[1] doubleValue]);
            dz = zcurrent - zlast;
            thick += dz;
            if(isSi && fabs(dz - 0.2) < 0.01) n200++;
            [theTerminal displayString:[material stringByAppendingFormat:@"%6.2f (%.2f)\n",dz,zlast]];
            / *
             if(newlayer) {
             if(layer > 26) {
             [theTerminal displayString:[NSString stringWithFormat:@"      ------> E N D   O F   L A Y E R %4d <-----\n     %d material strata with total thickness = %.2f\n\n",layer,nstrata,thick]];
             nstrata = 0;
             thick = 0;
             }
             layer++;
             //nstrata = 0;
             //thick = 0;
             newlayer = NO;
             }
             * /
            zbeforelast = zlast;
            zlast = zcurrent;
        }
        [theTerminal displayString:[NSString stringWithFormat:@"End track %d, nbad = %d, cassette = %d\n",itrk,nbad,cassette]];
        if(cassette != 35) trackFlag[itrk] += 99;
        else trackFlag[itrk] = nbad;
        [theTerminal displayString:[NSString stringWithFormat:@"===> TOTAL CALORIMETER THICKNESS: %.3f <====\n\n\n\n",zbeforelast - Z0]];
        
    }
    NSString * flagStr = @"";
    for(int ii=0; ii<20; ii++) {
        flagStr = [flagStr stringByAppendingFormat:@"%3d",trackFlag[ii]];
    }
    [theTerminal displayString:[NSString stringWithFormat:@"Trackflags: %@/n",flagStr]];
}
*/
#pragma mark - Alert

- (void) simpleAlert: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setShowsSuppressionButton:NO];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }
    
}


#pragma mark - Private humbug

- (void) birthdayNonsense {
 
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"BirthdayCoincidence";
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal showWindow:nil];

    double pn = 1.0;
    double fracOfYear = 1./365.;
    for (int i=2; i<80; i++) {
        pn = pn * fracOfYear * (double) (366-i);
        [theTerminal displayString:[NSString stringWithFormat:@"%2d %6.2f%%\n",i,100.*(1.-pn)]];
    }
}

@end
