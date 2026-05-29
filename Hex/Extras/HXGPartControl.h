//
//  HXGPartControl.h
//  Hex
//
//  Created by seez on 10/06/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGPartView.h"
#import "HXGPreferenceControl.h"


@interface HXGPartControl : NSWindowController {
    
    HXGPreferenceControl * thePreferences;
    
}


@property (assign) IBOutlet HXGPartView * partview;
@property (assign) IBOutlet NSButton * okbutton;
@property (assign) IBOutlet NSButton * frontbutton;
@property (assign) IBOutlet NSButton * backbutton;
@property (assign) IBOutlet NSButton * dicingbutton;
@property (assign) IBOutlet NSButton * hardwareOrientationbutton;


- (IBAction) changeFrontBack:(id)sender;

- (IBAction) useCheckBoxes:(id)sender;


- (IBAction) ok:(id)sender;

- (void) makePDF;

@end
