//
//  HXGStackWindowControl.h
//  Hex
//
//  Created by Chris Seez on 02/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackUp.h"
#import "HXGStackView.h"
#import "CSColours.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGStackWindowControl : NSWindowController {
    
    HXGStackUp * theStack;
    NSSegmentedControl * stackType;
    NSStepper * stepper;
    NSButton * pdfButton;
    NSTextField * descriptionLabel;
    NSTextField * resultLabel;
    NSTextField * stepperValue;
    NSColor * ivoryColor;
    NSColor * indigoColor;
    
    int ncassette;
    
    BOOL CEE;

}

@property (assign) IBOutlet HXGStackView * stackView;


+ (id) sharedStackControl;
- (id) init;

- (IBAction) changeSection:(id)sender;
- (IBAction) newStepperValue:(id)sender;
- (IBAction) makePDF:(id)sender;
@end

NS_ASSUME_NONNULL_END
