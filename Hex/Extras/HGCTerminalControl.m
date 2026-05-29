//
//  HGCTerminalControl.m
//
//  Created by Chris Seez on 23/05/2018.
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "HGCTerminalControl.h"

@interface HGCTerminalControl ()

@end

double alpha = 0.8;

@implementation HGCTerminalControl

+ (id) sharedTerminal {
    
    static dispatch_once_t pred;
    static HGCTerminalControl * theTerminal = nil;
    
    dispatch_once(&pred, ^{ theTerminal = [[self alloc] init]; });
    return theTerminal;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HGCTerminalControl"];

    foregColor = [NSColor indigoBlue];
    backgColor = [NSColor ivoryWhite];
    backgColor = [backgColor colorWithAlphaComponent:alpha];

    textstring = @"";
    
    [_printButton setToolTip:@"print ⌘P"];
    [_trashButton setToolTip:@"clear ⌥⌘X"];

    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
   
    [self.window setOpaque:NO];
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self terminalLayoutConstraints];
/*
    height = [[NSScreen mainScreen] frame].size.height-22.0;   //
    width = [[NSScreen mainScreen] frame].size.width * 0.5;
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,height);
    width = MIN(400.,width); // 660
    height = MIN(300.,height);
    wRect.size = NSMakeSize(width,height);
    

    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
*/
    [_textview setFont:[NSFont fontWithName:@"Menlo" size:13]];
    [_textview setContinuousSpellCheckingEnabled:NO];
    [_textview setDrawsBackground:YES];
    
    [_scrollview setDrawsBackground:NO];
    [_textview setBackgroundColor:backgColor];
    [_textview setTextColor:foregColor];

    [_textview setString:textstring];
    
    [_textview setSelectedTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          foregColor, NSBackgroundColorAttributeName,
          backgColor, NSForegroundColorAttributeName,
          nil]];

    
    //[_textview setNeedsDisplay:YES];

}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    [_cpItem setTitle:@"Print text"];
    [_printButton setToolTip:@"print ⌘P"];
    [_trashButton setToolTip:@"clear ⌥⌘X"];
//    [self.window makeKeyWindow];
//    [self.window orderFront:self];
    
}

- (void) makeWindowBig {
    
    double h = [[NSScreen mainScreen] frame].size.height-22.0;   //
    double w = [[NSScreen mainScreen] frame].size.width * 0.5;

    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,h);
    wRect.size = NSMakeSize(w*0.93,h);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
 //   [self terminalLayoutConstraints];
    [self showWindow:self];

}

- (void) makeWindowSmall {
    
    double h = [[NSScreen mainScreen] frame].size.height-22.0;   //
    double w = [[NSScreen mainScreen] frame].size.width * 0.5;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,h*0.7);
    wRect.size = NSMakeSize(w*0.65,h*0.35);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    [self terminalLayoutConstraints];
    [self showWindow:self];

}

- (void) makeWindowMedium {
    
    double h = [[NSScreen mainScreen] frame].size.height-22.0;   //
    double w = [[NSScreen mainScreen] frame].size.width * 0.5;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,h*0.7);
    wRect.size = NSMakeSize(w*0.65,h*0.55);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    [self terminalLayoutConstraints];
    [self showWindow:self];

}

- (void) makeWindowWide {
    
    double h = [[NSScreen mainScreen] frame].size.height-22.0;   //
    double w = [[NSScreen mainScreen] frame].size.width * 0.5;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(0.,h*0.7);
    wRect.size = NSMakeSize(w*0.93,h*0.3);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];
    [self terminalLayoutConstraints];
    [self showWindow:self];

}

- (void) terminalLayoutConstraints {

/*
    [NSLayoutConstraint
    constraintWithItem:_scrollview
    attribute:NSLayoutAttributeTop
    relatedBy:NSLayoutRelationEqual
    toItem:self.window.contentView
    attribute:NSLayoutAttributeTop
    multiplier:1.0
    constant:-20.].active = YES;
*/
    [NSLayoutConstraint
    constraintWithItem:_scrollview
    attribute:NSLayoutAttributeBottom
    relatedBy:NSLayoutRelationEqual
    toItem:self.window.contentView
    attribute:NSLayoutAttributeBottom
    multiplier:1.0
    constant:0.].active = YES;

    [NSLayoutConstraint
    constraintWithItem:_scrollview
    attribute:NSLayoutAttributeLeft
    relatedBy:NSLayoutRelationEqual
    toItem:self.window.contentView
    attribute:NSLayoutAttributeLeft
    multiplier:1.0
    constant:0.].active = YES;

    [NSLayoutConstraint
    constraintWithItem:_scrollview
    attribute:NSLayoutAttributeRight
    relatedBy:NSLayoutRelationEqual
    toItem:self.window.contentView
    attribute:NSLayoutAttributeRight
    multiplier:1.0
    constant:0.].active = YES;

    [_scrollview setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];



    [NSLayoutConstraint
    constraintWithItem:_titBox
    attribute:NSLayoutAttributeTop
    relatedBy:NSLayoutRelationEqual
    toItem:self.window.contentView
    attribute:NSLayoutAttributeTop
    multiplier:1.0
    constant:0.].active = YES;
 
/*
    [NSLayoutConstraint
    constraintWithItem:_titBox
    attribute:NSLayoutAttributeBottom
    relatedBy:NSLayoutRelationEqual
    toItem:_scrollview
    attribute:NSLayoutAttributeTop
    multiplier:1.0
    constant:0.].active = YES;
*/
/*
    [_titBox addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titBox(==20.)]"
                                                                     options:0
                                                                     metrics:nil
                                                      views:NSDictionaryOfVariableBindings(_titBox)]];
    
*/
    [_titBox setAutoresizingMask: NSViewWidthSizable|NSViewMinYMargin];

}

- (void) setDarkBackground:(BOOL) dark {
    
    if(dark) {
        foregColor = [NSColor greenColor];
        backgColor = [[NSColor blackColor] colorWithAlphaComponent:alpha-0.2];
    } else {
        foregColor = [NSColor indigoBlue];
        backgColor = [[NSColor ivoryWhite] colorWithAlphaComponent:alpha];
    }
    
    [_textview setBackgroundColor:backgColor];
    [_textview setTextColor:foregColor];
    [_textview setSelectedTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          foregColor, NSBackgroundColorAttributeName,
          backgColor, NSForegroundColorAttributeName,
          nil]];


}


- (void)windowDidResignKey:(NSNotification *)notification {
    [_cpItem setTitle:@"Export pdf..."];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [_cpItem setTitle:@"Print text"];
}

#pragma mark - IBAction

- (IBAction) changeColor:(id)sender {
    
    
    [self setDarkBackground:[sender tag] == 1];

    [_textview setNeedsDisplay:YES];

}

- (IBAction) trashString:(id)sender {
    
    textstring = @"";
    [_textview setString:textstring];
    [_textview setNeedsDisplay:YES];
    
}

- (IBAction) printString:(id)sender {
    
    [self printSavedText];
    
}

#pragma mark - display

- (void) displayString:(NSString *) string {
  
    textstring = [textstring stringByAppendingString:string];
    [_textview setString:textstring];
    [_textview setNeedsDisplay:YES];

}

- (void) clearString {
    
    textstring = @"";

}

#pragma mark - utilities

- (NSString *) getHighlightString {
    
    NSString * highlight = [[_textview string] substringWithRange:[_textview selectedRange]];
 
    return highlight;
}

- (void) printSavedText {


    NSPrintOperation * printOperation;
    // NSMakeRect(0, 0, 468, 648)
    NSTextView * printview = [[NSTextView alloc] initWithFrame:self.window.frame];
    [printview setEditable:true];
    NSRange range = NSMakeRange( 0, [[printview string] length]);
    [printview setSelectedRange:range];
    [[[printview textStorage] mutableString] appendString:textstring];
    //[printview setFont:[NSFont fontWithName:@"Menlo" size:11]];
    [[printview textStorage] setFont:[NSFont fontWithName:@"Menlo" size:9]];

    printOperation = [NSPrintOperation printOperationWithView:printview];
    
    [printOperation runOperation];
     
}

@end
