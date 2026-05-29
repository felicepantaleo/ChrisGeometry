//
//  HXGLayerMapFiles.h
//  Hex
//
//  Created by Chris Seez on 24/03/2020.
//  Copyright © 2020 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXGLayerMapFiles : NSObject
{
    NSArray * lineStrings;
    int first[100], count[100];
    NSArray * layerString;
    
    NSArray * tileStrings;
    int ipointtiles[100], nringtiles[100];
    int tessflags[47];
    NSPoint cassetteShift[12][47];  //--------!!!!!!!**********
    
    double sint, cost, sinten, costen;
    
    double rlist[50]; int nlist;
    
    double tenlist[2][10];
    
    int iFirstRing;
    
}

@property BOOL useV17;
@property (readonly) NSString * waferFlatFile;
@property (readonly) NSString * tileFlatFile;
@property (readonly) NSBezierPath * tileBodyBez;
@property (readonly) NSBezierPath * tileBodyOutlineBez;
@property (readonly) NSBezierPath * incompleteTileRingsBez;
@property (readonly) NSBezierPath * tensTileRingsBez;
@property (readonly) NSBezierPath * fivesTileRingsBez;
@property (readonly) BOOL layerOfTiles;
@property (readonly) int firstMarked;
@property (readonly) int lastMarked;
@property (readonly) int nten;
@property (readonly) int firstLine;

+ (id) sharedLayerMapFiles;
- (id) init;
- (void) loadFile;

- (NSString *) getLineNumber: (int) n;

- (int) getTessFlagForLayer: (int) layer;

- (NSArray *) getMapStringsForLayer: (int) layer;

- (void) makeTileBeziersForLayer: (int) layer;

- (int) tileRingForRadius: (double) r andLayer: (int) layer;

- (double) innerRingRadiusForLayer: (int) layer;

- (double *) getTenList;

@end
