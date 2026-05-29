//
//  HXGZbarControl.m
//  Hex
//
//  Created by Chris Seez on 05/03/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import "HXGZbarControl.h"

@interface HXGZbarControl ()

@end

@implementation HXGZbarControl

+ (id) sharedZbarControl {
    
    static dispatch_once_t pred;
    static HXGZbarControl * theZbarControl = nil;
    
    dispatch_once(&pred, ^{ theZbarControl = [[self alloc] init]; });
    return theZbarControl;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGZbarControl"];
    
    return self;
}

- (void) addZbrick: (NSRect) zb index: (int) i {
    
    zBricks[i] = zb;
   // NSLog(@"Added brick %2d: %8.2f %8.2f %8.2f %8.2f ",i,zb.origin.x,zb.origin.y,zb.size.width,zb.size.height);
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
 
    // First calculate the aspect ratio
    double maxR = -1.E10;
    double minR = 1.E10;
    double maxZ = -1.E10;
    double minZ = 1.E10;
    for (int i=0; i<14; i++) {
        if(maxR < zBricks[i].origin.x) maxR = zBricks[i].origin.x + zBricks[i].size.width;
        if(minR > zBricks[i].origin.x) minR = zBricks[i].origin.x;
        if(maxZ < zBricks[i].origin.y) maxZ = zBricks[i].origin.y + zBricks[i].size.height;
        if(minZ > zBricks[i].origin.y) minZ = zBricks[i].origin.y;
    }
    
    double widview = 1.2*(maxR-minR);
    double hgtview = 1.2*(maxZ-minZ);

    // Now define the window
    NSRect wRect;
    double height = [[NSScreen mainScreen] frame].size.height-30.;
    double width = widview*(height-30.)/hgtview;

    wRect.size = NSMakeSize(width,height);
    wRect.origin = NSZeroPoint;

    [[self window] setFrame:wRect display:YES];
    
    // Here we define the view

    [_zBarView setFrame:_zBarView.superview.bounds];
    NSRect bRect = NSMakeRect(minR-0.1*(maxR-minR),minZ-0.1*(maxZ-minZ),widview,hgtview);
    [_zBarView setBounds:bRect];

    [_zBarView drawBricks:zBricks];
}

- (void) makePDF {
  
    NSString * pdfName = @"Zbar model";
    NSSavePanel * export = [NSSavePanel savePanel];
    NSString * filename = [pdfName stringByAppendingString:@".pdf"];
    [export setNameFieldStringValue:filename];
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
