//
//  HXGPreferenceControl.h
//  Hex
//
//  Created by seez on 28/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSColours.h"
#import "HXGNotifications.h"
#import "HXGConstants.h"

@interface HXGPreferenceControl : NSWindowController {
    NSArray * theWells;
    NSMutableData * prefdat;
    NSString * path;
    BOOL changed;
    NSMutableArray * hexcols;
    int backgroundflag;
}

@property NSString * hexDirectory;

@property (readonly) double casAlpha;
@property (readonly) int flags;
@property (readonly) BOOL buildNewStructure;
@property (readonly) NSColor * waferHighLightColor;
@property (readonly) NSColor * zoneColor1;
@property (readonly) NSColor * zoneColor2;
@property (readonly) NSColor * zoneColor3;
@property (readonly) NSColor * zoneColor4;
@property (readonly) NSColor * zoneColor5;

@property (assign) IBOutlet NSColorWell * colw0;
@property (assign) IBOutlet NSColorWell * colw1;
@property (assign) IBOutlet NSColorWell * colw2;
@property (assign) IBOutlet NSColorWell * colw3;
@property (assign) IBOutlet NSColorWell * colw4;
@property (assign) IBOutlet NSColorWell * colw5;
//@property (assign) IBOutlet NSTextField * eightftof;
@property (assign) IBOutlet NSSlider * alphaSlide;
@property (assign) IBOutlet NSButton * plainButton;
@property (assign) IBOutlet NSButton * semiTransparentButton;
@property (assign) IBOutlet NSButton * starsButton;
@property (assign) IBOutlet NSButton * reptilesButton;

+ (id) sharedPreferences;

- (void) orderBack:(id) sender;

- (IBAction) showWindow: (id) sender;

- (IBAction)newcolor:(id)sender;

//- (IBAction)newvalue:(id)sender;

- (IBAction)newOpacity:(id)sender;

- (IBAction)newBackground:(id)sender;

- (IBAction)revertToFactory:(id)sender;

- (IBAction)ok:(id)sender;

- (NSArray *) getColors;

- (void) writePrefs;

- (BOOL) readPrefs;

- (void) setDefaultValues;

- (void) simpleAlert: (NSString *) message;

@end
