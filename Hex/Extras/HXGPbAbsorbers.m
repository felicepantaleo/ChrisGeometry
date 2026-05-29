//
//  HXGPbAbsorbers.m
//  Hex
//
//  Created by Chris Seez on 16/10/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGPbAbsorbers.h"

@implementation HXGPbAbsorbers

+ (id) sharedPbAbsorbers {
    
    static dispatch_once_t pred;
    static HXGPbAbsorbers * theAbsorbers = nil;
    
    dispatch_once(&pred, ^{ theAbsorbers = [[self alloc] init]; });
    return theAbsorbers;
    
}

- (id)init {
    
    [self readTheKarolFile];
    
    return self;
}

- (void) readTheKarolFile {
  
    NSString * file = @"PbPolyVertices";
    NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings];
 
}

- (void) decodeFileLines:(NSArray *) lineStrings {
    
    int layer = -1;
    BOOL isA = YES;
    NSMutableArray * xPoints;
    NSMutableArray * yPoints;
    for(int i=0; i<lineStrings.count; i++) {
        NSString * line = lineStrings[i];
        if(line.length < 1) break;
        NSArray * columns = [line componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@","]];
        NSString * Xstr = columns[1];
        if(Xstr.length < 2) continue;
        NSString * layerLabel = columns[0];
        if(layerLabel.length > 7) {
            if(layer > -1) {
                if(isA) {
                    leadAbsorberAx[layer] = [NSArray arrayWithArray:xPoints];
                    leadAbsorberAy[layer] = [NSArray arrayWithArray:yPoints];
               } else {
                   leadAbsorberBx[layer] = [NSArray arrayWithArray:xPoints];
                   leadAbsorberBy[layer] = [NSArray arrayWithArray:yPoints];
               }
            }
            layerLabel = [layerLabel substringFromIndex:6];
            NSString * type = [layerLabel substringFromIndex:layerLabel.length-1];
            //NSLog(@"Got <%@>: <%@>; type = %@",layerLabel,Xstr,type);
            layer = [[layerLabel substringToIndex:layerLabel.length-1] intValue] - 1;
            isA = [type isEqualToString:@"A"];
            //NSLog(@"layer %d, isA %d",layer,isA);
            xPoints = [NSMutableArray arrayWithCapacity:15];
            yPoints = [NSMutableArray arrayWithCapacity:15];
        }
        NSString * Ystr = columns[2];
        [xPoints addObject:[NSNumber numberWithDouble:[Xstr doubleValue]]];
        [yPoints addObject:[NSNumber numberWithDouble:[Ystr doubleValue]]];
    }
    if(isA) {
        leadAbsorberAx[layer] = [NSArray arrayWithArray:xPoints];
        leadAbsorberAy[layer] = [NSArray arrayWithArray:yPoints];
   } else {
       leadAbsorberBx[layer] = [NSArray arrayWithArray:xPoints];
       leadAbsorberBy[layer] = [NSArray arrayWithArray:yPoints];
   }

}

- (void) listPolygons {

    BOOL forSunanda = NO;
    NSString * listing = @"Pb Absorber Polygons\n--------------------";
    for (int i=0; i<13; i++) {
        listing = [listing stringByAppendingFormat:@"\n\nCassette layer %d A\n%ld points",i+1,leadAbsorberAx[i].count];
        if(forSunanda) {
            listing = [listing stringByAppendingString:@"\nx:"];
            for (int j=0; j<leadAbsorberAx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[leadAbsorberAx[i][j] doubleValue]];
            }
            
            listing = [listing stringByAppendingString:@"\ny:"];
            for (int j=0; j<leadAbsorberAx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[leadAbsorberAy[i][j] doubleValue]];
            }
        } else {
            listing = [listing stringByAppendingString:@"\n(x,y):"];
            for (int j=0; j<leadAbsorberAx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f, %8.2f",[leadAbsorberAx[i][j] doubleValue],[leadAbsorberAy[i][j] doubleValue]];
            }

        }

            listing = [listing stringByAppendingFormat:@"\n\nCassette layer %d B\n%ld points",i+1,leadAbsorberBx[i].count];
        if(forSunanda) {
            listing = [listing stringByAppendingString:@"\nx:"];
            for (int j=0; j<leadAbsorberBx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[leadAbsorberBx[i][j] doubleValue]];
            }
            
            listing = [listing stringByAppendingString:@"\ny:"];
            for (int j=0; j<leadAbsorberBx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f",[leadAbsorberBy[i][j] doubleValue]];
            }
        } else {
            listing = [listing stringByAppendingString:@"\n(x, y):"];
            for (int j=0; j<leadAbsorberBx[i].count; j++) {
                listing = [listing stringByAppendingFormat:@"\n%8.2f, %8.2f",[leadAbsorberBx[i][j] doubleValue],[leadAbsorberBy[i][j] doubleValue]];
            }
        }
    }
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"PbAbsorberPolygons";
    [theTerminal showWindow:self];
    [theTerminal makeWindowNarrow];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal displayString:listing];

}

- (NSBezierPath *) bezierAforCassetteLayer: (int) clayer {
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    if(clayer > 12) return path;
    
    NSArray * xVal = leadAbsorberAx[clayer];
    NSArray * yVal = leadAbsorberAy[clayer];

    [path setLineWidth:0.5];
    [path moveToPoint:NSMakePoint([xVal[0] doubleValue], [yVal[0] doubleValue])];
    for (int i = 1; i<xVal.count; i++) {
        [path lineToPoint:NSMakePoint([xVal[i] doubleValue], [yVal[i] doubleValue])];
    }
    [path closePath];

    return path;
}

- (NSBezierPath *) bezierBforCassetteLayer: (int) clayer {
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    if(clayer > 12) return path;

    NSArray * xVal = leadAbsorberBx[clayer];
    NSArray * yVal = leadAbsorberBy[clayer];

    [path setLineWidth:0.5];
    [path moveToPoint:NSMakePoint([xVal[0] doubleValue], [yVal[0] doubleValue])];
    for (int i = 1; i<xVal.count; i++) {
        [path lineToPoint:NSMakePoint([xVal[i] doubleValue], [yVal[i] doubleValue])];
    }
    [path closePath];

    return path;
}

@end
