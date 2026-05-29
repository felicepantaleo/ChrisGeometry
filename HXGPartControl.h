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


@interface HXGPartControl : NSWindowController
{
    HXGPreferenceControl * thePreferences;
    int partType;
    
}


@property (assign) IBOutlet HXGPartView * partview;
@property (assign) IBOutlet NSButton * okbutton;
@property (assign) IBOutlet NSButton * pdfbutton;


- (IBAction) setVersion:(id)sender;

- (IBAction) ok:(id)sender;

- (IBAction) makepdf:(id)sender;

@end
