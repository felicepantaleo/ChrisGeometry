//
//  HXGCellAreas.m
//  Hex
//
//  Created by Chris Seez on 10/05/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGCellAreas.h"

//const double guardWidth = 0.8985;

@implementation HXGCellAreas

+ (id) sharedCellAreas {
    
    static dispatch_once_t pred;
    static HXGCellAreas * theCellAreas = nil;
    
    dispatch_once(&pred, ^{ theCellAreas = [[self alloc] init]; });
    return theCellAreas;
    
}

- (id)init {
    
    //thePreferences = [HXGPreferenceControl sharedPreferences];
    waferSize = 167.44;         // 08; July 2025 - New convention
    theTerminal = [HGCTerminalControl sharedTerminal];
    
    return self;
}

- (void) calculateCellAreas {
    
    [theTerminal clearString];
    theTerminal.suggestedName = @"CellAreas";

    [theTerminal makeWindowNarrow];
    [theTerminal setDarkBackground:YES];
    
    theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];
    guardWidth = theHardwareConstants.halfDiceWidth;

   
    NSPoint voff[6],vpnt[6];
    NSString * typeStr[2] = {@"LD",@"HD"};
    
    sqrt3 = sqrt(3.);
    zoltanDistanceC = 38.9787;
    //double oldInset = 1.3335;
    activeWafer = theHardwareConstants.activeWidth;
    edgeInset = 0.5*(waferSize - activeWafer);
    //NSLog(@"edgeInset = %.5f (old = %.5f)",edgeInset,oldInset);
    
    BOOL verbose = NO;
    BOOL oldCrap = NO;
    
    NSString * textout = [NSString stringWithFormat:@"Layout wafer %.4f\nActive wafer %.4f\n",waferSize,activeWafer];
    if(oldCrap) textout = [textout stringByAppendingFormat:@"half active = %.4f\n",0.5*activeWafer];
    
    waferSide = waferSize/sqrt3;
    delta = 0.5 * waferSide - zoltanDistanceC;
    epsilon = edgeInset*sqrt3;
    //mouseBitePerp = (delta+epsilon)*0.5;
    mouseBitePerp = theHardwareConstants.mouseBitePerp;
    textout = [textout stringByAppendingFormat:@"Hardware consts mouseBitePerp %.4f\n",theHardwareConstants.mouseBitePerp];
    textout = [textout stringByAppendingFormat:@"mouseBitePerp %.4f\n\n",mouseBitePerp];
    // --------------- CHECK m1 calculation ------------
    double m1 = mouseBitePerp - 2.*0.435/sqrt3;
    if(oldCrap) textout = [textout stringByAppendingFormat:@"m1 %.4f\n",m1];
    
    double mu = 0.435/sqrt3;
    if(oldCrap) textout = [textout stringByAppendingFormat:@"mu %.4f\n",mu];
    double newdelta = delta - mu;
    double newepsilon = guardWidth*sqrt3;
    if(oldCrap) textout = [textout stringByAppendingFormat:@"newdelta %.4f\n",newdelta];
    if(oldCrap) textout = [textout stringByAppendingFormat:@"newepsilon %.4f\n",newepsilon];
    m1 = 0.5*(newdelta+newepsilon);
    if(oldCrap) textout = [textout stringByAppendingFormat:@"m1 = %.4f\n\n",m1];

    textout = [textout stringByAppendingString:@"\n----------------------------\n"];
    
    // -------------------------------------------------------
    int ntype[2] = {8,12};
    

    double extendedIdeal, truncatedIdeal;

    for (int i=0; i<2; i++) {
        fcell[i] = waferSide/(double)ntype[i];
        scell[i] = fcell[i]/sqrt3;
        double aExt =   0.5 * (double)(ntype[i] - 1) * fcell[i] - zoltanDistanceC;
        double aTrunc = zoltanDistanceC - 0.5 * (double)(ntype[i] - 2) * fcell[i];
        double cornerCellHeight = fcell[i] - mouseBitePerp;
        if(oldCrap) textout = [textout stringByAppendingFormat:@"aExt = %.4f\n",aExt];
        if(oldCrap) textout = [textout stringByAppendingFormat:@"aTrunc = %.4f\n",aTrunc];
        if(oldCrap) textout = [textout stringByAppendingFormat:@"cornerCellHeight = %.4f\n\n",cornerCellHeight];


// ---- set up the cell vertices games
        voff[0].x = 0;                 voff[0].y = -scell[i];
        voff[1].x =  fcell[i]*0.5;     voff[1].y = -scell[i]*0.5;
        voff[2].x =  fcell[i]*0.5;     voff[2].y =  scell[i]*0.5;
        voff[3].x = 0;                 voff[3].y =  scell[i];
        voff[4].x = -fcell[i]*0.5;     voff[4].y =  scell[i]*0.5;
        voff[5].x = -fcell[i]*0.5;     voff[5].y = -scell[i]*0.5;

        textout = [textout stringByAppendingFormat:@"Values for %@\n\n",typeStr[i]];

        if(oldCrap) textout = [textout stringByAppendingString:@"Using <test> method:\n"];
        double area = [self areaFrom: 6 Vertices: voff];
        textout = [textout stringByAppendingFormat:@"whole %.4f\n",area];
        
        vpnt[0].x = fcell[i]*0.5;   vpnt[0].y = -scell[i] + edgeInset;
        vpnt[1] = voff[2];
        vpnt[2] = voff[3];
        vpnt[3] = voff[4];
        vpnt[4].x = -fcell[i]*0.5;   vpnt[4].y = -scell[i] + edgeInset;
        area = [self areaFrom: 5 Vertices: vpnt];
        textout = [textout stringByAppendingFormat:@"extended %.4f\n",area];

        vpnt[0] = voff[0];
        vpnt[1] = voff[1];
        vpnt[2].x = voff[2].x;    vpnt[2].y = voff[2].y - edgeInset;
        vpnt[3].x = voff[4].x;    vpnt[3].y = voff[4].y - edgeInset;
        vpnt[4] = voff[5];
        area = [self areaFrom: 5 Vertices: vpnt];
        textout = [textout stringByAppendingFormat:@"truncated %.4f\n",area];
  
        vpnt[0].x = 0.5*fcell[i] - aExt; vpnt[0].y = -scell[i] + edgeInset;
        vpnt[1].x = voff[1].x;            vpnt[1].y = vpnt[0].y + aExt/sqrt3;
        vpnt[2] = voff[2];
        vpnt[3] = voff[3];
        vpnt[4] = voff[4];
        vpnt[5].x = voff[4].x;            vpnt[5].y= vpnt[0].y;
        area = [self areaFrom: 6 Vertices: vpnt];
        textout = [textout stringByAppendingFormat:@"bitten extended %.4f\n",area];

        if(i == 1) {
            vpnt[0].x = 0.5*fcell[i] - aTrunc; vpnt[0].y = -0.5*scell[i] + edgeInset;
            vpnt[1].x = voff[1].x;            vpnt[1].y = vpnt[0].y + aTrunc/sqrt3;
            vpnt[2] = voff[2];
            vpnt[3] = voff[3];
            vpnt[4] = voff[4];
            vpnt[5].x = voff[4].x;            vpnt[5].y= vpnt[0].y;
            area = [self areaFrom: 6 Vertices: vpnt];
            textout = [textout stringByAppendingFormat:@"bitten truncated %.4f\n",area];
            
            vpnt[0] = voff[0];
            vpnt[1].x = voff[0].x + cornerCellHeight; vpnt[1].y = voff[0].y + cornerCellHeight/sqrt3;
            vpnt[2].x = voff[4].x; vpnt[2].y = voff[5].y + 2.*cornerCellHeight/sqrt3;
            vpnt[3] = voff[5];
            area = [self areaFrom: 4 Vertices: vpnt];
            textout = [textout stringByAppendingFormat:@"corner cell %.4f\n",area];
        } else {
            vpnt[0] = voff[0];
            vpnt[1].x = voff[0].x + cornerCellHeight; vpnt[1].y = voff[0].y + cornerCellHeight/sqrt3;
            vpnt[2].x = -0.5*fcell[0]+aTrunc; vpnt[2].y = 0.5*scell[0]-edgeInset;
            vpnt[3].x = -0.5*fcell[0]; vpnt[3].y = vpnt[2].y;
            vpnt[4] = voff[5];
            area = [self areaFrom: 5 Vertices: vpnt];
            textout = [textout stringByAppendingFormat:@"corner cell %.4f\n",area];
        }
        
        textout = [textout stringByAppendingString:@"\n----------------------------\n"];

        acell[i] = 3. * sqrt3 * 0.5 * scell[i] * scell[i];
//        whole[i] = 1.5 * sqrt3 * scell[i] * scell[i];
        extendedIdeal = acell[i] * (7./6.);
        truncatedIdeal = acell[i] * (5./6.);
        double subtractArea = edgeInset * fcell[i];
        extended[i] = extendedIdeal - subtractArea;
        truncated[i] = truncatedIdeal - subtractArea;
        
        extendedBitten[i] = extended[i] - 0.5*aExt*aExt/sqrt3;
        
        double triangleHeight =  0.5 * (double)(ntype[i] - 2) * fcell[i] - zoltanDistanceC;
        if(triangleHeight > 0.) {
            subtractArea = 0.5*triangleHeight * triangleHeight/sqrt3;
            truncatedBitten[i] = truncated[i] - subtractArea;
        } else truncatedBitten[i] = 0.;
        
        corner[i] = cornerCellHeight*scell[i] + cornerCellHeight*cornerCellHeight/sqrt3;
        if(i==0){
            corner[0] -= 0.5*aTrunc*aTrunc/sqrt3;
        }
        
        if(oldCrap) {
            textout = [textout stringByAppendingFormat:@"Values for %@\n",typeStr[i]];
            textout = [textout stringByAppendingFormat:@"Whole %.4f\n",acell[i]];
            if(verbose) {
                textout = [textout stringByAppendingFormat:@"extended ideal %.4f\n",extendedIdeal];
                textout = [textout stringByAppendingFormat:@"truncated ideal %.4f\n",truncatedIdeal];
            }
            textout = [textout stringByAppendingFormat:@"extended side %.4f\n",extended[i]];
            textout = [textout stringByAppendingFormat:@"truncated side %.4f\n",truncated[i]];
            textout = [textout stringByAppendingFormat:@"extended bitten %.4f\n",extendedBitten[i]];
            textout = [textout stringByAppendingFormat:@"truncated bitten %.4f\n",truncatedBitten[i]];
            if(verbose) textout = [textout stringByAppendingFormat:@"cornerCellHeight %.4f\n",cornerCellHeight];
            textout = [textout stringByAppendingFormat:@"corner %.4f\n\n\n",corner[i]];
        }
    }
    
    [theTerminal displayString:textout];
    
    [self calculatePartialCellAreas];
    
}

- (void) calculatePartialCellAreas {
    
    //int ntype[2] = {8,12};

    BOOL verbose = NO;
    BOOL oldCrap = NO;

    NSString * textout = @"Additional partial cells\n\n";
    
    //double edgeInset = guardWidth + 0.435; // ?????????

    // Wafer universals defined in Zoltan's LD picture
    //NSPoint zoltanC = theHardwareConstants.LDzoltanC; //NSMakePoint(38.9787,82.3869);
    NSPoint zoltanD = theHardwareConstants.LDzoltanD; //NSMakePoint(47.4375,77.5032);
    NSPoint zoltanE = theHardwareConstants.LDzoltanE; //NSMakePoint(49.2345,76.4657);
    NSPoint zoltanF = theHardwareConstants.LDzoltanF; //NSMakePoint(51.8958!!!,74.95);

        
    // ------------ LD test stuff
    if(oldCrap) textout = [textout stringByAppendingString:@"Using <test> method:\n"];

    NSPoint voff[6],vpnt[6];
    int i = 0;
    /*
    double aExt =   0.5 * (double)(ntype[i] - 1) * fcell[i] - zoltanDistanceC;
    double aTrunc = zoltanDistanceC - 0.5 * (double)(ntype[i] - 2) * fcell[i];
    double cornerCellHeight = fcell[i] - mouseBitePerp;
    */
    // ---- set up the vertices games
    voff[0].x = 0;                 voff[0].y = -scell[i];
    voff[1].x =  fcell[i]*0.5;     voff[1].y = -scell[i]*0.5;
    voff[2].x =  fcell[i]*0.5;     voff[2].y =  scell[i]*0.5;
    voff[3].x = 0;                 voff[3].y =  scell[i];
    voff[4].x = -fcell[i]*0.5;     voff[4].y =  scell[i]*0.5;
    voff[5].x = -fcell[i]*0.5;     voff[5].y = -scell[i]*0.5;
    
    for (int j=0; j<6; j++) {vpnt[j]=voff[j];}
    vpnt[1].x -= guardWidth; vpnt[1].y -= guardWidth*0.5;
    vpnt[2].x -= guardWidth; vpnt[2].y += guardWidth*0.5;
    double area = [self areaFrom: 6 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-A %.4f\n",area];
    
    vpnt[0].x = voff[0].x-guardWidth; vpnt[0].y = voff[0].y+guardWidth*0.5;
    vpnt[1].x = voff[3].x-guardWidth; vpnt[1].y = voff[3].y-guardWidth*0.5;
    vpnt[2] = voff[4];
    vpnt[3] = voff[5];
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half LD-B %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full LD-B %.4f\n",area*2.];

    vpnt[0].x = voff[1].x; vpnt[0].y = voff[1].y - 0.5*scell[0] + guardWidth;
    vpnt[1] = voff[2]; vpnt[2] = voff[3]; vpnt[3] = voff[4];
    vpnt[4].x = voff[5].x; vpnt[4].y = voff[5].y - 0.5*scell[0] + guardWidth;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-C %.4f\n",area];

    vpnt[0].x = - guardWidth; vpnt[0].y = voff[0].y + guardWidth;
    vpnt[1].x = - guardWidth; vpnt[1].y = voff[3].y - guardWidth*0.5; // /sqrt3;
    vpnt[2] = voff[4];
    vpnt[3].x = voff[5].x; vpnt[3].y = vpnt[0].y;
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half LD-D %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full LD-D %.4f\n",area*2.];

    vpnt[0] = voff[0]; vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y - guardWidth;
    vpnt[3].x = voff[4].x; vpnt[3].y = voff[4].y - guardWidth;
    vpnt[4] = voff[5];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-E %.4f\n",area];

    vpnt[0] = voff[0]; vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y - guardWidth;
    vpnt[3].x = voff[4].x + guardWidth; vpnt[3].y = vpnt[2].y;
    vpnt[4].x = vpnt[3].x; vpnt[4].y = voff[5].y - guardWidth*0.5;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-F %.4f\n",area];

    vpnt[0].x = -guardWidth; vpnt[0].y = voff[0].y + edgeInset;
    vpnt[1].x = vpnt[0].x; vpnt[1].y = voff[3].y - guardWidth*0.5;
    vpnt[2] = voff[4];
    vpnt[3].x = voff[5].x; vpnt[3].y = voff[0].y + edgeInset;
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half LD-G %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full LD-G %.4f\n",area*2.];

    vpnt[0] = voff[0];
    vpnt[1].x = voff[1].x - guardWidth; vpnt[1].y = voff[1].y - guardWidth*0.5;
    vpnt[2].x = vpnt[1].x; vpnt[2].y = voff[2].y - edgeInset;
    vpnt[3].x = voff[4].x; vpnt[3].y = voff[4].y - edgeInset;
    vpnt[4] = voff[5];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-H %.4f\n",area];
  
    vpnt[0] = voff[0];
    vpnt[1].x = voff[0].x + 0.5*(1.5*scell[0]-edgeInset)*sqrt3;
    vpnt[1].y = voff[0].y + 0.5*(1.5*scell[0]-edgeInset);
    /*
    vpnt[2].x = 51.8958 - 4.5*fcell[0];
    vpnt[2].y = 74.9500 - 8.5*scell[0];
    vpnt[3].x = 49.2345 - 4.5*fcell[0];
    vpnt[3].y = 76.4657 - 8.5*scell[0];
     */
    vpnt[2] = theHardwareConstants.LDzoltanF;
    vpnt[2].x -= 4.5*fcell[0];
    vpnt[2].y -= 8.5*scell[0];
    vpnt[3] = theHardwareConstants.LDzoltanE;
    vpnt[3].x -= 4.5*fcell[0];
    vpnt[3].y -= 8.5*scell[0];
    vpnt[4].x = vpnt[3].x;
    vpnt[4].y = voff[5].y - guardWidth*0.5;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-V %.4f\n",area];
    /*
    [self makeProblemBezierFrom: 5 Vertices: vpnt];
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSPoint ptrans = NSMakePoint(4.5*fcell[0],8.5*scell[0]);
    [transform translateXBy: ptrans.x yBy: ptrans.y];
    [_problemCell transformUsingAffineTransform: transform];
    */
    
    vpnt[0].x = voff[1].x; vpnt[0].y = voff[0].y + guardWidth;
    vpnt[1] = voff[2];
    vpnt[2].x = voff[2].x - 0.5*(1.5*scell[0]-edgeInset)*sqrt3;
    vpnt[2].y = voff[2].y + 0.5*(1.5*scell[0]-edgeInset);
    /*
    NSAffineTransform * rot120 = [[NSAffineTransform alloc] init];
    [rot120 rotateByDegrees:120.];
    vpnt[3] = [rot120 transformPoint: zoltanF];
    vpnt[3].x += 7.*fcell[0]; vpnt[3].y -= scell[0];
    vpnt[4].x = voff[0].x - fcell[0] + mouseBitePerp; vpnt[4].y = vpnt[0].y;
     */
    vpnt[3] = theHardwareConstants.LDzoltanG;
    vpnt[3].x = -vpnt[3].x + 7.*fcell[0];
    vpnt[3].y -= scell[0];
    vpnt[4] = theHardwareConstants.LDzoltanH;
    vpnt[4].x = -vpnt[4].x + 7.*fcell[0];
    vpnt[4].y -= scell[0];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-W %.4f\n",area];

    /*
    vpnt[0].x = - 0.5*edgeInset*sqrt3; vpnt[0].y = voff[0].y + 0.5*edgeInset;
    NSAffineTransform * rot300 = [[NSAffineTransform alloc] init];
    [rot300 rotateByDegrees:300.];
    vpnt[1] = [rot300 transformPoint: zoltanF];
    vpnt[1].x -= 7.5*fcell[0]; vpnt[1].y += 0.5*scell[0];
    vpnt[2].x = voff[2].x - mouseBitePerp; vpnt[2].y = voff[2].y - guardWidth;
    vpnt[3] = voff[4]; vpnt[3].y -= guardWidth;
    vpnt[4] = voff[5];
     */
    vpnt[0].x = voff[0].x - 0.5*edgeInset*sqrt3;
    vpnt[0].y = voff[0].y + 0.5*edgeInset;
    vpnt[1] = theHardwareConstants.LDzoltanG;
    vpnt[1].x -= 7.5*fcell[0];
    vpnt[1].y = -vpnt[1].y + 0.5*scell[0];
    vpnt[2] = theHardwareConstants.LDzoltanH;
    vpnt[2].x -= 7.5*fcell[0];
    vpnt[2].y = -vpnt[2].y + 0.5*scell[0];
    vpnt[3].x = voff[4].x; vpnt[3].y = voff[4].y - guardWidth;
    vpnt[4] = voff[5];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-X %.4f\n",area];
    
    vpnt[0].x = zoltanD.x - 4.*fcell[0]; vpnt[0].y = 11.*scell[0] - zoltanD.y;
    vpnt[1].x = vpnt[0].x;  vpnt[1].y = voff[3].y - guardWidth*0.5;
    vpnt[2] = voff[4];
    //NSPoint cPnt = NSMakePoint(zoltanC.x - 4.*fcell[0],11.*scell[0]-zoltanC.y);
    double m = 1./sqrt3;
    //double cc = cPnt.y - cPnt.x*m;
    double cc = vpnt[0].y - vpnt[0].x*m;
    vpnt[3].x = voff[5].x;
    vpnt[3].y = m*vpnt[3].x + cc;
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-Y %.4f\n",area];
    
    // Reference to centre of *upper* cell
    vpnt[0] = NSMakePoint(zoltanE.x-4.5*fcell[0],9.5*scell[0]-zoltanE.y);
    vpnt[1] = NSMakePoint(zoltanF.x-4.5*fcell[0],9.5*scell[0]-zoltanF.y);
    vpnt[2].x = voff[2].x - 0.5*edgeInset*sqrt3; vpnt[2].y = voff[2].y + 0.5*edgeInset;
    vpnt[3] = voff[3];
    vpnt[4] = voff[4]; vpnt[4].x = vpnt[0].x; vpnt[4].y += guardWidth*0.5;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"LD-Z %.4f\n",area];
/*
    [self makeProblemBezierFrom: 5 Vertices: vpnt];
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSPoint ptrans = NSMakePoint(7.5*fcell[0],-0.5*scell[0]);
    [transform translateXBy: ptrans.x yBy: ptrans.y];
    [_problemCell transformUsingAffineTransform: transform];
*/
    textout = [textout stringByAppendingString:@"\n\n"];
// =====================================================================================
    // ------------ LD original partial extras calculations
    if(oldCrap) {
        double remove = guardWidth * (scell[0] + guardWidth/sqrt3);
        double LDA = acell[0] - remove;
        textout = [textout stringByAppendingFormat:@"LD-A = %.4f\n",LDA];
        
        double c = fcell[0]*0.5 - guardWidth;
        double LDB = c * (scell[0] + c/sqrt3); // c x s + c2/√3
        textout = [textout stringByAppendingFormat:@"Half LD-B = %.4f\n",LDB];
        textout = [textout stringByAppendingFormat:@"Full LD-B = %.4f\n",LDB*2.];
        
        double LDC = (7.*acell[0]/6.) - fcell[0]*guardWidth;
        textout = [textout stringByAppendingFormat:@"LD-C = %.4f\n",LDC];
        
        double LDD = 0.5 * LDC - (2.*scell[0] - guardWidth)*guardWidth + guardWidth*guardWidth*0.5/sqrt3;
        textout = [textout stringByAppendingFormat:@"Half LD-D = %.4f\n",LDD];
        textout = [textout stringByAppendingFormat:@"Full LD-D = %.4f\n",LDD*2.];
        
        //LD-E area = 5/6 full cell - f x g
        double LDE = 5.*acell[0]/6. - fcell[0]*guardWidth;
        textout = [textout stringByAppendingFormat:@"LD-E = %.4f\n",LDE];
        
        // LD-E area - (s-g) x g + g2/2√3
        double LDF = LDE - (scell[0] - guardWidth) * guardWidth - guardWidth*guardWidth/(2.*sqrt3);
        textout = [textout stringByAppendingFormat:@"LD-F = %.4f\n",LDF];
        
        //LD extended side - (2 x g) x (2 x s - i) + g2/√3
        double LDG = 0.5*extended[0] - guardWidth*(2.*scell[0] - edgeInset) + guardWidth*guardWidth/(2.*sqrt3);
        textout = [textout stringByAppendingFormat:@"Half LD-G = %.4f\n",LDG];
        textout = [textout stringByAppendingFormat:@"Full LD-G = %.4f\n",2.*LDG];
        
        //LD truncated side - g x s - g2/2√3
        double LDH = truncated[0] - guardWidth*(scell[0]-edgeInset) - guardWidth*guardWidth/(2.*sqrt3);
        textout = [textout stringByAppendingFormat:@"LD-H = %.4f\n",LDH];
        
        /*
         T1 = 1/2 x √3 x 1.5 x s x 1.5 x s
         T2 = 1/2 x (δ+ε) x 1/2 x (δ+ε)/√3
         Area = Se + T1 + T2
         Need to subtract:
         1. edge inset along 1.5 x f - (δ+ε)
         (add back in the subtracted √3 x inset2/2)
         2. g along 4 x s - h
         where h = 2 x 1/2 x (δ+ε)/√3
         */
        double T1 = 0.5 * sqrt3 * (1.5*scell[0]) * (1.5*scell[0]);
        double T2 = 0.5 * 0.5 * delta * delta/sqrt3;
        textout = [textout stringByAppendingFormat:@"T1 = %.4f; T2 = %.4f; Se = %.4f\n",T1,T2,extended[0]];
        textout = [textout stringByAppendingFormat:@"Sum = %.4f\n",T1-T2+extended[0]];
        double LDV = extended[0] + T1 - T2 - edgeInset*(1.5*fcell[0] - (delta+epsilon)) + sqrt3*edgeInset*edgeInset*0.5 - guardWidth*(4.*scell[0] - (delta+epsilon)/sqrt3);
        textout = [textout stringByAppendingFormat:@"LD-V = %.4f\n",LDV];
        
        //LD-W = (1.5 x full cell) - 1/2 x m x m√3 - i x (a + f/2) - g x (3f/2 - m)
        double a = fcell[0] - delta;
        if(verbose) textout = [textout stringByAppendingFormat:@"*** a = %.4f ***\n",a];
        double LDW = 1.5*acell[0] - 0.5*mouseBitePerp*mouseBitePerp*sqrt3 - edgeInset*(a + fcell[0]*0.5) - guardWidth*(1.5*fcell[0] - mouseBitePerp);
        textout = [textout stringByAppendingFormat:@"LD-W = %.4f\n",LDW];
        
        /*
         Area LD-X = Area of LD corner - pink triangle - g x c
         Pink triangle = c2/(2√3)
         */
        double LDX = corner[0] - 0.5*(fcell[0]-mouseBitePerp)*(fcell[0]-mouseBitePerp)/sqrt3 - guardWidth*(fcell[0]-mouseBitePerp);
        textout = [textout stringByAppendingFormat:@"LD-X = %.4f\n",LDX];
        
        /*
         Area LD-Y = (f -m) x (s - 2g/√3)
         */
        double LDY = (fcell[0]-mouseBitePerp) * (scell[0]-2.*guardWidth/sqrt3);
        textout = [textout stringByAppendingFormat:@"LD-Y = %.4f\n",LDY];
        
        /*
         T1 = 1/2 x f x s
         T2 = 1/2 x δ x (δ/2)/√3
         Area = St + T1 + T2
         Need to subtract:
         1. edge inset along 2 x f - δ
         2. g along 3 x s - h
         */
        double LDZ = truncated[0] + 0.5*fcell[0]*scell[0] + 0.25*delta*delta/sqrt3 - edgeInset*(2.*fcell[0] - delta) - guardWidth*(3.*scell[0] - mouseBitePerp*sqrt3);
        textout = [textout stringByAppendingFormat:@"LD-Z = %.4f\n",LDZ];
        
        textout = [textout stringByAppendingString:@"\n\n"];
    }
// =====================================================================================

    if(oldCrap) textout = [textout stringByAppendingString:@"Using <test> method:\n"];

    /*
     for(int i=0; i<4; i++) {
         NSLog(@"vpnt[%d]: %.4f, %.4f",i,vpnt[i].x+4.*fcell[0],vpnt[i].y-11.*scell[0]);
     }
     */
    // ------------ HD test stuff
    i = 1;
    // ---- set up the vertices games
    voff[0].x = 0;                 voff[0].y = -scell[i];
    voff[1].x =  fcell[i]*0.5;     voff[1].y = -scell[i]*0.5;
    voff[2].x =  fcell[i]*0.5;     voff[2].y =  scell[i]*0.5;
    voff[3].x = 0;                 voff[3].y =  scell[i];
    voff[4].x = -fcell[i]*0.5;     voff[4].y =  scell[i]*0.5;
    voff[5].x = -fcell[i]*0.5;     voff[5].y = -scell[i]*0.5;
    
    for (int j=0; j<6; j++) {vpnt[j]=voff[j];}
    vpnt[4].x += guardWidth; vpnt[4].y += guardWidth*0.5;
    vpnt[5].x += guardWidth; vpnt[5].y -= guardWidth*0.5;
    area = [self areaFrom: 6 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-A %.4f\n",area];
 
    
    vpnt[0].x = voff[0].x-guardWidth; vpnt[0].y = voff[0].y+guardWidth*0.5;
    vpnt[1].x = voff[3].x-guardWidth; vpnt[1].y = voff[3].y-guardWidth*0.5;
    vpnt[2] = voff[4];
    vpnt[3] = voff[5];
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half HD-B %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full HD-B %.4f\n",area*2.];

    vpnt[0] = voff[0];
    vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y + 0.5*scell[1] - guardWidth;
    vpnt[3].x = voff[5].x; vpnt[3].y = vpnt[2].y;
    vpnt[4] = voff[5];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-C %.4f\n",area];
    
    vpnt[0].x = - guardWidth; vpnt[0].y = voff[0].y + guardWidth;
    vpnt[1].x = - guardWidth; vpnt[1].y = voff[3].y - guardWidth*0.5;
    vpnt[2] = voff[4];
    vpnt[3].x = voff[5].x; vpnt[3].y = vpnt[0].y;
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half HD-D %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full HD-D %.4f\n",area*2.];

    vpnt[0] = voff[0]; vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y - guardWidth;
    vpnt[3].x = voff[4].x; vpnt[3].y = voff[4].y - guardWidth;
    vpnt[4] = voff[5];
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-E %.4f\n",area];

    vpnt[0] = voff[0];
    vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y - guardWidth;
    vpnt[3].x = voff[4].x + guardWidth; vpnt[3].y = vpnt[2].y;
    vpnt[4].x = vpnt[3].x; vpnt[4].y = voff[5].y - guardWidth*0.5;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-F %.4f\n",area];

    vpnt[0].x = voff[0].x + guardWidth; vpnt[0].y = voff[0].y + guardWidth*0.5;
    vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y - edgeInset;
    vpnt[3].x = vpnt[0].x; vpnt[3].y = vpnt[2].y;
    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"half HD-G %.4f\n",area];
    textout = [textout stringByAppendingFormat:@"full HD-G %.4f\n",area*2.];

    NSPoint HDzoltanE = theHardwareConstants.HDzoltanE; // NSMakePoint(86.2523,15.3805);
    NSPoint HDzoltanF = theHardwareConstants.HDzoltanF;
    
    vpnt[0] = voff[0];
    vpnt[1] = voff[1];
    vpnt[2].x = voff[2].x; vpnt[2].y = voff[2].y + 0.5*scell[1] - guardWidth;
    vpnt[3].x = 10.5*fcell[1] - HDzoltanF.x; vpnt[3].y = HDzoltanF.y - 2.5*scell[1];
    double len = 0.5*scell[1] - edgeInset;
    vpnt[4].x = voff[5].x - 0.5*len*sqrt3; vpnt[4].y = voff[5].y + 0.5*len;
    area = [self areaFrom: 5 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-X %.4f\n",area];
    

    vpnt[0].x = HDzoltanE.x - 10.*fcell[1]; vpnt[0].y = HDzoltanE.y - 4.*scell[1];
    vpnt[1].x = voff[3].x + 0.5*len*sqrt3; vpnt[1].y = voff[3].y + 0.5*len;
    vpnt[2] = voff[4];
    vpnt[3].x = voff[5].x; vpnt[3].y = vpnt[0].y;
    /*
     for(int i=0; i<4; i++) {
         NSLog(@"vpnt[%d]: %.4f, %.4f",i,vpnt[i].x + 10.*fcell[1],vpnt[i].y + 4.*scell[1]);
     }
    */

    area = [self areaFrom: 4 Vertices: vpnt];
    textout = [textout stringByAppendingFormat:@"HD-Y %.4f\n",area];
    
    [self makeProblemBezierFrom: 4 Vertices: vpnt];
    NSAffineTransform *transform = [NSAffineTransform transform];
    NSPoint ptrans = NSMakePoint(10.*fcell[1],4.*scell[1]);
    [transform translateXBy: ptrans.x yBy: ptrans.y];
    [_problemCell transformUsingAffineTransform: transform];



    textout = [textout stringByAppendingString:@"\n\n"];
// =====================================================================================

// ------------- Now the old HD partials calculations
    if(oldCrap) {
        
        // Removed area = g x s + g2/√3
        double HDA = acell[1] - (guardWidth*scell[1] + guardWidth*guardWidth/sqrt3);
        textout = [textout stringByAppendingFormat:@"HD-A = %.4f\n",HDA];
        
        /*
         c = f/2 - 0.8985
         HD-B half area = c x s + c2/√3
         */
        double HDB = (fcell[1]*0.5 - guardWidth)*scell[1] + (fcell[1]*0.5 - guardWidth)*(fcell[1]*0.5 - guardWidth)/sqrt3;
        textout = [textout stringByAppendingFormat:@"Half HD-B = %.4f\n",HDB];
        textout = [textout stringByAppendingFormat:@"Full HD-B = %.4f\n",HDB*2.];
        
        /*
         Ideal/layout area = 7/6 full cell
         Removed area = f x g
         */
        double HDC = (7./6.)*acell[1] - fcell[1]*guardWidth;
        textout = [textout stringByAppendingFormat:@"HD-C = %.4f\n",HDC];
        
        /*
         HD-D half area = 1/2 HD-C area - R
         where R = (2 s - g) g + g2/(2√3)
         */
        double HDD = 0.5*HDC - (2.*scell[1]-guardWidth)*guardWidth + 0.5*guardWidth*guardWidth/sqrt3;
        textout = [textout stringByAppendingFormat:@"Half HD-D = %.4f\n",HDD];
        textout = [textout stringByAppendingFormat:@"Full HD-D = %.4f\n",HDD*2.];
        
        /*
         HD-E area = 5/6 full cell - f x g
         */
        double HDE = (5./6.)*acell[1] - fcell[1]*guardWidth;
        textout = [textout stringByAppendingFormat:@"HD-E = %.4f\n",HDE];
        
        /*
         HD-F area = HD-E area - (s-g) x g + g2/2√3
         */
        double HDF = HDE - (scell[1]-guardWidth)*guardWidth - 0.5*guardWidth*guardWidth/sqrt3;
        textout = [textout stringByAppendingFormat:@"HD-F = %.4f\n",HDF];
        
        /*
         Area triangle ACG = 1/2 x 2.5s x 2.5s√3
         
         From this must be subtracted:
         Triangle ABD
         AD = 2.5s + i
         so area ABD = 1/2 x (2.5s + i) x (2.5s + i)/√3
         
         Triangle EFG
         area = 1/6 x whole cell
         
         guard ring along BC
         BC = 2.5f - AB
         AB = 2 x (2.5s + i)/√3
         */
        double HDX = 3.125*scell[1]*scell[1]*sqrt3;
        HDX -= 0.5*(2.5*scell[1]-edgeInset)*(2.5*scell[1]-edgeInset)/sqrt3;
        HDX -= (1./6.)*acell[1];
        HDX -= guardWidth*(2.5*fcell[1] - 2.*(2.5*scell[1]+edgeInset)/sqrt3);
        textout = [textout stringByAppendingFormat:@"HD-X = %.4f\n",HDX];
        
        /*
         Triangle T1 area = 1/2 x (s/2 - i) x (s/2 - i)√3
         Triangle T2 area = 1/2 x (s-g-2i) x (s-g-2i)/√3
         
         The remaining piece is ≈ HD-E
         */
        double HDY = HDE + 0.5*(0.5*scell[1]-edgeInset)*(0.5*scell[1]-edgeInset)/sqrt3 + 0.5*(scell[1]-guardWidth-2.*edgeInset)*(scell[1]-guardWidth-2.*edgeInset)/sqrt3;
        textout = [textout stringByAppendingFormat:@"HD-Y = %.4f\n",HDY];
        
    }
    
    
    [theTerminal displayString:textout];

}

- (double) areaFrom: (int) n Vertices:(NSPoint *) vpnt {
    
    double area = 0.;
    int j = n-1;
    for(int i=0; i<n; i++) {
        area +=  (vpnt[i].x + vpnt[j].x) * (vpnt[i].y - vpnt[j].y);
        j = i;
    }
    
    return area*0.5;
}

- (void) makeProblemBezierFrom: (int) n Vertices: (NSPoint *) vpnt {
    
    _problemCell = [NSBezierPath bezierPath];
    [_problemCell moveToPoint:vpnt[0]];
    for (int i=1; i<n; i++) {
        [_problemCell lineToPoint:vpnt[i]];
    }
    [_problemCell lineToPoint:vpnt[0]];
    [_problemCell closePath];
}
@end
