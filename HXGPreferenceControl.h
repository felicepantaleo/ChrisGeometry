//
//  HXGPreferenceControl.h
//  Hex
//
//  Created by seez on 28/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGNotifications.h"

@interface HXGPreferenceControl : NSWindowController {
    NSArray * theWells;
    NSMutableData * prefdat;
    NSString * path;
    BOOL changed;
    NSMutableArray * hexcols;
}

@property NSString * hexDirectory;

@property (readonly) double ftof8;
@property (readonly) double spare2; // free/empty/dummy
@property (readonly) double spare;  // free/empty/dummy
@property (readonly) int flags;


@property (assign) IBOutlet NSColorWell * colw0;
@property (assign) IBOutlet NSColorWell * colw1;
@property (assign) IBOutlet NSColorWell * colw2;
@property (assign) IBOutlet NSColorWell * colw3;
@property (assign) IBOutlet NSTextField * eightftof;


+ (id) sharedPreferences;

- (IBAction) showWindow: (id) sender;

- (IBAction)newcolor:(id)sender;

- (IBAction)newvalue:(id)sender;

- (IBAction)revertToFactory:(id)sender;

- (IBAction)ok:(id)sender;

- (NSArray *) getColors;

- (BOOL) writePrefs;

- (BOOL) readPrefs;

- (void) setDefaultValues;


@end
