//
//  HXGHardwareConstants.m
//  Hex
//
//  Created by Chris Seez on 02/06/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGHardwareConstants.h"

const int NLHGCAL = 47;

const double layoutHexagonWidth = 167.4408;

const double moduleSpacing = 0.2; // 200μm wafer spacing

const double radiusCalibLD = 3.05;
const double radiusCalibHD = 2.04;

const int NLD = 8;
const int NHD = 12;

@implementation HXGHardwareConstants

+ (id) sharedHardwareConstants {
    
    static dispatch_once_t pred;
    static HXGHardwareConstants * theHardwareConstants = nil;
    
    dispatch_once(&pred, ^{theHardwareConstants = [[self alloc] init]; });
    return theHardwareConstants;
    
}

- (id)init {
    
    self = [super init];

    _LDzoltanA = NSMakePoint(-0.8985,82.3869);
    _LDzoltanB = NSMakePoint( 0.8985,82.3869);
    _LDzoltanC = NSMakePoint(38.9787,82.3869);
    _LDzoltanD = NSMakePoint(47.4375,77.5032);
    _LDzoltanE = NSMakePoint(49.2345,76.4657);
    _LDzoltanF = NSMakePoint(51.8598,74.9500);
    _LDzoltanG = NSMakePoint(90.8385, 7.4369);
    _LDzoltanH = NSMakePoint(90.8385, 0.8985);
    
    _HDzoltanA = NSMakePoint(27.2975,82.3869);
    _HDzoltanB = NSMakePoint(29.0945,82.3869);
    _HDzoltanC = NSMakePoint(38.9787,82.3869);
    _HDzoltanD = NSMakePoint(51.8598,74.9500);
    _HDzoltanE = NSMakePoint(85.2148,17.1775);
    _HDzoltanF = NSMakePoint(86.2523,15.3805);
    _HDzoltanG = NSMakePoint(90.8385, 7.4369);
    
    _halfDiceWidth = _LDzoltanB.x;
    _activeWidth = _LDzoltanA.y * 2.;
    
    NSPoint pnt = _LDzoltanC;
    NSAffineTransform * transform = [NSAffineTransform transform];
    [transform rotateByDegrees:30.];
    pnt = [transform transformPoint:pnt];
    _mouseBitePerp = layoutHexagonWidth/sqrt(3.) - pnt.y;
    
    physicalWaferWidth = 2.*(_LDzoltanC.y+_halfDiceWidth);
    
    [self makeActiveWaferPoints];
    
    return self;
}

- (void) makeActiveWaferPoints {
      
    for (int i=0; i<6; i++) {
        rot60[i] = [NSAffineTransform transform];
        [rot60[i] rotateByDegrees:(double)(i*60)];
    }
    
    flipX = [NSAffineTransform transform];
    [flipX scaleXBy: -1. yBy: 1.];
    
    hardToReference = [NSAffineTransform transform];
    [hardToReference rotateByDegrees:150.];

    // ---- Whole wafer (both LD and HD)
    nAWpnts[0] = 12;
    NSPoint pnt1 = _LDzoltanF;
    NSPoint pnt2 = _LDzoltanC;
    for (int i=0; i<12; i+=2) {
        pnt1 = [rot60[1] transformPoint:pnt1];
        pnt2 = [rot60[1] transformPoint:pnt2];
        activeWaferPoint[0][i] = pnt1;
        activeWaferPoint[0][i+1] = pnt2;
    }
    
    // ---- LD 1 (Top half)
    nAWpnts[1] = 8;
    activeWaferPoint[1][0] = _LDzoltanH;
    activeWaferPoint[1][1] = _LDzoltanG;
    activeWaferPoint[1][2] = _LDzoltanF;
    activeWaferPoint[1][3] = _LDzoltanC;
    activeWaferPoint[1][4] = activeWaferPoint[0][0];
    activeWaferPoint[1][5] = activeWaferPoint[0][1];
    activeWaferPoint[1][6] = NSMakePoint(-_LDzoltanG.x,_LDzoltanG.y);
    activeWaferPoint[1][7] = NSMakePoint(-_LDzoltanH.x,_LDzoltanH.y);

    // ---- LD 2 (Bottom half)
    nAWpnts[2] = 8;
    for (int i=7; i>-1; i--) {
        activeWaferPoint[2][i] = NSMakePoint(activeWaferPoint[1][i].x,-activeWaferPoint[1][i].y);
    }
    
    // ---- LD 3 (Left semi)
    nAWpnts[3] = 8;
    activeWaferPoint[3][0] = _LDzoltanA;
    activeWaferPoint[3][1] = activeWaferPoint[0][0];
    activeWaferPoint[3][2] = activeWaferPoint[0][1];
    activeWaferPoint[3][3] = activeWaferPoint[0][2];
    activeWaferPoint[3][4] = activeWaferPoint[0][3];
    activeWaferPoint[3][5] = activeWaferPoint[0][4];
    activeWaferPoint[3][6] = activeWaferPoint[0][5];
    activeWaferPoint[3][7] = NSMakePoint(_LDzoltanA.x,-_LDzoltanA.y);
    
    // ---- LD 4 (Right semi)
    nAWpnts[4] = 8;
    for (int i=7; i>-1; i--) {
        activeWaferPoint[4][i] = NSMakePoint(-activeWaferPoint[3][i].x,activeWaferPoint[3][i].y);
    }

    // ---- LD 5 (Five)
    nAWpnts[5] = 10;
    activeWaferPoint[5][0] = _LDzoltanD;
    activeWaferPoint[5][1] = _LDzoltanC;
    activeWaferPoint[5][2] = activeWaferPoint[0][0];
    activeWaferPoint[5][3] = activeWaferPoint[0][1];
    activeWaferPoint[5][4] = activeWaferPoint[0][2];
    activeWaferPoint[5][5] = activeWaferPoint[0][3];
    activeWaferPoint[5][6] = activeWaferPoint[0][4];
    activeWaferPoint[5][7] = activeWaferPoint[0][5];
    activeWaferPoint[5][8] = activeWaferPoint[0][6];
    activeWaferPoint[5][9] = NSMakePoint(_LDzoltanD.x,-_LDzoltanD.y);
    
    // ---- LD 6 (Three)
    nAWpnts[6] = 6;
    activeWaferPoint[6][0] = _LDzoltanF;
    activeWaferPoint[6][1] = _LDzoltanE;
    activeWaferPoint[6][2] = NSMakePoint(_LDzoltanE.x,-_LDzoltanE.y);
    activeWaferPoint[6][3] = NSMakePoint(_LDzoltanF.x,-_LDzoltanF.y);
    activeWaferPoint[6][4] = NSMakePoint(_LDzoltanG.x,-_LDzoltanG.y);
    activeWaferPoint[6][5] = _LDzoltanG;

    // ---- HD 1 (Top)
    nAWpnts[7] = 6;
    activeWaferPoint[7][0] = _HDzoltanE;
    activeWaferPoint[7][1] = _HDzoltanD;
    activeWaferPoint[7][2] = _HDzoltanC;
    activeWaferPoint[7][3] = activeWaferPoint[0][0];
    activeWaferPoint[7][4] = activeWaferPoint[0][1];
    activeWaferPoint[7][5] = NSMakePoint(-_HDzoltanE.x,_HDzoltanE.y);

    // ---- HD 2 (Bottom)
    nAWpnts[8] = 10;
    activeWaferPoint[8][0] = _HDzoltanG;
    activeWaferPoint[8][1] = _HDzoltanF;
    activeWaferPoint[8][2] = NSMakePoint(-_HDzoltanF.x,_HDzoltanF.y);
    activeWaferPoint[8][3] = activeWaferPoint[0][2];
    activeWaferPoint[8][4] = activeWaferPoint[0][3];
    activeWaferPoint[8][5] = activeWaferPoint[0][4];
    activeWaferPoint[8][6] = activeWaferPoint[0][5];
    activeWaferPoint[8][7] = activeWaferPoint[0][6];
    activeWaferPoint[8][8] = activeWaferPoint[0][7];
    activeWaferPoint[8][9] = activeWaferPoint[0][8];

    // ---- HD 3 (Left)
    nAWpnts[9] = 8;
    activeWaferPoint[9][0] = NSMakePoint(-_HDzoltanB.x,_HDzoltanB.y);
    activeWaferPoint[9][1] = activeWaferPoint[0][0];
    activeWaferPoint[9][2] = activeWaferPoint[0][1];
    activeWaferPoint[9][3] = activeWaferPoint[0][2];
    activeWaferPoint[9][4] = activeWaferPoint[0][3];
    activeWaferPoint[9][5] = activeWaferPoint[0][4];
    activeWaferPoint[9][6] = activeWaferPoint[0][5];
    activeWaferPoint[9][7] = NSMakePoint(-_HDzoltanB.x,-_HDzoltanB.y);
    
    // ---- HD 4 (Right)
    nAWpnts[10] = 8;
    for (int i=7; i>-1; i--) {
        activeWaferPoint[10][i] = NSMakePoint(-activeWaferPoint[9][i].x,activeWaferPoint[9][i].y);
    }
    
    // ---- Now reorient all to Reference
    
    for (int itype=0; itype<11; itype++) {
        for (int i=0; i<nAWpnts[itype]; i++) {
            activeWaferPoint[itype][i] = [hardToReference transformPoint:activeWaferPoint[itype][i]];
        }
    }


}

- (NSBezierPath *) bezierForActiveAt:(NSPoint) pnt forType:(int) ityp andRotation:(int)jrot {
    
    NSBezierPath * bez = [NSBezierPath bezierPath];

    NSPoint wpnt = [rot60[jrot%6] transformPoint:activeWaferPoint[ityp][0]];
    if(jrot > 5) wpnt = [flipX transformPoint:wpnt];
    wpnt.x += pnt.x;
    wpnt.y += pnt.y;
    [bez moveToPoint:wpnt];

    for (int i=1; i<nAWpnts[ityp]; i++) {
        wpnt = [rot60[jrot%6] transformPoint:activeWaferPoint[ityp][i]];
        if(jrot > 5) wpnt = [flipX transformPoint:wpnt];
        wpnt.x += pnt.x;
        wpnt.y += pnt.y;
        [bez lineToPoint:wpnt];
    }
    [bez closePath];

    
    return bez;
}


- (void) writeConstantsToTerminal {
    
    NSString * text = @"Hardware constants (mm):\n";
    
    text = [text stringByAppendingFormat:@"\nlayoutHexagonWidth = %.4f",layoutHexagonWidth];
    text = [text stringByAppendingFormat:@"\nmoduleSpacing = %.4f\n",moduleSpacing];
    
    text = [text stringByAppendingFormat:@"\nradiusCalibLD = %.3f",radiusCalibLD];
    text = [text stringByAppendingFormat:@"\nradiusCalibHD = %.3f\n",radiusCalibHD];

    text = [text stringByAppendingFormat:@"\nLDzoltanA = (%.3f, %.3f)",_LDzoltanA.x,_LDzoltanA.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanB = (%.3f, %.3f)",_LDzoltanB.x,_LDzoltanB.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanC = (%.3f, %.3f)",_LDzoltanC.x,_LDzoltanC.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanD = (%.3f, %.3f)",_LDzoltanD.x,_LDzoltanD.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanE = (%.3f, %.3f)",_LDzoltanE.x,_LDzoltanE.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanF = (%.3f, %.3f)",_LDzoltanF.x,_LDzoltanF.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanG = (%.3f, %.3f)",_LDzoltanG.x,_LDzoltanG.y];
    text = [text stringByAppendingFormat:@"\nLDzoltanH = (%.3f, %.3f)\n",_LDzoltanH.x,_LDzoltanH.y];

    text = [text stringByAppendingFormat:@"\nHDzoltanA = (%.3f, %.3f)",_HDzoltanA.x,_HDzoltanA.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanB = (%.3f, %.3f)",_HDzoltanB.x,_HDzoltanB.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanC = (%.3f, %.3f)",_HDzoltanC.x,_HDzoltanC.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanD = (%.3f, %.3f)",_HDzoltanD.x,_HDzoltanD.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanE = (%.3f, %.3f)",_HDzoltanE.x,_HDzoltanE.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanF = (%.3f, %.3f)",_HDzoltanF.x,_HDzoltanF.y];
    text = [text stringByAppendingFormat:@"\nHDzoltanG = (%.3f, %.3f)\n",_HDzoltanG.x,_HDzoltanG.y];
    
    text = [text stringByAppendingFormat:@"\nhalfDiceWidth = %.4f",_halfDiceWidth];
    text = [text stringByAppendingFormat:@"\nactiveWidth = %.4f",_activeWidth];
    text = [text stringByAppendingFormat:@"\nmouseBitePerp = %.4f",_mouseBitePerp];
    text = [text stringByAppendingFormat:@"\nphysicalWaferWidth = %.4f",physicalWaferWidth];

    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"HardwareConstants";
    [theTerminal showWindow:self];
    [theTerminal makeWindowNarrow];
    [theTerminal setDarkBackground:YES];
    [theTerminal clearString];
    [theTerminal displayString:text];
    
    NSPoint pnt1 = _LDzoltanC;
    NSPoint pnt2 = _LDzoltanF;
    double alen = sqrt((pnt1.x-pnt2.x)*(pnt1.x-pnt2.x) + (pnt1.y-pnt2.y)*(pnt1.y-pnt2.y));

    double gulf = layoutHexagonWidth + moduleSpacing - _activeWidth;
    
    [theTerminal displayString:@"\n\nDerived quantities:"];

    text = [NSString stringWithFormat:@"\n\nMousebite flat = %.2f\nGulf between active wafers = %.2f\nSide of equilateral void = %.2f",alen,gulf,alen+2.*gulf];
    /*
     mbarea is equilateral triangle where three wafers of pure active area come together
     From the active area of a wafer computed as a hexagon, two such areas need removal
     */
    double mbarea = 0.25 * alen * alen * sqrt(3.);
    double activeArea = 0.5*sqrt(3.)*_activeWidth*_activeWidth - 2.*mbarea;
    double moduleArea = 0.5*sqrt(3.)*(layoutHexagonWidth + moduleSpacing)*(layoutHexagonWidth + moduleSpacing);
    text = [text stringByAppendingFormat:@"\nMouse bite equilateral = %.1f\nactiveArea = %.1f\nModule area = %.1f\nFraction active = %.5f",mbarea,activeArea,moduleArea,activeArea/moduleArea];
    
    NSPoint pntF = _LDzoltanF;
    NSPoint pntG = _LDzoltanG;
    double tside = sqrt((pntF.x-pntG.x)*(pntF.x-pntG.x) + (pntF.y-pntG.y)*(pntF.y-pntG.y));
    double lossWid = gulf*0.5;
    double sidearea = lossWid * tside * 6.;
    double sideFrac = sidearea/moduleArea;
    /*
     mbsuperarea is mbarea plus the losswid bits including 3 tiny triangles
     */
    double tinytriangles = sqrt(3.)*0.25*lossWid;
    double mbsuperarea = mbarea + 3.*lossWid*alen + tinytriangles;
    double mbFrac = 2.*mbsuperarea/moduleArea;
    
    text = [text stringByAppendingFormat:@"\n\ntside = %.1f\nlossWid = %.2f\nsidearea = %.1f\nsideFrac = %.5f\nmbFrac = %.5f",tside,lossWid,sidearea,sideFrac,mbFrac];
    
    [theTerminal displayString:text];

}


@end
