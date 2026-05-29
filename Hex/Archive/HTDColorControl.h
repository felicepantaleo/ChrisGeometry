//
//  HTDColorControl.h
//
//  Created by seez on 19/05/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTDFadeView.h"
#import <Carbon/Carbon.h>
#import "HXGNotifications.h"
#import "HXGConstants.h"


@interface HTDColorControl : NSWindowController
{
    NSString * htdDirectory;
    
    NSArray * theWells;
    NSMutableData * cdat;

    BOOL changed;
}

extern char const cryptoHTD[8];

@property NSArray * colorArray;

@property (assign) IBOutlet HTDFadeView * fview;

@property (assign) IBOutlet NSColorWell * cw0;
@property (assign) IBOutlet NSColorWell * cw1;
@property (assign) IBOutlet NSColorWell * cw2;
@property (assign) IBOutlet NSColorWell * cw3;
@property (assign) IBOutlet NSColorWell * cw4;
@property (assign) IBOutlet NSColorWell * cw5;
@property (assign) IBOutlet NSColorWell * cw6;
@property (assign) IBOutlet NSColorWell * cw7;
@property (assign) IBOutlet NSColorWell * cw8;
@property (assign) IBOutlet NSColorWell * cw9;
@property (assign) IBOutlet NSColorWell * cw10;
@property (assign) IBOutlet NSColorWell * cw11;
@property (assign) IBOutlet NSColorWell * cw12;
@property (assign) IBOutlet NSColorWell * cw13;
@property (assign) IBOutlet NSColorWell * cw14;
@property (assign) IBOutlet NSColorWell * cw15;

+ (id) sharedColors;

- (IBAction)setToDefault:(id)sender;
- (IBAction)newColor:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction) showWindow: (id) sender;

- (void) makeLookup;

- (void) setDefaultCoding: (NSMutableData *) data;
- (BOOL) writeUsingPath: (NSString*) path;
- (BOOL) readUsingPath: (NSString*) path;
- (void) writeCurrent;

@end
