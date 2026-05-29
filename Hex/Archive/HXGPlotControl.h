//
//  HXGPlotControl.h
//  Hex
//
//  Created by Chris Seez on 16/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HXGPlotView.h"
#import "HTDFadeView.h"
#import "HXGNotifications.h"

@interface HXGPlotControl : NSWindowController {
    
    NSView * titleBarView;
    double width, height;
    double plotwidth, plotheight, axiswidth, urmargin;
    double scale;
    double scalevalues[10];
    int nbinx, nbiny;
    double binsize, xlow, ylow;
    double scalemax;
    int ismax;
    NSString * titlestring;
    NSString * shorttitle;
    NSString * titletext;
    NSString * stitletext;
    BOOL twenty;
    BOOL showDepth;
    BOOL showSlice;
    BOOL rotated;
    
    NSMutableAttributedString * rotStr;
    NSMutableAttributedString * unrotStr;
}

@property (assign) IBOutlet NSWindow * plotwindow;

@property (assign) IBOutlet HXGPlotView * plotview;
@property (readonly) HTDFadeView * fview;
@property (assign) IBOutlet NSBox * controlbox;
@property NSButton * colsButton;
@property NSButton * histoButton;
@property NSButton * pdfButton;
@property NSButton * twentyButton;
@property NSButton * dataButton;
@property NSButton * depthButton;
@property NSButton * sliceButton;
@property NSButton * rotateButton;
@property NSButton * profileButton;

@property BOOL removed;

@property NSStepper * stepper;
@property NSTextField * maxlabel;
@property NSTextField * titlabel;


+ (id) sharedPlotControl;
- (IBAction) histoRemovedMaterial:(id)sender;
- (IBAction) changeColors:(id)sender;
- (IBAction) makePDF:(id)sender;
- (IBAction) set20x20:(id)sender;
- (IBAction) setDataDepth:(id)sender;
- (IBAction) toggleSlice:(id)sender;
- (IBAction) toggleRotated:(id)sender;
- (IBAction) makeProfile:(id)sender;
- (void) setPlotWidth: (int) w height: (int) h andScale: (double) s;
- (void) setPlotDimensions: (double) bsz xlow: (double) x0 ylow: (double) y0;
- (void) setTitle:(NSString *) tit andShort:(NSString *) stit;
- (void) loadArray:(double *) d and: (double *) e;

@end
