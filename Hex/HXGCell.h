//
//  HXGCell.h
//  Hex
//
//  Created by Chris Seez on 03/08/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "CSColours.h"
#import <Foundation/Foundation.h>

@interface HXGCell : NSObject {
    double hftof;
    double waferside;
    NSPoint waferPoints[6];
    double xoff[6],yoff[6];
    double sin60,cos60;

}

@property (readonly) int ID;
@property (readonly) NSBezierPath * gridCell;
@property (readonly) NSBezierPath * wholeCell;
@property (readonly) NSBezierPath * edgeCell;
@property NSBezierPath * partialCell;
@property (readonly) NSColor * cellColor;
@property (readonly) NSColor * partialColor;
@property int irColor;
@property int clickColor;


@property (readonly) NSPoint centre;
@property (readonly) BOOL inside;
@property BOOL inpartial;
@property (readonly) BOOL modifiedPartial;
@property (readonly) BOOL whole;
@property (readonly) BOOL small;
@property (readonly) BOOL edge;
@property (readonly) BOOL corner;
@property (readonly) BOOL notSplit;
@property BOOL split;
@property (readonly) int iu;
@property (readonly) int iv;
@property int iup; // ---- iu, iv coordinates with this placement
@property int ivp;
@property (readonly) int count;
@property (readonly) int iut;
@property (readonly) int ivt;
@property (readonly) int itc;
@property (readonly) BOOL keycell;
@property (readonly) double side;

+ (id) cellWithWafer:(NSPoint *)w side:(double)s at:(NSPoint) p ID:(int)i andDetId:(int *) d;

- (void) makePartialMods: (int) iflag;

@end
