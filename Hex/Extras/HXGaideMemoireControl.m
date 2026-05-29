//
//  HXGaideMemoireControl.m
//  Hex
//
//  Created by Chris Seez on 24/06/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGaideMemoireControl.h"

@interface HXGaideMemoireControl ()

@end

@implementation HXGaideMemoireControl

+ (id) sharedAideMemoireControl {
    
    static dispatch_once_t pred;
    static HXGaideMemoireControl * theHelp = nil;
    
    dispatch_once(&pred, ^{ theHelp = [[self alloc] init]; });
    return theHelp;

}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGaideMemoireControl"];
        
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];

    NSString * imageFile;
    NSString * pathname;
    
    if(_ihelp == 0) pathname = @"HexHelp";
    else if(_ihelp == 1) pathname = @"SiFileLineKey";
    
    suggestedName = [@"AideMemoire" stringByAppendingString:pathname];
    
    imageFile  = [[NSBundle mainBundle] pathForResource:pathname ofType:@"png"];
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:imageFile];
    _iView.image = image;
    
}

- (void) makePDF {
  
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:suggestedName];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF file"];
    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * pdfpath = [[export URL] path];
            NSData * data = [self.window.contentView dataWithPDFInsideRect:self.window.contentView.frame];
            [data writeToFile:pdfpath options:0 error:nil];
        }
    }];

}

@end
