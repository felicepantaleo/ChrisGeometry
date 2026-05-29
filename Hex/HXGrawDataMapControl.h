//
//  HXGrawDataMapControl.h
//  Hex
//
//  Created by Chris Seez on 21/04/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGrawDataMapView.h"
#import "HXGNotifications.h"
#import "HGCTerminalControl.h"
#import "HXGHardwareNumbering.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGrawDataMapControl : NSWindowController {
    
    HGCTerminalControl * theTerminal;
    HXGHardwareNumbering * theHardwareNumbering;
   
    //----------------------------------------------------------
    // Index of these arrays is Si cell number minus one
    // Trying to make them redundant (16 April 2024)
    /*
    int LD0U[212],LD0V[212];
    BOOL LD0cFlag[212];
    int HD0U[468],HD0V[468];
    BOOL HD0cFlag[468];
    */
    /* ---------------------------------------------
     This is the new stuff using HXGHardwareNumbering
     April 2024
    ----------------------------------------------- */
    int * LDU;
    int * HDU;
    int * LDPU;
    int * HDPU;
    int * LDV;
    int * HDV;
    int * LDPV;
    int * HDPV;
    BOOL * LDcFlag;
    BOOL * HDcFlag;
    BOOL * LDPcFlag;
    BOOL * HDPcFlag;

    //*****
    int LD0pin[212],LD0ROC[212],LD0Trg[424];
    int HD0pin[468],HD0ROC[468],HD0Trg[936];
    int LD1pin[212],LD1ROC[212],LD1Trg[424];
    int LD2pin[212],LD2ROC[212],LD2Trg[424];
    int LD3pin[212],LD3ROC[212],LD3Trg[424];
    int LD4pin[212],LD4ROC[212],LD4Trg[424];
    int LD5pin[212],LD5ROC[212],LD5Trg[424];
    int HD1pin[468],HD1ROC[468],HD1Trg[936];
    int HD2pin[468],HD2ROC[468],HD2Trg[936];
    int HD3pin[468],HD3ROC[468],HD3Trg[936];
    int HD4pin[468],HD4ROC[468],HD4Trg[936];

    double LD0traces[216];
    //----------------------------------------------------------
    
//    int LD0Cell[12][12],HD0Cell[24][24];
    int LD0calib[6], LD0calibROC[6], LD0calibCell[6];
    int HD0calib[12], HD0calibROC[12], HD0calibCell[12];
    int LDPcalibCell[100]; // !!!
    int HDPcalibCell[100]; // !!!
    
    int LD1calib[6], LD1calibROC[6], LD1calibCell[6];
    int LD2calib[6], LD2calibROC[6], LD2calibCell[6];
    int LD3calib[6], LD3calibROC[6], LD3calibCell[6];
    int LD4calib[6], LD4calibROC[6], LD4calibCell[6];
    int LD5calib[6], LD5calibROC[6], LD5calibCell[6];
    int HD1calib[12], HD1calibROC[12], HD1calibCell[12];
    int HD2calib[12], HD2calibROC[12], HD2calibCell[12];
    int HD3calib[12], HD3calibROC[12], HD3calibCell[12];
    int HD4calib[12], HD4calibROC[12], HD4calibCell[12];

    //-----------------------------------------------------------
    
    // These arrays set to contain info specific to particular partial
    // wafer for which mapping is being displayed
    int * Ppin;
    int * PROC;
    int * Pcalib;
    int * PcalibROC;
    int * PcalCell;
    int * Ptrg;

    //BOOL LDsplitBase[212], HDsplitBase[468];

    int ipLD[6][37],ipHD[12][37];
    
    double plotheight,plotwidth,height,width;
    
    int rocPin[37],siCell[37],iu[37],iv[37],tlink[37],tcell[37];
    BOOL calib[37],unconnected[37],split[37];
    
    NSButton * pdfButton;
    
    BOOL selectedDense;
    int selectedPartial;
    int selectedRoc;
    int halfCount;
    int nHalves;
    int menuOffset;
    
    NSPopUpButton * partialPopUp;
    NSPopUpButtonCell * popCell;

    int LDcrosscheck[212],HDcrosscheck[470];

    BOOL debugPrint;
    int npart;
    int sPart[11];
}

@property (assign) IBOutlet HXGrawDataMapView * rawView;
@property (assign) IBOutlet NSButton * LDbutton;
@property (assign) IBOutlet NSButton * HDbutton;
@property (assign) IBOutlet NSStepper * stepper;
@property (assign) IBOutlet NSTextField * rocText;

//---- These 4 arrays contain the full lists of calibration cells
@property (readonly) int * LD0cCell;
@property (readonly) int * HD0cCell;
@property (readonly) int * LDPcCell;
@property (readonly) int * HDPcCell;

//@property (readonly) int * LDCell;
//@property (readonly) int * HDCell;
@property BOOL * LDsplit;
@property BOOL * HDsplit;
@property BOOL partialWafer;
@property NSString * mapText;
@property BOOL refTypeCode;

+ (id) sharedRawDataMap;

- (void) initialize;

- (void) readTheHexaboardFiles;

//- (void) loadU:(int *) U andV:(int *) V andCalFlag:(BOOL *)flag forDensity:(BOOL)dense andPartial:(BOOL) part;

- (IBAction) makePDF:(id)sender;
- (IBAction) makeCSV:(id)sender;
- (IBAction) changeSelectedRoc:(id)sender;

- (void) setupRawDataMapTextFile:(id) window;
- (void) setSelectedPartial:(int) sP;
- (void) partialWaferSetUp;
- (void) loadPartialsMapView;
- (void) selectPartialForDisplay;
- (void) wholesText;
- (void) partialsText;

- (NSString *) wholeUVMapForHD:(BOOL) dens;
- (NSString *) partialUVMapForHD:(BOOL) dens;

- (void) getTrgID:(int *) tid forHD:(BOOL) dens andPartial:(int) ipart;
//- (void) writeUVMapForHD:(BOOL) dens;
//- (void) writePartialUVMapForHD:(BOOL) dens;

@end

NS_ASSUME_NONNULL_END
