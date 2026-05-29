//
//  HGCTerminalControl.m
//  Lambda
//
//  Created by Chris Seez on 23/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "HGCTerminalControl.h"

@interface HGCTerminalControl ()

@end
const double zFront = 3195.5; // (with B-field on, i.e. 3210.5 - 15.)

@implementation HGCTerminalControl

+ (id) sharedTerminal {
    
    static dispatch_once_t pred;
    static HGCTerminalControl * theTerminal = nil;
    
    dispatch_once(&pred, ^{ theTerminal = [[self alloc] init]; });
    return theTerminal;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HGCTerminalControl"];
    textstring = @"";
    indigoColor = [NSColor indigoBlue];
    ivoryColor = [NSColor ivoryWhite];
    textstring = @"";
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
   
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];

    height = [[NSScreen mainScreen] frame].size.height-22.0;   //
    width = [[NSScreen mainScreen] frame].size.width * 0.5;
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,height);
    width = MIN(400.,width); // 660
    height = MIN(300.,height);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    [_scrollview setFrame:_scrollview.superview.bounds];
    [_scrollview setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];

    [_textview setFont:[NSFont fontWithName:@"Menlo" size:13]];
    [_textview setContinuousSpellCheckingEnabled:NO];
    [_textview setDrawsBackground:YES];
    
    [_scrollview setDrawsBackground:NO];
    [_textview setBackgroundColor:ivoryColor];
    [_textview setTextColor:indigoColor];
    
    [_textview setString:textstring];
    
    [_textview setNeedsDisplay:YES];
}

- (void)windowDidResignKey:(NSNotification *)notification {
    [_cpItem setEnabled:NO];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [_cpItem setEnabled:YES];
}

#pragma mark - New stuff using this as a terminal
- (void) displayLayerdEdx:(double *) d {
    
    textstring = [textstring stringByAppendingString:@"\n//--- Integrated dEdx in front of sensor\ndouble layerdEdx[47] = {"];
    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%5.2f,",d[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%5.2f}; // (MeV)\n",d[46]];

    [_textview setString:textstring];
    [_textview setNeedsDisplay:YES];

}

- (void) displaySensorZ:(double *) z {
    
    textstring = [textstring stringByAppendingString:@"\n//--- Si sensor z position (front from front HGCAL z = 3210.5)\ndouble sensorZ[47] = {"];
    for (int i=0; i<46; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",z[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f}; // (mm)\n",z[46]];

    [_textview setString:textstring];
    [_textview setNeedsDisplay:YES];

}

- (void) displaySFrontCEE:(double *)fCEE andCEH:(double *) fCEH {
    
    textstring = [textstring stringByAppendingString:@"\n//--- Front face of CEE cassettes\ndouble frontCEE[13] = {"];
    for (int i=0; i<12; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",fCEE[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f} // (mm)\n",fCEE[12]];

    textstring = [textstring stringByAppendingString:@"\n//--- Front face of CEH absorbers\ndouble frontCEH[21] {"];
    for (int i=0; i<20; i++) {
        if(i%10 == 0) textstring = [textstring stringByAppendingString:@"\n"];
        textstring = [textstring stringByAppendingFormat:@"%7.2f,",fCEH[i]];
    }
    textstring = [textstring stringByAppendingFormat:@"%7.2f}; // (mm)\n",fCEH[20]];

}

- (void) displayString:(NSString *) string {
    
    textstring = [textstring stringByAppendingString:string];
    [_textview setString:textstring];
    [_textview setNeedsDisplay:YES];

}

- (NSString *) getHighlightString {
    
    NSString * highlight = [[_textview string] substringWithRange:[_textview selectedRange]];
 
    return highlight;
}


@end
