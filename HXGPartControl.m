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

- (void) showWindow:(id)sender
{
    [super showWindow:sender];
    NSRect fRect=self.window.contentView.frame;
    fRect.origin.y += 40.;
    fRect.size.height -= 40.;
    [_partview setPartFrame:fRect];
    
    [_partview setColors:[thePreferences getColors]];
    partType = 1;
    
    if(partType == 0) {
        [_partview makeParts50];
    } else {
        [_partview makeParts47];

    }

}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
}

- (IBAction) setVersion:(id)sender {
    
    if([sender selectedSegment] == 0) {
        [_partview makeParts50];
    } else {
        [_partview makeParts47];
    }
}

- (IBAction) ok:(id)sender
{
    [self close];
}

- (IBAction) makepdf:(id)sender
{
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
