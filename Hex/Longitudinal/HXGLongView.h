//
//  HXGLongView.h
//  Hex
//
//  Created by Chris Seez on 22/02/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGPreferenceControl.h"
#import "CSBeziers.h"
#import "CSColours.h"
#import "HXGNotifications.h"
#import "PDFKit/PDFKit.h"
#import "Quartz/Quartz.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGLongView : NSView {

    HXGPreferenceControl * thePreferences;

    NSImage * edmsImage;
    NSPDFImageRep * pdfRep;
    NSBezierPath * etaLine[5];
    NSBezierPath * etaZone[5];
    int iZoneCol[5];
    int iZoneButton[5];
    NSMutableAttributedString * etaLabel[5];
    NSRect labelRect[5];
    NSRect labelBox[5];
    NSAffineTransform * xform[5];
    BOOL pdf;
    NSRect vRect;
    NSRect frameRect;
    NSColor * colorOption[5];
}

@property NSPoint crossHairs;
@property BOOL showcoords;
@property BOOL calibrationMode;
@property int nlines;
@property int nzones;
//@property NSColor * zoneColor;
@property double zLow;
@property double rLow;
@property double scale;
@property NSString * fileName;
@property double scrollmag;
@property BOOL scrolling;
@property NSScrollView * scrollView;

- (id) initWithFrame:(NSRect)fRect;
- (void) setLongViewFrame:(NSRect)fRect;
- (void) loadDiagram;
- (void) setViewBounds;
- (void) centreLongViewAt:(NSPoint) centre;
- (NSString *) stringForWindowToViewOf:(NSPoint) pnt;
- (NSString *) stringForViewToWindowOf:(NSPoint) pnt;
- (void) addEtaLine:(double) eta;
- (void) addEtaZoneFrom:(double) eta1 To:(double) eta2 Button:(int) ibut;
- (void) setZone: (int) izone colorTo: (int) icol;
- (void) setColorFor:(int) iCol To:(NSColor *) col;
- (NSColor *) getColor: (int) icol;
- (void) mouseDown:(NSEvent *)theEvent;
- (void) savePDF:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
