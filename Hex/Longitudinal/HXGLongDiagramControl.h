//
//  HXGLongDiagramControl.h
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGNotifications.h"
#import "HXGLongView.h"
#import "HXGColorPicker.h"
#import "HGCTerminalControl.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGLongDiagramControl : NSWindowController {
 
    HXGColorPicker * theColorPicker;
    HGCTerminalControl * theTerminal;

    NSRect outerRect;
    NSRect vRect; // longView frame rect

    NSScrollView * scrollView;
    BOOL scrolling;

    NSPoint crossHairs;
    
    double zLow,rLow,scale;
    
    NSSegmentedControl * etaSegs[5];
    NSStepper * stepper[5];
    NSButton * activeB[5];
    NSButton * activeR[5];
    NSButton * setColorButton[5];
    double values[5],digh[5], digt[5], digu[5];
    
    NSButton * colBoxButton;
    NSStepper * colStepper;
    int iCol;
    
    int idigit;
    int last;
    
    NSDate * lastDigit;
    int jdigit;
    BOOL firstDigit;

    NSTimeInterval tstart;
    int repcount;

}


@property (assign) IBOutlet HXGLongView * longView;
@property (assign) IBOutlet NSTextField * positionLabel;
@property (assign) IBOutlet NSButton * calibrationButton;
@property (assign) IBOutlet NSButton * fixedButton;
@property (assign) IBOutlet NSButton * scrollButton;
@property (assign) IBOutlet NSSlider * magSlide;
@property (assign) IBOutlet NSTextField * magLabel;
@property (assign) IBOutlet NSButton * testButton;




+ (id) sharedDiagramControl;

- (IBAction) changeScrolling:(id)sender;
//- (IBAction) showCrossHairs:(id)sender;
- (IBAction) calibrationMode:(id)sender;
- (IBAction) adjustPosition:(id)sender;
- (IBAction) changeMagnification:(id)sender;
- (IBAction) debugDump:(id)sender;

- (void) newCrossHairs:(NSNotification *) note;
- (void) makePDF;

@end

NS_ASSUME_NONNULL_END
