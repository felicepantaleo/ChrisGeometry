//
//  HXGLayerMapFiles.h
//  Hex
//
//  Created by Chris Seez on 24/03/2020.
//  Copyright © 2020 seez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSColours.h"

@interface HXGLayerMapFiles : NSObject {
    
    int displayLayer;    // ---- Displayed layer counting from 0
    double radRetr;
    
    NSArray * lineStrings;
    int first[100], count[100];
    NSArray * layerString;
    
    NSArray * tileStrings;
    
    
    /* Indices of ipointFileLine are zero-counted layer and ring
       
       Index of ipointtiles, nringtiles, tessflags is zero-counted layer  */
    
    int ipointFileLine[47][42];
    int ipointtiles[47], nringtiles[47];
    int tessflags[47];
    NSPoint cassetteShift[12][47];
    
    double sint, cost, sinten, costen;
    
    double rlist[50]; int nlist;
    
    int lnphi[21];
    double rShift[21];
    
    double tenlist[2][10];
    
    double tileSpec[4];
    
    int iFirstRing;
    
    //int nincomplete;
    int nringsmapped;
    int ntiles;
    int ntile;
    //double radLowIncomplete[10];
    //double radHighIncomplete[10];
    //BOOL tilePresent[10][432];
    BOOL tilePresent[42][72];
    double radMinComplete;
    double radMaxComplete;
    
    NSPoint siRetractionVector[2][12]; // [CEtype][icas]
                                       // CEtype: 0 = CEE, 1 = CEH; icas = cassette -1
    
    NSBezierPath * tileOneRingBezier[2];
    NSBezierPath * tileRingsBezier;
    NSBezierPath * fiveMarkerBezier;
    NSBezierPath * tenMarkerBezier;


}

@property int version;
//@property BOOL useV17;
@property NSString * siNameFilePath;
@property NSString * tileNameFilePath;
@property NSString * siDirPath;
@property NSString * tileDirPath;

@property (readonly) NSString * version0tooltip;
@property (readonly) NSString * version1tooltip;


@property (readonly) NSString * waferFlatFile;
@property (readonly) NSString * tileFlatFile;
/*
@property (readonly) NSBezierPath * tileBodyBez;
@property (readonly) NSBezierPath * tileBodyOutlineBez;
@property (readonly) NSBezierPath * incompleteTileRingsBez;
@property (readonly) NSBezierPath * tensTileRingsBez;
@property (readonly) NSBezierPath * fivesTileRingsBez;
@property (readonly) NSBezierPath * scintCassetteBez;
*/
@property (readonly) NSBezierPath * scintCassetteBez;
@property (readonly) BOOL layerOfTiles;
@property (readonly) int firstMarked;
@property (readonly) int lastMarked;
@property (readonly) int nten;
@property (readonly) int firstLine;
@property (readonly) double rfirst;
@property (readonly) double rlast;

@property (readonly) int tileL0; // first layer with tiles
@property (readonly) int * layerNphi;
@property (readonly) double * layerRshift;


+ (id) sharedLayerMapFiles;

- (id) init;

- (BOOL) loadFiles;

- (NSString *) getLineNumber: (int) n;

- (int) getTessFlagForLayer: (int) layer;

- (NSArray *) getMapStringsForLayer: (int) layer;

- (int) getFirstLineNumberForLayer: (int) layer;

- (int) getTileLineNumberForLayer: (int) layer andRing: (int) iring;

- (NSString *) getTileLineString: (int) line;

//- (void) makeTileBeziersForLayer: (int) layer;

- (void) makeTileBezierForLayer: (int) layer Retracted: (BOOL) retracted;

- (void) drawTileBeziersWithLineWidth:(double) linewidth;

- (void) drawTileBeziersForCassette: (int) cassette;

//- (void) cassetteTileBeziersForLayer: (int) layer andCassette: (int) cassette;

// AND THIS ONE !!!!!!!!!!!!!!
- (int) tileRingForRadius: (double) r;

//- (double) innerRingRadiusForLayer: (int) layer retracted: (BOOL) isRetracted;

- (double) innerRingRadius;

- (double *) getTenList;

- (double *) tileSpecFor: (int) iring;

- (NSPoint) getRetVecForCEtype:(int) layer andCassette: (int) cassette;

- (int) countOfTilesInLayer: (int) layer;

- (int) iphiTileAt: (NSPoint) pnt;

//- (int) iphiRetractedTileAt: (NSPoint) pnt;

- (int) tilesContainPoint: (NSPoint) pnt;

@end
