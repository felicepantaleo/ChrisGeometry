//
//  HXGaideMemoireControl.h
//  Hex
//
//  Created by Chris Seez on 24/06/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGaideMemoireControl : NSWindowController {
    
    NSString * suggestedName;
    
}

@property (assign) IBOutlet NSImageView * iView;
@property int ihelp;

+ (id) sharedAideMemoireControl;
- (void) makePDF;

@end

NS_ASSUME_NONNULL_END
