//
//  HXGDisplayPngControl.m
//  Hex
//
//  Created by Chris Seez on 20/02/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import "HXGDisplayPngControl.h"

@interface HXGDisplayPngControl ()

@end

const double windowBar = 30.;
const double menuBar = 30.;

@implementation HXGDisplayPngControl

+ (id) sharedPngDisplayControl {
    
    static dispatch_once_t pred;
    static HXGDisplayPngControl * thePngDisplay = nil;
    
    dispatch_once(&pred, ^{thePngDisplay = [[self alloc] init]; });
    return thePngDisplay;

}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGDisplayPngControl"];
    screenWidth = [[NSScreen mainScreen] frame].size.width;
    screenHeight = [[NSScreen mainScreen] frame].size.height;
    
    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];

}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    [self.window setTitle:windowTitle];
        
    NSString * imageFile;
    
    imageFile  = [[NSBundle mainBundle] pathForResource:pngFile ofType:@"png"];
    NSImage * image = [[NSImage alloc] initWithContentsOfFile:imageFile];

    double width, height;
    if(fixedWidth) {
        width = widthFraction*screenWidth;
        height = (width*image.size.height/image.size.width) + windowBar;
    } else {
        height = heightFraction*(screenHeight-menuBar-windowBar) + windowBar;
        width = (height*image.size.width/image.size.height);
    }
    
    NSRect wRect = NSMakeRect(leftSpaceFraction*screenWidth,screenHeight*(1.-topSpaceFraction) - height,width,height);
    [self.window setFrame:wRect display:YES];
    
    [_iView setFrame:_iView.superview.bounds];
    
    _iView.image = image;
    
}

- (void) setPngFile:(NSString *) filename {
    
    pngFile = filename;
}

- (void) setWindowTitle:(NSString *) title andPdfName:(NSString *) name {
    
    windowTitle = title;
    pdfName = name;
    
}

- (void) setWidthFraction:(double) fraction {
    
    widthFraction = fraction;
    fixedWidth = YES;
}

- (void) setHeightFraction:(double) fraction {
    
    heightFraction = fraction;
    fixedWidth = NO;
}
- (void) setTopFraction:(double) tfrac andLeftFraction:(double) lfrac {
    
    topSpaceFraction = tfrac;
    leftSpaceFraction = lfrac;
}

- (void) makePDF {
  
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
