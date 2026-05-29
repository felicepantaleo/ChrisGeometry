//
//  HXGNeighbourFinder.m
//  Hex
//
//  Created by Chris Seez on 25/10/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGNeighbourFinder.h"

const int densityNumberLD = 8;
const int densityNumberHD = 12;

const int       iuMask = 0x0000001F;
const int       ivMask = 0x000003E0;
const int    waferMask = 0x000FFC00;
const int    layerMask = 0x01F00000;
const int detectorMask = 0xF0000000;

const int      HGCalEE = 0x80000000;
const int     HGCalHSi = 0x90000000;

const int signMask = 0x00000010;

const int ivShift = 5;
const int waferShift = 10;

const int duCell[6] = {-1, 0,+1,+1, 0,-1};
const int dvCell[6] = {-1,-1, 0,+1,+1, 0};

const int duWaf[6] = { 0,+1,+1, 0,-1,-1};
const int dvWaf[6] = {-1, 0,+1,+1, 0,-1};

@implementation HXGNeighbourFinder

+ (id) sharedNeighbourFinder {

// Thread-safe instantiation of HXGNeighbourFinder as a Singleton

    static dispatch_once_t pred;
    static HXGNeighbourFinder * theNeighbourFinder = nil;
    
    dispatch_once(&pred, ^{theNeighbourFinder = [[self alloc] init]; });
    return theNeighbourFinder;
}

- (id)init {
  
    self = [super init];
 
/* ------------------------------------------------------------------------
        For the CMSSW version the following line needs to be replaced
        by whatever is necessary to enable the access to the methods
        that do the equivalent of:
            waferExists, waferIsHD, waferPartial, placementIndexForWafer
        in this code
   ------------------------------------------------------------------------- */
    theDetInterface = [HXGDetIdInterface sharedDetInterface];
 
/* ----------------------------------------
     Fill the edgeIndex -> iu,iv mappings
   ---------------------------------------- */
    for(int iu = 0; iu < 2*densityNumberLD; iu++) {
        for(int iv = 0; iv < 2*densityNumberLD; iv++) {
            int edgeIndex = [self edgeIndexForU:iu andV:iv density:NO];
            if(edgeIndex > -1) {
                iuEdgeLD[edgeIndex] = iu;
                ivEdgeLD[edgeIndex] = iv;
            }
        }
    }
 
    // -------------------- CHRIS's DEBUG CODE --------------------------
    BOOL debug1 = NO;
    if(debug1) {
        NSString * outString = @"";
        for (int i=0; i<(2*densityNumberLD - 1)*3; i++) {
            outString = [outString stringByAppendingFormat:@"%d iu:iv = %d:%d\n",i,iuEdgeLD[i],ivEdgeLD[i]];
        }
        if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
        theTerminal.suggestedName = @"Debug neighbours";
        [theTerminal makeWindowBig];
        [theTerminal setDarkBackground:YES];
        //[theTerminal clearString];
        [theTerminal showWindow:nil];
        [theTerminal displayString:outString];
    }
    // -------------------- END DEBUG CODE --------------------------

    for(int iu = 0; iu < 2*densityNumberHD; iu++) {
        for(int iv = 0; iv < 2*densityNumberHD; iv++) {
            int edgeIndex = [self edgeIndexForU:iu andV:iv density:YES];
            if(edgeIndex > -1) {
                iuEdgeHD[edgeIndex] = iu;
                ivEdgeHD[edgeIndex] = iv;
            }
        }
    }

/* ----------------------------------------------
         Fill the edgeIndex -> side mappings
         and the edgeIndex -> corner mappings
   ---------------------------------------------- */
    int edgeIndex = 1;
    int edgeCount = densityNumberLD - 1;
    int nedge = 6*densityNumberLD - 3;
    for(int i=0; i<6; i++) {
        for(int j = edgeIndex; j < edgeIndex + edgeCount+i%2; j++) {
            sideLD[j%nedge] = i;
        }
        edgeIndex += edgeCount+i%2;
    }

    edgeIndex = 0;
    for(int i=0; i<6; i++) {
        sideLD[edgeIndex] += (i+1)*10;
        edgeIndex += edgeCount + (i+1)%2;
    }

    edgeIndex = 1;
    edgeCount = densityNumberHD - 1;
    nedge = 6*densityNumberHD - 3;
    for(int i=0; i<6; i++) {
        for(int j = edgeIndex; j < edgeIndex + edgeCount+i%2; j++) {
            sideHD[j%nedge] = i;
        }
        edgeIndex += edgeCount+i%2;
    }
    
    edgeIndex = 0;
    for(int i=0; i<6; i++) {
        sideHD[edgeIndex] += (i+1)*10;
        edgeIndex += edgeCount + (i+1)%2;
    }

// -------------------- CHRIS's DEBUG CODE --------------------------
// ------- Some optional debug printout is probably useful here
//         Will need to be completely different in CMSSW
    BOOL debug2 = NO;
    if(debug2) {
        int ie=0;
        NSLog(@"--------------- sideLD ---------------");
        for (int i=0; i<5; i++) {
            NSString * debugString = @"";
            for(int j=0; j<10; j++) {
                debugString = [debugString stringByAppendingFormat:@"%d,",sideLD[ie]];
                ie++;
                if(ie == 45) break;
            }
            NSLog(@"%@",debugString);
        }
        NSLog(@"--------------- sideHD ---------------");
        ie=0;
        for (int i=0; i<7; i++) {
            NSString * debugString = @"";
            for(int j=0; j<10; j++) {
                debugString = [debugString stringByAppendingFormat:@"%d,",sideHD[ie]];
                ie++;
                if(ie == 69) break;
            }
            NSLog(@"%@",debugString);
        }
    }
// -------------------- END DEBUG CODE --------------------------

    return self;
}

- (int) edgeIndexForU:(int)iu andV:(int)iv density:(BOOL)HD {
    
    int densityNumber;
    
    if(HD) densityNumber = densityNumberHD;
    else   densityNumber = densityNumberLD;
    
    int maxIndex = 2*densityNumber - 1;
    int halfMax = densityNumber - 1;

    if((iv > iu + halfMax) || (iv < iu - densityNumber)) return -1; // iu:iv for non-existent cell
    
    int edgeIndex = -1;
    
    if (iv == 0 || iu - iv == densityNumber) edgeIndex = iu;
    else if(iu == maxIndex) edgeIndex = maxIndex + iv - halfMax;
    else if(iv == maxIndex) edgeIndex = 2*maxIndex + densityNumber - iu;
    else if(iv - iu == halfMax) edgeIndex = 2 * maxIndex + densityNumber - iu;
    else if( iu == 0) edgeIndex = 3 * maxIndex - iv;

    return edgeIndex;
}
/* -----------------------------------------------------------------------------------------------
   nearestNeighboursOfDetId: DetId
   returns array of up to 7 nearest neighbour DetIds (otherwise array values are zero)
   ----------------------------------------------------------------------------------------------- */
- (int *) nearestNeighboursOfDetId:(int) DetId {
 
    for(int i=0; i<8; i++) { detIdVec[i] = 0;}
    if(!((DetId & detectorMask) == HGCalEE || (DetId & detectorMask) == HGCalHSi)) return detIdVec;
    
    BOOL HD = [theDetInterface waferIsHD:DetId];
    
    int iu = DetId & iuMask;
    int iv = (DetId & ivMask) >> ivShift ;
    int edgeIndex = [self edgeIndexForU:iu andV:iv density:HD];
    BOOL partialWafer = [theDetInterface waferPartial:DetId];

    if(edgeIndex < 0) { // Cell is not on the edge of a wafer (~80% of cells)
        if(partialWafer) {
            // Special treatment for partial wafers: some cells present in whole wafers do not exist
            int nn = 0;
            for (int i=0; i<6; i++) {
                detIdVec[nn] = (DetId & ~(iuMask | ivMask)) | (iu+duCell[i]) | ((iv+dvCell[i]) << ivShift);
                if([theDetInterface DetIdExists:detIdVec[nn]]) nn++;
                else detIdVec[nn] = 0;
            }
        } else {
            detIdVec[0] = (DetId & ~(iuMask | ivMask)) | (iu-1) | ((iv-1) << ivShift);
            detIdVec[1] = (DetId & ~(iuMask | ivMask)) | (iu  ) | ((iv-1) << ivShift);
            detIdVec[2] = (DetId & ~(iuMask | ivMask)) | (iu+1) | ((iv  ) << ivShift);
            detIdVec[3] = (DetId & ~(iuMask | ivMask)) | (iu+1) | ((iv+1) << ivShift);
            detIdVec[4] = (DetId & ~(iuMask | ivMask)) | (iu  ) | ((iv+1) << ivShift);
            detIdVec[5] = (DetId & ~(iuMask | ivMask)) | (iu-1) | ((iv  ) << ivShift);
        }
    } else { // Cell is on the edge
        int * iuEdge = iuEdgeLD;
        int * ivEdge = ivEdgeLD;
        int * side = sideLD;
        int densityNumber = densityNumberLD;
        if(HD) {
            iuEdge = iuEdgeHD;
            ivEdge = ivEdgeHD;
            side = sideHD;
            densityNumber = densityNumberHD;
        }
        
        int edgeCount = 3*(2*densityNumber - 1);
        int mod = 2*densityNumber;
        int iside = side[edgeIndex]%10;
        int corner = side[edgeIndex]/10 - 1;
        
/* -------------------------------------------------------------------------------
        First step: include the 4 neighbours in the same wafer (corners only 3)
   ------------------------------------------------------------------------------- */
        int icount = 4;
        int ioff = iside + 2;
        if(corner > -1) {
            icount = 3;
            ioff = corner + 2;
        }

        int nn = 0;
        for (int i=0; i<icount; i++) {
            int j = (ioff + i)%6;
            detIdVec[nn] = (DetId & ~(iuMask | ivMask)) | (iu+duCell[j]+mod)%mod | ((iv+dvCell[j]+mod)%mod << ivShift);
            if(partialWafer) {
                if(![theDetInterface DetIdExists:detIdVec[nn]]) {
                    detIdVec[nn] = 0;
                    nn--;
                }
            }
            nn++;
        }
        icount = nn;
        /* ----------------------------------------------------------------------------------
           There is a special case in the LD partial wafer where the cell with edgeIndex = 37
           is not an edge cell. The result is ugly but not crazy. This cell is included in
           partial LD1 (Top Half) and LD4 (Right Semi).
         
           It can be corrected for here by code like:
           const int weirdPartialCell = 37;
           if(partialWafer && !HD && edgeIndex == weirdPartialCell) return detIdVec;
           ---------------------------------------------------------------------------------- */
        
        const int weirdPartialCell = 37;
        if(partialWafer && !HD && edgeIndex == weirdPartialCell) return detIdVec;


/* -------------------------------------------------------------------------------
                Second step: Find the wafer adjacent to this wafer side
   ------------------------------------------------------------------------------- */
        BOOL mirror = NO;
        int irot = [theDetInterface placementIndexForWafer:DetId];
        int idir = (iside + irot)%6;
        if(irot > 5) {
            mirror = YES;
            irot = (12-irot)%6;
            idir = (irot - iside + 5)%6;
        }
        
        int waferId = (DetId & waferMask) >> waferShift;

        int wiu = waferId & iuMask;
        int wiv = (waferId  & ivMask) >> ivShift  ;

        if(wiu & signMask) wiu = -(wiu & ~signMask);
        
        if(wiv & signMask) wiv = -(wiv & ~signMask);

        int wiuNxt = wiu + duWaf[idir];
        int wivNxt = wiv + dvWaf[idir];
        
        int wuId = abs(wiuNxt);
        if(wiuNxt < 0) wuId = wuId | signMask;
        int wvId = abs(wivNxt);
        if(wivNxt < 0) wvId = wvId | signMask;

        int DetIdNxt = (DetId & ~waferMask) | (wuId | (wvId << ivShift)) << waferShift;
        
        // Next wafer adjacent to this edge may not exist
        // (We could be on the edge of the HGCAL acceptance)
        // if so, we are done...
        if(![theDetInterface waferExists:DetIdNxt]) return detIdVec;

/* -------------------------------------------------------------------------------
        Third step: locate the neighbour cells in the wafer specified by DetIdNxt
   ------------------------------------------------------------------------------- */
        int jrot = [theDetInterface placementIndexForWafer:DetIdNxt];
        if(jrot > 5) jrot = (12-jrot)%6;
        
        int drot = (irot-jrot+6)%6;
        if(mirror) drot = (6 - drot)%6;
        
        BOOL HDnxt = [theDetInterface waferIsHD:DetIdNxt];
        BOOL sameDens = (HD == HDnxt);
        
        int maxIndex = 2*densityNumber-1;
        int sum, newIndex, istart, iend;
        
        if(drot%2 == 0) {
            // --- Ideally matched neighbour wafer (extended edge cells with truncated edge cells)
            sum = maxIndex*((iside+2)%3);
            newIndex = (sum - edgeIndex + (drot/2)*maxIndex + edgeCount)%edgeCount;
            istart = 0;
            iend = 2;
        } else {
            // --- Imperfectly matched neighbour wafer (extended edge cells with extended edge cells,
            //      or truncated with trucated)
            sum = ((densityNumber - 1) + (iside + 4)*maxIndex)%(3*maxIndex);
            newIndex = (sum - edgeIndex + (drot/2+1)*maxIndex + edgeCount)%edgeCount;
            istart = 0;
            iend = 3;
            if(corner > -1) {
                if(corner%2 == 0) {
                    istart = 1;
                } else {
                    iend = 2;
                }
            }
        }
/* ----------------------------------------------------------------------------------------
        Deal now with the special case of crossing to a wafer with different
        density.
        Need to deal with a number of specific cases identified empirically
        and not analytically explicable
   ---------------------------------------------------------------------------------------- */
        if(!sameDens) { // Wafer density changing
            if(HDnxt) { // LD -> HD transition
                newIndex = (3*newIndex)/2 + drot%2;
                iuEdge = iuEdgeHD;
                ivEdge = ivEdgeHD;
                edgeCount = 3*(2*densityNumberHD - 1);
                iend = 3;
                int jside = sideHD[newIndex];
                if(corner > -1) { // ---- Special treatment for LD corners
                    if(corner == 0 && jside == 1) newIndex++;
                    else if(corner == 1 && jside == 1) iend = 2;
                    else if(corner == 3 && (jside == 3 || jside == 4)) istart = 1;
                    else if(corner == 4 && jside == 3) newIndex++;
                    else if(corner == 5 && jside == 3) istart = 1;
                }
            } else { // HD -> LD transition
                newIndex = (2*newIndex)/3;
                iuEdge = iuEdgeLD;
                ivEdge = ivEdgeLD;
                edgeCount = 3*(2*densityNumberLD - 1);
                iend = 2;
                int jside = sideLD[newIndex]%10;
                //int jcorner = sideLD[newIndex]/10 - 1;
                if(iside == 1) { // Special treatment for HD -> LD transition
                    if(jside == 1) {
                        if(edgeIndex%3 == 0) newIndex++;
                    } else if(jside == 4) {
                        if(edgeIndex%3 == 0) newIndex--;
                        else if(edgeIndex%3 == 1) iend = 1;
                    }
                } else if(iside == 2) {
                    if(jside == 2) {
                        if(edgeIndex%3 == 2) istart = 1;
                    } else if(jside == 4) {
                        if(edgeIndex%3 == 2) iend = 1;
                    } else if(jside == 5) {
                        if(edgeIndex%3 != 1) newIndex--;
                    }
                } else if(iside == 3) {
                    if(jside == 5) {
                        if(edgeIndex%3 == 1) newIndex--;
                    }
                } else if(iside == 4) {
                    if(jside == 3) {
                        if(edgeIndex%3 == 2) newIndex--;
                    }
                }
                if(corner > -1) { // Special treatment for HD corners
                    if(corner == 1) {
                        if(jside == 5) newIndex--;
                    } else if(corner == 3) iend = 1;
                    else if(corner == 4 && jside == 5) {
                        istart = 0;
                        iend = 1;
                    }
                }
            }
        }
 
        partialWafer = [theDetInterface waferPartial:DetIdNxt];
        // ---- Loop now adds the 1,2 or 3 cells in the adjacent wafer
        for (int i=istart; i<iend; i++) {
            int iuNxt = iuEdge[(newIndex+i)%edgeCount];
            int ivNxt = ivEdge[(newIndex+i)%edgeCount];
            detIdVec[icount] = (DetIdNxt & ~(iuMask | ivMask)) | iuNxt | (ivNxt << ivShift);
            if(partialWafer) {
                if([theDetInterface DetIdExists:detIdVec[icount]]) icount++;
                else detIdVec[icount] = 0;
            } else  icount++;
        }
    }
    
    return detIdVec;
}
#pragma mark - Chris's private test of HD/LD  iside/jside combinations in actual final geoemetry
- (void) HDLDcomboTestWithWafers: (NSArray *) waf inLayer:(int) layer {
    
    NSArray * wafers = [NSArray arrayWithArray:waf];
 
    NSString * outList = [NSString stringWithFormat:@"\n\n    ====> Layer %d <====\n\n",layer];
    
    for (int i=0; i<wafers.count; i++) {
        HXGWafer * w = wafers[i];
        if((w.whole || w.part) && !w.LD) {
            int irot = w.channelZero;
            if(layer < 27 && layer%2 == 0) irot = (6-irot)%6;
            for (int j=0; j<6; j++) {
                int idir = (j + irot)%6;
                int wiu = w.detId[0] + duWaf[idir];
                int wiv = w.detId[1] + dvWaf[idir];
                for(int k=0; k<wafers.count; k++) {
                    HXGWafer * wnew = wafers[k];
                    if(wnew.detId[0] == wiu && wnew.detId[1] == wiv) {
                        if((wnew.whole || wnew.part) && wnew.LD) {
                            int jrot = wnew.channelZero;
                            int jside = (idir+3-jrot+6)%6;
                            int iside = j;
                            if(layer < 27 && layer%2 == 0) {
                                jrot = (6-jrot)%6;
                                jside = (jrot-idir-4+12)%6;
                                iside = (5-j)%6;
                            }
                            if(combo[iside][jside] == 20) outList = [outList stringByAppendingFormat:@"Wafer %d:%d -> %d:%d is %d->%d\n",w.detId[0],w.detId[1],wiu,wiv,iside,jside];
                            combo[iside][jside] ++;
                        }
                    }
                }

            }
        }
    }
 
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"Debug neighbours";
    [theTerminal makeWindowBig];
    [theTerminal setDarkBackground:YES];
    //[theTerminal clearString];
    [theTerminal showWindow:nil];
    [theTerminal displayString:outList];
/*
    outList = @"\n\n\n";
    for (int i=0; i<6; i++) {
        outList = [outList stringByAppendingFormat:@"%4d %4d %4d %4d %4d %4d\n",combo[0][i],combo[1][i],combo[2][i],combo[3][i],combo[4][i],combo[5][i]];
    }
 */
    [theTerminal displayString:outList];

}
@end
