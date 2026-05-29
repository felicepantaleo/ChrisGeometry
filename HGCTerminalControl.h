//
//  HGCTerminalControl.h
//  Lambda
//
//  Created by Chris Seez on 23/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

//#import "LAMLongitudinalControl.h"
#import "HGCMaterials.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

@interface HGCTerminalControl : NSWindowController {
    
    //LAMLongitudinalControl * theLongControl;
    HGCMaterials * materials;

    int ntot;
    double zAbs[100];
    double zSi[100];
    NSPoint innerPoints[100];
    NSPoint outerPoints[100];
    
    NSString * textstring;
    NSColor * indigoColor;
    NSColor * ivoryColor;
        
    double width,height;
    
    double ef[50];
    double hf[50];
    double hb[50];

}

@property NSScrollView * scrollview;
@property NSMenuItem * cpItem;
@property (assign) IBOutlet NSTextView * textview;

+ (id) sharedTerminal;

- (void) displayLayerdEdx:(double *) d;

- (void) displaySensorZ:(double *) z;

- (void) displaySFrontCEE:(double *)fCEE andCEH:(double *) fCEH;

- (void) displayString:(NSString *) string;

- (NSString *) getHighlightString;

@end
