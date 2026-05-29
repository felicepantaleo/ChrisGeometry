//
//  HXGStructuredWafer.m
//  Hex
//
//  Created by Chris Seez on 15/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGStructuredWafer.h"

/* ----------------------------------------------------------------------------------
    See: NotesOnStructuredWafer.pdf in Supporting files/Documentation
   ---------------------------------------------------------------------------------- */

const int incLD[16] = {8,9,10,11,12,13,14,15,16,15,14,13,12,11,10,9};
const int incHD[24] = {12,13,14,15,16,17,18,19,20,21,22,23,24,23,22,21,20,19,18,17,16,15,14,13};

const int calibLD[6] = {12, 59, 66, 138, 148, 156};
const int calibHD[12] = {28,34,84,146,152,201,254,259,288,371,376,399};
const int partialCalibLD[6] = {11, 62, 86, 144, 154, 162};
const int partialCalibHD[12] = {29, 36, 110, 134, 140, 214, 245, 297, 325, 374, 414, 420};

const double textScale = 0.38;

@implementation HXGStructuredWafer

+ (id) sharedStructuredWafer {
    
    static dispatch_once_t pred;
    static HXGStructuredWafer * theStructuredWafer = nil;
    
    dispatch_once(&pred, ^{theStructuredWafer = [[self alloc] init]; });
    return theStructuredWafer;
}

- (id)init {
    
    self = [super init];
    
    waferSide = layoutHexagonWidth/sqrt(3.);
    
    theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];
        
    LDzoltanA = theHardwareConstants.LDzoltanA;
    LDzoltanB = theHardwareConstants.LDzoltanB;
    LDzoltanC = theHardwareConstants.LDzoltanC;
    LDzoltanD = theHardwareConstants.LDzoltanD;
    LDzoltanE = theHardwareConstants.LDzoltanE;
    LDzoltanF = theHardwareConstants.LDzoltanF;
    LDzoltanG = theHardwareConstants.LDzoltanG;
    LDzoltanH = theHardwareConstants.LDzoltanH;
    
    HDzoltanA = theHardwareConstants.HDzoltanA;
    HDzoltanB = theHardwareConstants.HDzoltanB;
    HDzoltanC = theHardwareConstants.HDzoltanC;
    HDzoltanD = theHardwareConstants.HDzoltanD;
    HDzoltanE = theHardwareConstants.HDzoltanE;
    HDzoltanF = theHardwareConstants.HDzoltanF;
    HDzoltanG = theHardwareConstants.HDzoltanG;
    
    cellSideLD = layoutHexagonWidth/(double)(3 * NLD);
    cellSideHD = layoutHexagonWidth/(double)(3 * NHD);
    cellWidthLD = sqrt(3.) * cellSideLD;
    cellWidthHD = sqrt(3.) * cellSideHD;
    
    halfDiceWidth = theHardwareConstants.halfDiceWidth;
    mouseBitePerp = theHardwareConstants.mouseBitePerp;
    activeWidth = theHardwareConstants.activeWidth;
    
    cellColor[0] = [NSColor paleBlue];   // whole cell
    cellColor[1] = [NSColor sageGreen];  // extended edge cell
    cellColor[2] = [NSColor greyGreen];  // reduced edge cell
    cellColor[3] = [NSColor orchidPink]; // corner cell
    
    trgColor[0] = [NSColor sageGreen];
    trgColor[1] = [NSColor palePeach];
    trgColor[2] = [NSColor orchidPink];
    trgColor[3] = [NSColor paleBlue];
    trgColor[4] = [NSColor greyGreen]; // for weird configurations in HD partials
    trgColor[5] = [NSColor whiteColor]; // for weird trigger cell in LD1

    
    for (int i=0; i<6; i++) {
        rot60[i] = [NSAffineTransform transform];
        [rot60[i] rotateByDegrees:(double)(i*60)];
    }
    
    flipX = [NSAffineTransform transform];
    [flipX scaleXBy: -1. yBy: 1.];
    
    flipY = [NSAffineTransform transform];
    [flipY scaleXBy: 1. yBy: -1.];
    
    hardToReference = [NSAffineTransform transform];
    [hardToReference rotateByDegrees:150.];
    referenceToHard = [NSAffineTransform transform];
    [referenceToHard rotateByDegrees:210.];
    
    offsetLD[0] = NSMakePoint(0.,-cellSideLD);
    offsetHD[0] = NSMakePoint(0.,-cellSideHD);
    for (int i=1; i<6; i++) {
        offsetLD[i] = [rot60[i] transformPoint:offsetLD[0]];
        offsetHD[i] = [rot60[i] transformPoint:offsetHD[0]];
    }

    // ------ Make the layout hexagon
    waferLayoutHexagon = [NSBezierPath bezierPath];
    NSPoint pnt = NSMakePoint(-0.5*waferSide,0.5*layoutHexagonWidth);
    [waferLayoutHexagon moveToPoint:pnt];
    for(int i=0; i<5; i++) {
        pnt = [rot60[1] transformPoint:pnt];
        [waferLayoutHexagon lineToPoint:pnt];
    }
    [waferLayoutHexagon closePath];
    [waferLayoutHexagon setLineWidth:0.2];
    
    // ----- Make the physical wafer
    double dx = halfDiceWidth*LDzoltanC.x/LDzoltanC.y;
    NSPoint cprime = NSMakePoint(-LDzoltanC.x-dx,LDzoltanC.y+halfDiceWidth);
    NSPoint ccprime = [hardToReference transformPoint:cprime];
    ccprime.x = -ccprime.x;
    ccprime = [referenceToHard transformPoint:ccprime];
    physicalWafer = [NSBezierPath bezierPath];
    [physicalWafer moveToPoint:cprime];
    for(int i=0; i<5; i++) {
        [physicalWafer lineToPoint:ccprime];
        cprime = [rot60[1] transformPoint:cprime];
        [physicalWafer lineToPoint:cprime];
        ccprime = [rot60[1] transformPoint:ccprime];
    }
    [physicalWafer lineToPoint:ccprime];
    [physicalWafer closePath];
    [physicalWafer setLineWidth:0.15];

    // ----- Make the centre marker (x,y) axes in hardware orientation
    hardXyAxes = [NSBezierPath bezierPath];
    [hardXyAxes moveToPoint:NSMakePoint(-100.,0.)];
    [hardXyAxes lineToPoint:NSMakePoint(+100.,0.)];
    [hardXyAxes moveToPoint:NSMakePoint(0.,-100.)];
    [hardXyAxes lineToPoint:NSMakePoint(0.,+100.)];
    [hardXyAxes setLineWidth:0.1];

    [self makeGridForDense:NO];
    [self makeGridForDense:YES];
    
    [self addCalibrationCellsForDense:NO];
    [self addCalibrationCellsForDense:YES];
    
    [self setDicingLines];
    
    [self makePartialWaferForDense:NO];
    [self makePartialWaferForDense:YES];
    
    theDetInterface = [HXGDetIdInterface sharedDetInterface];
    
    NSArray * arrayOfArrays = [NSArray arrayWithObjects:cellsArrayLD,cellsArrayHD,partialCellsArrayLD[0],partialCellsArrayLD[1],partialCellsArrayLD[2],partialCellsArrayLD[3],partialCellsArrayLD[4],partialCellsArrayLD[5],partialCellsArrayHD[0],partialCellsArrayHD[1],partialCellsArrayHD[2],partialCellsArrayHD[3],partialCellsArrayHD[4],nil];
    [theDetInterface setCellsArrays:arrayOfArrays];

        
    return self;
}
#pragma mark - The big construction work
- (void) makeGridForDense:(BOOL) HD {
    
    theNeighbourFinder = [HXGNeighbourFinder sharedNeighbourFinder];
    
    double side = cellSideLD;
    double width = cellWidthLD;
    int * edge = edgeLD[0];
    int * corner = cornerLD[0];
    NSPoint * offset = offsetLD;
    int n = NLD;
    const int * inc = incLD;
    NSMutableArray * cellsArray = [NSMutableArray arrayWithCapacity:3*n*n];
    if(HD) {
        side = cellSideHD;
        width = cellWidthHD;
        edge = edgeHD[0];
        corner = cornerHD[0];
        offset = offsetHD;
        n = NHD;
        inc = incHD;
    }
    
    // ------------- Make the array of cells -------------------------
    
    int ig = 0;
    double y = 0.5*(layoutHexagonWidth - side);
    for (int ivert=0; ivert < 2*n; ivert++) {
        double x = (-0.5*(double)inc[ivert] + 0.5)*width;
        NSPoint cntr = NSMakePoint(x,y);
        for (int ihorz=0; ihorz < inc[ivert]; ihorz++) {
            HXGStructuredCell * cs = [HXGStructuredCell cellDense:HD withCentre:cntr];
            for (int i=0; i<6; i++) {
                [cs setGridCorner:i To:[self vectorSum:cntr And:offset[i]]];
                [cs setCellCorner:i To:[self vectorSum:cntr And:offset[i]]];
            }
            [cs makeGridBezier];
            [cs makeCellBezier];
            [cs setType:0];
            [cs setGridCount:ig];
            int iv = ihorz;
            if(ivert > n) iv += ivert-n;
            [cs setIdU:ivert andV:iv];
            [cs setEdgeIndex:[theNeighbourFinder edgeIndexForU:ivert andV:iv density:HD]];
            [cellsArray addObject:cs];
            cntr.x += width;
            ig++;
        }
        y -= 1.5*side;
    }
    
    if(HD) cellsArrayHD = [NSArray arrayWithArray:cellsArray];
    else cellsArrayLD = [NSArray arrayWithArray:cellsArray];
    
    // ---------- Now adjust the edge cells -----------------
    
    for (int icell=0; icell < n; icell++) {            // EDGE 0
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=2; icnr<5; icnr++) {
            NSPoint cnr = [cs getCellCorner:icnr];
            cnr.y = 0.5 * activeWidth;
            [cs setCellCorner:icnr To:cnr];
        }
        [cs makeCellBezier];
        [cs setType:2];
    }
    
    int icell = 0;
    for (int i=0; i < n; i++) {            // EDGE 1
        icell += inc[i];
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=3; icnr<6; icnr++) {
            NSPoint cnr = [rot60[5] transformPoint:[cs getCellCorner:icnr]];
            cnr.y = 0.5 * activeWidth;
            cnr = [rot60[1] transformPoint:cnr];
            [cs setCellCorner:icnr To:cnr];
        }
        [cs makeCellBezier];
        [cs setType:1];
    }
    
    for (int i=0; i < n; i++) {            // EDGE 2
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=4; icnr<7; icnr++) {
            NSPoint cnr = [rot60[4] transformPoint:[cs getCellCorner:icnr%6]];
            cnr.y = 0.5 * activeWidth;
            cnr = [rot60[2] transformPoint:cnr];
            [cs setCellCorner:icnr%6 To:cnr];
        }
        [cs makeCellBezier];
        [cs setType:2];
        icell += inc[i+n];
    }
    
    icell = (int) cellsArray.count - 1;
    for (int i=0; i < n; i++) {            // EDGE 3
        icell --;
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=5; icnr<8; icnr++) {
            NSPoint cnr = [rot60[3] transformPoint:[cs getCellCorner:icnr%6]];
            cnr.y = 0.5 * activeWidth;
            cnr = [rot60[3] transformPoint:cnr];
            [cs setCellCorner:icnr%6 To:cnr];
        }
        [cs setType:1];
        [cs makeCellBezier];
    }
    
    icell = (int) cellsArray.count - 1;
    for (int i=0; i < n; i++) {            // EDGE 4
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=0; icnr<3; icnr++) {
            NSPoint cnr = [rot60[2] transformPoint:[cs getCellCorner:icnr]];
            cnr.y = 0.5 * activeWidth;
            cnr = [rot60[4] transformPoint:cnr];
            [cs setCellCorner:icnr To:cnr];
        }
        [cs makeCellBezier];
        [cs setType:2];
        icell -= inc[2*n-1-i];
    }
    
    icell = -1;
    for (int i=0; i < n; i++) {            // EDGE 5
        icell += inc[i];
        HXGStructuredCell * cs = cellsArray[icell];
        for (int icnr=1; icnr<4; icnr++) {
            NSPoint cnr = [rot60[1] transformPoint:[cs getCellCorner:icnr]];
            cnr.y = 0.5 * activeWidth;
            cnr = [rot60[5] transformPoint:cnr];
            [cs setCellCorner:icnr To:cnr];
        }
        [cs setType:1];
        [cs makeCellBezier];
    }
    
    // ---------- Now adjust the corner cells -----------------
    NSPoint pointA,pointB,pointC,pointD;
    
    double m1 = 1./sqrt(3.);                // Line 1
    double r = waferSide - mouseBitePerp;
    double c1 =  r*0.5 * (sqrt(3.) + m1);
    
    double m2 = -m1;                        // Line 2
    double c2 = (layoutHexagonWidth-3.*side)*0.5 + 0.5*m2*width*(double)(n-1);
    
    double m3 = sqrt(3.);                   // Line 3
    double c3 = activeWidth;
    
    double xa = (c3 - c1)/(m1-m3);          // Point A
    double ya = m1*xa + c1;
    pointA = NSMakePoint(xa,ya);
    
    double xb = (c2 - c1)/(m1-m2);          // Point B
    double yb = m1*xb + c1;
    pointB = NSMakePoint(xb,yb);
    
    double yc = 0.5*activeWidth;            // Point C
    double xc = (yc - c1)/m1;
    pointC = NSMakePoint(xc,yc);
    
    double xd = -(double)(n/2 - 1)*width;    // Point D
    double yd = m1*xd + c1;
    pointD = NSMakePoint(xd,yd);
    
    
    int nc = (int) cellsArray.count;
    int icorner[6];
    int iextend[6];
    int ireduce[6];
    icorner[0] = 0;          iextend[0] = icorner[0] + n;        ireduce[0] = icorner[0] + 1;
    icorner[1] = (nc - n)/2; iextend[1] = icorner[1] - inc[n-1]; ireduce[1] = icorner[1] + inc[n];
    icorner[2] = nc - n - 1; iextend[2] = icorner[2] + 1;        ireduce[2] = icorner[2] - inc[2*n-2];
    icorner[3] = nc - 1;     iextend[3] = icorner[3] - 1;        ireduce[3] = icorner[3] - inc[2*n-1];
    icorner[4] = icorner[1] + inc[n] - 1;
    iextend[4] = icorner[4] - inc[n];   ireduce[4] = icorner[4] + inc[n+1];
    icorner[5] = inc[0] - 1; iextend[5] = icorner[5] + inc[1];   ireduce[5] = icorner[5] - 1;
    
    //-------------------------------------------------- CORNER 0
    HXGStructuredCell * cs = cellsArray[icorner[0]];
    [cs setCellCorner:5 To:pointB];
    [cs setCellCorner:4 To:pointB];
    if(HD) {
        [cs setCellCorner:3 To:pointD];
        [cs setCellCorner:2 To:pointD];
    } else [cs setCellCorner:3 To:pointC];
    [cs makeCellBezier];
    [cs setType:3];
    
    cs = cellsArray[iextend[0]];
    [cs setCellCorner:3 To:pointB];
    [cs setCellCorner:4 To:pointA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[0]];
        [cs setCellCorner:3 To:pointC];
        [cs setCellCorner:4 To:pointD];
        [cs makeCellBezier];
    }
    
    //-------------------------------------------------- CORNER 2
    NSPoint pA = [rot60[2] transformPoint:pointA];
    NSPoint pB = [rot60[2] transformPoint:pointB];
    NSPoint pC = [rot60[2] transformPoint:pointC];
    NSPoint pD = [rot60[2] transformPoint:pointD];
    
    cs = cellsArray[icorner[2]];
    [cs setCellCorner:0 To:pB];
    [cs setCellCorner:1 To:pB];
    if(HD) {
        [cs setCellCorner:5 To:pD];
        [cs setCellCorner:4 To:pD];
    } else [cs setCellCorner:5 To:pC];
    [cs makeCellBezier];
    [cs setType:3];
    
    
    cs = cellsArray[iextend[2]];
    [cs setCellCorner:5 To:pB];
    [cs setCellCorner:0 To:pA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[2]];
        [cs setCellCorner:5 To:pC];
        [cs setCellCorner:0 To:pD];
        [cs makeCellBezier];
    }
    
    //-------------------------------------------------- CORNER 4
    pA = [rot60[4] transformPoint:pointA];
    pB = [rot60[4] transformPoint:pointB];
    pC = [rot60[4] transformPoint:pointC];
    pD = [rot60[4] transformPoint:pointD];
    
    cs = cellsArray[icorner[4]];
    [cs setCellCorner:2 To:pB];
    [cs setCellCorner:3 To:pB];
    if(HD) {
        [cs setCellCorner:1 To:pD];
        [cs setCellCorner:0 To:pD];
    } else [cs setCellCorner:1 To:pC];
    [cs makeCellBezier];
    [cs setType:3];
    
    
    cs = cellsArray[iextend[4]];
    [cs setCellCorner:1 To:pB];
    [cs setCellCorner:2 To:pA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[4]];
        [cs setCellCorner:1 To:pC];
        [cs setCellCorner:2 To:pD];
        [cs makeCellBezier];
    }
    
    //-------------------------------------------------- CORNER 5
    pA = [flipX transformPoint:pointA];
    pB = [flipX transformPoint:pointB];
    pC = [flipX transformPoint:pointC];
    pD = [flipX transformPoint:pointD];
    
    cs = cellsArray[icorner[5]];
    [cs setCellCorner:1 To:pB];
    [cs setCellCorner:2 To:pB];
    if(HD) {
        [cs setCellCorner:3 To:pD];
        [cs setCellCorner:4 To:pD];
    } else [cs setCellCorner:3 To:pC];
    [cs makeCellBezier];
    [cs setType:3];
    
    
    cs = cellsArray[iextend[5]];
    [cs setCellCorner:3 To:pB];
    [cs setCellCorner:2 To:pA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[5]];
        [cs setCellCorner:3 To:pC];
        [cs setCellCorner:2 To:pD];
        [cs makeCellBezier];
    }
    
    //-------------------------------------------------- CORNER 1
    pA = [rot60[2] transformPoint:pA];
    pB = [rot60[2] transformPoint:pB];
    pC = [rot60[2] transformPoint:pC];
    pD = [rot60[2] transformPoint:pD];
    
    cs = cellsArray[icorner[1]];
    [cs setCellCorner:3 To:pB];
    [cs setCellCorner:4 To:pB];
    if(HD) {
        [cs setCellCorner:5 To:pD];
        [cs setCellCorner:0 To:pD];
    } else [cs setCellCorner:5 To:pC];
    [cs makeCellBezier];
    [cs setType:3];
    
    
    cs = cellsArray[iextend[1]];
    [cs setCellCorner:5 To:pB];
    [cs setCellCorner:4 To:pA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[1]];
        [cs setCellCorner:5 To:pC];
        [cs setCellCorner:4 To:pD];
        [cs makeCellBezier];
    }
    
    //-------------------------------------------------- CORNER 3
    pA = [rot60[2] transformPoint:pA];
    pB = [rot60[2] transformPoint:pB];
    pC = [rot60[2] transformPoint:pC];
    pD = [rot60[2] transformPoint:pD];
    
    cs = cellsArray[icorner[3]];
    [cs setCellCorner:5 To:pB];
    [cs setCellCorner:0 To:pB];
    if(HD) {
        [cs setCellCorner:1 To:pD];
        [cs setCellCorner:2 To:pD];
    } else [cs setCellCorner:1 To:pC];
    [cs makeCellBezier];
    [cs setType:3];
    
    
    cs = cellsArray[iextend[3]];
    [cs setCellCorner:1 To:pB];
    [cs setCellCorner:0 To:pA];
    [cs makeCellBezier];
    
    if(HD) {
        cs = cellsArray[ireduce[3]];
        [cs setCellCorner:1 To:pC];
        [cs setCellCorner:0 To:pD];
        [cs makeCellBezier];
    }
    
}

- (void) makePartialWaferForDense:(BOOL) HD {
    
    double side = cellSideLD;
    double width = cellWidthLD;
    int * edge = edgeLD[0];
    int * corner = cornerLD[0];
    NSPoint * offset = offsetLD;
    int n = NLD;
    const int * inc = incLD;
    double diceVert1 = diceVert1LD;
    double diceVert2 = diceVert2LD;
    double diceHorz = diceHorzLD;
    NSMutableArray * cellsArray = [NSMutableArray arrayWithCapacity:3*n*n+20];
    NSArray * inputCells = cellsArrayLD;
    int ivHorzDice = 7;
    int ihV1Dice = -1;
    int ihV2Dice = 7;
    int iSpecial1 = 7;
    int iSpecial2 = 16;
    int iSpecial3 = 26;
    int iSpecial4 = 182;
    int iSpecial5 = 191;
    if(HD) {
        side = cellSideHD;
        width = cellWidthHD;
        edge = edgeHD[0];
        corner = cornerHD[0];
        offset = offsetHD;
        n = NHD;
        inc = incHD;
        diceVert1 = diceVert1HD;
        diceVert2 = diceVert2HD;
        diceHorz = diceHorzHD;
        inputCells = cellsArrayHD;
        ivHorzDice = 9;
        ihV1Dice = -8;
        ihV2Dice = 6;
        iSpecial1 = 144;
        iSpecial2 = 164;
        iSpecial3 = 186;
        iSpecial4 = -99;
        iSpecial5 = -99;
    }
    
    // ------------- Build the array of partial cells -------------------------
    
    int iin = -1;
    for (int ivert=0; ivert < 2*n; ivert++) {
        for (int ihorz=0; ihorz < inc[ivert]; ihorz++) {
            iin++;
            HXGStructuredCell * cs = inputCells[iin];
            if(iin == iSpecial1 || iin == iSpecial2 || iin == iSpecial3 || iin == iSpecial4 || iin == iSpecial5) {
                cs = [HXGStructuredCell cellWithCell:cs];
                [self specialTreatmentFor:cs Special:iin];
                [cellsArray addObject:cs];
                if(!HD && iin == iSpecial3) {
                    [cellsArray[17] setSiblingCell:cs];
                    [cs setSiblingCell:cellsArray[17]];
                }
                if(!HD && iin == iSpecial5) {
                    [cs setSiblingCell:cellsArray[195]];
                    [cellsArray[195] setSiblingCell:cs];
                }
                continue;
            }
            
            if(ivert == ivHorzDice) {             //--- Horizontal dicing band (top) ---------------
                cs = [HXGStructuredCell cellWithCell:cs];
                if(HD && cs.edge) {
                    int ip = 0;
                    if(ihorz > 0) ip = 3;
                    [cs setCellCorner:4 To:dicePntHorzHD[ip]];
                }
                [self setCell:cs BottomTo:diceHorz+halfDiceWidth];
            } else if(ivert == ivHorzDice+1) { //--- Horizontal dicing band (bottom)
                cs = [HXGStructuredCell cellWithCell:cs];
                if(HD && cs.edge) {
                    int ip = 1;
                    if(ihorz > 0) ip = 2;
                    [cs setCellCorner:4 To:dicePntHorzHD[ip]];
                }
                [self setCell:cs TopTo:diceHorz-halfDiceWidth];
            }
            
            if(ihorz == (inc[ivert]+ihV1Dice)/2) {       //--- Vertical dicing band 1 -------------
                if(ivert%2 == (int) HD) { // low side cell; adjust right edges
                    cs = [HXGStructuredCell cellWithCell:cs];
                    [self setCell:cs RightTo:diceVert1-halfDiceWidth];
                } else {           // split cells
                    cs = [HXGStructuredCell cellWithCell:cs];
                    HXGStructuredCell * css = [HXGStructuredCell cellWithCell:cs];
                    [self constructSplitCell:css LeftAt:diceVert1-halfDiceWidth];
                    [css makeCellBezier];
                    [cellsArray addObject:css];
                    [self constructSplitCell:cs RightAt:diceVert1+halfDiceWidth];
                    [cs setSiblingCell:css];
                    [css setSiblingCell:cs];
                }
            } else if(ihorz == (inc[ivert]+ihV1Dice)/2 + 1 && ivert%2 == (int) HD) {// high side cell; do left edges
                cs = [HXGStructuredCell cellWithCell:cs];
                [self setCell:cs LeftTo:diceVert1+halfDiceWidth];
            } else if (ihorz == (inc[ivert]+ihV2Dice)/2) { //--- Vertical dicing band 2 -------------
                if(ivert%2 == (int) HD) { // low side cell; adjust right edges
                    cs = [HXGStructuredCell cellWithCell:cs];
                    [self setCell:cs RightTo:diceVert2-halfDiceWidth];
                } else {           // split cells
                    cs = [HXGStructuredCell cellWithCell:cs];
                    HXGStructuredCell * css = [HXGStructuredCell cellWithCell:cs];
                    [self constructSplitCell:css LeftAt:diceVert2-halfDiceWidth];
                    [cellsArray addObject:css];
                    [self constructSplitCell:cs RightAt:diceVert2+halfDiceWidth];
                    [cs setSiblingCell:css];
                    [css setSiblingCell:cs];
                }
            } else if(ihorz == (inc[ivert]+ihV2Dice)/2 + 1 && ivert%2 == (int) HD) {// high side cell; do left edges
                cs = [HXGStructuredCell cellWithCell:cs];
                [self setCell:cs LeftTo:diceVert2+halfDiceWidth];
            }
            [cellsArray addObject:cs];
        }
    }
    
    if(HD) partialCellsArrayHD[0] = [NSArray arrayWithArray:cellsArray];
    else   partialCellsArrayLD[0] = [NSArray arrayWithArray:cellsArray];
    
    [self addPartialCalibrationCellsForDense:NO];
    [self addPartialCalibrationCellsForDense:YES];
    
    [self constructPartialArraysForLD];
    [self constructPartialArraysForHD];
        
}



#pragma mark - Private tools

- (void) addCalibrationCellsForDense:(BOOL) HD {
    
    NSArray * cellsArray = cellsArrayLD;
    const int * calib = calibLD;
    int nc = 6;
    double radius = radiusCalibLD;
    if(HD) {
        cellsArray = cellsArrayHD;
        calib = calibHD;
        nc = 12;
        radius = radiusCalibHD;
    }
    
    int hard = 1;
    int ical = 0;
    for(int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        [cs setHardwareChan:hard];
        hard++;
        if(i == calib[ical]) {
            [cs setCalibWithRadius:radius];
            ical++;
            hard++;
        }
    }
    
}

- (void) addPartialCalibrationCellsForDense:(BOOL) HD {
    
    NSArray * cellsArray = partialCellsArrayLD[0];
    const int * calib = partialCalibLD;
    int nc = 6;
    double radius = radiusCalibLD;
    if(HD) {
        cellsArray = partialCellsArrayHD[0];
        calib = partialCalibHD;
        nc = 12;
        radius = radiusCalibHD;
    }
    
    int hard = 1;
    int ical = 0;
    for(int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        [cs setPartialHardwareChan:hard];
        hard++;
        if(i == calib[ical]) {
            [cs setPartialCalibWithRadius:radius];
            ical++;
            hard++;
        }
    }
    
}

- (void) constructPartialArraysForLD {
    
    NSMutableArray * cellsArray1 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray2 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray3 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray4 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray5 = [NSMutableArray arrayWithCapacity:100];
    
    NSArray * inputArray = partialCellsArrayLD[0];
    
    for(int i=0; i<inputArray.count; i++) {
        HXGStructuredCell * cs = inputArray[i];
        double y = [cs getCellCorner:1].y;
        double x = [cs getCellCorner:0].x;
        if(x < diceVert1LD) {
            [cellsArray3 addObject:cs];
            [cs setPresentInType:3];
            [cellsArray5 addObject:cs];
            [cs setPresentInType:5];
        } else {
            [cellsArray4 addObject:cs];
            [cs setPresentInType:4];
            if(x < diceVert2LD) {
                [cellsArray5 addObject:cs];
                [cs setPresentInType:5];
            }
        }
        if(y > diceHorzLD) {
            [cellsArray1 addObject:cs];
            [cs setPresentInType:1];
        }
        else {
            [cellsArray2 addObject:cs];
            [cs setPresentInType:2];
        }
    }
    
    partialCellsArrayLD[1] = [NSArray arrayWithArray:cellsArray1];
    partialCellsArrayLD[2] = [NSArray arrayWithArray:cellsArray2];
    partialCellsArrayLD[3] = [NSArray arrayWithArray:cellsArray3];
    partialCellsArrayLD[4] = [NSArray arrayWithArray:cellsArray4];
    partialCellsArrayLD[5] = [NSArray arrayWithArray:cellsArray5];
    
}

- (void) constructPartialArraysForHD {
    
    NSMutableArray * cellsArray1 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray2 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray3 = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray * cellsArray4 = [NSMutableArray arrayWithCapacity:100];
    
    NSArray * inputArray = partialCellsArrayHD[0];
    
    for(int i=0; i<inputArray.count; i++) {
        HXGStructuredCell * cs = inputArray[i];
        double y = [cs getCellCorner:2].y;
        double x = [cs getCellCorner:0].x;
        if(x < diceVert1HD) {
            [cellsArray3 addObject:cs];
            [cs setPresentInType:3];
        }
        else if(x > diceVert2HD) {
            [cellsArray4 addObject:cs];
            [cs setPresentInType:4];
        }
        if(y > diceHorzHD) {
            [cellsArray1 addObject:cs];
            [cs setPresentInType:1];
        } else {
            [cellsArray2 addObject:cs];
            [cs setPresentInType:2];
        }
    }
    
    partialCellsArrayHD[1] = [NSArray arrayWithArray:cellsArray1];
    partialCellsArrayHD[2] = [NSArray arrayWithArray:cellsArray2];
    partialCellsArrayHD[3] = [NSArray arrayWithArray:cellsArray3];
    partialCellsArrayHD[4] = [NSArray arrayWithArray:cellsArray4];
    
}

- (void) setDicingLines {
    
    double activeHalfW = 0.5 * activeWidth;
    
    diceVert1LD = 0.;
    diceHorzLD = 0.;
    HXGStructuredCell * cs = cellsArrayLD[16];
    NSPoint pnt = [cs getGridCorner:0];
    diceVert2LD = pnt.x;
    
    cs = cellsArrayHD[2];
    pnt = [cs getGridCorner:0];
    diceVert1HD = pnt.x;
    cs = cellsArrayHD[9];
    pnt = [cs getGridCorner:0];
    diceVert2HD = pnt.x;
    cs = cellsArrayHD[144];
    pnt = [cs getGridCorner:1];
    diceHorzHD = pnt.y;
    // NSLog(@"0: diceHorzHD = %.4f",diceHorzHD);
    
    //----------- Make the dicing band points
    
    dicePntVert1LD[0] = LDzoltanA;
    dicePntVert1LD[1] = LDzoltanA;
    dicePntVert1LD[1].x = -dicePntVert1LD[1].x;
    dicePntVert1LD[2] = LDzoltanB;
    dicePntVert1LD[2].x = -dicePntVert1LD[2].x;
    dicePntVert1LD[3] = LDzoltanB;
        
    dicePntVert2LD[0] = LDzoltanD;
    dicePntVert2LD[1] = LDzoltanD;
    dicePntVert2LD[1].x = dicePntVert2LD[1].x;
    dicePntVert2LD[2] = LDzoltanE;
    dicePntVert2LD[2].x = dicePntVert2LD[2].x;
    dicePntVert2LD[3] = LDzoltanE;
    
    double x = waferSide - mouseBitePerp;
    
    dicePntHorzLD[0] = NSMakePoint(-x,diceHorzLD + halfDiceWidth);
    dicePntHorzLD[1] = NSMakePoint(-x,diceHorzLD - halfDiceWidth);
    dicePntHorzLD[2] = NSMakePoint( x,diceHorzLD - halfDiceWidth);
    dicePntHorzLD[3] = NSMakePoint( x,diceHorzLD + halfDiceWidth);
    
    
    // ---- Now the HDs
    dicePntVert1HD[0] = NSMakePoint(diceVert1HD - halfDiceWidth,activeHalfW);
    dicePntVert1HD[1] = NSMakePoint(diceVert1HD - halfDiceWidth,-activeHalfW);
    dicePntVert1HD[2] = NSMakePoint(diceVert1HD + halfDiceWidth,-activeHalfW);
    dicePntVert1HD[3] = NSMakePoint(diceVert1HD + halfDiceWidth,activeHalfW);
    
    dicePntVert2HD[0] = NSMakePoint(diceVert2HD - halfDiceWidth,activeHalfW);
    dicePntVert2HD[1] = NSMakePoint(diceVert2HD - halfDiceWidth,-activeHalfW);
    dicePntVert2HD[2] = NSMakePoint(diceVert2HD + halfDiceWidth,-activeHalfW);
    dicePntVert2HD[3] = NSMakePoint(diceVert2HD + halfDiceWidth,activeHalfW);
    
    double zPntExHD = HDzoltanE.x;  // Use Zoltan's points
    double zPntFxHD = HDzoltanF.x;
    
    dicePntHorzHD[0] = NSMakePoint(-zPntExHD,diceHorzHD + halfDiceWidth);
    dicePntHorzHD[1] = NSMakePoint(-zPntFxHD,diceHorzHD - halfDiceWidth);
    dicePntHorzHD[2] = NSMakePoint( zPntFxHD,diceHorzHD - halfDiceWidth);
    dicePntHorzHD[3] = NSMakePoint( zPntExHD,diceHorzHD + halfDiceWidth);
    
    //NSLog(@"diceHorzHD + halfDiceWidth %.6f, diceHorzHD - halfDiceWidth %.6f",diceHorzHD + halfDiceWidth,diceHorzHD - halfDiceWidth);

    
}

- (void) setCell:(HXGStructuredCell *) cx BottomTo:(double) y {
    
    NSPoint pnt;
    pnt = [cx getCellCorner:5];
    pnt.y = y;
    [cx setCellCorner:5 To: pnt];
    pnt.x = [cx getCellCorner:0].x;
    [cx setCellCorner:0 To: pnt];
    pnt.x = [cx getCellCorner:1].x;
    [cx setCellCorner:1 To: pnt];
    
    [cx makeCellBezier];
    
}

- (void) setCell:(HXGStructuredCell *) cx TopTo:(double) y {
    
    NSPoint pnt = NSMakePoint([cx getCellCorner:4].x,y);
    [cx setCellCorner:4 To: pnt];
    pnt.x = [cx getCellCorner:3].x;
    [cx setCellCorner:3 To: pnt];
    pnt.x = [cx getCellCorner:2].x;
    [cx setCellCorner:2 To: pnt];
    
    [cx makeCellBezier];
    
}

- (void) setCell:(HXGStructuredCell *) cx LeftTo:(double) x {
    
    NSPoint pnt = NSMakePoint(x,[cx getCellCorner:5].y);
    if(fabs(pnt.y - [cx getGridCorner:5].y) < 0.001) pnt.y -= 0.5*halfDiceWidth;
    [cx setCellCorner:5 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:4].y);
    if(fabs(pnt.y - [cx getGridCorner:4].y) < 0.001) pnt.y += 0.5*halfDiceWidth;
    [cx setCellCorner:4 To: pnt];
    
    [cx makeCellBezier];
    
}

- (void) setCell:(HXGStructuredCell *) cx RightTo:(double) x {
    
    NSPoint pnt = NSMakePoint(x,[cx getCellCorner:1].y);
    if(fabs(pnt.y - [cx getGridCorner:1].y) < 0.001) pnt.y -= 0.5*halfDiceWidth;
    [cx setCellCorner:1 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:2].y);
    if(fabs(pnt.y - [cx getGridCorner:2].y) < 0.001) pnt.y += 0.5*halfDiceWidth;
    [cx setCellCorner:2 To: pnt];
    
    [cx makeCellBezier];
    
}

- (void) constructSplitCell:(HXGStructuredCell *) cx LeftAt:(double) x {
    
    NSPoint pnt;
    pnt = NSMakePoint(x,[cx getCellCorner:0].y);
    if(fabs(pnt.y - [cx getGridCorner:0].y) < 0.001) pnt.y += 0.5*halfDiceWidth;
    [cx setCellCorner:0 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:1].y);
    [cx setCellCorner:1 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:2].y);
    [cx setCellCorner:2 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:3].y);
    if(fabs(pnt.y - [cx getGridCorner:3].y) < 0.001) pnt.y -= 0.5*halfDiceWidth;
    [cx setCellCorner:3 To: pnt];
    
    [cx makeCellBezier];
    [cx setSplit:YES];
    
}

- (void) constructSplitCell:(HXGStructuredCell *) cx RightAt:(double) x {
    
    NSPoint pnt;
    pnt = NSMakePoint(x,[cx getCellCorner:0].y);
    if(fabs(pnt.y - [cx getGridCorner:0].y) < 0.001) pnt.y += 0.5*halfDiceWidth;
    [cx setCellCorner:0 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:5].y);
    [cx setCellCorner:5 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:4].y);
    [cx setCellCorner:4 To: pnt];
    pnt = NSMakePoint(x,[cx getCellCorner:3].y);
    if(fabs(pnt.y - [cx getGridCorner:3].y) < 0.001) pnt.y -= 0.5*halfDiceWidth;
    [cx setCellCorner:3 To: pnt];
    
    [cx makeCellBezier];
    [cx setSplit:YES];
    
}

- (void) specialTreatmentFor:(HXGStructuredCell *) cx Special:(int) i {
    
    if(i == 7) {
        NSPoint pnt = NSMakePoint(47.4374,77.5032);
        [cx setCellCorner:2 To: pnt];
        pnt.y = [cx getGridCorner:1].y - 0.5*halfDiceWidth;
        [cx setCellCorner:1 To: pnt];
        [cx setSpecial:YES];
    } else if(i == 16) {
        NSPoint pnt = NSMakePoint(47.4375, [cx getGridCorner:3].y - 0.5*halfDiceWidth);
        [cx setCellCorner:3 To:pnt];
        [cx setCellCorner:2 To:pnt];
        pnt.y = [cx getGridCorner:0].y + 0.5*halfDiceWidth;
        [cx setCellCorner:1 To:pnt];
        [cx setCellCorner:0 To:pnt];
        [cx setType:0];
        [cx setSpecial:YES];
    } else if(i == 26) {
        NSPoint pnt = LDzoltanE; // Zoltan E (LD)
        [cx setCellCorner:4 To:pnt];
        pnt = LDzoltanF; // Zoltan F (LD)
        [cx setCellCorner:3 To:pnt];
        pnt.y = [cx getGridCorner:5].y  - 0.5*halfDiceWidth;
        pnt.x = 49.2345;
        [cx setCellCorner:5 To:pnt];
        [cx setType:3];
        [cx setSpecial:YES];
    } else if(i == 182) {
        NSPoint pnt = LDzoltanE; // Zoltan E (LD) transposed
        pnt.y = -pnt.y;
        [cx setCellCorner:0 To:pnt];
        [cx setCellCorner:5 To:pnt];
        pnt.y = [cx getGridCorner:4].y + 0.5*halfDiceWidth;
        [cx setCellCorner:4 To:pnt];
        pnt = LDzoltanF; // Zoltan F (LD) transposed
        pnt.y = -pnt.y;
        [cx setCellCorner:1 To:pnt];
        [cx setType:3];
        [cx setSpecial:YES];
    } else if(i == 191) {
        NSPoint pnt = LDzoltanD; // Zoltan D (LD) transposed
        pnt.y = -pnt.y;
        [cx setCellCorner:0 To:pnt];
        [cx setCellCorner:1 To:pnt];
        [cx setCellCorner:2 To:pnt];
        pnt.y = [cx getGridCorner:3].y - 0.5*halfDiceWidth;
        [cx setCellCorner:3 To:pnt];
        [cx setSpecial:YES];
    } else if(i == 144) {
        NSPoint pnt = HDzoltanE; // Zoltan E (HD) transposed
        pnt.x = -pnt.x;
        [cx setCellCorner:0 To:pnt];
        [cx setCellCorner:4 To:pnt];
        [cx setCellCorner:5 To:pnt];
        pnt.x = [cx getGridCorner:2].x;
        pnt.y = HDzoltanE.y;
        [cx setCellCorner:1 To:pnt];
        [cx setSpecial:YES];
    } else if(i == 164) {
        NSPoint pnt = [cx getGridCorner:5];
        pnt.y += halfDiceWidth;
        [cx setCellCorner:5 To:pnt];
        [cx setCellCorner:0 To:HDzoltanE];
        [cx setCellCorner:1 To:HDzoltanE];
        //[cx setCellCorner:2 To:HDzoltanE];
        [cx setSpecial:YES];
    } else if(i == 186) {
        NSPoint pnt = [cx getGridCorner:4];
        pnt.y = diceHorzHD - halfDiceWidth;
        [cx setCellCorner:4 To:pnt];
        [cx setCellCorner:3 To:HDzoltanF];
        [cx setCellCorner:2 To:HDzoltanF];
        [cx setSpecial:YES];
    }
    
    [cx makeCellBezier];
    
}

-(NSPoint) vectorSum:(NSPoint) p And:(NSPoint) q {
    return NSMakePoint(p.x+q.x,p.y+q.y);
}
#pragma mark - Tools
- (NSPoint) convertPoint:(NSPoint) pnt toReferenceFromRotated:(int) irot {
   
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot < -1 || irot > 5) {
        [transform appendTransform:flipX];
    }
    if(irot < 0) [transform appendTransform:hardToReference];
    else [transform appendTransform:rot60[(12-irot)%6]];
    
    pnt = [transform transformPoint:pnt];
    
    return pnt;
}

- (NSPoint) convertPoint:(NSPoint) pnt toRotatedFromReference:(int) irot {
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) [transform appendTransform:rot60[irot%6]];
    else [transform appendTransform:referenceToHard];
    if(irot < -1 || irot > 5) {
        [transform appendTransform:flipX];
    }

    pnt = [transform transformPoint:pnt];
    
    return pnt;
}

- (NSPoint) convertPoint:(NSPoint) pnt toRotated:(int) irot fromRotated:(int) jrot {

    /*
        Rotation indices:
        -2 = hardware orientation mirrored
        -1 = hardware orientation
         0 - 11 = Sunanda's placement index
     */
    
    if(irot == jrot) return pnt;

    NSAffineTransform * transform = [NSAffineTransform transform];

    if(irot < 6 && (jrot > 5 || jrot == -2)) {   // TO a mirrored from a not mirrored
        [transform appendTransform:flipX];
    }
    
    if(irot == -1) [transform appendTransform:referenceToHard];
    if(jrot == -1) [transform appendTransform:hardToReference];
    int iirot = irot;
    if(irot < 0) iirot = 0;
    int jjrot = jrot;
    if(jrot < 0) jjrot = 0;
    [transform appendTransform:rot60[(12-jjrot+iirot)%6]];
    
    if(jrot < 6 && (irot > 5 || irot == -2)) { // TO a not mirrored from a mirrored
        [transform appendTransform:flipX];
    }

    pnt = [transform transformPoint:pnt];
    
    return pnt;

}

- (NSPoint) centroidOfCellUvid: (int *) iuiv inWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored {
 
    iuivId[0] = iuiv[0];
    iuivId[1] = iuiv[1];
    
    BOOL HD = waf.thickflag < 2;
    int irot = waf.channelZero;
    if(isMirrored) irot += 6;

    int ityp = waf.type;
    if(ityp == 0) ityp = -1;
    [self makeGridToCellMapForDense:HD Partial:ityp];
    
    int count = NLD;
    NSArray * cellsArray = cellsArrayLD;
    const int * inc = incLD;
    if(HD) {
        count = NHD;
        cellsArray = cellsArrayHD;
        inc = incHD;
    }

    int ip = 0;
    BOOL done = NO;
    for (int ivert=0; ivert < 2*count; ivert++) {
        for (int ihorz=0; ihorz < inc[ivert]; ihorz++) {
            int ivv = ihorz;
            if(ivert > count) ivv += ivert-count;
            if(iuivId[0] == ivert && iuivId[1] == ivv) {
                iuivId[2] = ip;
                done = YES;
                break;
            }
            ip++;
        }
        if(done) break;
    }
    
    if(ip >= gridToCellMap.count) return NSMakePoint(-1.E20,-1.E20);
    
    chosenCell = gridToCellMap[iuivId[2]];

    
    if(waf.part && ![chosenCell isPresentInType:waf.type]) return NSMakePoint(-1.E20,-1.E20);
    
    NSPoint pnt = [chosenCell getCellCentroid];
    chosenCellGridCentre = chosenCell.centre;
    
 // ----- if it is in a partial wafer and that cell is split...
    if(chosenCell.split && !waf.whole) {
        if(chosenCell.siblingCell && [chosenCell.siblingCell isPresentInType:waf.type]) {
            NSPoint qnt = [chosenCell.siblingCell getCellCentroid];
            pnt.x = 0.5*(pnt.x + qnt.x);
            pnt.y = 0.5*(pnt.y + qnt.y);
        }
    }
    
    // ---- Now need to do the transformations for iplacement
    chosenCellGridCentre = [hardToReference transformPoint:chosenCellGridCentre];
    chosenCellGridCentre = [rot60[waf.channelZero] transformPoint:chosenCellGridCentre];
    if(isMirrored) chosenCellGridCentre = [flipX transformPoint:chosenCellGridCentre];

    pnt = [hardToReference transformPoint:pnt];
    pnt = [rot60[waf.channelZero] transformPoint:pnt];
    if(isMirrored) pnt = [flipX transformPoint:pnt];

    return pnt;
}

- (HXGStructuredCell *) getChosenCell {
    return chosenCell;
}

- (NSPoint) getChosenCellGridCentre {
    return chosenCellGridCentre;
}


- (HXGStructuredCell *) cellAtPoint:(NSPoint) point Dense:(BOOL) HD Partial:(BOOL) partial {
    /* -------------------------------
     Method calculates cell iu,iv detId indices from the struct "point", which
     contains the x, y coordinates of a point relative to the wafer centre
     
     Uses the constants:
     count - characteristic number of the wafer (8 for LD wafers, 12 for HD wafers)
     side   - side of cell = cell width/sqrt(3)
     hWidth - half cell width
     ----------------------------------- */
   
    int iu,iv,iw;

    NSBezierPath * testHex = [hardToReference transformBezierPath:waferLayoutHexagon];
    if(![testHex containsPoint:point]) { // Check point is in wafer
        iuivId[2] = -1;
        return [HXGStructuredCell nullCell];
    }
    
    int count = NLD;
    double hWidth = 0.5*cellWidthLD;
    double side = cellSideLD;
    NSArray * cellsArray = cellsArrayLD;
    const int * inc = incLD;
    if(HD) {
        count = NHD;
        hWidth = 0.5*cellWidthHD;
        side = cellSideHD;
        cellsArray = cellsArrayHD;
        inc = incHD;
    }

    //--- Shift x,y axes origin to centre of cell (0,0)
    double x = point.x + 0.5*side;
    double y = point.y + (double)(2*count-1)*hWidth;
    
    double sin60 = sin(M_PI/3.);
    double cos60 = cos(M_PI/3.);
    //--- Calculate coordinates in u,v,w system
    double u =  x*sin60 + y*cos60 + 100.*hWidth; // Add 100.*hWidth to avoid
    double v = -x*sin60 + y*cos60 + 100.*hWidth; // casting integer on a negative number
    double w =  y + 100.*hWidth;                 // in the subsequent step

    //---- Set iu and iv to run from 0 to 4*N-1 (counting cell half widths)
    //         iw runs from -N to +3*N-1
    iu = (int) (u/hWidth) - 100 + count + 1;
    iv = (int) (v/hWidth) - 100 + count + 1;
    iw = (int) (w/hWidth) - 100 - count + 1;
    
    iuivId[0] = (iu + iw)/3; // Sunanda's u index
    iuivId[1] = (iv + iw)/3; // Sunanda's v index
    
    // Now deal with the extended side cells (which include more area than the grid hex cell)
    if(iv+iw < 0) {                             // bottom-right cells (in reference orientation)
        iuivId[0] = (iu+iw+1)/3;
    } else if(iuivId[1]-iuivId[0] > count-1) {  // left-side cells
        iuivId[0] = (iu+iw+1)/3;
        iuivId[1] = (iv+iw-1)/3;
    } else if(iuivId[0] > 2*count-1) {          // top-right cells
        iuivId[0] = 2*count-1;
        iuivId[1] = (iv+iw-1)/3;
    }
    
    // ---- Fudges for horizontal dicing line
    NSPoint pnt = [referenceToHard transformPoint:point];
    if(partial) {
        if(HD) {
            if(pnt.y < diceHorzHD && iuivId[0] < 10) {
                iuivId[0] = 10;
                iuivId[1] = (iv+iw+1)/3;
            }
        } else {
            if(pnt.y > diceHorzLD && iuivId[0] > 7) {
                iuivId[0] = 7;
                iuivId[1] = (iv+iw-1)/3;
            }
        }
    }
    
    int ip = 0;
    BOOL done = NO;
    for (int ivert=0; ivert < 2*count; ivert++) {
        for (int ihorz=0; ihorz < inc[ivert]; ihorz++) {
            int ivv = ihorz;
            if(ivert > count) ivv += ivert-count;
            if(iuivId[0] == ivert && iuivId[1] == ivv) {
                iuivId[2] = ip;
                done = YES;
                break;
            }
            ip++;
        }
        if(done) break;
    }
    
    chosenCell = gridToCellMap[iuivId[2]];
    
#ifdef DEBUG
    if(_debugPolyContain) {
        if([self testContainmentOf:pnt inBez:chosenCell.cellBezier]) {
            NSAlert * alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"We disagree here"];
            [alert setInformativeText:@"chosenCell"];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert runModal];

        }
        if(chosenCell.siblingCell) {
            if([self testContainmentOf:pnt inBez:chosenCell.siblingCell.cellBezier]) {
                NSAlert * alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"We disagree here"];
                [alert setInformativeText:@"chosenCell.siblinCell"];
                [alert setAlertStyle:NSAlertStyleWarning];
                [alert runModal];
            }
        }
   }
#endif
    
    if([chosenCell.cellBezier containsPoint:pnt]) return chosenCell;
    if(chosenCell.siblingCell) {
        chosenCell = chosenCell.siblingCell;
        if([chosenCell.cellBezier containsPoint:pnt]) return chosenCell;
    }
     
    return [HXGStructuredCell nullCell];
}


- (void) makeGridToCellMapForDense:(BOOL) HD Partial:(int) ipart {
    
  
    NSArray * cellsArray;
    int n = 3*NLD*NLD;
    if(HD) {
        if(ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
        else cellsArray = cellsArrayHD;
        n = 3*NHD*NHD;
    } else {
        if(!HD && ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
        else cellsArray = cellsArrayLD;
    }

    NSMutableArray * map = [NSMutableArray arrayWithCapacity:n];
    HXGStructuredCell * nullCell = [HXGStructuredCell nullCell];
    
    for (int i=0; i<n; i++) {
        [map addObject:nullCell];
    }
    
    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        if(cs.gridCount < 0 || cs.gridCount > n-1) NSLog(@"You fucked up %d",cs.gridCount);
        else [map replaceObjectAtIndex:cs.gridCount withObject:cs];
    }
    
    gridToCellMap = [NSArray arrayWithArray:map];

}

- (double) getCalibAreaForDense:(BOOL) HD {
    
    double r = radiusCalibLD;
    if(HD) r = radiusCalibHD;
    
    return M_PI*r*r;
}

- (double) getCellSideForDense:(BOOL) HD {
    
    if(HD) return cellSideHD;
    return cellSideLD;
    
}

- (NSString *) triggerAndRocTextForCell:(HXGStructuredCell *) cs inPartial:(int) pType {
    
    if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
    [theRawDataMap getTrgID:trgCells forHD:cs.HD andPartial:pType];
    
    int ih;
    if(pType == 0) ih = cs.hard-1;
    else ih = cs.partialHard-1;
    int jh = 999;
    
    if(cs.split) {
        if([cs.siblingCell isPresentInType:pType]) jh = cs.siblingCell.partialHard-1;
    }
    
    ih = MIN(ih,jh);

    NSString * text = [NSString stringWithFormat:@"\nROC:TrLink:TrCell = %d:%d:%d; ROC pin %d",(trgCells[ih]/100)%10,trgCells[ih]%10,(trgCells[ih]/10)%10,trgCells[ih]/10000];
    if(trgCells[ih]%10 == 9) text = [NSString stringWithFormat:@"\nROC = %d; ROC pin %d (Not part of a trigger sum)",(trgCells[ih]/100)%10,trgCells[ih]/10000];
    
    return text;
}
#pragma mark - test of my polygonContainment method
- (BOOL) testContainmentOf:(NSPoint) p inBez:(NSBezierPath *) polyPath {
   
    if(!theTerminal) {
        theTerminal = [HGCTerminalControl sharedTerminal];
        theTerminal.suggestedName = @"TestContainmentAlgorithm";
        [theTerminal makeWindowBig];
        [theTerminal setDarkBackground:YES];
    }
    
    [theTerminal displayString:[NSString stringWithFormat:@"Test point: (%.3f, %.3f)\n",p.x,p.y]];
    
    NSInteger count = polyPath.elementCount;
    if(count > 20) {
        NSLog(@"testContainment count = %ld - I quit",count);
        return YES;
    }
    NSPoint v[20];
    
    for (int i=0; i<count; i++) {
        NSInteger pe  = [polyPath elementAtIndex:i associatedPoints:&v[i]];
        [theTerminal displayString:[NSString stringWithFormat:@"%d (pe = %ld) vtx: (%.3f, %.3f)\n",i,pe,v[i].x,v[i].y]];
    }
    
    BOOL standard = [polyPath containsPoint:p];
    BOOL me = [self polygonWithVertices:v Count: (int) count containsPoint:p];
    
    [theTerminal displayString:[NSString stringWithFormat:@"testContainment standard = %d, me = %d\n\n",standard,me]];
    
    return (me ^= standard);
        
}

- (BOOL) polygonWithVertices:(NSPoint *) vtx Count: (int) n containsPoint:(NSPoint) pnt {

    /* -------------------------------------------------------------------
       Ray casting algorithm for convex polygon
       Point is inside if line from point in chosen direction (+x) crosses
       one side and one side only
       ------------------------------------------------------------------- */
    
    int nc = 0;
    for (int i=0; i<n; i++) {
        int j = (i+1)%n;
        if(vtx[i].x == vtx[j].x && vtx[i].y == vtx[j].y) continue; // Don't bother with duplicated vertex
        if((vtx[i].y > pnt.y && vtx[j].y < pnt.y) || (vtx[i].y < pnt.y && vtx[j].y > pnt.y)) {
            if(vtx[i].x > pnt.x && vtx[j].x > pnt.x) {
                nc++;
                [theTerminal displayString:[NSString stringWithFormat:@"Crossing a: i = %d, nc = %d\n",i,nc]];
            } else {
                double slope = (vtx[i].x - vtx[j].x)/(vtx[i].y - vtx[j].y);
                double xcross = vtx[i].x + (pnt.y - vtx[i].y)*slope;
                if(xcross > pnt.x) {
                    nc++;
                    [theTerminal displayString:[NSString stringWithFormat:@"Crossing b: i = %d, nc = %d\n",i,nc]];
                }
            }
        }
    }
    
    return (nc == 1);
}


#pragma mark - Drawing code

- (void) setNeighbourList: (NSArray *) narray {

    neighbourList = [NSArray arrayWithArray:narray];
    highlightNeighbours = YES;
        
}


//---------- The universal wafer draw (wholes and partials) ----------------------------
- (void) drawCellsForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored {
    
    BOOL HD = waf.thickflag < 2;
    int irot = waf.channelZero;
    if(isMirrored) irot += 6;
    NSPoint pnt = NSMakePoint(waf.xc,waf.yc);
    
    int ityp = waf.type;
    if(ityp == 0) [self drawCellsDense:HD Rotated:irot At:pnt];
    else [self drawPartialCellsDense:HD ForPartial: ityp Rotated:irot At:pnt];
    
    highlightNeighbours = NO;
    neighbourList = [NSArray array];

    
}

//---------- The set of whole wafer drawing methods  ----------------------------

- (void) drawCellsDense:(BOOL) HD {
    
    [self drawCellsDense:HD Rotated:-1 At:NSZeroPoint];
}

- (void) drawCellsDense:(BOOL) HD Rotated:(int) irot {

    [self drawCellsDense:HD Rotated:irot At:NSZeroPoint];
}

- (void) drawCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot {
    
    if(_trigger) {
        if(!theRawDataMap) theRawDataMap = [HXGrawDataMapControl sharedRawDataMap];
        int jpart = ipart;
        if(jpart < 0) jpart = 0;
        [theRawDataMap getTrgID:trgCells forHD:HD andPartial:jpart];
    }
    
    if(ipart < 0) [self drawCellsDense:HD Rotated:irot At:NSZeroPoint];
    else [self drawPartialCellsDense:HD ForPartial:ipart Rotated: irot At:NSZeroPoint];

}

- (void) drawCellsDense:(BOOL) HD Rotated:(int) irot At: (NSPoint) point {
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    NSAffineTransform * translate = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    [translate translateXBy:point.x yBy:point.y];
    [transform appendTransform:translate];
    
    NSArray * cellsArray = cellsArrayLD;
    if(HD) cellsArray = cellsArrayHD;
    
    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        NSPoint pnt = cs.centre;
        pnt = [transform transformPoint:pnt];
        NSBezierPath * cellBez = [NSBezierPath bezierPath];
        [cellBez appendBezierPath:cs.cellBezier];
        cellBez = [transform transformBezierPath:cellBez];
        if(_trigger) {
            int j = [cs trgCellColorIndex];
            [trgColor[j] set];
        } else {
            [cellColor[cs.type] set];
            if(i == 0) [[NSColor redColor] set];
            if(highlightNeighbours) {
                 for(int ingh=0; ingh<neighbourList.count; ingh++) {
                    HXGCellIndex * cx = neighbourList[ingh];
                     if(cs.uvId[0] == cx.iu && cs.uvId[1] == cx.iv) [[NSColor pastelBlue] set];
                }
            }
        }
        [cellBez fill];
        if(cs.calib) {
            NSBezierPath * calibBez = [NSBezierPath bezierPath];
            [calibBez appendBezierPath:cs.calibBezier];
            calibBez = [transform transformBezierPath:calibBez];
            [[NSColor fadedBlue] set];
            [calibBez fill];
            [[NSColor blackColor] set];
            [calibBez setLineWidth:0.1];
            [calibBez stroke];
        }
        [[NSColor blackColor] set];
        [cellBez setLineWidth:0.2];
        [cellBez stroke];
    }
    
}

//---------- The set of partial wafer drawing methods ----------------------------

- (void) drawPartialCellsDense:(BOOL) HD {
    
    [self drawPartialCellsDense:HD ForPartial:0 Rotated: -1 At:NSZeroPoint];
}

- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart {
    
    [self drawPartialCellsDense:HD ForPartial:ipart Rotated: -1 At:NSZeroPoint];
}

- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot {
    
    [self drawPartialCellsDense:HD ForPartial:ipart Rotated: irot At:NSZeroPoint];
}

- (void) drawPartialCellsDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt {

    NSArray * cellsArray;
    if(!HD && ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
    if( HD && ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
    if(!cellsArray) return;

    NSAffineTransform * transform = [NSAffineTransform transform];
    NSAffineTransform * translate = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    [translate translateXBy:pnt.x yBy:pnt.y];
    [transform appendTransform:translate];

    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        NSBezierPath * cellBez = [NSBezierPath bezierPath];
        [cellBez appendBezierPath:cs.cellBezier];
        cellBez = [transform transformBezierPath:cellBez];
        if(_trigger) {
            int j = [cs trgCellColorIndex];
            int k = [cs anomalousColorIndexForPartial:ipart];
            if(k > -1) j = k;
            [trgColor[j] set];
            int ih = cs.partialHard - 1;
            if(trgCells[ih]%10 == 9 && (!cs.siblingCell || ![cs.siblingCell isPresentInType:ipart])) [[NSColor whiteColor] set];
        } else {
            [cellColor[cs.type] set];
            if(cs.partialHard == 1) [[NSColor redColor] set];
            if(highlightNeighbours) {
                for(int ingh=0; ingh<neighbourList.count; ingh++) {
                    HXGCellIndex * cx = neighbourList[ingh];
                    if(cs.uvId[0] == cx.iu && cs.uvId[1] == cx.iv) [[NSColor pastelBlue] set];
                }
            }
        }
        [cellBez fill];
        if(cs.partialCalib) {
            NSBezierPath * calibBez = [NSBezierPath bezierPath];
            [calibBez appendBezierPath:cs.calibBezier];
            calibBez = [transform transformBezierPath:calibBez];
            [[NSColor fadedBlue] set];
            [calibBez fill];
            [calibBez setLineWidth:0.1];
            [[NSColor blackColor] set];
            [calibBez stroke];
        }
        [[NSColor blackColor] set];
        [cellBez setLineWidth:0.2];
        [cellBez stroke];
    }
    
}

//---------- The grid drawing method ----------------------------

- (void) drawGridDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot {
  
    /* ----------------------------------------------------------------------
     NB: Since grid for standard wholes is same for complete "whole" partial
     the partial cells array can be used
       ---------------------------------------------------------------------- */
    if(ipart < 0) ipart = 0;
    NSArray * cellsArray;
    if(!HD && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
    if( HD && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
    if(!cellsArray) return;

    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];

    [[NSColor blackColor] set];
    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        NSBezierPath * gridBez = [NSBezierPath bezierPath];
        gridBez = [transform transformBezierPath:cs.gridBezier];
        [gridBez stroke];
    }
    
}

- (void) drawWaferLayoutHexagon:(int) irot {

    NSBezierPath * bez = waferLayoutHexagon;
    if(irot > -1) bez = [hardToReference transformBezierPath:bez];
    [[NSColor whiteColor] set];
    [bez fill];
    [[NSColor blackColor] set];
    [bez stroke];

}

- (void) drawHardXyAxes:(int) irot {

    NSBezierPath * bez = hardXyAxes;
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    bez = [transform transformBezierPath:bez];
    
    [[NSColor blackColor] set];
    [bez stroke];

}

- (void) drawPhysicalWafer:(int) irot {

    NSBezierPath * bez = physicalWafer;
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    bez = [transform transformBezierPath:bez];
    
    [[NSColor siliconBrown] set];
    [bez fill];
    [[NSColor blackColor] set];
    [bez stroke];

}

- (void) highlightCell:(HXGStructuredCell *) cs Rotated:(int) irot isPartial:(BOOL) partial {
   
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    
    cellBez = [NSBezierPath bezierPath];
    [cellBez appendBezierPath:cs.cellBezier];
    cellBez = [transform transformBezierPath:cellBez];
    NSColor * col = [[NSColor wildViolet] blendedColorWithFraction:0.2 ofColor:[NSColor whiteColor]];
    [col set];
    [cellBez fill];
    if((partial && cs.partialCalib) || (!partial && cs.calib)) {
        calibHighlighted = YES;
        calibBez = [NSBezierPath bezierPath];
        [calibBez appendBezierPath:cs.calibBezier];
        calibBez = [transform transformBezierPath:calibBez];
        col = [NSColor peachOrange];
        [col set];
        [calibBez fill];
        [calibBez setLineWidth:0.1];
        [[NSColor blackColor] set];
        [calibBez stroke];
    } else calibHighlighted = NO;
    [[NSColor blackColor] set];
    [cellBez setLineWidth:0.8];
    [cellBez stroke];


}

- (void) outlineHighlightCell:(BOOL) thick {
  
    double wid = 0.8;
    if(thick) wid = 0.2;
    else {
        NSColor * col = [[NSColor wildViolet] blendedColorWithFraction:0.2 ofColor:[NSColor whiteColor]];
        [col set];
        [cellBez fill];
        if(calibHighlighted) {
            col = [NSColor peachOrange];
            [col set];
            [calibBez fill];
            [calibBez setLineWidth:0.1];
            [[NSColor blackColor] set];
            [calibBez stroke];
        }
    }
    [[NSColor blackColor] set];
    [cellBez setLineWidth:wid];
    [cellBez stroke];

}

#pragma mark - Text drawing
//---------- The universal label draw (wholes and partials) ----------------------------
- (void) drawLabelsForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored {
    
    BOOL HD = waf.thickflag < 2;
    int irot = waf.channelZero;
    if(isMirrored) irot += 6;
    NSPoint pnt = NSMakePoint(waf.xc,waf.yc);
    
    int ityp = waf.type;
    if(waf.whole) ityp = -1;
    [self drawLabelsUvDense:HD ForPartial: ityp Rotated: irot At: pnt];
    [self drawLabelsHardDense:HD ForPartial:ityp Rotated:irot At:pnt];
    
}

- (void) drawEdgeIndexForWafer:(HXGWafer *) waf Mirrored:(BOOL) isMirrored {
    
    BOOL HD = waf.thickflag < 2;
    int irot = waf.channelZero;
    if(isMirrored) irot += 6;
    NSPoint pnt = NSMakePoint(waf.xc,waf.yc);
    
    int ityp = waf.type;
    if(waf.whole) ityp = -1;
    [self drawEdgeIndexDense:HD ForPartial: ityp Rotated: irot At: pnt];
    
}

- (void) drawLabelsUvDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot {
    
    [self drawLabelsUvDense: HD ForPartial:ipart Rotated:irot At:NSZeroPoint];
}

- (void) drawLabelsUvDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt {
 
    NSArray * cellsArray;
    int n = NLD;

    if(HD) {
        if(ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
        if(ipart < 0) cellsArray = cellsArrayHD;
        if(ipart > -1) n = NHD + 2;
        else n = NHD;
    } else {
        if(ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
        if(ipart < 0) cellsArray = cellsArrayLD;
    }
    if(!cellsArray) return;
    
    double fs = cellSideLD*textScale;
    if(HD) fs = cellSideHD*textScale*1.2;


    NSAffineTransform * transform = [NSAffineTransform transform];
    NSAffineTransform * translate = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    [translate translateXBy:pnt.x yBy:pnt.y];
    [transform appendTransform:translate];

    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        
        NSString * str;
        if(_trigger) {
            int ih = cs.hard;
            if(ipart > -1) ih = cs.partialHard;
            ih -= 1;
            if(trgCells[ih]%10 == 9 || trgCells[ih]%10 == -1) continue;
            str = [NSString stringWithFormat:@"%d:%d:%d",(trgCells[ih]/100)%10,trgCells[ih]%10,(trgCells[ih]/10)%10];
        } else str = [NSString stringWithFormat:@"%02d:%02d",cs.uvId[0],cs.uvId[1]];
        NSPoint pnt = cs.centre;
        pnt = [transform transformPoint:pnt];
        int ihard = cs.hard;
        if(ipart > -1) ihard = cs.partialHard;
        if(_trigger)  pnt.y += 0.2*fs;
        else if(!HD && irot == -1 && ipart > -1 && cs.partialHard > 102 && cs.partialHard < 119) {
            pnt.y += 0.3*fs;
        } else if(irot > -1 || ihard > n) pnt.y += 0.6*fs;
        else if(HD) pnt.y -= 0.05 * fs;
        else pnt.y += 0.3 * fs;
        if(irot == -1 && _trigger && HD && ihard > 159 && ihard < 181) {
            pnt.y = cs.centre.y + 0.8 * fs;
        }
        [self drawString:str At:pnt Size:fs];
    }
    
}

- (void) drawEdgeIndexDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt {
 
    NSArray * cellsArray;
    int n = NLD;

    if(HD) {
        if(ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
        if(ipart < 0) cellsArray = cellsArrayHD;
        if(ipart > -1) n = NHD + 2;
        else n = NHD;
    } else {
        if(ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
        if(ipart < 0) cellsArray = cellsArrayLD;
    }
    if(!cellsArray) return;
    
    double fs = cellSideLD*textScale*1.8;
    if(HD) fs = cellSideLD*textScale*1.6;


    NSAffineTransform * transform = [NSAffineTransform transform];
    NSAffineTransform * translate = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    [translate translateXBy:pnt.x yBy:pnt.y];
    [transform appendTransform:translate];

    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        
        NSString * str = @" ";
        if(cs.edgeIndex > -1) str = [NSString stringWithFormat:@"%d",cs.edgeIndex];
        NSPoint pnt = cs.centre;
        pnt = [transform transformPoint:pnt];
        [self drawString:str At:pnt Size:fs];
    }
    
}

- (void) drawLabelsHardDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot {
    
    [self drawLabelsHardDense: HD ForPartial: ipart Rotated: irot At: NSZeroPoint];
}

- (void) drawLabelsHardDense:(BOOL) HD ForPartial:(int) ipart Rotated:(int) irot At:(NSPoint) pnt {
 
    NSArray * cellsArray;
    if(HD) {
        if(ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
        if(ipart == -1) cellsArray = cellsArrayHD;
    } else {
        if(ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
        if(ipart == -1) cellsArray = cellsArrayLD;
    }
    if(!cellsArray) return;
    
    double fs = cellSideLD*textScale;
    if(HD) fs = cellSideHD*textScale*1.2;


    NSAffineTransform * transform = [NSAffineTransform transform];
    NSAffineTransform * translate = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    [translate translateXBy:pnt.x yBy:pnt.y];
    [transform appendTransform:translate];

    BOOL lastSplit = NO;
    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        NSPoint pnt = cs.centre;
        pnt = [transform transformPoint:pnt];
        NSString * str;
        int ihard = cs.partialHard;
        BOOL calib = cs.partialCalib;
        if(ipart == -1) {
            ihard = cs.hard;
            calib = cs.calib;
        }
        if(HD && irot < 0 && ipart > -1 && ihard > 159 && ihard < 181) pnt.y += 0.6*fs;
        if(cs.split) {
            if((irot == 2 && !lastSplit) || (irot == 5 && lastSplit) || (irot == 8 && !lastSplit) || (irot == 11 && lastSplit)) {
            } else {
                double y = pnt.y;
                if(irot == 2 || irot == 5) y -= 0.3*fs;
                pnt.x = 0.5*([cs getCellCorner:2].x + [cs getCellCorner:4].x);
                pnt.y = cs.centre.y;
                pnt = [transform transformPoint:pnt];
                pnt.y = y;
                str = [NSString stringWithFormat:@"\n%d",ihard];
                [self drawString:str At:pnt Size:fs];
            }
            lastSplit = YES;
        } else {
            lastSplit = NO;
            if(calib) str = [NSString stringWithFormat:@"\n%d %d",ihard,ihard+1];
            else str = [NSString stringWithFormat:@"\n%d",ihard];
            [self drawString:str At:pnt Size:fs];
        }
    }
    
}

- (void) drawLabelsGridCountDense:(BOOL) HD Rotation:(int) irot {
 
    /*
     The GridCounts counts cells, but NOT the calib cells
    */
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    
    
    NSArray * cellsArray = cellsArrayLD;
    double fs = cellSideLD*textScale*1.5;
    if(HD) {
        cellsArray = cellsArrayHD;
        fs = cellSideHD*textScale*1.5;
    }
    
    for (int i=0; i<cellsArray.count; i++) {
        NSString * str = [NSString stringWithFormat:@"%d",i];
        HXGStructuredCell * cs = cellsArray[i];
        NSPoint pnt = [transform transformPoint:cs.centre];
        [self drawString:str At:pnt Size:fs];
    }
    
}
- (void) drawLabelsEdgeIndexDense:(BOOL) HD ForPartial:(int) ipart Rotation:(int) irot {
    
    
    NSAffineTransform * transform = [NSAffineTransform transform];
    if(irot > -1) {
        [transform appendTransform:hardToReference];
        [transform appendTransform:rot60[irot%6]];
    }
    if(irot < -1 || irot > 5) [transform appendTransform:flipX];
    
    double fs = cellSideLD*textScale*1.5;
    NSArray * cellsArray;
    if(HD) {
        fs = cellSideHD*textScale*1.5;
        if(ipart > -1 && ipart < 5) cellsArray = partialCellsArrayHD[ipart];
        if(ipart == -1) cellsArray = cellsArrayHD;
    } else {
        if(ipart > -1 && ipart < 6) cellsArray = partialCellsArrayLD[ipart];
        if(ipart == -1) cellsArray = cellsArrayLD;
    }
    if(!cellsArray) return;
    
    for (int i=0; i<cellsArray.count; i++) {
        HXGStructuredCell * cs = cellsArray[i];
        if(cs.edgeIndex > -1) {
            NSString * str = [NSString stringWithFormat:@"%d",cs.edgeIndex];
            NSPoint pnt = [transform transformPoint:cs.centre];
            [self drawString:str At:pnt Size:fs];
        }
    }
    
}

- (void) drawString:(NSString *) str At: (NSPoint) pnt Size:(double) fs {
  
    NSMutableAttributedString * astr = [[NSMutableAttributedString alloc] initWithString:str];
    [astr addAttribute:NSFontAttributeName
                value:[NSFont systemFontOfSize:fs]
                range:NSMakeRange(0,astr.length)];
    double h = astr.size.height;
    double w = astr.size.width;
    [astr drawAtPoint:NSMakePoint(pnt.x-w*0.5,pnt.y-h*0.5)];

}


@end
