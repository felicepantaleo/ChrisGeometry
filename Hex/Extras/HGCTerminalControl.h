//
//  HGCTerminalControl.h
//
//  Created by Chris Seez on 23/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "CSColours.h"
#import <Cocoa/Cocoa.h>

@interface HGCTerminalControl : NSWindowController {
    
    NSString * textstring;
    NSColor * foregColor;
    NSColor * backgColor;

}

@property NSScrollView * scrollview;
@property NSMenuItem * cpItem;
@property (assign) IBOutlet NSTextView * textview;
@property (assign) IBOutlet NSBox * titBox;
@property (assign) IBOutlet NSButton * printButton;
@property (assign) IBOutlet NSButton * trashButton;


+ (id) sharedTerminal;

- (IBAction) changeColor:(id)sender;

- (IBAction) trashString:(id)sender;

- (IBAction) printString:(id)sender;

- (void) setDarkBackground:(BOOL) dark;

- (void) makeWindowBig;

- (void) makeWindowSmall;

- (void) makeWindowMedium;

- (void) makeWindowWide;

- (void) displayString:(NSString *) string;

- (void) clearString;

- (NSString *) getHighlightString;

- (void) printSavedText;

@end
