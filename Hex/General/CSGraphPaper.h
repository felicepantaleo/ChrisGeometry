//
//  CSGraphPaper.h
//  Hex
//
//  Created by Chris Seez on 09/11/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSGraphPaper : NSObject {
    
    NSRect boundsRect;
    double power;
    double mantissa;
    double tenDeltax,tenDeltay;
    double fiveDeltax,fiveDeltay;
    double oneDeltax,oneDeltay;
    
    double xFirst,yFirst;
    double xLast,yLast;

    double wOne,wFive,wTen;
    double thicknessMultiplier;
    double alpha;
    NSColor * baseColor;
    NSColor * graphColor;

    NSBezierPath * tenLines;
    NSBezierPath * fiveLines;
    NSBezierPath * oneLines;
    
    NSBezierPath * axesBezier;
    
    BOOL axisLeft;
    BOOL axisRight;
    BOOL axisTop;
    BOOL axisBottom;
    
    BOOL ticksInsideX;
    BOOL ticksInsideY;

}

@property double fontSize;
@property NSString * fontName;


+ (id) squarePaperFor:(NSRect) brect AtLeastNxDivs:(int) mindiv;

+ (id) squarePaperFor:(NSRect) brect AtLeastNyDivs:(int) mindiv;

- (void) makeAxisLeft:(BOOL)l right:(BOOL)r top:(BOOL)t bottom:(BOOL)b;

- (void) setColor:(NSColor *) col transparency:(double) a andThickness: (double) t;

- (void) setTicksInsideX:(BOOL)x andY:(BOOL)y;

- (void) draw;

@end
