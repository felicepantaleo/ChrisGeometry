//
//  HXGPartControl.m
//  Hex
//
//  Created by seez on 10/06/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGPartControl.h"

@interface HXGPartControl ()

@end

@implementation HXGPartControl

- (id)init
{
    self=[super initWithWindowNibName: @"HXGPartControl"];
    thePreferences = [HXGPreferenceControl sharedPreferences];
    
    return self;
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    NSRect fRect=self.window.contentView.frame;
    fRect.origin.y += 40.;
    fRect.size.height -= 40.;
    [_partview setPartFrame:fRect];
    
    [_partview setColors]; // !!!!!!!!!!!!!!!
    [_partview makeParts47];
    
    BOOL back = NO;
    [_frontbutton setState:!back];
    [_backbutton setState:back];
    _partview.seenFromBack = back;
    
    _partview.showDicingLines = NO;
    [_dicingbutton setState:NO];
    _partview.hardwareOrientation = NO;
    [_hardwareOrientationbutton setState:NO];

}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
}


- (IBAction) changeFrontBack:(id)sender {
    
    BOOL back = ([sender tag] == 1);
    [_frontbutton setState:!back];
    [_backbutton setState:back];
    _partview.seenFromBack = back;
    [_partview setNeedsDisplay:YES];
    
}

- (IBAction) useCheckBoxes:(id)sender {
      
    _partview.showDicingLines = [_dicingbutton state];
    _partview.hardwareOrientation = [_hardwareOrientationbutton state];
   [_partview setNeedsDisplay:YES];
    
}

- (IBAction) ok:(id)sender
{
    [self close];
}

- (void) makePDF {
    
    NSString * filename = @"PartWafers.pdf";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            [self->_partview savePDF:pdfpath];
        }
    }];
}

@end
