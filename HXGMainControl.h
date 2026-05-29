//
//  HXGMainControl.h
//  Hex
//
//  Created by seez on 26/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//
//

#import <Cocoa/Cocoa.h>
#import "HXGHexView.h"
#import "HXGPreferenceControl.h"
#import "HXGPositionControl.h"
#import "HXGPlotControl.h"
#import "HistViewControl.h"
//#import "LAMLongitudinalControl.h"
#import "HXGCellControl.h"
#import "HGCTerminalControl.h"
#import "HXGNotifications.h"
#import "HXGLayerMapFiles.h"
#import "CSColours.h"

@interface HXGMainControl : NSWindowController
{
    HXGPreferenceControl * thePreferences;
    HXGPositionControl * thePosition;
    HXGPlotControl * thePlot;
    HXGCellControl * theCellControl;
    // HXGInnerBoundaryControl * theInnerBoundaryControl;
    //LAMLongitudinalControl * theLAMLongControl;
    HistViewControl * theHist;
    HistViewControl * hist1;
    HistViewControl * hist2;
    HistViewControl * hist3;
    HistViewControl * hist4;
    HGCTerminalControl * theTerminal;
    // HXGGlobalPersistence * theConfiguration;
    HXGLayerMapFiles * theMapFiles;

    //           ***** March 2020 *****
    int layer; //  INTERNAL counting is from zero, using this variable
    //  EXTERNAL display and interface is (or is meant to be) by ordinal value
    // -------------------------------------------------------------------------

    //           *** May 2021 ***
    // Variables relevant for change to new 47 layer (longitudinal reoptimized)
    // - nLayers
    // - centreoncentre
    // - BOOL mercedes = layer%2 in HXGHexView
    // ? Introduce "New 47 layer geometry" checkbox in xib
    //
    
    dispatch_group_t group;

    double width;
    double height;
    
    int nLayers;
    double zLayer[100],riLayer[100],roLayer[100],sroLayer[100];
    
    double etainr,etaout;
    double tanang, z0, r0;
     
    double ro;
    double ri;
    double sro;
    double zL;
    
    BOOL centreoncentre;
    
    BOOL numberWafers;
    BOOL useDetId;
    BOOL useV17;
    BOOL rotateRotated;
    BOOL showGrid;
    BOOL showCassettes;
    BOOL markZero;
    BOOL markTypeOne;

    BOOL showpoint;
    double etatest,phitest;
    
    NSString * path;
    
    NSString * summary;
    
    double binsize, phistart, etastart;
    int nbinphi, nbineta;
    double maxDead[320000], runningDead[320000], deadStart[320000], runningStart[320000], totalDepth[320000];
    double removed[320];
    BOOL removePb;
    BOOL trimCEH;
    int nscanlayers;
    double trimWidth;
   
    BOOL radiationLengths;
    double * absorber;
    double CEEremoval[28];
    double CEHCu;
    
    double rSens[100];
    
    NSPoint innerPoints[100];
    NSPoint outerPoints[100];
    int nouter;
    int nCEE;

    
}

@property (assign) IBOutlet NSTextField * summaryText;

@property (assign) IBOutlet NSWindow * mainwindow;
@property (assign) IBOutlet HXGHexView * hexview;

@property (assign) IBOutlet NSStepper * stepper;
@property (assign) IBOutlet NSSegmentedControl * layerSegs;
// @property (assign) IBOutlet NSButton * paintPartialbutton;
 
@property (assign) IBOutlet NSButton * detIdbutton;
@property (assign) IBOutlet NSButton * v17Button;
@property (assign) IBOutlet NSButton * v16Button;
@property (assign) IBOutlet NSButton * axisButton;
@property (assign) IBOutlet NSButton * pluszButton;
@property (assign) IBOutlet NSButton * minuszButton;
@property (assign) IBOutlet NSButton * rotateButton;
@property (assign) IBOutlet NSButton * gridButton;
@property (assign) IBOutlet NSButton * numberWafersButton;
@property (assign) IBOutlet NSButton * markZeroButton;
@property (assign) IBOutlet NSButton * chan1Button;
@property (assign) IBOutlet NSButton * barButton;
@property (assign) IBOutlet NSButton * showCassetteButton;
@property (assign) IBOutlet NSButton * zoomButton;

@property (assign) IBOutlet NSTextField * testText;
@property (assign) IBOutlet NSButton * removeTestPointButton;
@property (assign) IBOutlet NSBox * testPointBox;


- (id) init;

- (void) showWindow:(id)sender;

- (void) windowDidLoad;

- (void) setShowCoords:(BOOL)show;

- (void) setShowFileLine:(BOOL)show;

- (void) exportPDF;

- (void) exportMultiPDF;

- (void) writeWaferSummary;

- (void) newPreferences:(NSNotification *) note;

- (void) newPosition:(NSNotification *) note;

- (void) deleteTestPoint;

- (void) newLayer:(NSNotification *) note;

- (IBAction) changeLayer:(id)sender;

- (IBAction) changeLayerSegment:(id)sender;

- (IBAction) changeDisplay:(id)sender;

- (IBAction) changeFile:(id)sender;

- (IBAction) changeMarker:(id)sender;

- (IBAction) axisDisplay:(id)sender;

- (IBAction) changeMagnification:(id)sender;

- (IBAction) zoomOnTestPoint:(id)sender;

- (void) gapsStudy;

- (void) testHisto;

- (BOOL) toggleWaferNumbering;

- (void) setDefaults;

@end
