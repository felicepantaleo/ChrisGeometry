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
    NSColor *col0, *col1, *col2, *col3, *cola, *colb;
    
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
    
    double full, side;
        
    BOOL pdf;    
}

@property int partType;

- (void) setPartFrame: (NSRect) fRect;

- (void) setColors:(NSArray *) hexcols;

- (void) makeParts50;

- (void) makeParts47;

- (void) savePDF:(NSString *)path;

@end
