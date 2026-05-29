//
//  HXGStructuredCell.m
//  Hex
//
//  Created by Chris Seez on 15/05/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGStructuredCell.h"


@implementation HXGStructuredCell

+ (id) cellDense:(BOOL) HD withCentre:(NSPoint) cntr {
    
    HXGStructuredCell * cell = [[self alloc] initDense:(BOOL) HD withCentre:(NSPoint) cntr];
    
    return cell;
}

+ (id) cellWithCell:(HXGStructuredCell *) cx {
    
    HXGStructuredCell * cell = [[self alloc] initWithCentre:cx.centre];
    
    [cell copyCell:(HXGStructuredCell *) cx];
    
    return cell;
}

+ (id) nullCell {
    
    HXGStructuredCell * cell = [[self alloc] initWithCentre:(NSPoint) NSZeroPoint];
    
    [cell setType:-1];
    
    return cell;
}


- (id) initWithCentre:(NSPoint) cntr {
    
    self = [super init];
    _centre = cntr;
    _uvId = uvIdRef;
    presenceFlags = 0;

    return self;
}

- (id) initDense:(BOOL) HD withCentre:(NSPoint) cntr {
    
    self = [super init];
    _centre = cntr;
    _uvId = uvIdRef;
    _HD = HD;
    presenceFlags = 0;

    return self;
}


- (void) copyCell:(HXGStructuredCell *) cx {
    
    for (int i=0; i<6; i++) {
        gridCorner[i] = [cx getGridCorner:i];
        cellCorner[i] = [cx getCellCorner:i];
    }
    uvIdRef[0] = cx.uvId[0];
    uvIdRef[1] = cx.uvId[1];
    _gridBezier = cx.gridBezier;
    _cellBezier = cx.cellBezier;
    _type = cx.type;
    _whole = cx.whole;
    _edge = cx.edge;
    _corner = cx.corner;
    _gridCount = cx.gridCount;
    _HD = cx.HD;
    _edgeIndex = cx.edgeIndex;
    
}

#pragma mark - Setters and getters
- (void) setType:(int) ityp {
    
    /* ----------------------
      -1: null cell
       0: whole
       1: extended edge
       2: truncated edge
       3: corner
       ---------------------- */
    
    _type = ityp;

    _whole  = _type == 0;
    _edge   = _type == 1 || _type == 2;
    _corner = _type == 3;
}

- (void) setPresentInType:(int) pType {
    
    int ishift = pType;
    if(_HD) ishift += 5;
    presenceFlags = presenceFlags | 1<<ishift;
}

- (BOOL) isPresentInType:(int) pType {
    
    int ishift = pType;
    if(_HD) ishift += 5;
    int mask = 1<<ishift;
    int and = presenceFlags & mask;
    
    return (and > 0);
}

- (void) setSiblingCell:(HXGStructuredCell *) cs {
    
    _siblingCell = cs;
}

- (void) setGridCount:(int) ig {
    
    _gridCount = ig;
}

- (void) setEdgeIndex:(int) ei {
    
    _edgeIndex = ei;
}

- (void) setGridCorner:(int) i To: (NSPoint) pnt {
    
    i += 6;
    gridCorner[i%6] = pnt;
    
}

- (NSPoint) getGridCorner: (int) i {
    
    i += 6;
    return gridCorner[i%6];
}

- (void) setCellCorner:(int) i To: (NSPoint) pnt {
    
    i += 6;
    cellCorner[i%6] = pnt;
    
}

- (NSPoint) getCellCorner: (int) i {
    
    i += 6;
    return cellCorner[i%6];
}

- (void) setIdU:(int) iu andV:(int) iv {
    
    uvIdRef[0] = iu;
    uvIdRef[1] = iv;
}

- (void) setCalibWithRadius:(double) r {
    
    _calib = YES;
    [self makeCalibBezier:r];
    
}

- (void) setPartialCalibWithRadius:(double) r {
    
    _partialCalib = YES;
    [self makeCalibBezier:r];
    
}

- (void) setHardwareChan:(int) ihard {
    _hard = ihard;
}

- (void) setPartialHardwareChan:(int) ihard {
    _partialHard = ihard;
}

- (void) setSplit:(BOOL) isSplit {
    
    _split = isSplit;
}

- (void) setSpecial:(BOOL) isSpecial {
    
    _special = isSpecial;
}
#pragma mark - Trigger stuff

- (int) trgRegion {
    
    int region = 1;
    int boundary;
    if(_HD) boundary = 12;
    else boundary = 8;
    
    region = 1;
    if(_uvId[0] < boundary) {
        if (_uvId[1] < boundary) region = 0;
    } else if(_uvId[1] < _uvId[0]) region = 2;
    
    return region;
}

- (int) trgCellColorIndex {

    int region = 1;
    int boundary,ncell;
    if(_HD) {
        boundary = 12;
        ncell = 3;
    } else {
        boundary = 8;
        ncell = 2;
    }
    
    region = 1;
    if(_uvId[0] < boundary) {
        if (_uvId[1] < boundary) region = 0;
    } else if(_uvId[1] < _uvId[0]) region = 2;
 
    int jv = _uvId[1]/ncell;
    int ju = _uvId[0]/ncell;
    if(region == 1) {
        ju = (_uvId[1]-_uvId[0]+boundary)/ncell;
    } else if(region == 2) {
        jv = (_uvId[1]-_uvId[0]+boundary)/ncell;
    }

    int index = jv%2 + 2*(ju%2);
    if(region == 1 && _uvId[0] >= boundary) {
        if(index == 1) index = 2;
        else if(index == 2) index = 1;
    }
    
    return index;
}

- (int) anomalousColorIndexForPartial:(int) ipart {

    /*
     Colours defined in HXGStructuredWafer init:
     trgColor[0] = [NSColor sageGreen];
     trgColor[1] = [NSColor peachOrange];
     trgColor[2] = [NSColor orchidPink];
     trgColor[3] = [NSColor paleBlue];
     trgColor[4] = [NSColor greyGreen]; // for weird configurations
     */
    int ldn[5] = {4,5,4,29,9};
    int ld1HardList[4] = { 95, 97,100,102};
    int ld1ColIndex[4] = {  5,  5,  5,  5};
    int ld2HardList[5] = {115,117,133,134,135};
    int ld2ColIndex[5] = {  3,  0,  2,  0,  0};
    int ld3HardList[4] = { 14, 61,142,197};
    int ld3ColIndex[4] = {  2,  3,  1,  0};
    int ld4HardList[29] = { 15, 17, 19, 37, 39, 42, 62, 64, 67, 68, 70, 95, 97,100,102,
                           129,131,132,134,143,159,162,165,188,190,191,198,209,211};
    int ld4ColIndex[29] = {  2,  0,  1,  2,  3,  2,  3,  1,  0,  0,  3,  3,  2,  1,  2,
                             3,  0,  0,  3,  0,  2,  1,  2,  0,  3,  3,  1,  3,  2};
    int ld5HardList[9] = { 39, 67, 80, 95, 97,129,146,162,201};
    int ld5ColIndex[9] = {  2,  0,  1,  2,  1,  0,  3,  2,  0};

    int hdn[4] = {17,42,22,70};
    int hd1HardList[17] = { 75, 93,129,132,151,152,153,154,156,157,163,164,165,172,173,174,177};
    int hd1ColIndex[17] = {  2,  0,  0,  3,  3,  3,  3,  3,  2,  2,  2,  2,  2,  3,  3,  3,  2};
    int hd2HardList[42] = {184,187,188,189,190,191,192,193,195,196,197,199,200,201,202,
                           203,208,209,211,212,213,214,215,216,219,220,222,223,224,225,
                           226,245,246,247,249,250,251,271,272,274,275,296};
    int hd2ColIndex[42] = {  2,  3,  3,  3,  3,  2,  2,  2,  4,  4,  4,  3,  3,  3,  0,
                             0,  2,  2,  3,  3,  3,  2,  2,  2,  4,  4,  3,  3,  3,  0,
                             0,  4,  4,  4,  3,  0,  0,  4,  4,  0,  0,  4};
    int hd3HardList[22] = { 32, 99,100,101,163,164,165,166,187,188,211,212,232,233,234,
                           262,263,285,310,331,427,443};
    int hd3ColIndex[22] = {  3,  3,  3,  3,  1,  1,  1,  0,  0,  0,  0,  0,  3,  3,  3,
                             1,  1,  1,  0,  0,  1,  1};
    int hd4HardList[70] = { 27, 42, 44, 45, 75, 78, 91, 92, 94, 95,110,111,112,113,115,
                           116,130,131,133,134,135,153,154,157,158,159,198,199,200,204,
                           220,222,223,227,228,246,247,248,271,272,274,275,276,296,299,
                           300,301,319,320,321,343,344,345,363,364,365,381,382,383,400,
                           401,402,419,420,421,436,452,453,466,467};
    int hd4ColIndex[70] = {  1,  3,  1,  1,  3,  2,  3,  3,  2,  2,  3,  3,  3,  0,  0,
                             0,  1,  1,  0,  0,  0,  2,  1,  0,  0,  0,  2,  0,  0,  2,
                             2,  2,  0,  2,  2,  2,  2,  2,  1,  1,  1,  1,  3,  1,  1,
                             3,  3,  0,  0,  0,  0,  0,  2,  0,  2,  2,  1,  1,  1,  1,
                             1,  3,  1,  3,  3,  1,  1,  2,  2,  2};



    int * ldHardList[5] = {ld1HardList,ld2HardList,ld3HardList,ld4HardList,ld5HardList};
    int * ldColIndex[5] = {ld1ColIndex,ld2ColIndex,ld3ColIndex,ld4ColIndex,ld5ColIndex};
    
    int * hdHardList[4] = {hd1HardList,hd2HardList,hd3HardList,hd4HardList};
    int * hdColIndex[4] = {hd1ColIndex,hd2ColIndex,hd3ColIndex,hd4ColIndex};

    
    int * hardList; // method needs input partial type
    int * colIndex;
    int n;
    
    if(_HD) {
        n = hdn[ipart-1];
        hardList = hdHardList[ipart-1];
        colIndex = hdColIndex[ipart-1];
    } else {
        hardList = ldHardList[ipart-1];
        colIndex = ldColIndex[ipart-1];
        n = ldn[ipart-1];
    }
    
    for (int i=0; i<n; i++) {
        if(_partialHard == hardList[i]) return colIndex[i];
    }
        
    return -1;
}

#pragma mark - Computations

- (double) getCellArea {
    
    double A = 0.;
    for(int i=0; i<6; i++) {
        A += cellCorner[i].x * cellCorner[(i+1)%6].y - cellCorner[(i+1)%6].x * cellCorner[i].y;
    }
    
    return 0.5*A;
}

- (NSPoint) getCellCentroid {
    
    double A = [self getCellArea];
    double cx = 0.;
    double cy = 0.;
    for (int i=0; i<6; i++) {
        cx += (cellCorner[i].x + cellCorner[(i+1)%6].x) * (cellCorner[i].x*cellCorner[(i+1)%6].y - cellCorner[(i+1)%6].x*cellCorner[i].y);
        cy += (cellCorner[i].y + cellCorner[(i+1)%6].y) * (cellCorner[i].x*cellCorner[(i+1)%6].y - cellCorner[(i+1)%6].x*cellCorner[i].y);
    }
    cx /= 6.*A;
    cy /= 6.*A;
    
    return NSMakePoint(cx,cy);
}

#pragma mark - Bezier path construction

- (void) makeCalibBezier:(double) r {
    
    _calibBezier = [NSBezierPath bezierPath];
    [_calibBezier appendBezierPathWithArcWithCenter:_centre radius:r startAngle:0.0 endAngle:360.0];
    
    [_calibBezier setLineWidth:0.1];

}

- (void) makeGridBezier {
    
    _gridBezier = [NSBezierPath bezierPath];
    [_gridBezier moveToPoint:gridCorner[0]];
    for (int i=1; i<6; i++) {
        [_gridBezier lineToPoint:gridCorner[i]];
    }
    [_gridBezier closePath];
    [_gridBezier setLineWidth:0.1];

}

- (void) makeCellBezier {
    
    _cellBezier = [NSBezierPath bezierPath];
    [_cellBezier moveToPoint:cellCorner[0]];
    for (int i=1; i<6; i++) {
        [_cellBezier lineToPoint:cellCorner[i]];
    }
    [_cellBezier closePath];
    [_cellBezier setLineWidth:0.2];
}
@end
