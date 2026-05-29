//
//  HistViewControl.h
//  Hex
//
//  Created by Chris Seez on 25/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HistView.h"

@interface HistViewControl : NSWindowController {
    
    double freeHeight;
    double width;
    double height;
    double plotwidth;
    double plotheight;
    NSPoint windowOrigin;
    NSString * histWindowTitle;
    
}

@property (assign) IBOutlet HistView * histView;
@property NSButton * pdfButton;



+ (id) sharedHistViewControl;

+ (id) histViewControl;

- (IBAction) makePDF:(id)sender;

- (void) showWindowAt:(NSPoint)p withTitle:(NSString *) tit forPlotSize:(NSSize) s;

- (void) axisTitles: (NSString *) xtit And: (NSString *)ytit;

- (void) axisAttributedTitles: (NSAttributedString *) xtit And: (NSAttributedString *)ytit;

- (void) histFillColor:(NSColor *) fillColor;

- (void) histFillColor:(NSColor *) fillColor For:(int) n;

- (void) fixYmax:(double) ymax;

- (void) addLabel:(NSString *) label at:(NSPoint) p;

- (void) drawHistogram: (double *) contents Bins: (int) nbin Xlow: (double) xlo Dx: (double) dx Title: (NSString *) tit;

- (void) drawHistogram;

- (void) addHistogram:(double *)contents Bins:(int)nbin Xlow:(double)xlo Dx:(double)dx Title:(NSString *)tit;

- (void) addHistogram:(double *)contents;

- (void) addHistogram:(double *)contents withColor:(NSColor *) color;

@end
