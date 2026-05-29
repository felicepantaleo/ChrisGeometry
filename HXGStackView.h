//
//  HXGStackView.h
//  Hex
//
//  Created by Chris Seez on 02/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackUp.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGStackView : NSView {

    HXGStackUp * theStack;

    NSImage * upperAbsorber;
    double cehAbsorbY;
    double cehDiagJump;

    BOOL CEE;
    double scale;
    double top;
    double xzero;
    double width;
}

- (void)makeDiagramFor:(BOOL)cee;

@end

NS_ASSUME_NONNULL_END
