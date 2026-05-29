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
#import "HXGWafer.h"
#import "HXGEtaRingsControl.h"
#import "HXGPreferenceControl.h"
#import "HXGHardwareConstants.h"
#import "HXGPositionControl.h"
#import "HXGPlotControl.h"
#import "HistViewControl.h"
#import "HXGCellControl.h"
#import "HGCTerminalControl.h"
#import "HXGNotifications.h"
#import "HXGLayerMapFiles.h"
#import "HXGCoverageControl.h"
#import "CSColours.h"
#import "HXGConstants.h"
#import "HXGCellLocatorWindowControl.h"
#import "HXGPruthviCSV.h"

@interface HXGMainControl : NSWindowController {
    
    HXGPreferenceControl * thePreferences;
    HXGHardwareConstants * theHardwareConstants;
    HXGPositionControl * thePosition;
    HXGPlotControl * thePlot;
    HXGCellControl * theCellControl;
    HXGCoverageControl * theCoverage;
    HistViewControl * theHist;
    HistViewControl * hist1;
    HistViewControl * hist2;
    HistViewControl * hist3;
    HistViewControl * hist4;
    HGCTerminalControl * theTerminal;
    HXGLayerMapFiles * theMapFiles;
    HXGEtaRingsControl * theRings;
    HXGCellLocatorWindowControl * theCellLocator;
    HXGPruthviCSV * thePruthviCSV;

    //           ***** March 2020 *****
    int layer; //  INTERNAL counting is from zero, using this variable
    //  EXTERNAL display and interface is (or is meant to be) by ordinal value
    // -------------------------------------------------------------------------
    
    NSScrollView * scrollView;
    NSRect vRect; // hexview frame rect (in locked - non-scrolling - state)
    NSRect scRect; // scrollView content rect (in unlocked - scrolling - state)
    double scrollmag;

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
    
#ifdef DEBUG
//    double etafirst[7000];
#endif

    int version;

    BOOL numberWafers;
    BOOL useDetId;
    BOOL showRetracted;
    BOOL showActiveWafer;
    BOOL rotateRotated;
    BOOL showGrid;
    BOOL showGridForPartials;
    BOOL showCassettes;
    BOOL markTypeOne;
    BOOL markTypeBar;
    BOOL scrolling;
    BOOL locked;
    BOOL numberCassettes;
    BOOL showCellLabels;
    

    BOOL showpoint;
    
    NSString * pathroot;
    NSString * path;
    
    NSString * siDirPath;
    //NSString * fullOtherPath;
    NSString * siNameFilePath;
    
    NSString * tileDirPath;
    //NSString * tileFilePath;
    NSString * tileNameFilePath;

    NSString * otherSiFileName;
    NSString * otherTileFileName;

    NSString * summary;
    
    BOOL onlyOneCassette,cassetteView;
    int oneCassette;
   
    NSSize halfBoundsSize;
    
    BOOL showbreakdown;
    
    /*
    double binsize, phistart, etastart;
    int nbinphi, nbineta;
    double maxDead[320000], runningDead[320000], deadStart[320000], runningStart[320000], totalDepth[320000];
    double removed[320];
    //BOOL removePb;
    BOOL trimCEH;
    int nscanlayers;
    double trimWidth;
     */
   
    //BOOL radiationLengths;
    //double * absorber;
    //double CEEremoval[28];
    //double CEHCu;
    
    
    //NSPoint innerPoints[100];
    //NSPoint outerPoints[100];
    //int nouter;
    //int nCEE;

}

@property (assign) IBOutlet NSTextField * summaryText;

@property (assign) IBOutlet NSWindow * mainwindow;
@property (assign) IBOutlet HXGHexView * hexview;

@property (assign) IBOutlet NSStepper * stepper;
@property (assign) IBOutlet NSSegmentedControl * layerSegs;
@property (assign) IBOutlet NSSlider * magSlide;
@property (assign) IBOutlet NSButton * lockButton;
@property (assign) IBOutlet NSButton * scrollButton;

@property (assign) IBOutlet NSButton * showCentreButton;
@property (assign) IBOutlet NSButton * showStructureButton;
@property (assign) IBOutlet NSButton * showCellLabelsButton;
@property (assign) IBOutlet NSButton * showEdgeIndexButton;

@property (assign) IBOutlet NSTextField * otherFileNamesField;
@property (assign) IBOutlet NSTextField * centreText;


@property (assign) IBOutlet NSButton * otherButton;
@property (assign) IBOutlet NSButton * v19Button;
@property (assign) IBOutlet NSButton * v17Button;

@property (assign) IBOutlet NSButton * retractedButton;
@property (assign) IBOutlet NSButton * activeOnlyButton;
@property (assign) IBOutlet NSButton * rotateButton;
@property (assign) IBOutlet NSButton * partialGridButton;
@property (assign) IBOutlet NSButton * gridButton;
@property (assign) IBOutlet NSButton * numberWafersButton;
@property (assign) IBOutlet NSButton * detIdbutton;
@property (assign) IBOutlet NSButton * chan1Button;
@property (assign) IBOutlet NSButton * barButton;
@property (assign) IBOutlet NSButton * axisButton;
@property (assign) IBOutlet NSButton * pluszButton;
@property (assign) IBOutlet NSButton * minuszButton;
@property (assign) IBOutlet NSButton * showCassetteButton;
@property (assign) IBOutlet NSButton * numberCassetteButton;
@property (assign) IBOutlet NSButton * oneCassetteButton;
@property (assign) IBOutlet NSButton * cassetteViewButton;
@property (assign) IBOutlet NSStepper * oneCassetteStepper;
@property (assign) IBOutlet NSTextField * oneCassetteText;

@property (assign) IBOutlet NSButton * pdfOptionsButton;
@property (assign) IBOutlet NSButton * pdfShowKeyButton;
@property (assign) IBOutlet NSButton * pdfShowSummaryButton;
@property (assign) IBOutlet NSButton * pdfShowHexDateButton;


@property (assign) IBOutlet NSButton * zoomButton;
@property (assign) IBOutlet NSTextField * testText;
@property (assign) IBOutlet NSButton * removeTestPointButton;
@property (assign) IBOutlet NSBox * testPointBox;
@property (assign) IBOutlet NSImageView * waferTypeKey;
@property (assign) IBOutlet NSBox * scrollThresholdBox;

@property BOOL testRetractions;
@property (readonly) int etaRingColor;


- (id) init;

- (void) showWindow:(id)sender;

- (void) windowDidLoad;

- (void) setShowCoords:(BOOL)show;

- (void) setShowFileLine:(BOOL)show;

- (void) setShowWaferCentre:(BOOL)show;

- (void) exportPDF;

- (void) exportMultiPDF;

- (void) writeWaferSummary;

- (void) pedroStyleSummary;

- (void) detIdCount;

- (void) detIdCountWithBreakdown;

- (void) checkSiTileOverlaps;

- (void) newPreferences:(NSNotification *) note;

- (void) newPosition:(NSNotification *) note;

- (void) deleteTestPoint;

- (void) performPruthviCheck;

- (void) newLayer:(NSNotification *) note;

- (void) newRings:(NSNotification *) note;

- (void) newCentre:(NSNotification *) note;

- (void) coverageStudy:(NSNotification *) note;

- (void) chooseOtherSiFileAndTile:(BOOL) tileAlso;

- (void) chooseOtherTileFile;


- (IBAction) changeLayer:(id)sender;

- (IBAction) changeLayerSegment:(id)sender;

- (IBAction) changeDisplay:(id)sender;

- (IBAction) changeFile:(id)sender;

- (IBAction) changeRetraction:(id)sender;

- (IBAction) changeActive:(id)sender;

- (IBAction) changeMarker:(id)sender;

- (IBAction) axisDisplay:(id)sender;

- (IBAction) changeMagnification:(id)sender;

- (IBAction) changeMagLock:(id)sender;

- (IBAction) changeScrolling:(id)sender;

- (IBAction) showCentre:(id)sender;

- (IBAction) zoomOnTestPoint:(id)sender;

- (IBAction) changeOnlyOneCassette:(id)sender;

- (IBAction) changePdfOptions:(id)sender;

- (void) testHisto;

- (BOOL) toggleWaferNumbering;

- (void) setDefaults;

@end
