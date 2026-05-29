//
//  HXGLayerMapFiles.m
//  Hex
//
//  Created by Chris Seez on 24/03/2020.
//  Copyright © 2020 seez. All rights reserved.
//

#import "HXGLayerMapFiles.h"

const long one = 1;

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
    
    _tileL0 = 34; // Counting from 1
    _layerNphi = lnphi;
    _layerRshift = rShift;
    for(int i=0; i<21; i++){ lnphi[i] = 288;} // initialize to v17 default

    return self;
}

- (BOOL) loadFiles {
    
    _version0tooltip = @"v17 files:\ngeomnew_corrected_360_V2.txt\ntiles_posts_pattern_spaces-scenario13k.txt";
    _version1tooltip = @"v19 files:\nmodmapv16.6_cmssw_flatfile.txt\ntilefile-Nov2023.txt";
    
    if(_version == 0) {
        _waferFlatFile = @"geomnew_corrected_360_V2.txt"; // @"v17-22042022-cmssw_flatfile.txt";
        _tileFlatFile = @"tiles_posts_pattern_spaces-scenario13k.txt";
    } else if(_version == 1) {
        _waferFlatFile = @"modmapv16.6_cmssw_flatfile.txt";
        _tileFlatFile = @"tilefile-Nov2023.txt";
    } else if(_version == 2) {
        _waferFlatFile = [NSString stringWithContentsOfFile:_siNameFilePath
                                                   encoding:NSUTF8StringEncoding error:nil];
        _tileFlatFile = [NSString stringWithContentsOfFile:_tileNameFilePath                                                   encoding:NSUTF8StringEncoding error:nil];
    }
    _layerOfTiles = NO;
    
    NSString * fullPath = [_siDirPath stringByAppendingFormat:@"/%@",_waferFlatFile];
    
    NSError * error = nil;
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:&error];
    
    if(_version == 2 && error) { // If error object was instantiated, handle it.
        NSString * info = [NSString stringWithFormat:@"Path = %@\nFile read error = %@",fullPath,error];
        [self fileReadAlert:@"Si flat-file read error" withInfo:info];
        return NO;
    }
    
    
    
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];
    
    
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    
    for (int i=0;i<47;i++) {
        int lay;
        NSString * str = lineStrings[i];
        
        while ([str rangeOfString:@"  "].location != NSNotFound) {
            str = [str stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        }
        NSArray * columns = [str componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        if(_version == 2 && columns.count < 8) {
            NSString * info = [NSString stringWithFormat:@"File error, line = %d, count = %lu\nFile = %@",i,columns.count,_waferFlatFile];
            [self fileReadAlert:@"Si flat-file error" withInfo:info];
            return NO;
        }
        lay = [columns[0] intValue];
        tessflags[i] = [columns[1] intValue];
        if(i == 0 || i == 27) {
            int CEtype = i/26;
            for (int j=2; j<columns.count; j++) {
                if(j%2 == 0) siRetractionVector[CEtype][(j-2)/2].x = [columns[j] doubleValue];
                else         siRetractionVector[CEtype][(j-2)/2].y = [columns[j] doubleValue];
            }
        }
    }
    
    int startLoc = 47;
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
    
    //------------- Now the tile file ----------
    
    fullPath = [_tileDirPath stringByAppendingFormat:@"/%@",_tileFlatFile];
    
    error = nil;
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                             encoding:NSUTF8StringEncoding error:&error];
    if(_version == 2 && error) { // If error object was instantiated, handle it.
        NSString * info = [NSString stringWithFormat:@"Path = %@\nFile read error = %@",fullPath,error];
        [self fileReadAlert:@"Tile flat-file read error" withInfo:info];
        return NO;
    }
    
    tileStrings = [fileContents componentsSeparatedByCharactersInSet:
                   [NSCharacterSet newlineCharacterSet]];
    
    if([tileStrings[tileStrings.count-1]  isEqual: @""])
        tileStrings = [tileStrings subarrayWithRange:NSMakeRange(0, tileStrings.count-1)];
    
    for(int i=0; i<47; i++) {
        ipointtiles[i] = 0;
        nringtiles[i] = 0;
    }
    startLoc = 0;
    int current = 33;
    int n = 0;
    
    BOOL headerAbsent = YES;
    
    for(int i=0; i<tileStrings.count; i++) {
        NSString * temp = tileStrings[i];
        if(temp.length < 2) continue;
        if([[tileStrings[i] substringToIndex:1]  isEqual: @"#"]) continue;
        //const char * l = [tileStrings[i] UTF8String];
        while ([temp rangeOfString:@"  "].location != NSNotFound) {
            temp = [temp stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        }
        
        NSArray * columns = [temp componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        if(_version == 2 && columns.count < 3) {
            NSString * info = [NSString stringWithFormat:@"Path = %@\ncolumns.count = %ld",fullPath,columns.count];
            [self fileReadAlert:@"Tile flat-file error" withInfo:info];
            return NO;
        }

        if(columns.count < 10) {  // Header line
            int tl = [columns[0] intValue];
            lnphi[tl - _tileL0]  = [columns[1] intValue];
            rShift[tl - _tileL0] = [columns[2] doubleValue];
            headerAbsent = NO;
            continue;
        }
        int ordinal,iring;
        ordinal = [columns[0] intValue];
        iring = [columns[1] intValue];
        
        if(_version == 2 && (ordinal < current || ordinal > current+1 || iring < 0 || iring > 50)) {
            NSString * info = [NSString stringWithFormat:@"Path = %@\nordinal = %d (current %d); iring = %d",fullPath,ordinal,current,iring];
            [self fileReadAlert:@"Tile flat-file error" withInfo:info];
            return NO;
        }
        
        //sscanf(l,"%d %d",&ordinal,&iring);
        // ordinal = layer; iring = CMSSW ring number - 1 (i.e. file ring number counts from 0[)
        ipointFileLine[ordinal-1][iring] = i;
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
    
    if(_version == 2 && current != 47) {
        NSString * info = [NSString stringWithFormat:@"Path = %@\nTerminate with current = %d",fullPath,current];
        [self fileReadAlert:@"Tile flat-file error" withInfo:info];
        return NO;
    }

    
    if(headerAbsent) {
        for(int i=0; i<21; i++){ lnphi[i] = 288;}
    }
    
    return YES;
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

- (int) getFirstLineNumberForLayer: (int) layer {  // Zero counted layer
    return first[layer];
}

- (int) getTileLineNumberForLayer: (int) layer andRing: (int) iring {  // Zero counted layer and ring
    
    return ipointFileLine[layer][iring];
    
}

- (NSString *) getTileLineString: (int) line {
    
    NSString * tileString = @"";
    
    if(line > 0) tileString = tileStrings[line];
    
    return tileString;
}

- (double) innerRingRadius {
    
    double r = 999999.;
    if(nringtiles[displayLayer] > 0) r = rlist[0]+radRetr;
    return r;
}

- (int) tileRingForRadius: (double) r {

    /*
     Returns iRing counting from 1
     
     */
    
    int iring = -1;
    
    if(nringtiles[displayLayer] > 0) {
        if(r > rlist[0]+radRetr && r < rlist[nlist]+radRetr) {
            for (int i=1; i < nlist+1; i++) {
                if(r < rlist[i]+radRetr) {
                    iring = i + iFirstRing;
                    break;
                }
            }
        }
    }
    
 /*
    if(iring < 0) {
        NSLog(@"tileRingForRadius < 0: layer %d",displayLayer);
        NSLog(@"nlist = %d; rlist[0] = %.1f; iFirstRing = %d",nlist,rlist[0],iFirstRing);
        NSLog(@"radRetr = %.1f",radRetr);
    }
  */
    
    return iring;
}
/* ------- The old method
- (void) makeTileBeziersForLayer: (int) layer {

    double dphi = 2.*M_PI/(double) lnphi[layer-_tileL0+1];
    ntiles = lnphi[layer-_tileL0+1];
    BOOL HD = (lnphi[layer-_tileL0+1] > 288);
    sint = sin(dphi);
    cost = cos(dphi);
    dphi *= 8.;
    sinten = sin(M_PI/18.);
    costen = cos(M_PI/18.);
    
    nincomplete = 0;
    
    _layerOfTiles = NO;
    _tileBodyBez = [NSBezierPath bezierPath];
    _tileBodyOutlineBez = [NSBezierPath bezierPath];
    _incompleteTileRingsBez = [NSBezierPath bezierPath];
    _tensTileRingsBez = [NSBezierPath bezierPath];
    _fivesTileRingsBez = [NSBezierPath bezierPath];
    _scintCassetteBez = [NSBezierPath bezierPath];
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
    
    double rstart, rend, sipm;
    for(int i=0; i<nringtiles[layer]; i++) {
        const char * l = [tileStrings[ip] UTF8String];
        int ordinal, ring;
        long hex[4];
        sscanf(l,"%d %d %lf %lf %lf %lX %lX %lX %lX",&ordinal,&ring,&rstart,&rend,&sipm,&hex[0],&hex[1],&hex[2],&hex[3]);
       
        if(i == 0) {
            iFirstRing = ring;
            _rfirst = rstart;
        }
        rlist[nlist] = rstart;
        rlist[nlist+1] = rend;
        nlist++;
        
        long full = 0xFFFFFF;
        if(HD) full = 0xFFFFFFFFF;
        if(hex[0] == full && hex[1] == full && hex[2] == full && hex[3] == full) {
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
            radLowIncomplete[nincomplete] = rstart;
            radHighIncomplete[nincomplete] = rend;
            
            NSPoint p2 = NSMakePoint(rstart,0.);
            NSPoint p3 = NSMakePoint(rend+0.5,0.); // *** fudge !!!
            NSPoint p4 = [self rotateTilePoint:p3];
            NSPoint p1 = [self rotateTilePoint:p2];
            //int test[96];
            for(int j=0; j<lnphi[layer-_tileL0+1]; j++) {
                int jj = j%96;
                int iword = jj/24;
                int ibit = 23-jj%24;
                if(HD) {
                    jj = j%144;
                    iword = jj/36;
                    ibit = 35-jj%36;
                }
                tilePresent[nincomplete][j] = hex[iword] & one<<ibit;
                if(hex[iword] & one<<ibit) {
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
            nincomplete++;
        }
        ip++;
    }
    _rlast = rend;
    double phiang = 0.;
    for(int i=0; i<12; i++) {
        NSPoint p = NSMakePoint(_rfirst*cos(phiang),_rfirst*sin(phiang));
        [_scintCassetteBez moveToPoint:p];
        p = NSMakePoint(_rlast*cos(phiang),_rlast*sin(phiang));
        [_scintCassetteBez lineToPoint:p];
        phiang += M_PI/6.;
    }
    
    double rlo = rlist[bstart];
    double rhi = rlist[bstart+bezlist];
    radMinComplete = rlo;
    radMaxComplete = rhi;

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
    for(int i=0; i<lnphi[layer-_tileL0+1]; i++) {
        [_tileBodyOutlineBez moveToPoint:plo];
        [_tileBodyOutlineBez lineToPoint:phi];
        plo = [self rotateTilePoint:plo];
        phi = [self rotateTilePoint:phi];
    }
    

}
*/
- (void) makeTileBezierForLayer: (int) layer Retracted: (BOOL) retracted {

    BOOL HD = (lnphi[layer - _tileL0+1] > 288);
    displayLayer = layer;
    radRetr = 0.;
    if(retracted) {
        radRetr = 4.;
        if(HD) radRetr = 8.;
    }
    
    _layerOfTiles = NO;
    tileOneRingBezier[0] = [NSBezierPath bezierPath];
    tileOneRingBezier[1] = [NSBezierPath bezierPath];
    _firstMarked = -1;

    if(nringtiles[layer] < 1) return;
    _layerOfTiles = YES;
    nringsmapped = 0;
    ntiles = lnphi[layer-_tileL0+1];


    ntile = 24;
    if(HD) ntile = 36;
    double dphi = 2.*M_PI/(double) lnphi[layer-_tileL0+1];
    double ret = 4.;
    if(HD) ret = 8.;

    sint = sin(dphi);
    cost = cos(dphi);

    int ip = ipointtiles[layer];
    nlist = 0;
    
    long full = 0xFFFFFF;
    if(HD) full = 0xFFFFFFFFF;
    
    fiveMarkerBezier = [NSBezierPath bezierPath];
    tenMarkerBezier = [NSBezierPath bezierPath];
    NSPoint centre = NSZeroPoint;

    double rstart, rend, sipm;
    for(int i=0; i<nringtiles[layer]; i++) {
        const char * l = [tileStrings[ip] UTF8String];
        int ordinal, ring;
        long hex[4];
        sscanf(l,"%d %d %lf %lf %lf %lX %lX %lX %lX",&ordinal,&ring,&rstart,&rend,&sipm,&hex[0],&hex[1],&hex[2],&hex[3]);
       
        if(i == 0) {
            iFirstRing = ring;
            _rfirst = rstart;
        }
        rlist[nlist] = rstart;
        rlist[nlist+1] = rend;
        nlist++;
        double phia = 0.;
        for (int iword=0; iword<2; iword++) {
            double xret = 0.;
            double yret = 0.;
            if(retracted) {
                double ang = M_PI/12. + (double)iword * M_PI/6.;
                xret = ret*cos(ang);
                yret = ret*sin(ang);
            }
            NSPoint p2 = NSMakePoint(rstart*cos(phia),rstart*sin(phia));
            NSPoint p3 = NSMakePoint(rend*cos(phia),rend*sin(phia));
            NSPoint p4 = [self rotateTilePoint:p3];
            NSPoint p1 = [self rotateTilePoint:p2];
            NSPoint pr1 = NSMakePoint(p1.x+xret,p1.y+yret);
            NSPoint pr2 = NSMakePoint(p2.x+xret,p2.y+yret);
            NSPoint pr3 = NSMakePoint(p3.x+xret,p3.y+yret);
            NSPoint pr4 = NSMakePoint(p4.x+xret,p4.y+yret);
            for(int j=0; j<ntile; j++) {
                int ibit = ntile-1-j;
                if(nringsmapped > 41 || ibit+iword*ntile > 72) NSLog(@"WHAT? %d %d",nringsmapped,ibit+iword*ntile);
                if(hex[iword] & (one<<ibit)) {
                    [tileOneRingBezier[iword] moveToPoint:pr1];
                    [tileOneRingBezier[iword] lineToPoint:pr2];
                    [tileOneRingBezier[iword] lineToPoint:pr3];
                    [tileOneRingBezier[iword] lineToPoint:pr4];
                    [tileOneRingBezier[iword] lineToPoint:pr1];
                    tilePresent[nringsmapped][j+iword*ntile] = YES;
                } else tilePresent[nringsmapped][j+iword*ntile] = NO;
                p1 = [self rotateTilePoint:p1];
                p2 = [self rotateTilePoint:p2];
                p3 = [self rotateTilePoint:p3];
                p4 = [self rotateTilePoint:p4];
                pr1.x = p1.x + xret; pr1.y = p1.y + yret;
                pr2.x = p2.x + xret; pr2.y = p2.y + yret;
                pr3.x = p3.x + xret; pr3.y = p3.y + yret;
                pr4.x = p4.x + xret; pr4.y = p4.y + yret;
            }
            //[tileOneRingBezier[iword] closePath];
            phia += M_PI/6.;
        }
        if(hex[0] == full && hex[1] == full && hex[2] == full && hex[3] == full) {
            
            if(ring%10 == 9) {                // File counts from 0; Hex display counts
                
                [tenMarkerBezier moveToPoint:NSMakePoint(rstart, 0.)];
                [tenMarkerBezier appendBezierPathWithArcWithCenter:centre radius:rstart startAngle:0. endAngle:30. clockwise:NO];
                [tenMarkerBezier lineToPoint:NSMakePoint(rend*cos(M_PI/6.),rend*sin(M_PI/6.))];
                [tenMarkerBezier appendBezierPathWithArcWithCenter:centre radius:rend startAngle:30. endAngle:0. clockwise:YES];
                [tenMarkerBezier closePath];

                if(_firstMarked < 0) _firstMarked = ring + 1;
                _lastMarked = ring + 1;
            } else if(ring%10 == 4) {         // File counts from 0; Hex display counts
                [fiveMarkerBezier moveToPoint:NSMakePoint(rstart, 0.)];
                [fiveMarkerBezier appendBezierPathWithArcWithCenter:centre radius:rstart startAngle:0. endAngle:30. clockwise:NO];
                [fiveMarkerBezier lineToPoint:NSMakePoint(rend*cos(M_PI/6.),rend*sin(M_PI/6.))];
                [fiveMarkerBezier appendBezierPathWithArcWithCenter:centre radius:rend startAngle:30. endAngle:0. clockwise:YES];
                [fiveMarkerBezier closePath];
            }
//        } else {
//            radLowIncomplete[nincomplete] = rstart;
//            radHighIncomplete[nincomplete] = rend;
        }
        ip++;
        nringsmapped++;
    }
    _rlast = rend;
    
    if(retracted) {
        double ang = M_PI/12.;
        double xret = ret*cos(ang);
        double yret = ret*sin(ang);
        NSAffineTransform * transform = [NSAffineTransform transform];
        [transform translateXBy:xret yBy:yret];
        tenMarkerBezier = [transform transformBezierPath:tenMarkerBezier];
        fiveMarkerBezier = [transform transformBezierPath:fiveMarkerBezier];
    }
    
    NSBezierPath * one = [NSBezierPath bezierPath];
    [one appendBezierPath:tileOneRingBezier[0]];
    [one appendBezierPath:tileOneRingBezier[1]];
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    [transform rotateByDegrees:30.];
    
    NSBezierPath * oneten = [NSBezierPath bezierPath];
    [oneten appendBezierPath:tenMarkerBezier];
    [oneten appendBezierPath:[transform transformBezierPath:tenMarkerBezier]];
    
    NSBezierPath * onefive = [NSBezierPath bezierPath];
    [onefive appendBezierPath:fiveMarkerBezier];
    [onefive appendBezierPath:[transform transformBezierPath:fiveMarkerBezier]];

    tileRingsBezier = [NSBezierPath bezierPath];
    [tileRingsBezier appendBezierPath:tileOneRingBezier[0]];
    [tileRingsBezier appendBezierPath:tileOneRingBezier[1]];
    tenMarkerBezier = [NSBezierPath bezierPath];
    [tenMarkerBezier appendBezierPath:oneten];
    fiveMarkerBezier = [NSBezierPath bezierPath];
    [fiveMarkerBezier appendBezierPath:onefive];

    transform = [NSAffineTransform transform];
    [transform rotateByDegrees:60.];
    for (int i=1; i<6 ; i++) {
        one = [transform transformBezierPath:one];
        [tileRingsBezier appendBezierPath:one];
        oneten = [transform transformBezierPath:oneten];
        [tenMarkerBezier appendBezierPath:oneten];
        onefive = [transform transformBezierPath:onefive];
        [fiveMarkerBezier appendBezierPath:onefive];
   }
    
}

- (void) drawTileBeziersWithLineWidth:(double) linewidth {
    
    [[NSColor fadedBlue] set];
    [tileRingsBezier fill];
    
    [[NSColor pastelBlue]set];
    [tenMarkerBezier fill];
    
    [[NSColor paleBlue] set];
    [fiveMarkerBezier fill];

    [[NSColor blackColor] set];
    [tileRingsBezier setLineWidth:linewidth];
    [tileRingsBezier stroke];

}

- (void) drawTileBeziersForCassette: (int) cassette {
    
    NSBezierPath * one = [NSBezierPath bezierPath];
    int index = (cassette+1)%2;
    [one appendBezierPath:tileOneRingBezier[index]];
    
    if(cassette > 1) {
        NSAffineTransform * transform = [NSAffineTransform transform];
        [transform rotateByDegrees:30.*(double)(cassette-index-1)];
        one = [transform transformBezierPath:one];
    }

    [[NSColor fadedBlue] set];
    [one fill];
    [[NSColor blackColor] set];
    [one setLineWidth:2.];
    [one stroke];

}
/*
- (void) cassetteTileBeziersForLayer: (int) layer andCassette: (int) cassette {
    
    // Beziers for a specific cassette
    // Called from HexView layoutFromFiles

    BOOL HD = (lnphi[layer - _tileL0+1] > 288);
    
    _layerOfTiles = NO;
    _tileBodyBez = [NSBezierPath bezierPath];
    _tileBodyOutlineBez = [NSBezierPath bezierPath];
    _incompleteTileRingsBez = [NSBezierPath bezierPath];
    _tensTileRingsBez = [NSBezierPath bezierPath];
    _fivesTileRingsBez = [NSBezierPath bezierPath];
    _scintCassetteBez = [NSBezierPath bezierPath];
   _firstMarked = -1;

    if(nringtiles[layer] < 1) return;
    _layerOfTiles = YES;
    
    int ntile = 24;
    if(HD) ntile = 36;

    int j1 = cassette*ntile;
    int j0 = j1-ntile;
    double phiadeg = (cassette-1) * 30.;
    double phibdeg = phiadeg + 30.;
    double phia = phiadeg*M_PI/180.;
    double phib = phibdeg*M_PI/180.;

    int ip = ipointtiles[layer];
    nlist = 0;
    
    int bezlist = 0;
    int bstart = -1;
 
    long full = 0xFFFFFF;
    if(HD) full = 0xFFFFFFFFF;

    double rstart, rend, sipm;
    for(int i=0; i<nringtiles[layer]; i++) {
        const char * l = [tileStrings[ip] UTF8String];
        int ordinal, ring;
        long hex[4];
        sscanf(l,"%d %d %lf %lf %lf %lX %lX %lX %lX",&ordinal,&ring,&rstart,&rend,&sipm,&hex[0],&hex[1],&hex[2],&hex[3]);
       
        if(i == 0) {
            iFirstRing = ring;
            _rfirst = rstart;
        }
        rlist[nlist] = rstart;
        rlist[nlist+1] = rend;
        nlist++;
        if(hex[0] == full && hex[1] == full && hex[2] == full && hex[3] == full) {
            if(bstart == -1) bstart = nlist-1;
            bezlist++;
        } else {
            
            NSPoint p2 = NSMakePoint(rstart*cos(phia),rstart*sin(phia));
            NSPoint p3 = NSMakePoint(rend*cos(phia),rend*sin(phia));
            NSPoint p4 = [self rotateTilePoint:p3];
            NSPoint p1 = [self rotateTilePoint:p2];
            //int test[96];
            for(int j=j0; j<j1; j++) {
                int jj = j%(4*ntile);
                int iword = jj/ntile;
                int ibit = ntile-1 - jj%ntile;
                if(hex[iword] & (one<<ibit)) {
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
    _rlast = rend;
    
    double rlo = rlist[bstart];
    double rhi = rlist[bstart+bezlist];

    NSPoint centre = NSZeroPoint;
    NSPoint p0 = NSMakePoint(rlo*cos(phia),rlo*sin(phia));
    NSPoint p1 = NSMakePoint(rhi*cos(phia),rhi*sin(phia));
    NSPoint p2 = NSMakePoint(rhi*cos(phib),rhi*sin(phib));
    NSPoint p3 = NSMakePoint(rlo*cos(phib),rlo*sin(phib));
    

    [_tileBodyBez moveToPoint:p0];
    [_tileBodyBez lineToPoint:p1];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rhi startAngle:phiadeg endAngle:phibdeg clockwise:NO];
    [_tileBodyBez lineToPoint:p3];
    [_tileBodyBez appendBezierPathWithArcWithCenter:centre radius:rlo startAngle:phibdeg endAngle:phiadeg clockwise:YES];
    [_tileBodyBez closePath];

    
    [_tileBodyOutlineBez appendBezierPathWithArcWithCenter:centre radius:rlo startAngle:phiadeg endAngle:phibdeg];
    for(int i=0; i<bezlist+bstart; i++) {
        NSPoint pp = NSMakePoint(rlist[i+1]*cos(phia),rlist[i+1]*sin(phia));
        [_tileBodyOutlineBez moveToPoint:pp];
        [_tileBodyOutlineBez appendBezierPathWithArcWithCenter:centre radius:rlist[i+1] startAngle:phiadeg endAngle:phibdeg];
    }
    [_tileBodyOutlineBez moveToPoint:p3];
    [_tileBodyOutlineBez lineToPoint:p2];

    NSPoint plo = p0;
    NSPoint phi = p1;
    for(int i=j0; i<j1; i++) {
        [_tileBodyOutlineBez moveToPoint:plo];
        [_tileBodyOutlineBez lineToPoint:phi];
        plo = [self rotateTilePoint:plo];
        phi = [self rotateTilePoint:phi];
    }
    

}
*/
- (double *) getTenList {
    
    return &tenlist[0][0];
}

- (NSPoint) getRetVecForCEtype:(int) CEtype andCassette: (int) cassette {
    
    return siRetractionVector[CEtype][cassette-1];
}

- (double *) tileSpecFor: (int) iring {
    
    /*
     tileSpec 0: inner radius
              1: outer radius
              2: h = b = 2πρ/nphi (where ρ = outer radius of the inner ring of the pair (= inner radius of the outer ring of the pair))
              3: a = 2πρ/nphi (where ρ = inner radius of the inner ring of the pair)
     */
  
    int inr = iring - iFirstRing - 1;
    int outr = inr + 1;
    tileSpec[0] = rlist[inr];
    tileSpec[1] = rlist[outr];
    
    int imid = (outr)%2;
    int ir = inr;
    if(imid == 0) ir -= 1; //
    
    int nphi = lnphi[displayLayer - _tileL0];

    tileSpec[2] = 2.*M_PI*tileSpec[imid]/(double)nphi;
    tileSpec[3] = 2.*M_PI*rlist[ir]/(double)nphi;

    
    return tileSpec;
}
- (int) countOfTilesInLayer: (int) layer {
    
    int tileCount = 0;
    int nfull = lnphi[layer-_tileL0+1];

    int ip = ipointtiles[layer];

    BOOL HD = (lnphi[layer-_tileL0+1] > 288);
    int nbit = 24;
    if(HD) nbit = 36;

    for(int i=0; i<nringtiles[layer]; i++) {
        const char * l = [tileStrings[ip] UTF8String];
        int ordinal, ring;
        double rstart, rend, sipm;
        long hex[4];
        sscanf(l,"%d %d %lf %lf %lf %lX %lX %lX %lX",&ordinal,&ring,&rstart,&rend,&sipm,&hex[0],&hex[1],&hex[2],&hex[3]);
        long full = 0xFFFFFF;
        if(HD) full = 0xFFFFFFFFF;
        if(hex[0] == full && hex[1] == full && hex[2] == full && hex[3] == full) {
            tileCount += nfull;
        } else {
            for(int iword=0; iword < 4; iword++) {
                for(int ibit=0; ibit<nbit; ibit++) {
                    if(hex[iword] & one<<ibit) tileCount += 3; // File is for 120º
                }
            }
        }
        ip++;
    }

    return tileCount;
}

- (int) iphiTileAt: (NSPoint) pnt {
    /* -------------------------------------------
     From iphiRetractedTileAt: 6 May 2025
     returns:
     iphi of tile, if found
     -1 - no tile
     ------------------------------------------- */
   
    if(displayLayer+1 < _tileL0) return -1;
    
    double radius = sqrt(pnt.x*pnt.x + pnt.y*pnt.y);
    if(radius < _rfirst+radRetr) return -1;
    if(radius > _rlast+radRetr) return -1;
    
    double phi = atan2(pnt.y,pnt.x);
    if(phi < 0.) phi = phi + 2.*M_PI;
    phi = phi/(2.*M_PI);
    int nt = (int) (phi*(double)ntiles);

    for(int i=0; i<nringsmapped; i++) {
        if(radius > rlist[i]+radRetr && radius < rlist[i+1]+radRetr) {
            if(tilePresent[i][nt%(2*ntile)]) return nt;
        }
    }

    return -1;
}
/*
- (int) iphiRetractedTileAt: (NSPoint) pnt {
    // -------------------------------------------
    // From tilesContainPoint: 27 April 2025
    // returns:
    // iphi of tile, if found
    // -1 - no tile
     ------------------------------------------- //
   
    if(currentLayer < _tileL0) return -1;
    double retr = 4.;
    if(currentLayer < 38) retr = 8.;
    
    double radius = sqrt(pnt.x*pnt.x + pnt.y*pnt.y);
    if(radius < _rfirst+retr) return -1;
    if(radius > _rlast+retr) return -1;
    
    double phi = atan2(pnt.y,pnt.x);
    if(phi < 0.) phi = phi + 2.*M_PI;
    phi = phi/(2.*M_PI);
    int nt = (int) (phi*(double)ntiles);
    
    for(int i=0; i<nringsmapped; i++) {
        if(radius > rlist[i]+retr && radius < rlist[i+1]+retr) {
            if(tilePresent[i][nt%(2*ntile)]) return nt;
        }
    }

    return -1;
}
*/
- (int) tilesContainPoint: (NSPoint) pnt {
    /* -------------------------------------------
        From HexView stateAtPoint 23 Jan 2025
        istate: 0 - no sensor
                3 - tile
               99 - tile might be in Si
       ------------------------------------------- */

    if(displayLayer+1 < _tileL0) return 99;
    
    double radius = sqrt(pnt.x*pnt.x + pnt.y*pnt.y);
    
    if(radius < _rfirst+radRetr) return 99;
    if(radius > _rlast+radRetr) return 0;
    
    double phi = atan2(pnt.y,pnt.x);
    if(phi < 0.) phi = phi + 2.*M_PI;
    phi = phi/(2.*M_PI);
    int nt = (int) (phi*(double)ntiles);

    for(int i=0; i<nringsmapped; i++) {
        if(radius > rlist[i]+radRetr && radius < rlist[i+1]+radRetr) {
            if(tilePresent[i][nt%(2*ntile)]) return 3;
        }
    }

    return 99;
}

#pragma mark - private methods

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

- (void) fileReadAlert:(NSString *) message withInfo:(NSString *) info {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setInformativeText:info];
    [alert setAlertStyle:NSAlertStyleWarning];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }

}
    
- (void) simpleAlert: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setShowsSuppressionButton:NO];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }
    
}

@end
