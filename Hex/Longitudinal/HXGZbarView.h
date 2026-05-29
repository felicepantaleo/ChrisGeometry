//
//  HXGZbarView.h
//  Hex
//
//  Created by Chris Seez on 05/03/2026.
//  Copyright © 2026 seez. All rights reserved.
//

#import "CSColours.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGZbarView : NSView {
    
    NSRect zBricks[14];
}

- (void) drawBricks: (NSRect *) zb;

@end

NS_ASSUME_NONNULL_END
