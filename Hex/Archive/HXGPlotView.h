//
//  HXGPlotView.h
//  Hex
//
//  Created by Chris Seez on 16/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTDColorControl.h"
#import "HistViewControl.h"
#import "HXGNotifications.h"

@interface HXGPlotView : NSView {
    
    HTDColorControl * colorControl;
    HistViewControl * theHist;

    
    NSRect frameRect;
    double * plotdata;
    double * depthdata;
    double bscl;
    double binsize, xlow, ylow;
    int nx,ny;
    double plotwidth,plotheight;
    double axiswidth,urmargin;
    NSRect axisRect;
    NSPoint loPoint, hiPoint;
    
    NSImage * plotImage;
    BOOL newplotimage;
    
    double scalemaxDat,scalemaxDep,scalemax;
    
    double xtext[20],ytext[20],xval[20],yval[20];
    int nxtext,nytext;

    NSBezierPath * xscale;
    NSBezierPath * yscale;
    NSBezierPath * path20x20;
    
    BOOL pdf, twenty;
    NSImage * scaleImage;
    NSString * titlestring;
    NSString * shorttitle;

    double profile[500];
    BOOL sliceactive,makingprofile,rotated,endrotation;
    double ycentre;
    double halflength;
    int clocktick,rotcount,nstart,nrot,nrollup;
    NSTimer * timer;
    NSBezierPath * line;
    NSBezierPath * linup;
    NSBezierPath * lindn;
    NSBezierPath * upperTriangle;
    NSBezierPath * lowerTriangle;
    
    NSBezierPath * end;
    
    NSColor * lineColor;
    NSColor * spotColor;
    double dline[2],phase;
    BOOL dragging;
    NSPoint mousePoint;
    NSPoint refPoint;


}

@property BOOL showDepth;
@property double xslice;
@property double yslice;


- (void) changeColors;

- (void) setPlotFrame:(NSRect)fRect;

- (void) setShortTitle:(NSString *) s;

- (void) setPlotParams: (int) nbinx and: (int) nbiny scale: (double) scale;

- (void) setPlotDimensions: (double) bsz xlow: (double) x0 ylow: (double) y0;

- (double) loadPlotData:(double *) d and: (double *) e;

- (void) setScaleMax: (double) s;

- (void) showTwenty:(BOOL) t;

- (void) showSlice:(BOOL)active;

- (void) rotateSlice:(BOOL)rot;

- (void) makeProfile;

- (void) displayProfile;

- (double) setDataDepth:(BOOL) dd;

- (void) savePDF:(NSString *) path withTitle:(NSString *) title;

- (void) dragUpdate:(NSNotification *) note;


@end
