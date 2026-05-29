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
    
    NSBezierPath * histoBez[10];
    NSBezierPath * outlineBez[10];
    NSColor * histFillColor[10];

    
    NSMutableAttributedString * powerstring;
    NSString * fname;
    int fsize;

    double xValueToCoord;
    double yValueToCoord;
    
    BOOL drawLabel;
    NSString * labelString;
    NSPoint labelPoint;

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

- (void) setPlotFrame:(NSRect)fRect;

- (void) addLabel:(NSString *) label at:(NSPoint) p;

- (void) setFillColor:(NSColor *) col For: (int) n;

- (void) setUpHist;

- (void) makeHistoBezier;

- (void) savePDF:(NSString *) path;

@end
