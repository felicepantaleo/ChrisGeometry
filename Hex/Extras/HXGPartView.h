//
//  HXGPartView.h
//  Hex
//
//  Created by seez on 10/06/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGWafer.h"
#import "CSColours.h"


@interface HXGPartView : NSView
{
    NSColor *cola, *colb;
    
    NSMutableArray * wafers;
    NSMutableArray * wholes;
    NSMutableArray * parts;
    NSMutableArray * bisections;
    NSPoint textloc[20];
    NSPoint id47loc[14];
    NSArray * text;
    NSArray * name;
    NSRect frameRect;
    NSString * tableText;
    NSPoint tableLoc;
    
    NSImage * tableImage;
    
    double full, side;
        
    BOOL pdf;    
}

@property BOOL hardwareOrientation;
@property BOOL seenFromBack;
@property BOOL showDicingLines;

- (void) setPartFrame: (NSRect) fRect;

- (void) setColors;

- (void) makeParts47;

- (void) savePDF:(NSString *)path;

@end
