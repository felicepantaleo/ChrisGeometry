//
//  HXGPositionControl.h
//  Hex
//
//  Created by Chris Seez on 14/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HXGPositionControl : NSWindowController

@property (assign) IBOutlet NSButton * showButton;
@property (assign) IBOutlet NSTextField * etastring;
@property (assign) IBOutlet NSTextField * phistring;


@property BOOL showposition;
@property double eta;
@property double phi;




+ (id) sharedPositionControl;

- (void) orderBack:(id) sender;

- (void) setState:(BOOL)on eta:(double)e phi:(double)p;

- (void) notify;

- (IBAction) changeState:(id)sender;

- (IBAction)ok:(id)sender;

@end
