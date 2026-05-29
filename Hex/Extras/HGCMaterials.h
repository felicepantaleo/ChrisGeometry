//
//  HGCMaterials.h
//  Lambda
//
//  Created by Chris Seez on 21/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "CSColours.h"
#import "HGCTerminalControl.h"
#import <Cocoa/Cocoa.h>

@interface HGCMaterials : NSWindowController {
    
    HGCTerminalControl * theTerminal;
    
    NSMutableDictionary * dic;
    NSArray * mat;
    NSString * textstring;
    NSColor * indigoColor;
    NSColor * ivoryColor;

    double PCB[3];
    double epoxy[3];
    double kapton[3];
    //double retvals[3];

}

@property (assign) IBOutlet NSTextView * textview;

+ (id) sharedMaterials;

- (double) x0For:(NSString *) material;

- (double) lambdaFor:(NSString *) material;

- (double) dEdxFor:(NSString *) material;

- (void) showMaterials;

@end
