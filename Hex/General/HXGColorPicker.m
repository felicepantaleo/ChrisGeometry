//
//  HXGColorPicker.m
//  Hex
//
//  Created by Chris Seez on 06/03/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGColorPicker.h"

@interface HXGColorPicker ()

@end

NSString * const HXGNewColourNotification = @"HXGNewColour";

@implementation HXGColorPicker

+ (id) sharedColorPicker {
    
    static dispatch_once_t pred;
    static HXGColorPicker * thePicker = nil;
    
    dispatch_once(&pred, ^{ thePicker = [[self alloc] init]; });
    return thePicker;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGColorPicker"];
    
    _message = @"";
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
//    NSLog(@"self.window.delegate = %@",self.window.delegate);
    
    [self.window setBackgroundColor:[NSColor blackColor]];

    
    [_textField setStringValue:_message];
    [_colorWell setColor:_workingColor];
    theColorPanel = [NSColorPanel sharedColorPanel];
    theColorPanel.showsAlpha = YES;
    [NSColorPanel setPickerMode:NSColorPanelModeRGB];
    
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}

- (IBAction) replaceColor:(id)sender {
    
    _workingColor = _colorWell.color;

    NSNumber * colPoint = [NSNumber numberWithInt:_ipoint];
    
    NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:_workingColor,@"newColor",colPoint,@"colPoint",nil];

    NSNotification * note = [NSNotification notificationWithName: HXGNewColourNotification object:self userInfo:d];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];

}

- (void) windowWillClose:(NSNotification *) notification {
    
    //NSLog(@"I try to close the window");
    [[NSColorPanel sharedColorPanel] close];
}

@end
