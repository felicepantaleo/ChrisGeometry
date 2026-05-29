//
//  HXGDisplayAbsorbersControl.h
//  Hex
//
//  Created by Chris Seez on 07/11/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGNotifications.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGDisplayAbsorbersControl : NSWindowController {
  
    long flags;
    BOOL showCEEPb;
    BOOL showCEECu;
    BOOL showCEHSpacers;
    BOOL showZbars;

    

}

@property (assign) IBOutlet NSButton * showSpacersButton;
@property (assign) IBOutlet NSButton * showCEEPbButton;
@property (assign) IBOutlet NSButton * showCEECuButton;
@property (assign) IBOutlet NSButton * showZbarsButton;
@property (assign) IBOutlet NSSlider * oddAlphaSlide;

+ (id) sharedAbsorberControl;
- (void) orderBack:(id) sender;
- (IBAction) changeDisplay:(id)sender;

@end

NS_ASSUME_NONNULL_END
