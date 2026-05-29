//
//  HXGCuCoolingPlates.m
//  Hex
//
//  Created by Chris Seez on 12/11/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGCuCoolingPlates.h"

@implementation HXGCuCoolingPlates

+ (id) sharedCuCoolingPlates {
    
    static dispatch_once_t pred;
    static HXGCuCoolingPlates * theCuPlates = nil;
    
    dispatch_once(&pred, ^{theCuPlates = [[self alloc] init]; });
    return theCuPlates;
    
}

- (id)init {
    
    [self readTheKarolFile];
    
    return self;
}

- (void) readTheKarolFile {
  
    NSString * file = @"CEE-CuPolygons";
    NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings];
 
}

- (void) decodeFileLines:(NSArray *) lineStrings {
 
    
    int layer = -1;
    NSMutableArray * xPoints;
    NSMutableArray * yPoints;
    
    for(int i=0; i<lineStrings.count; i++) {
        NSString * line = lineStrings[i];
        if(line.length < 1) break;
        NSArray * columns = [line componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@","]];
        NSString * Xstr = columns[1];
        if(Xstr.length < 1) continue;
        NSString * layerLabel = columns[0];
        if(layerLabel.length > 10) {
            if(layer > -1) {
                coolingCuCEEx[layer] = [NSArray arrayWithArray:xPoints];
                coolingCuCEEy[layer] = [NSArray arrayWithArray:yPoints];
            }
            layerLabel = [layerLabel substringFromIndex:14];
            layer = [layerLabel intValue] - 1;
            xPoints = [NSMutableArray arrayWithCapacity:20];
            yPoints = [NSMutableArray arrayWithCapacity:20];
        } else {
            NSString * Ystr = columns[2];
            [xPoints addObject:[NSNumber numberWithDouble:[Xstr doubleValue]]];
            [yPoints addObject:[NSNumber numberWithDouble:[Ystr doubleValue]]];
        }
    }
    coolingCuCEEx[layer] = [NSArray arrayWithArray:xPoints];
    coolingCuCEEy[layer] = [NSArray arrayWithArray:yPoints];
}

- (void) listPolygons {

    NSString * listing = @"Cu Cooling Plate Polygons\n-------------------------";
    BOOL forSunanda = NO;
    BOOL showR = YES;
    double rmax = 0.;
    double rmaxLayer[13];
    for (int i=0; i<13; i++) {
        listing = [listing stringByAppendingFormat:@"\n\nCassette layer %d\n%ld points",i+1,coolingCuCEEx[i].count];
        if(forSunanda) {
            listing = [listing stringByAppendingString:@"\nx:"];
            int npnt = (int) coolingCuCEEx[i].count;
            for (int j=0; j<npnt; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[coolingCuCEEx[i][j] doubleValue]];
            }
            
            listing = [listing stringByAppendingString:@"\ny:"];
            for (int j=0; j<npnt; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[coolingCuCEEy[i][j] doubleValue]];
            }
        } else {
            listing = [listing stringByAppendingString:@"\n(x,y):"];
            int npnt = (int) coolingCuCEEx[i].count;
            rmax = 0.;
            for (int j=0; j<npnt; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f, %8.2f",[coolingCuCEEx[i][j] doubleValue],[coolingCuCEEy[i][j] doubleValue]];
                if(showR) {
                    double r = sqrt([coolingCuCEEx[i][j] doubleValue]*[coolingCuCEEx[i][j] doubleValue] + [coolingCuCEEy[i][j] doubleValue]*[coolingCuCEEy[i][j] doubleValue]);
                    listing = [listing stringByAppendingFormat:@" (r =%8.2f)",r];
                    if(r>rmax) rmax=r;
                }
            }
            rmaxLayer[i] = rmax;
        }
    }
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"CuCoolingPlatePolygons";

    [theTerminal showWindow:self];
    [theTerminal makeWindowNarrow];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal displayString:listing];
 
    if(showR) {
        listing = @"\n\nMaximum radii\n--------------";
        for (int i=0; i<13; i++) {
            listing = [listing stringByAppendingFormat:@"\n%2d %8.2f",i+1,rmaxLayer[i]];
        }
        [theTerminal displayString:listing];
    }
}

- (NSBezierPath *) bezierCuCEEforCasLayer: (int) clayer {
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    if(clayer > 12) return path;
    
    NSArray * xVal = coolingCuCEEx[clayer];
    NSArray * yVal = coolingCuCEEy[clayer];

    [path setLineWidth:0.5];
    [path moveToPoint:NSMakePoint([xVal[0] doubleValue], [yVal[0] doubleValue])];
    for (int i = 1; i<xVal.count; i++) {
        [path lineToPoint:NSMakePoint([xVal[i] doubleValue], [yVal[i] doubleValue])];
    }
    [path closePath];

    return path;
}

@end
