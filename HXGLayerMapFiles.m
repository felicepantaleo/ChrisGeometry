//
//  HXGLayerMapFiles.m
//  Hex
//
//  Created by Chris Seez on 24/03/2020.
//  Copyright © 2020 seez. All rights reserved.
//

#import "HXGLayerMapFiles.h"

@implementation HXGLayerMapFiles

+ (id) sharedLayerMapFiles {
    
    static dispatch_once_t pred;
    static HXGLayerMapFiles * theLayerMapFiles = nil;
    
    dispatch_once(&pred, ^{ theLayerMapFiles = [[self alloc] init]; });
    
    return theLayerMapFiles;
    
}

- (id)init {
    
    sint = sin(M_PI/144.);
    cost = cos(M_PI/144.);
    sinten = sin(M_PI/18.);
    costen = cos(M_PI/18.);

    return self;
}

- (void) loadFile {
    
    _waferFlatFile = @"geomCMSSW10052021_corrected"; //@"geomCMSSW10052021";
    if(_useV17) _waferFlatFile = @"v17-11032022cmssw_flatfile";
    _tileFlatFile = @"tiles_posts_pattern_spaces-scenario13k";
    
    _layerOfTiles = NO;

    NSString * fullPath = [[NSBundle mainBundle] pathForResource:_waferFlatFile ofType:@"txt"];
    
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];
    
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
   
    if(_useV17) {
        for (int i=0;i<47;i++) {
            int lay;
            double vec[24] = {[0 ... 23] = 0.};
            const char * l = [lineStrings[i] UTF8String];
            int ir = sscanf(l,"%d %d %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf %lf",&lay,&tessflags[i],&vec[0],&vec[1],&vec[2],&vec[3],&vec[4],&vec[5],&vec[6],&vec[7],&vec[8],&vec[9],&vec[10],&vec[11],&vec[12],&vec[13],&vec[14],&vec[15],&vec[16],&vec[17],&vec[18],&vec[19],&vec[20],&vec[21],&vec[22],&vec[23]);
            if(ir < 8) NSLog(@"v17 file read error, ir = %d",ir);
            //NSLog(@"i = %d, lay = %d, ir = %d, tessflag = %d",i,lay,ir,tessflags[i]);
            //NSLog(@"---------- Vecs 0, 12: %f %f",vec[0],vec[12]);
        }
    } else {
        const char * l = [lineStrings[1] UTF8String];
        sscanf(l,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d ",&tessflags[0],&tessflags[1],&tessflags[2],&tessflags[3],&tessflags[4],&tessflags[5],&tessflags[6],&tessflags[7],&tessflags[8],&tessflags[9],&tessflags[10],&tessflags[11],&tessflags[12],&tessflags[13],&tessflags[14],&tessflags[15],&tessflags[16],&tessflags[17],&tessflags[18],&tessflags[19],&tessflags[20],&tessflags[21],&tessflags[22],&tessflags[23],&tessflags[24],&tessflags[25],&tessflags[26],&tessflags[27],&tessflags[28],&tessflags[29],&tessflags[30],&tessflags[31],&tessflags[32],&tessflags[33],&tessflags[34],&tessflags[35],&tessflags[36],&tessflags[37],&tessflags[38],&tessflags[39],&tessflags[40],&tessflags[41],&tessflags[42],&tessflags[43],&tessflags[44],&tessflags[45],&tessflags[46]);
    }
    //NSString * tf = @"";
    //for (int i=0; i<47; i++) {
    //    tf = [tf stringByAppendingFormat:@" %d",tessflags[i]];
    //}
    //NSLog(@"tessflags: %@",tf);

    
    int startLoc = 2; // i.e. skip the first two lines for v16
    if(_useV17) startLoc = 47;
    int currentLayer = 1;
    for(int i=startLoc; i<lineStrings.count; i++) {
        int layer;
        const char * l = [lineStrings[i] UTF8String];
        sscanf(l,"%d",&layer);
        if(layer > currentLayer) {
            first[currentLayer-1] = startLoc;
            count[currentLayer-1] = i-startLoc;
            startLoc = i;
            currentLayer = layer;
        }
    }
    first[currentLayer-1] = startLoc;
    count[currentLayer-1] = (int)lineStrings.count-startLoc;
    
    //--------------------------------------------------------------------------------------------------------------
    
    fullPath = [[NSBundle mainBundle] pathForResource:_tileFlatFile ofType:@"txt"];
    
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                             encoding:NSUTF8StringEncoding error:nil];
    tileStrings = [fileContents componentsSeparatedByCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];
    
    if([tileStrings[tileStrings.count-1]  isEqual: @""])
        tileStrings = [tileStrings subarrayWithRange:NSMakeRange(0, tileStrings.count-1)];
    
    for(int i=0; i<50; i++) {
        ipointtiles[i] = 0;
        nringtiles[i] = 0;
        
    }
    startLoc = 0;
    int current = 1;
    int n = 0;
    for(int i=0; i<tileStrings.count; i++) {
        NSString * temp = tileStrings[i];
        if(temp.length < 2) continue;
        if([[tileStrings[i] substringToIndex:1]  isEqual: @"#"]) continue;
        int ordinal;
        const char * l = [tileStrings[i] UTF8String];
        sscanf(l,"%d",&ordinal);
        if(ordinal > current) {
            ipointtiles[ordinal-1] = i;
            nringtiles[ordinal-2] = n;
            startLoc = i;
            current = ordinal;
            n = 0;
        }
        n++;
    }
    nringtiles[current-1] = n;
    
}
- (int) getTessFlagForLayer: (int) layer {
    return tessflags[layer];
}

- (NSString *) getLineNumber: (int) n {
    return lineStrings[n];
}
- (NSArray *) getMapStringsForLayer: (int) layer {  // Zero counted layer
    
    layerString = [lineStrings subarrayWithRange:NSMakeRange(first[layer], count[layer])];
    _firstLine = first[layer];
    return layerString;
}

- (double) innerRingRadiusForLayer: (int) layer {
    
    double r = 99999999.;
    if(nringtiles[layer] > 0) r = rlist[0];
    return r;
}

- (int) tileRingForRadius: (double) r andLayer: (int) layer {
    
    int iring = -1;
    
    if(nringtiles[layer] > 0) {
        if(r > rlist[0] && r < rlist[nlist]) {
            for (int i=1; i < nlist+1; i++) {
                if(r < rlist[i]) {
                    iring = i + iFirstRing;
                    break;
                }
            }
        }
    }
    
    return iring;
}

- (void) makeTileBeziersForLayer: (int) layer {
    
    _layerOfTiles = NO;
    _tileBodyBez = [NSBezierPath bezierPath];
    _tileBodyOutlineBez = [NSBezierPath bezierPath];
    _incompleteTileRingsBez = [NSBezierPath bezierPath];
    _tensTileRingsBez = [NSBezierPath bezierPath];
    _fivesTileRingsBez = [NSBezierPath bezierPath];
    _firstMarked = -1;

    if(nringtiles[layer] < 1) return;
    _layerOfTiles = YES;

    int ip = ipointtiles[layer];
    nlist = 0;
    int bezlist = 0;
    int bstart = -1;
    double fivelist[2][10];
    int nfive = 0;
    _nten = 0;
    
    for(int i=0; i<nringtiles[layer]; i++) {
        const char * l = [tileStrings[ip] UTF8String];
        int ordinal, ring, hex[4]; double rstart, rend, sipm;
        sscanf(l,"%d %d %lf %lf %lf %X %X %X %X",&ordinal,&ring,&rstart,&rend,&sipm,&hex[0],&hex[1],&hex[2],&hex[3]);
       
        if(i == 0) iFirstRing = ring;
        rlist[nlist] = rstart;
        rlist[nlist+1] = rend;
        nlist++;
        if(hex[0] == 0xFFFFFF && hex[1] == 0xFFFFFF && hex[2] == 0xFFFFFF && hex[3] == 0xFFFFFF) {
            if(bstart == -1) bstart = nlist-1;
            bezlist++;
            if(ring%10 == 9) {                // File counts from 0; Hex display counts
                tenlist[0][_nten] = rstart;    // from 1
                tenlist[1][_nten] = rend;
                _nten++;
                if(_firstMarked < 0) _firstMarked = ring + 1;
                _lastMarked = ring + 1;
            } else if(ring%10 == 4) {         // File counts from 0; Hex display counts
                fivelist[0][nfive] = rstart;  // from 1
                fivelist[1][nfive] = rend;
                nfive++;
            }
        } else {
            NSPoint p2 = NSMakePoint(rstart,0.);
            NSPoint p3 = NSMakePoint(rend+0.5,0.); // *** fudge !!!
            NSPoint p4 = [self rotateTilePoint:p3];
            NSPoint p1 = [self rotateTilePoint:p2];
            //int test[96];
            for(int j=0; j<288; j++) {
                int jj = j%96;
                int iword = jj/24;
                int ibit = 23-jj%24;
                if(hex[iword] & (1<<ibit)) {
                    [_incompleteTileRingsBez moveToPoint:p1];
                    [_incompleteTileRingsBez lineToPoint:p2];
                    [_incompleteTileRingsBez lineToPoint:p3];
                    [_incompleteTileRingsBez lineToPoint:p4];
                    [_incompleteTileRingsBez lineToPoint:p1];
                }
                p1 = [self rotateTilePoint:p1];
                p2 = [self rotateTilePoint:p2];
                p3 = [self rotateTilePoint:p3];
                p4 = [self rotateTilePoint:p4];
            }
        }
        ip++;
    }
    double rlo = rlist[bstart];
    double rhi = rlist[bstart+bezlist];

    NSPoint centre = NSZeroPoint;
    [_tileBodyBez moveToPoint:NSMakePoint(centre.x+rlo,centre.y)];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rlo startAngle:0. endAngle:180. clockwise:NO];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rlo startAngle:180. endAngle:0. clockwise:NO];
    [_tileBodyBez lineToPoint:NSMakePoint(centre.x+rhi,centre.y)];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rhi startAngle:0. endAngle:180. clockwise:YES];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rhi startAngle:180. endAngle:0. clockwise:YES];
    [_tileBodyBez closePath];
    
    [_tileBodyOutlineBez appendBezierPathWithArcWithCenter:centre radius:rlo startAngle:0. endAngle:360.];
    for(int i=0; i<bezlist+bstart; i++) {
        [_tileBodyOutlineBez moveToPoint:NSMakePoint(centre.x+rlist[i+1],centre.y)];
        [_tileBodyOutlineBez appendBezierPathWithArcWithCenter:centre radius:rlist[i+1] startAngle:0. endAngle:360.];
    }
    
    for(int i=0; i<_nten; i++) {
        [_tensTileRingsBez moveToPoint:NSMakePoint(centre.x+tenlist[0][i], centre.y)];
        [_tensTileRingsBez appendBezierPathWithArcWithCenter:centre radius:tenlist[0][i] startAngle:0. endAngle:360. clockwise:NO];
        [_tensTileRingsBez lineToPoint:NSMakePoint(centre.x+tenlist[1][i],centre.y)];
        [_tensTileRingsBez appendBezierPathWithArcWithCenter:centre radius:tenlist[1][i] startAngle:360. endAngle:0. clockwise:YES];
        [_tensTileRingsBez closePath];
    }

    
    for(int i=0; i<nfive; i++) {
        [_fivesTileRingsBez moveToPoint:NSMakePoint(centre.x+fivelist[0][i], centre.y)];
        [_fivesTileRingsBez appendBezierPathWithArcWithCenter:centre radius:fivelist[0][i] startAngle:0. endAngle:360. clockwise:NO];
        [_fivesTileRingsBez lineToPoint:NSMakePoint(centre.x+fivelist[1][i],centre.y)];
        [_fivesTileRingsBez appendBezierPathWithArcWithCenter:centre radius:fivelist[1][i] startAngle:360. endAngle:0. clockwise:YES];
        [_fivesTileRingsBez closePath];
    }

    NSPoint plo = NSMakePoint(rlo,0.);
    NSPoint phi = NSMakePoint(rhi,0.);
    for(int i=0; i<288; i++) {
        [_tileBodyOutlineBez moveToPoint:plo];
        [_tileBodyOutlineBez lineToPoint:phi];
        plo = [self rotateTilePoint:plo];
        phi = [self rotateTilePoint:phi];
    }
    

}

- (double *) getTenList {
    
    return &tenlist[0][0];
}

- (NSPoint) rotateTilePoint:(NSPoint) pnt {
    
    NSPoint newpnt;
    
    newpnt.x = pnt.x*cost - pnt.y*sint;
    newpnt.y = pnt.x*sint + pnt.y*cost;
    
    return newpnt;
}

- (NSPoint) rotateTenDegrees:(NSPoint) pnt {
    
    NSPoint newpnt;
    
    newpnt.x = pnt.x*costen - pnt.y*sinten;
    newpnt.y = pnt.x*sinten + pnt.y*costen;
    
    return newpnt;
}


@end
