//
//  HXGColorPicker.h
//  Hex
//
//  Created by Chris Seez on 06/03/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGNotifications.h"
#import "CSColours.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGColorPicker : NSWindowController {
    
    NSColorPanel * theColorPanel;
    
}

@property (assign) IBOutlet NSTextField * textField;
@property (assign) IBOutlet NSColorWell * colorWell;
@property int ipoint;
@property NSColor * workingColor;
@property NSString * message;

+ (id) sharedColorPicker;
- (void) orderBack:(id) sender;

- (IBAction) replaceColor:(id)sender;

//- (void) windowWillClose:(NSNotification *) notification;

@end

NS_ASSUME_NONNULL_END
