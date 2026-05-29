//
//  HXGDisplayPngControl.h
//  Hex
//
//  Created by Chris Seez on 20/02/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGDisplayPngControl : NSWindowController {
    
    NSString * windowTitle;
    NSString * pdfName;
    NSString * pngFile;
    BOOL fixedWidth;
    double widthFraction;
    double heightFraction;
    double topSpaceFraction;
    double leftSpaceFraction;
    
    double screenWidth;
    double screenHeight;
}

@property (assign) IBOutlet NSImageView * iView;

+ (id) sharedPngDisplayControl;

- (void) setPngFile:(NSString *) filename;
- (void) setWindowTitle:(NSString *) title andPdfName:(NSString *) name;
- (void) setWidthFraction:(double) fraction;
- (void) setHeightFraction:(double) fraction;
- (void) setTopFraction:(double) tfrac andLeftFraction:(double) lfrac;

- (void) makePDF;

@end

NS_ASSUME_NONNULL_END
