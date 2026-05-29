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
    
    BOOL dark;

}

@property (assign) IBOutlet NSBox * lightBox;
@property (assign) IBOutlet NSBox * darkBox;

@property NSScrollView * scrollview;
//@property NSMenuItem * cpItem;
@property (assign) IBOutlet NSTextView * textview;
@property (assign) IBOutlet NSBox * titBox;
@property (assign) IBOutlet NSButton * printButton;
@property (assign) IBOutlet NSButton * pdfButton;
@property (assign) IBOutlet NSButton * diskButton;
@property (assign) IBOutlet NSButton * trashButton;
@property NSString * suggestedName;


+ (id) sharedTerminal;

- (void) changedText:(NSNotification *) note;

- (IBAction) changeColor:(id)sender;

- (IBAction) trashString:(id)sender;

- (IBAction) printString:(id)sender;

- (IBAction) makePDF:(id)sender;

- (IBAction) saveToDisk:(id)sender;

- (void) setDarkBackground:(BOOL) dk;

- (void) makeWindowBig;

- (void) makeWindowNarrow;

- (void) makeWindowSmall;

- (void) makeWindowMedium;

- (void) makeWindowWide;

- (void) displayString:(NSString *) string;

- (void) clearString;

- (void) scrollToBottom;

- (NSString *) getHighlightString;

- (void) makePDF;

- (void) printSavedText;

@end
