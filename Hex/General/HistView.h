//
//  HistView.h
//  Hex
//
//  Created by Chris Seez on 25/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "CSColours.h"
#import <Cocoa/Cocoa.h>

@interface HistView : NSView {
   
    NSRect frameRect;
    NSRect axisRect;
    NSRect titleRect;
    NSRect xtitRect;
    NSRect ytitRect;
    NSRect pdfrect;
    
    double xlomarg,ylomarg,xhimarg,yhimarg;
    
    int ypower;
    int nymaj;
    double ymajnum[10];
    double yvlab[10];
    double xvlab;
    NSString * yformatStr;
    NSBezierPath * yaxisBez;
    double scaleMax;
        
    int nxmaj;
    double xmajnum[10];
    double xhlab[10];
    double yhlab;
    NSString * xformatStr;
    NSBezierPath * xaxisBez;

    NSBezierPath * stackBez; // This will go
    
    NSBezierPath * histoBez[10];      // [100] This is testing only!!!!
    NSBezierPath * outlineBez[10];
    NSColor * histFillColor[10];

    
    NSMutableAttributedString * powerstring;
    NSString * fname;
    int fsize;

    double xValueToCoord;
    double yValueToCoord;
    
    double scaleToCoord;
    double xorigin;
    double yorigin;
    
    BOOL drawLabel;
    NSString * labelString;
    NSPoint labelPoint;
    
    int npointLabels;
    NSString * pointLabelString[50];
    NSPoint pointLabelPnt[50];

    int narrow;
    NSBezierPath * arrowBez[10];
    double phiArrow[10];

}

@property NSString * title;
@property NSMutableAttributedString * xtit;
@property NSMutableAttributedString * ytit;
@property double * contents;
@property double * higher;
@property int nbin;
@property double xlo;
@property double deltax;
@property double fixedYmax;
@property BOOL binDividers;
@property int nstacked;
@property BOOL specialPlot;

- (void) setPlotFrame:(NSRect)fRect;

- (void) addLabel:(NSString *) label at:(NSPoint) p;

- (void) addPointLabel:(NSString *) label at:(NSPoint) p;

- (void) setFillColor:(NSColor *) col For: (int) n;

- (void) setUpHist;

- (void) setUpPlot:(NSRect) f;

- (void) makeHistoBezier;

- (void) makePlotBezier: (NSPoint *) plotPnt;

- (void) savePDF:(NSString *) path;

- (void) drawArrowFrom:(NSPoint) s To:(NSPoint) e headSize:(double) h;

@end
