//
//  HXGZbarControl.h
//  Hex
//
//  Created by Chris Seez on 05/03/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGZbarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HXGZbarControl : NSWindowController {
   
    NSRect vRect;
    NSRect zBricks[14];
}

@property (assign) IBOutlet HXGZbarView * zBarView;

+ (id) sharedZbarControl;
- (void) addZbrick: (NSRect) zb index: (int) i;

@end

NS_ASSUME_NONNULL_END
