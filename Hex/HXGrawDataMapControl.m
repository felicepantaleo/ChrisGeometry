//
//  HXGrawDataMapControl.m
//  Hex
//
//  Created by Chris Seez on 21/04/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGrawDataMapControl.h"

NSString * const HXGNewWaferSetUpNotification = @"HXGNewWaferSetUp";

@interface HXGrawDataMapControl ()

@end

//const int nLD = 198;
//const int nHD = 444;

/* -------------------------------------------------------
   Quite a lot of cleaning up to be done...
   - save CSV stuff not really needed

   ------------------------------------------------------- */

//#pragma GCC diagnostic ignored "-Wgnu-folding-constant"


@implementation HXGrawDataMapControl
+ (id) sharedRawDataMap {
    
    static dispatch_once_t pred;
    static HXGrawDataMapControl * theRawDataMap = nil;
    
    dispatch_once(&pred, ^{ theRawDataMap = [[self alloc] init]; });
    return theRawDataMap;
    
}

- (id)init {
    
    self=[super initWithWindowNibName: @"HXGrawDataMapControl"];
    
    [self initialize];
    
 /*
    _LDsplit = LDsplitBase;
    for (int i=0; i<212; i++) {
        _LDsplit[i] = NO;
        if(LDPcFlag[i]) {
            BOOL listed = NO;
            for (int j=0; j<6; j++) {
                if(LDPcalibCell[j] == i+1) listed = YES;
            }
            if(!listed) {
                LDPcFlag[i] = NO;
                _LDsplit[i] = YES;
            }
        }
    }

    _HDsplit = HDsplitBase;
    for (int i=0; i<468; i++) {
        _HDsplit[i] = NO;
        if(HDPcFlag[i]) {
            BOOL listed = NO;
            for (int j=0; j<12; j++) {
                if(HDPcalibCell[j] == i+1) listed = YES;
            }
            if(!listed) {
                HDPcFlag[i] = NO;
                _HDsplit[i] = YES;
            }
        }
    }
*/
    return self;
}

- (void) initialize {
    
    _partialWafer = NO;
    
    if(!theHardwareNumbering) theHardwareNumbering = [HXGHardwareNumbering sharedHardwareNumbering];
    
    LDU  = theHardwareNumbering.LDU;
    HDU  = theHardwareNumbering.HDU;
    LDPU = theHardwareNumbering.LDPU;
    HDPU = theHardwareNumbering.HDPU;
    LDV  = theHardwareNumbering.LDV;
    HDV  = theHardwareNumbering.HDV;
    LDPV = theHardwareNumbering.LDPV;
    HDPV = theHardwareNumbering.HDPV;
    LDcFlag  = theHardwareNumbering.LDcFlag;
    LDPcFlag = theHardwareNumbering.LDPcFlag;
    HDcFlag  = theHardwareNumbering.HDcFlag;
    HDPcFlag = theHardwareNumbering.HDPcFlag;

    [self readTheHexaboardFiles];
    
    _LDsplit = theHardwareNumbering.LDsplit;
    _HDsplit = theHardwareNumbering.HDsplit;

}

- (void) readTheHexaboardFiles {
 
    NSString * file = @"LD0-hexaboardMap";
    NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    NSString * fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    NSArray * lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD0pin andROC:LD0ROC andTrig:LD0Trg count:198];


    file = @"HD0-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:HD0pin andROC:HD0ROC andTrig:HD0Trg count:468];
    
    //--- Correct the pin numbering (wrong in HD0 mapping spreadsheet)
    for (int i=0; i<444; i++) {HD0pin[i] -= 1;}

    //debugPrint = YES;
    //debugPrint = NO;
    
    file = @"LD1-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD1pin andROC:LD1ROC andTrig:LD1Trg count:212];


    file = @"LD2-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD2pin andROC:LD2ROC andTrig:LD2Trg count:212];

    file = @"LD3-hexaboardMapV11";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD3pin andROC:LD3ROC andTrig:LD3Trg count:212];

    file = @"LD4-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD4pin andROC:LD4ROC andTrig:LD4Trg count:212];

    file = @"LD5-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:LD5pin andROC:LD5ROC andTrig:LD5Trg count:212];


    file = @"HD1-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:HD1pin andROC:HD1ROC andTrig:HD1Trg count:468];

    file = @"HD2-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:HD2pin andROC:HD2ROC andTrig:HD2Trg count:468];
    
    file = @"HD3-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:HD3pin andROC:HD3ROC andTrig:HD3Trg count:468];

    file = @"HD4-hexaboardMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    [self decodeFileLines:lineStrings forPin:HD4pin andROC:HD4ROC andTrig:HD4Trg count:468];
    
    //debugPrint = YES;
    //debugPrint = NO;


    //---- Now the calib maps ---------------------------------------------------------------------
    
    file = @"LD0-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD0calib ROC: LD0calibROC andCell: LD0calibCell];


    file = @"HD0-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: HD0calib ROC: HD0calibROC andCell: HD0calibCell];


    file = @"LD1-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD1calib ROC: LD1calibROC andCell: LD1calibCell];
 
    file = @"LD2-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD2calib ROC: LD2calibROC andCell: LD2calibCell];
 
    file = @"LD3-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD3calib ROC: LD3calibROC andCell: LD3calibCell];

    file = @"LD4-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD4calib ROC: LD4calibROC andCell: LD4calibCell];

    file = @"LD5-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeCalibFile:lineStrings forCalib: LD5calib ROC: LD5calibROC andCell: LD5calibCell];

    file = @"HD1-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    for(int i=0;i<12;i++) { HD1calibROC[i] = 999;}
    [self decodeCalibFile:lineStrings forCalib: HD1calib ROC: HD1calibROC andCell: HD1calibCell];

    file = @"HD2-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    for(int i=0;i<12;i++) { HD2calibROC[i] = 999;}
    [self decodeCalibFile:lineStrings forCalib: HD2calib ROC: HD2calibROC andCell: HD2calibCell];
    
    file = @"HD3-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    for(int i=0;i<12;i++) { HD3calibROC[i] = 999;}
    [self decodeCalibFile:lineStrings forCalib: HD3calib ROC: HD3calibROC andCell: HD3calibCell];
    
    file = @"HD4-calibMap";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    for(int i=0;i<12;i++) { HD4calibROC[i] = 999;}
    [self decodeCalibFile:lineStrings forCalib: HD4calib ROC: HD4calibROC andCell: HD4calibCell];


    _LD0cCell = LD0calibCell;
    _HD0cCell = HD0calibCell;
    _LDPcCell = LDPcalibCell;
    _HDPcCell = HDPcalibCell;
    
    int ldpartialcalib[6] = {13,65,90,149,160,169};
    for(int i=0; i<6; i++) {LDPcalibCell[i]=ldpartialcalib[i];}
    int hdpartialcalib[12] = {31,39,114,139, 146,221,253,306, 335,385,426,433};
    for(int i=0; i<12; i++) {HDPcalibCell[i]=hdpartialcalib[i];}
    
    //---- Extra for LD0 trace lengths ------
    // LD-Full_Analog_Channels.csv
  
    file = @"LD-Full_Analog_Channels";
    fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];
    fileContents = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:nil];
    lineStrings = [fileContents componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if([lineStrings[lineStrings.count-1]  isEqual: @""])
        lineStrings = [lineStrings subarrayWithRange:NSMakeRange(0, lineStrings.count-1)];
    [self decodeTraceFile:lineStrings To: LD0traces];

   return;
}

- (void)windowDidLoad {
    [super windowDidLoad];
 
    height = 0.98 * ([[NSScreen mainScreen] frame].size.height-22.);
    width = 0.372 * height; // was 0.42
    plotheight = height - 16.;
    
    plotwidth = width;
    
    NSRect wRect;                                // Here we define the window
    wRect.origin = NSMakePoint(360.,[[NSScreen mainScreen] frame].size.height-height-22.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrame:wRect display:YES];

    NSRect vRect;                                // Here we define the view
    vRect.origin = NSMakePoint(0.0,height - plotheight - 22.);
    vRect.size = NSMakeSize(plotwidth,plotheight);
    id test = [_rawView initWithFrame:vRect]; // some redundancy to sort out here
    if(test != _rawView) {
        NSLog(@"Marbles lost");
    }
    
    _rawView.pdf = NO;
    
    // ------------------- pop-up menu for partials choice
    NSRect brect = NSMakeRect(145.,42.,165.,20.);
    partialPopUp = [[NSPopUpButton alloc] initWithFrame:brect pullsDown:NO];
    popCell = [partialPopUp cell];
    [partialPopUp setAction:@selector(changePartial:)];
    [self makePartialMenu];
    [[[self window] contentView] addSubview:partialPopUp];

    
    for(int i=0;i<198;i++) {
        LDcrosscheck[i] = -1;
    }
    for(int i=0;i<444;i++) {
        HDcrosscheck[i] = -1;
    }

}

- (void) makePartialMenu {
    
    int const nchoice = 10;
    NSString * partialMenu[10] = {@"LD1 Top (half)",@"LD2 Bottom (half)",@"LD3 Left (semi)",@"LD4 Right (semi)",@"LD5 Five",@"seperator",@"HD1 Top (chop4)",@"HD2 Bottom (chop2)",@"HD3 Left (semi-)",@"HD4 Right(semi-)"};
    BOOL choiceEnabled[10] = {YES,YES,YES,YES,YES,NO,YES,YES,YES,YES};
    
    npart = 0;
    [partialPopUp removeAllItems];
    [popCell setAutoenablesItems:NO];
    for(int i = 0; i < nchoice; i++) {
        if([partialMenu[i] isEqualToString:@"seperator"]) [popCell.menu addItem:[NSMenuItem separatorItem]];
        else {
            [popCell addItemWithTitle:partialMenu[i]];
            [[popCell itemAtIndex:i] setEnabled:choiceEnabled[i]];
        }
        if(choiceEnabled[i]) {
            sPart[npart] = i;
            npart++;
        }
    }
    
    selectedPartial = sPart[0];
    [popCell selectItemAtIndex:selectedPartial];

    selectedDense = NO;
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
        
    selectedDense = NO;


    _rawView.partial = _partialWafer;
    
    [_LDbutton setHidden:_partialWafer];
    [_HDbutton setHidden:_partialWafer];
    [_LDbutton setState:!selectedDense];
    [_HDbutton setState:selectedDense];
    [partialPopUp setHidden:!_partialWafer];
    
    if(_partialWafer) {
        selectedPartial = sPart[0];                   // !!!!!!!!!!!!!!!!!!!!!!
        [popCell selectItemAtIndex:selectedPartial];
        [_stepper setIntValue:0];
        [self partialWaferSetUp];
       return;
    }
        
    if(selectedDense) halfCount = 11;
    else halfCount = 5;
    [_stepper setMaxValue:(double)halfCount];
    [_stepper setIntValue:0];

    selectedRoc = [_stepper intValue];
    NSString * text = [NSString stringWithFormat:@"%1d.%1d",selectedRoc/2,selectedRoc%2];
    [_rocText setStringValue:text];
    
    

    [self buildRocFrames];
/*
#ifdef DEBUG
    [self debugOutput];
#endif
*/
    [_rawView setUpFormats];
    [self loadMapView];
    
}

- (void) partialWaferSetUp {
   
    if(selectedPartial < 0) selectedPartial = 0;
    int nHalfRocs[11] = {3,3,3,3,6,0,  5,8,4,4,0};
    nHalves = nHalfRocs[selectedPartial];
    halfCount = nHalves - 1;
    if(selectedPartial > 5) selectedDense = YES;
    [_stepper setMaxValue:(double) halfCount];
    
    selectedRoc = [_stepper intValue];
    NSString * text = [NSString stringWithFormat:@"%1d.%1d",selectedRoc/2,selectedRoc%2];
    [_rocText setStringValue:text];

    [self selectPartialForDisplay];

    [self partialsRocFrames];

    [_rawView setUpFormats];
    selectedRoc = 0;
    [_stepper setIntegerValue:0];


    [self loadPartialsMapView];

}
- (void) loadPartialsMapView {
    
    /* --- rawView properties ---
     @property int halfroc;
     @property BOOL dense;
     @property int * rocPin;
     @property int * siCell;
     @property int * iu;
     @property int * iv;
     @property BOOL * calib;
     @property NSString * calibName;
     @property BOOL * unconnected;
     */
    
    _rawView.halfroc = selectedRoc;
    _rawView.dense = selectedDense;
    int * ip = ipLD[selectedRoc];
    int * U = LDPU; //LD0U;
    int * V = LDPV; //LD0V;
    BOOL * S = _LDsplit;

    if(selectedDense) {
        ip = ipHD[selectedRoc];
        U = HDPU; //HD0U;
        V = HDPV; //HD0V;
        S = _HDsplit;
    }

    for (int i=0; i<37; i++) {
        unconnected[i] = NO;
        calib[i] = NO;
        split[i] = NO;
    }
    
    for (int i=0; i<37; i++) {
        if(ip[i] == -500) unconnected[i] = YES;
        else if(ip[i] < 0) {
            calib[i] = YES;
            siCell[i] = -ip[i]+1;
            iu[i] = U[-ip[i]];
            iv[i] = V[-ip[i]];
            tcell[i] = -1; //Ptrg[-2*ip[i]];
            tlink[i] = -1; //Ptrg[-2*ip[i]+1];
            _rawView.calibName = [NSString stringWithFormat:@"CALIB%1d",selectedRoc%2];
        } else {
            rocPin[i] = Ppin[ip[i]];
            siCell[i] = ip[i]+1;
            iu[i] = U[ip[i]];
            iv[i] = V[ip[i]];
            tcell[i] = Ptrg[2*ip[i]];
            tlink[i] = Ptrg[2*ip[i]+1];
            split[i] = S[ip[i]+1];
            if(tlink[i] > 3) NSLog(@"i=%d, tcell[i] = %d, tlink[i] = %d",i,tcell[i],tlink[i]);
        }
    }
    
    /* ??? Need test only for LD3, LD5, HD3...
    //--- clean split (+2 is the trick!) WTF!!!!
    for (int i=0; i<37; i++) {
        if(split[i]) {
            BOOL OK = NO;
            for (int j=0; j<37; j++) {
                if(siCell[j] == siCell[i]+2) OK = YES;
            }
            split[i] = OK;
        }
    }
    */
    for (int i=0; i<37; i++) {
        if(split[i]) {
            if(selectedPartial == 2 || selectedPartial == 8 || (selectedPartial == 4 && (2*iv[i]-iu[i]>7) ) ) split[i] = NO;
        }
    }
    
    _rawView.rocPin = rocPin;
    _rawView.siCell = siCell;
    _rawView.tlink = tlink;
    _rawView.tcell = tcell;
    _rawView.iu = iu;
    _rawView.iv = iv;
    _rawView.calib = calib;
    _rawView.unconnected = unconnected;
    _rawView.split = split;
    
    [_rawView setNeedsDisplay:YES];
    
}

- (void) loadMapView {
    
    /* --- rawView properties ---
     @property int halfroc;
     @property BOOL dense;
     @property int * rocPin;
     @property int * siCell;
     @property int * iu;
     @property int * iv;
     @property BOOL * calib;
     @property NSString * calibName;
     @property BOOL * unconnected;
     */
    
    _rawView.halfroc = selectedRoc;
    _rawView.dense = selectedDense;
    int * ip = ipLD[selectedRoc];
    int * U = LDU; //LD0U;
    int * V = LDV; //LD0V;
    int * T = LD0Trg;
    int * crosscheck = LDcrosscheck;
    int * pin = LD0pin;
    if(selectedDense) {
        ip = ipHD[selectedRoc];
        U = HDU; //HD0U;
        V = HDV; //HD0V;
        T = HD0Trg;
        crosscheck = HDcrosscheck;
        pin = HD0pin;
    }
    for (int i=0; i<37; i++) {
        unconnected[i] = NO;
        calib[i] = NO;
        split[i] = NO;
    }
    
    for (int i=0; i<37; i++) {
        if(ip[i] == -500) unconnected[i] = YES;
        else if(ip[i] < 0) {
            calib[i] = YES;
            siCell[i] = -ip[i]+1;
            iu[i] = U[-ip[i]];
            iv[i] = V[-ip[i]];
            tcell[i] = -1; //T[-2*ip[i]];
            tlink[i] = -1; //T[-2*ip[i]+1];
            crosscheck[siCell[i]-1]=i+100*(selectedRoc%2)+1000*(selectedRoc/2);
            _rawView.calibName = [NSString stringWithFormat:@"CALIB%1d",selectedRoc%2];
        } else {
            rocPin[i] = pin[ip[i]];
            siCell[i] = ip[i]+1;
            iu[i] = U[ip[i]];
            iv[i] = V[ip[i]];
            tcell[i] = T[2*ip[i]];
            tlink[i] = T[2*ip[i]+1];
            crosscheck[siCell[i]-1]=i+100*(selectedRoc%2)+1000*(selectedRoc/2);
        }
    }
    _rawView.rocPin = rocPin;
    _rawView.siCell = siCell;
    _rawView.tlink = tlink;
    _rawView.tcell = tcell;
    _rawView.iu = iu;
    _rawView.iv = iv;
    _rawView.calib = calib;
    _rawView.unconnected = unconnected;
    
    [_rawView setNeedsDisplay:YES];
    
}

- (void) selectPartialForDisplay {
   
    if(selectedPartial == 0) {
        Ppin = LD1pin;
        PROC = LD1ROC;
        Pcalib = LD1calib;
        PcalibROC = LD1calibROC;
        PcalCell = LD1calibCell;
        Ptrg = LD1Trg;
    } if(selectedPartial == 1) {
        Ppin = LD2pin;
        PROC = LD2ROC;
        Pcalib = LD2calib;
        PcalibROC = LD2calibROC;
        PcalCell = LD2calibCell;
        Ptrg = LD2Trg;
    } if(selectedPartial == 2) {
        Ppin = LD3pin;
        PROC = LD3ROC;
        Pcalib = LD3calib;
        PcalibROC = LD3calibROC;
        PcalCell = LD3calibCell;
        Ptrg = LD3Trg;
    } if(selectedPartial == 3) {
        Ppin = LD4pin;
        PROC = LD4ROC;
        Pcalib = LD4calib;
        PcalibROC = LD4calibROC;
        PcalCell = LD4calibCell;
        Ptrg = LD4Trg;
    } if(selectedPartial == 4) {
        Ppin = LD5pin;
        PROC = LD5ROC;
        Pcalib = LD5calib;
        PcalibROC = LD5calibROC;
        PcalCell = LD5calibCell;
        Ptrg = LD5Trg;
    } if(selectedPartial == 6) {
        Ppin = HD1pin;
        PROC = HD1ROC;
        Pcalib = HD1calib;
        PcalibROC = HD1calibROC;
        PcalCell = HD1calibCell;
        Ptrg = HD1Trg;
    } if(selectedPartial == 7) {
        Ppin = HD2pin;
        PROC = HD2ROC;
        Pcalib = HD2calib;
        PcalibROC = HD2calibROC;
        PcalCell = HD2calibCell;
        Ptrg = HD2Trg;
    } if(selectedPartial == 8) {
        Ppin = HD3pin;
        PROC = HD3ROC;
        Pcalib = HD3calib;
        PcalibROC = HD3calibROC;
        PcalCell = HD3calibCell;
        Ptrg = HD3Trg;
    } if(selectedPartial == 9) {
        Ppin = HD4pin;
        PROC = HD4ROC;
        Pcalib = HD4calib;
        PcalibROC = HD4calibROC;
        PcalCell = HD4calibCell;
        Ptrg = HD4Trg;
    }
    
    NSString * ldhd = @"LD";
    int nsel = selectedPartial + 1;
    
    if(selectedPartial > 5) {
        nsel = nsel - 6;
        ldhd = @"HD";
    }
    
    _rawView.partialName = [NSString stringWithFormat:@"%@%1d partial wafer",ldhd,nsel];
    
}

#pragma mark - building the arrays of information
/*
- (void) loadU:(int *) U andV:(int *) V andCalFlag:(BOOL *)flag forDensity:(BOOL)dense andPartial:(BOOL) part {
 
    if(dense) {
        int n = 444;
        if(part) n = 468;
        for(int i=0; i<n;i++) {
            HD0U[i] = U[i];
            HD0V[i] = V[i];
            HD0cFlag[i] = flag[i];
//            HD0Cell[U[i]][V[i]] = i+1;
        }
    } else {
        int n = 198;
        if(part) n = 212;
        for(int i=0; i<n; i++) {
            LD0U[i] = U[i];
            LD0V[i] = V[i];
            LD0cFlag[i] = flag[i];
//            LD0Cell[U[i]][V[i]] = i+1;
        }
    }
}
*/
- (void) decodeFileLines:(NSArray *) lineStrings forPin:(int *) pin andROC:(int *) ROC andTrig:(int *) trg count: (int) n {
    
// Sr. No.; Si Cell No.; Pin No.; Chip No.; Trigger Cell No.; Tigger Link; Sector No.
//    0          1          2        3            4               5           6
    
    for(int i=0; i<n; i++) {
        ROC[i] = -1;
        trg[2*i] = -1;
        trg[2*i+1] = -1;
    }
   
    for(int i=0; i<lineStrings.count; i++) {
        NSString * line = lineStrings[i];
        if(line.length < 1) break;
        NSArray * columns = [line componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@","]];
        int ichan = [columns[1] intValue];
        pin[ichan-1] = [columns[2] intValue];
        ROC[ichan-1] = [columns[3] intValue];
        NSString * trigStr = columns[4];
        if(trigStr.length == 5) {
            trigStr = [trigStr substringWithRange:NSMakeRange(4,1)];
            trg[2*(ichan-1)] = [trigStr intValue];
            trg[2*(ichan-1)+1] = [columns[5] intValue];
        } else {
            trg[2*(ichan-1)] = -1;
            trg[2*(ichan-1)+1] = -1;
        }
    }

}

- (void) decodeCalibFile:(NSArray *) lineStrings forCalib: (int *) calib ROC: (int *) ROC andCell: (int *) cell {

//   Sr. No.; Sector No.;                 ; Si Cell; Pin No.; Chip No.; ----- LD
//   Sr. No.; Sector No.; Trigger Cell No.; Si Cell; Pin No.; Chip No.  ----- HD
   
    
    for(int i=0; i<lineStrings.count; i++) {
        NSString * line = lineStrings[i];
        if(line.length < 1) break;
        NSArray * columns = [line componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@","]];
        if(columns.count < 5) break;

        cell[i] = [columns[3] intValue];
        calib[i] = [[columns[4] substringWithRange:NSMakeRange(6,1)] intValue];
        ROC[i] = [columns[5] intValue];
        
        if(debugPrint) NSLog(@"i = %d, cell %d, calib %d, ROC %d",i,cell[i],calib[i],ROC[i]);
    }
}

- (void) decodeTraceFile:(NSArray *) lineStrings To: (double *) LD0traces {
    
    for(int i=0; i<216; i++) {
        LD0traces[i] = 0.;
    }
    for(int i=0; i<lineStrings.count; i++) {
        NSString * line = lineStrings[i];
        NSArray * columns = [line componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@","]];
        if(columns.count < 7) break;
        for(int j=0; j<3; j++) {
            NSString * chan = [columns[2+j*3] substringFromIndex:7];
            NSRange range = [chan rangeOfString:@">"];
            int ichan = [[chan substringToIndex:range.location] intValue];
            LD0traces[j*72+ichan] = [columns[3+j*3] doubleValue];
        }
    }
    
}

- (void) buildRocFrames {

    BOOL * LDflag;
    BOOL * HDflag;
    if(_partialWafer) {
        LDflag = LDPcFlag;
        HDflag = HDPcFlag;
    } else {
        LDflag = LDcFlag;
        HDflag = HDcFlag;
    }
    for(int ihroc=0; ihroc<6; ihroc++) {
        int ical = (ihroc%2);
        int ipin = ical*36;
        int roc = ihroc/2;
        for(int i=0; i<18; i++) {
            ipLD[ihroc][i] = -500;
            for(int j=0; j<198; j++) {
                if(LD0pin[j] == ipin && LD0ROC[j] == roc && !LDflag[j]) { //!!
                    ipLD[ihroc][i] = j;
                    break;
                }
            }
            ipin++;
        }
        for(int j=0; j<6; j++) {
            if(LD0calib[j] == ical && LD0calibROC[j] == roc) {
                ipLD[ihroc][18] = -LD0calibCell[j]+1; // The ip's are 0 counting!
                break;
            }
        }
        for(int i=19; i<37; i++) {
            ipLD[ihroc][i] = -500;
            for(int j=0; j<198; j++) {
                if(LD0pin[j] == ipin && LD0ROC[j] == roc && !LDflag[j]) { //!!
                    ipLD[ihroc][i] = j;
                    break;
                }
            }
            ipin++;
        }
    }
//------- High density ----------------
    for(int ihroc=0; ihroc<12; ihroc++) {
        int ical = (ihroc%2);
        int ipin = ical*36;
        int roc = ihroc/2;
        for(int i=0; i<18; i++) {
            ipHD[ihroc][i] = -500;
            for(int j=0; j<444; j++) {
                if(HD0pin[j] == ipin && HD0ROC[j] == roc && !HDflag[j]) { //!!
                    ipHD[ihroc][i] = j;
                    break;
                }
            }
            ipin++;
        }
        for(int j=0; j<12; j++) {
            if(HD0calib[j] == ical && HD0calibROC[j] == roc) {
                ipHD[ihroc][18] = -HD0calibCell[j]+1; // The ip's are 0 counting!
                break;
            }
        }
        for(int i=19; i<37; i++) {
            ipHD[ihroc][i] = -500;
            for(int j=0; j<444; j++) {
                if(HD0pin[j] == ipin && HD0ROC[j] == roc && !HDflag[j]) { //!!
                    ipHD[ihroc][i] = j;
                    break;
                }
            }
            ipin++;
        }
    }

}

- (void) partialsRocFrames {
   
    if(selectedDense) {
        for(int ihroc=0; ihroc<nHalves; ihroc++) {
            int ical = (ihroc%2);
            int ipin = ical*36;
            int roc = ihroc/2;
            for(int i=0; i<18; i++) {
                ipHD[ihroc][i] = -500;
                for(int j=0; j<468; j++) {
                    if(Ppin[j] == ipin && PROC[j] == roc) {
                        ipHD[ihroc][i] = j;
                        break;
                    }
                }
                ipin++;
            }
            ipHD[ihroc][18] = -500;
            for(int j=0; j<12; j++) {
                if(Pcalib[j] == ical && PcalibROC[j] == roc) {
                    ipHD[ihroc][18] = -PcalCell[j]+1; // The ip's are 0 counting!
                    break;
                }
            }
            for(int i=19; i<37; i++) {
                ipHD[ihroc][i] = -500;
                for(int j=0; j<468; j++) {
                    if(Ppin[j] == ipin && PROC[j] == roc) {
                        ipHD[ihroc][i] = j;
                        break;
                    }
                }
                ipin++;
            }
        }
    } else {
        for(int ihroc=0; ihroc<nHalves; ihroc++) {
            int ical = (ihroc%2);
            int ipin = ical*36;
            int roc = ihroc/2;
            for(int i=0; i<18; i++) {
                ipLD[ihroc][i] = -500;
                for(int j=0; j<212; j++) {
                    if(Ppin[j] == ipin && PROC[j] == roc) {
                        ipLD[ihroc][i] = j;
                        break;
                    }
                }
                ipin++;
            }
            for(int j=0; j<6; j++) {
                if(Pcalib[j] == ical && PcalibROC[j] == roc) {
                    ipLD[ihroc][18] = -PcalCell[j]+1; // The ip's are 0 counting!
                    break;
                }
            }
            for(int i=19; i<37; i++) {
                ipLD[ihroc][i] = -500;
                for(int j=0; j<212; j++) {
                    if(Ppin[j] == ipin && PROC[j] == roc) {
                        ipLD[ihroc][i] = j;
                        break;
                    }
                }
                ipin++;
            }
        }
    }
}
#pragma mark - access to trigger info

- (void) getTrgID:(int *) tid forHD:(BOOL) dens andPartial:(int) ipart {
    
    if(!dens) {
        if(ipart == 0) [self load:tid withPin:LD0pin andROC:LD0ROC andTrg:LD0Trg forCount:212];
        else if(ipart == 1) [self load:tid withPin:LD1pin andROC:LD1ROC andTrg:LD1Trg forCount:212];
        else if(ipart == 2) [self load:tid withPin:LD2pin andROC:LD2ROC andTrg:LD2Trg forCount:212];
        else if(ipart == 3) [self load:tid withPin:LD3pin andROC:LD3ROC andTrg:LD3Trg forCount:212];
        else if(ipart == 4) [self load:tid withPin:LD4pin andROC:LD4ROC andTrg:LD4Trg forCount:212];
        else if(ipart == 5) [self load:tid withPin:LD5pin andROC:LD5ROC andTrg:LD5Trg forCount:212];
    } else {
             if(ipart == 0) [self load:tid withPin:HD0pin andROC:HD0ROC andTrg:HD0Trg forCount:468];
        else if(ipart == 1) [self load:tid withPin:HD1pin andROC:HD1ROC andTrg:HD1Trg forCount:468];
        else if(ipart == 2) [self load:tid withPin:HD2pin andROC:HD2ROC andTrg:HD2Trg forCount:468];
        else if(ipart == 3) [self load:tid withPin:HD3pin andROC:HD3ROC andTrg:HD3Trg forCount:468];
        else if(ipart == 4) [self load:tid withPin:HD4pin andROC:HD4ROC andTrg:HD4Trg forCount:468];
    }
        
}

- (void) load:(int *) tid withPin:(int *) pin andROC:(int *) roc andTrg:(int *) trg forCount:(int) n {
    
     for (int i=0; i<n; i++) {
         if(trg[2*i+1] < 0) tid[i] = 10000*pin[i] + 100*roc[i] + 9;
         else tid[i] = 10000*pin[i] + 100*roc[i] + 10*trg[2*i] + trg[2*i+1];
     }
}
#pragma mark - IBActions

- (IBAction) changeSelectedRoc:(id)sender {
    
    if(sender == _LDbutton) {
        selectedDense = NO;
        halfCount = 5;
    }
    if(sender == _HDbutton) {
        selectedDense = YES;
        halfCount = 11;
    }
    [_LDbutton setState:!selectedDense];
    [_HDbutton setState:selectedDense];
    
    [_stepper setMaxValue:(double) halfCount];
    
    int previous = selectedRoc;
    selectedRoc = [_stepper intValue];
    if(selectedPartial == 4 && selectedRoc == 3) {
        // Hides unused half-ROC
        if(previous == 2) selectedRoc = 4;
        else selectedRoc = 2;
    }
    
    NSString * text = [NSString stringWithFormat:@"%1d.%1d",selectedRoc/2,selectedRoc%2];
    [_rocText setStringValue:text];
    
    if(_partialWafer) [self loadPartialsMapView];
    else [self loadMapView];

}

- (IBAction) makePDF:(id)sender {
    
    int originalRoc = selectedRoc;
    BOOL originalDense = selectedDense;
    
    NSString * filename = @"mapForXX-ROCn-n.pdf";
    NSSavePanel *export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save PDF files"];
    if(_partialWafer) {
        int ipart = selectedPartial + 1;
        NSString * ptype = @"LD";
        if(ipart > 6) {
            ipart = ipart - 6;
            ptype = @"HD";
        }
        NSString * message = [NSString stringWithFormat:@"Saving map tables for %@%d",ptype,ipart];
        [export setMessage:message];
    }
    else [export setMessage:@"Saving full set of map tables for full wafers"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * pdfp = [[export URL] path];
            if(self->_partialWafer) [self pdfsForPartials:pdfp];
            else [self pdfsForWholes:pdfp];
        }
    }];
    
    selectedRoc = originalRoc;
    selectedDense = originalDense;
    [self changeSelectedRoc:self];
}

- (IBAction) makeCSV:(id)sender {

    int originalRoc = selectedRoc;
    BOOL originalDense = selectedDense;
    
    NSString * filename = @"mapForXX-ROCn-n.csv";
    NSSavePanel * export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save CSV files"];
    if(_partialWafer) {
        int ipart = selectedPartial + 1;
        NSString * ptype = @"LD";
        if(ipart > 6) {
            ipart = ipart - 6;
            ptype = @"HD";
        }
        NSString * message = [NSString stringWithFormat:@"Saving csv map tables for %@%d",ptype,ipart];
        [export setMessage:message];
    }
    else [export setMessage:@"Saving full set of csv map tables for full wafers"];
    [export beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * csvp = [[export URL] path];
            if(self->_partialWafer) [self csvsForPartials:csvp];
            else [self csvsForWholes:csvp];
        }
    }];
    
    selectedRoc = originalRoc;
    selectedDense = originalDense;
    [self changeSelectedRoc:self];
}

- (IBAction) changePartial:(id)sender {
 
    
    selectedPartial = (int) [partialPopUp indexOfSelectedItem];

    selectedRoc = 0;
    [_stepper setIntegerValue:0];
    
    if(selectedPartial > 5) {
        selectedDense = YES;
    } else {
        selectedDense = NO;
    }
    
    NSString * text = [NSString stringWithFormat:@"%1d.%1d",selectedRoc/2,selectedRoc%2];
    [_rocText setStringValue:text];
    
    int dens = 0;
    if(selectedDense) dens = 1;
    NSNumber * density = [NSNumber numberWithInteger:dens];
    NSNumber * part = [NSNumber numberWithInteger:selectedPartial];
    NSDictionary * d = [NSDictionary dictionaryWithObjectsAndKeys:density,@"setDensity",part,@"setPartial",nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewWaferSetUpNotification object:self userInfo:d];

    [self partialWaferSetUp];  // Or the other way round?

    [self loadPartialsMapView];  // Or the other way round?
    
    //[self selectPartialForDisplay];

}
#pragma mark - saving the complete text map
- (void) setupRawDataMapTextFile:(id) window {
        
    _refTypeCode = YES; // Add some selection somewhere?

    NSString * filename = @"WaferCellMap.txt";
    if(_refTypeCode) filename = @"WaferCellMapRefCode.txt";
    NSSavePanel * export = [NSSavePanel savePanel];
    [export setNameFieldStringValue:filename];
    [export setCanCreateDirectories:YES];
    [export setTitle:@"Save silicon wafer channel map"];
    [export setMessage:@"Saving full set of channel mappings for whole and partial wafers"];
    [export beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSString * path = [[export URL] path];
            [self saveRawDataMapTextFile:path];
        }
    }];

}


- (void) saveRawDataMapTextFile: (NSString *) path {
//    0         1         2         3         4         5         6         7
//    012345678901234567890123456789012345678901234567890123456789012345678901234567890
    _mapText =
    @"    Dens   Wtype     ROC HalfROC     Seq  ROCpin  SiCell  TrLink  TrCell      iu      iv   trace       t\n";

    [self showWindow:self];

    [self wholesText];

    [self partialsText];
    
    [_mapText writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    [self.window close];

}

#pragma mark - the map output stuff

- (void) pdfsForWholes: (NSString *) pdfp {
   
    _rawView.pdf = YES;

    for(int i=0; i<6; i++) {
        selectedRoc = i;
        selectedDense = NO;
        [self loadMapView];
        NSString * identifier = [NSString stringWithFormat:@"LD-ROC%1d-%1d",i/2,i%2];
        NSString * pdfpath = [pdfp stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [_rawView savePDF:pdfpath];
    }
    for(int i=0; i<12; i++) {
        selectedRoc = i;
        selectedDense = YES;
        [self loadMapView];
        NSString * identifier = [NSString stringWithFormat:@"HD-ROC%1d-%1d",i/2,i%2];
        NSString * pdfpath = [pdfp stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [_rawView savePDF:pdfpath];
    }
    _rawView.pdf = NO;

}

- (void) pdfsForPartials: (NSString *) pdfp {
  
    _rawView.pdf = YES;
    int ipart = selectedPartial + 1;
    NSString * ptype = @"LD";
    if(ipart > 6) {
        ipart = ipart - 6;
        ptype = @"HD";
    }
    for(int i=0; i<nHalves; i++) {
        selectedRoc = i;
        [self loadPartialsMapView];
        NSString * identifier = [NSString stringWithFormat:@"%@%1d-ROC%1d-%1d",ptype,ipart,i/2,i%2];
        NSString * pdfpath = [pdfp stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [_rawView savePDF:pdfpath];
    }
    _rawView.pdf = NO;
}

- (void) csvsForWholes: (NSString *) path {
   
    for(int i=0; i<6; i++) {
        selectedRoc = i;
        selectedDense = NO;
        [self loadMapView];
        NSString * identifier = [NSString stringWithFormat:@"LD-ROC%1d-%1d",i/2,i%2];
        NSString * pdfpath = [path stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [self saveCSV:pdfpath];
    }
    for(int i=0; i<12; i++) {
        selectedRoc = i;
        selectedDense = YES;
        [self loadMapView];
        NSString * identifier = [NSString stringWithFormat:@"HD-ROC%1d-%1d",i/2,i%2];
        NSString * pdfpath = [path stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [self saveCSV:pdfpath];
    }

}
- (void) csvsForPartials: (NSString *) path {
  
    int ipart = selectedPartial + 1;
    NSString * ptype = @"LD";
    if(ipart > 6) {
        ipart = ipart - 6;
        ptype = @"HD";
    }
    for(int i=0; i<nHalves; i++) {
        selectedRoc = i;
        [self loadPartialsMapView];
        NSString * identifier = [NSString stringWithFormat:@"%@%1d-ROC%1d-%1d",ptype,ipart,i/2,i%2];
        NSString * pdfpath = [path stringByReplacingOccurrencesOfString:@"XX-ROCn-n" withString:identifier];
        [self saveCSV:pdfpath];
    }
}

- (void) saveCSV:(NSString *)path {
    
    NSString * csvString = @"";

    csvString = [csvString stringByAppendingString:@"Nseq,ROC pin,Si cell,iu,iv,comment\n"];
    for (int line = 0; line < 37; line++) {
        csvString = [csvString stringByAppendingFormat:@"%2d,",line];
        if(unconnected[line]) {
            csvString = [csvString stringByAppendingString:@",,,,Unconnected"];
        } else {
            NSString * entry = [NSString stringWithFormat:@"%2d,",rocPin[line]];
            if(calib[line]) entry = [NSString stringWithFormat:@"%@,",_rawView.calibName];;
            csvString = [csvString stringByAppendingString:entry];
            csvString = [csvString stringByAppendingFormat:@"%3d,",siCell[line]];
            csvString = [csvString stringByAppendingFormat:@"%2d,%2d,",iu[line],iv[line]];
            if(calib[line]) csvString = [csvString stringByAppendingString:@"Calib cell"];
            else if(_partialWafer && split[line]) {
                csvString = [csvString stringByAppendingFormat:@"Cells %d+%d",siCell[line],siCell[line]+1];
            }
        }
        csvString = [csvString stringByAppendingString:@"\n"];
    }
    [csvString writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];

}

- (void) wholesText {
 
    //    0         1         2         3         4         5         6         7
    //    012345678901234567890123456789012345678901234567890123456789012345678901234567890
        _mapText =
        @"    Dens   Wtype     ROC HalfROC     Seq  ROCpin  SiCell  TrLink  TrCell      iu      iv   trace       t\n";
    if(_refTypeCode) {
        _mapText =
        @"   Wtype     ROC HalfROC     Seq  ROCpin  SiCell  TrLink  TrCell      iu      iv   trace       t\n";
    }

    selectedPartial = -1;
    for(int i=0; i<6; i++) {
        selectedRoc = i;
        selectedDense = NO;
        [self loadMapView];
        [self halfText];
    }
    for(int i=0; i<12; i++) {
        selectedRoc = i;
        selectedDense = YES;
        [self loadMapView];
        [self halfText];
    }
}
- (NSString *) wholeUVMapForHD:(BOOL) dens {
    
    NSString * mapString = @"chan  iu  iv\n";
    
    if(dens) {
        for (int i=0; i<444; i++) {
            mapString = [mapString stringByAppendingFormat:@"%4d %3d %3d\n",i+1,HDU[i],HDV[i]];
        }
    } else {
        for (int i=0; i<198; i++) {
            mapString = [mapString stringByAppendingFormat:@"%4d %3d %3d\n",i+1,LDU[i],LDV[i]];
        }
    }
    
    
    return mapString;
}

- (NSString *) partialUVMapForHD:(BOOL) dens{
    
    NSString * mapString = @"chan  iu  iv\n";

    if(dens) {
        for (int i=0; i<468; i++) {
            mapString = [mapString stringByAppendingFormat:@"%4d %3d %3d\n",i+1,HDPU[i],HDPV[i]];
        }
    } else {
        for (int i=0; i<212; i++) {
            mapString = [mapString stringByAppendingFormat:@"%4d %3d %3d\n",i+1,LDPU[i],LDPV[i]];
        }
    }
    
    
    return mapString;
}
/*
- (void) writeUVMapForHD:(BOOL) dens {
    
    if(!theHardwareNumbering) theHardwareNumbering = [HXGHardwareNumbering sharedHardwareNumbering];

    NSString * mapString;
    NSMutableArray * UVmap = [NSMutableArray arrayWithCapacity:200];
    
    if(dens) {
        for (int i=0; i<444; i++) {
            mapString = [NSString stringWithFormat:@"%2d%2d",HD0U[i],HD0V[i]];
            [UVmap addObject:mapString];
        }
    } else {
        for (int i=0; i<198; i++) {
            mapString = [NSString stringWithFormat:@"%2d%2d",LD0U[i],LD0V[i]];
            [UVmap addObject:mapString];
        }
    }

    [theHardwareNumbering storeMap: UVmap forDens:dens andPartial:NO];

}

- (void) writePartialUVMapForHD:(BOOL) dens{
    
    if(!theHardwareNumbering) theHardwareNumbering = [HXGHardwareNumbering sharedHardwareNumbering];

    NSString * mapString;
    NSMutableArray * UVmap = [NSMutableArray arrayWithCapacity:200];

    if(dens) {
        for (int i=0; i<468; i++) {
            mapString = [NSString stringWithFormat:@"%2d%2d",HD0U[i],HD0V[i]];
            [UVmap addObject:mapString];
        }
    } else {
        for (int i=0; i<212; i++) {
            mapString = [NSString stringWithFormat:@"%2d%2d",LD0U[i],LD0V[i]];
            [UVmap addObject:mapString];
        }
    }
    
    [theHardwareNumbering storeMap: UVmap forDens:dens andPartial:YES];

}
*/
- (void) setSelectedPartial:(int) sP {
    
    selectedPartial = sP;

}

- (void) partialsText {
 
    [self partialWaferSetUp];
    
    for(int i=0; i<npart; i++) {
        selectedPartial = sPart[i];
        [self selectPartialForDisplay];
        selectedDense = NO;
        if(selectedPartial > 6) {
            selectedDense = YES;
        }
        [self partialWaferSetUp];
        for(int j=0; j<nHalves; j++) {
            selectedRoc = j;
            [self loadPartialsMapView];
            if(selectedPartial == 4 && selectedRoc == 3) {
                // Unused half-ROC
                unconnected[18] = YES;
            }
            [self halfText];
        }
    }
}
- (void) halfText {

//     @"    Dens   Wtype     ROC HalfROC     Seq  ROCpin  SiCell  TrLink  TrCell      iu      iv       t\n";
//
//    NB: rocPin is now defined in a purely mechanical way
//    from the seq and the half
    
    NSString * typeCode[6] = {@"F",@"T",@"B",@"L",@"R",@"5"};
    NSString * typeString;
    
    NSString * rocpinName;
    NSString * dens = @"      LD";
    int wtype = selectedPartial + 1;

    if(selectedDense) {
        dens = @"      HD";
        if(selectedPartial > 0) wtype = selectedPartial - 5;
    }
    if(_refTypeCode) {
        dens = @"    ML-";
        if(selectedDense) dens = @"    MH-";
        typeString = [dens stringByAppendingString:typeCode[wtype]];
    }
    int roc = selectedRoc/2;
    int hroc = selectedRoc%2;
    for (int line = 0; line < 37; line++) {
        int pin = line;
        if(calib[line]) {
            rocpinName = [NSString stringWithFormat:@"  CALIB%1d",hroc];
        } else {
            if(line > 18) pin-=1;
            rocpinName = [NSString stringWithFormat:@"%8d",pin + hroc*36];
        }
        if(_refTypeCode) {
            _mapText = [_mapText stringByAppendingFormat:@"%@%8d%8d%8d%@",typeString,roc,hroc,line,[_rawView rocPinNameForHroc:hroc andChan:line]];
        } else {
            _mapText = [_mapText stringByAppendingFormat:@"%@%8d%8d%8d%8d%@",dens,wtype,roc,hroc,line,[_rawView rocPinNameForHroc:hroc andChan:line]];
        }
        // Generalized system still needs debugging....
        //[_rawView rocPinNameForHroc:hroc andChan:line]];
        if(unconnected[line]) {
            _mapText = [_mapText stringByAppendingString:@"      -1      -1      -1      -1      -1    0.00      -1\n"];
        } else {
            int t = 1;
            if(calib[line]) t = 0;
            if(selectedPartial > 0) if(split[line]) t = 2;
            double trace = 0;
            if(!selectedDense && wtype == 0) trace = LD0traces[pin + hroc*36 + roc*72];
            _mapText = [_mapText stringByAppendingFormat:@"%8d%8d%8d%8d%8d%8.2f%8d\n",siCell[line],tlink[line],tcell[line],iu[line],iv[line],trace,t];
#ifdef DEBUG
            [self crossCheckForType:typeString andLine:line andHroc:hroc];
#endif
        }
        
    }
}

- (void) crossCheckForType:(NSString *) typeString andLine: (int) line andHroc:(int) hroc {
    
    if([typeString isEqualToString:@"    ML-F"]) {
        int hard = siCell[line];
        int rpin = LD0pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    MH-F"]) {
        int hard = siCell[line];
        int rpin = HD0pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !HDcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; HDcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],HDcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    ML-T"]) {
        int hard = siCell[line];
        int rpin = LD1pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    ML-B"]) {
        int hard = siCell[line];
        int rpin = LD2pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    ML-L"]) {
        int hard = siCell[line];
        int rpin = LD3pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    ML-R"]) {
        int hard = siCell[line];
        int rpin = LD4pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    ML-5"]) {
        int hard = siCell[line];
        int rpin = LD5pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !LDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; LDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],LDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    MH-T"]) {
        int hard = siCell[line];
        int rpin = HD1pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !HDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; HDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],HDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    MH-B"]) {
        int hard = siCell[line];
        int rpin = HD2pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !HDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; HDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],HDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    MH-L"]) {
        int hard = siCell[line];
        int rpin = HD3pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !HDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; HDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],HDPcFlag[hard-1]);
        }
    } else if([typeString isEqualToString:@"    MH-R"]) {
        int hard = siCell[line];
        int rpin = HD4pin[hard-1];
        NSString * pinstring = [NSString stringWithFormat:@"%8d",rpin];
        if(![pinstring isEqualToString:[_rawView rocPinNameForHroc:hroc andChan:line]] && !HDPcFlag[hard-1]) {
            NSLog(@"ERROR%@: hard = %d; rpin = %d; rocpinname = %@; HDPcFlag = %d",typeString,hard,rpin,[_rawView rocPinNameForHroc:hroc andChan:line],HDPcFlag[hard-1]);
        }
    }
}

/*
#pragma mark - debug stuff
#ifdef DEBUG

- (void) debugOutput {
 
    BOOL LD0uv  = NO;
    BOOL HD0uv  = NO;
    BOOL LD0roc = NO;
    BOOL HD0roc = NO;
    BOOL LD0cal = NO;
    BOOL HD0cal = NO;
    BOOL LD0pnt = NO;
    BOOL HD0pnt = NO;
    int flag = 0;
    if(LD0uv)  flag +=  1;
    if(HD0uv)  flag +=  2;
    if(LD0roc) flag +=  4;
    if(HD0roc) flag +=  8;
    if(LD0cal) flag += 16;
    if(HD0cal) flag += 32;
    if(LD0pnt) flag += 64;
    if(HD0pnt) flag +=128;
    if(flag != 0) [self debugPrintout:flag];
    
}


- (void) debugPrintout:(int) flag {
    
    NSString * text = @"";
    if(flag & 1) {
        text = [text stringByAppendingString:@"Low density full wafer\n\n"];
    
        for(int i=0; i<198; i++) {
            text = [text stringByAppendingFormat:@"%3d: (%2d, %2d)",i+1,LD0U[i],LD0V[i]];
            if(LD0cFlag[i]) text = [text stringByAppendingString:@" *** CALIB ***\n"];
            else text = [text stringByAppendingString:@"\n"];
        }
    }
    
    if(flag & 2) {
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density full wafer\n\n"];
        for(int i=0; i<444;i++) {
            text = [text stringByAppendingFormat:@"%3d: (%2d, %2d)",i+1,HD0U[i],HD0V[i]];
            if(HD0cFlag[i]) text = [text stringByAppendingString:@" *** CALIB ***\n"];
            else text = [text stringByAppendingString:@"\n"];
        }
    }
    
    if(flag & 4) {
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pin ROC\n\n"];
        for(int i=0; i<198; i++) {
            text = [text stringByAppendingFormat:@"%3d: pin=%2d, ROC=%2d",i+1,LD0pin[i],LD0ROC[i]];
            if(LD0cFlag[i]) text = [text stringByAppendingString:@" *** CALIB ***\n"];
            else text = [text stringByAppendingString:@"\n"];
        }
    }
    
    if(flag & 8) {
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pin ROC\n\n"];
        for(int i=0; i<444; i++) {
            text = [text stringByAppendingFormat:@"%3d: pin=%2d, ROC=%2d",i+1,HD0pin[i],HD0ROC[i]];
            if(HD0cFlag[i]) text = [text stringByAppendingString:@" *** CALIB ***\n"];
            else text = [text stringByAppendingString:@"\n"];
        }
    }
    
    if(flag & 16) {
        text = [text stringByAppendingString:@"------------------------------------------\nLow density calib info\n\n"];
        for(int i=0; i<6; i++) {
            text = [text stringByAppendingFormat:@"%2d: cell=%3d, ROC=%2d calib=%1d\n",i,LD0calibCell[i],LD0calibROC[i],LD0calib[i]];
        }
    }
    
    if(flag & 32) {
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density calib info\n\n"];
        for(int i=0; i<12; i++) {
            text = [text stringByAppendingFormat:@"%2d: cell=%3d, ROC=%2d calib=%1d\n",i,HD0calibCell[i],HD0calibROC[i],HD0calib[i]];
        }
    }

    if(flag & 64) {
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 0.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[0][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 0.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[1][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 1.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[2][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 1.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[3][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 2.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[4][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nLow density pointers (ROC 2.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipLD[5][i]];
        }
    }
    if(flag & 128) {
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 0.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[0][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 0.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[1][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 1.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[2][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 1.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[3][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 2.0)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[4][i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density pointers (ROC 2.1)\n\n"];
        for(int i=0; i<37; i++) {
            text = [text stringByAppendingFormat:@"%2d: pointer=%4d\n",i,ipHD[5][i]];
        }
    }
    if(flag & 256) {
        text = [text stringByAppendingString:@"------------------------------------------\nLow density crosscheck\n\n"];
        for(int i=0; i<198; i++) {
            text = [text stringByAppendingFormat:@"Si cell %3d: ROC/ECON-D seq = %04d\n",i+1,LDcrosscheck[i]];
        }
        text = [text stringByAppendingString:@"------------------------------------------\nHigh density crosscheck\n\n"];
        for(int i=0; i<444; i++) {
            text = [text stringByAppendingFormat:@"Si cell %3d: ROC/ECON-D seq = %04d\n",i+1,HDcrosscheck[i]];
        }
    }

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    [theTerminal showWindow:nil];
    [theTerminal displayString:text];
    

}
#endif
*/
@end
