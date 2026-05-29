//
//  HXGdebugRotationControl.m
//  Hex
//
//  Created by Chris Seez on 17/01/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGdebugRotationControl.h"

@interface HXGdebugRotationControl ()

@end

@implementation HXGdebugRotationControl

+ (id) sharedRotationControl {
    
    static dispatch_once_t pred;
    static HXGdebugRotationControl * theRotationControl = nil;
    
    dispatch_once(&pred, ^{ theRotationControl = [[self alloc] init]; });
    return theRotationControl;
    
}

- (id)init {
    self=[super initWithWindowNibName: @"HXGdebugRotationControl"];
    
    if(!theCellControl) theCellControl = [HXGCellControl sharedCellControl];

    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
   
    /*
     Wafer characteristic number: N (LD=8, HD=12) (=number of cells per side)
     Cell side: R = Wafer flat-to-flat / (3 * N)
     Cell half flat-to-flat: r = R * sin(60º) (= wafer side / (2 * N))
     */
    
    if(!theHardwareConstants) theHardwareConstants = [HXGHardwareConstants sharedHardwareConstants];
    [theCellControl setWaferSize:layoutHexagonWidth];
    [theCellControl setHardwareOrientation:NO];
 
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(newSpec:)
               name:HXGCellSpecNotification
             object:nil];

}

- (void) showWindow:(id)sender {
    [super showWindow:sender];

    int n = 8;
    if(theCellControl.cellview) {
        n = theCellControl.cellview.count;
        placement = theCellControl.iplacement;
    }
    
    if(n == 8 || n == 12) {
        NN = (double) n;
    } else {
        NN = 8.;
    }
    RR = layoutHexagonWidth/(3.*NN);
    rr = RR*sin(M_PI/3.);

    iu=0;
    iv=0;
    [_iuStepper setIntegerValue:iu];
    [_ivStepper setIntegerValue:iv];
    [_ivStepper setMaxValue:MIN(2*n-1,iu+n-1)];
    [_iuStepper setMaxValue:MIN(2*n-1,iv+n)];

    [_placementStepper setIntegerValue:placement];
    
    [self changeStepper:self];
}

- (void)windowWillClose:(NSNotification *)notification {
    
    theCellControl.cellview.showCellPoint = NO;
    [theCellControl.cellview setNeedsDisplay:YES];
}

- (IBAction) changeStepper:(id)sender {
    
    int n = (int) (NN+0.1);
    iu = (int)[_iuStepper integerValue];
    [_ivStepper setMaxValue:MIN(2*n-1,iu+n-1)];
    iv = (int)[_ivStepper integerValue];
    [_iuStepper setMaxValue:MIN(2*n-1,iv+n)];


    [_iuText setStringValue:[NSString stringWithFormat:@"%2d",iu]];
    [_ivText setStringValue:[NSString stringWithFormat:@"%2d",iv]];
    
    NSPoint offset = [self calculatePosition];
    resultString = @"HD 432 cell wafer";
    if(n == 8) resultString = @"LD 192 cell wafer";
    resultString = [resultString stringByAppendingFormat:@"\nPlacement index = %d",placement];
    resultString = [resultString stringByAppendingFormat:@"\nCell (%2d,%2d) at: %.2f, %.2f",iu,iv,offset.x,offset.y];
    
    [_resultText setStringValue:resultString];
    
    if(!theCellControl.cellview.showCellPoint) {
        [theCellControl showWindow:nil];
        int iwaf = 0;
        if(theCellControl.cellview.count == 12) iwaf = 1;
        [theCellControl drawCellsInWafer:iwaf]; // 0 chooses LD (192)
    }
    [theCellControl.cellview markPoint:offset];

}

- (void) newSpec:(NSNotification *) note {
   
    if(theCellControl.cellview.hardwareOrientation) [self.window close];
    if(!theCellControl.cellControlWindowOpen) [self.window close];
    
    NN = (double) theCellControl.cellview.count;
    placement = theCellControl.iplacement;
    
    if(NN < 8.) {
        theCellControl.cellview.showCellPoint = NO;
        [theCellControl.cellview setNeedsDisplay:YES];
        [[self window] close];
    } else if([[self window] isVisible]){
        RR = layoutHexagonWidth/(3.*NN);
        rr = RR*sin(M_PI/3.);
        [self changeStepper:self];
    }

            
}

- (NSPoint) calculatePosition {
    
    NSPoint pos = NSZeroPoint;
    
    /*
     First calculate x' and y' (the local 2D Cartesian coordinates with respect to the wafer centre: i.e. possibly rotated)
     x' = [1.5*(iu-iv)-0.5] * R
     y' = [iu+iv-2*N+1] * r

     Then change sign of x' if the wafer front does not point towards +z [see note 1]

     Then rotate the local 2D Cartesian coordinates according to the ir rotation index, so that they match up with the global coordinate system
     θ = ir * 60º
     x = x'*cos(θ) - y'*sin(θ)
     y = x'*sin(θ) + y'cos(θ)
     */
    
    double xprime = (1.5 * (double)(iu-iv) - 0.5) * RR;
    double yprime = ((double)(iu+iv) - 2.*NN + 1.) * rr;
    
    //if(placement > 5) xprime = -xprime;
    
    double rot = (double)(placement%6);
    double theta = rot * (M_PI/3.);
    
    pos.x = xprime*cos(theta) - yprime*sin(theta);
    pos.y = xprime*sin(theta) + yprime*cos(theta);
    if(placement > 5) pos.x = -pos.x;
    return pos;
}

- (NSPoint) calculateSunandaPosition {
    
    NSPoint pos = NSZeroPoint;
    
    double u = (double)iu;
    double v = (double)iv;
    
    if(placement == 0) {
        pos.x = (1.5 * (u-v) - 0.5) * RR;
        pos.y = (u + v - 2.*NN + 1.) * rr;
    }
    if(placement == 1) {
        //x = [1.5*(v-N)+0.5] * R
        //y = -[2*v-u-N+1] * r
        pos.x = (1.5 * (v - NN) + 0.5) * RR;
        pos.y = -(2.*v - u - NN + 1.) * rr;
    }
    if(placement == 2) {
        //x = -[1.5*(u-N)+1] * R
        //y = -[2*v-u-N] * r
        pos.x = -(1.5 * (u-NN) + 1.) * RR;
        pos.y = -(2.*v - u - NN) * rr;
    }
    if(placement == 3) {
        //x = -[1.5*(u-v)+0.5] * R
        //y = -[v+u-2*N+1] * r
        pos.x = -(1.5*(u-v) + 0.5) * RR;
        pos.y = -(v + u - 2.*NN + 1.) * rr;
    }
    if(placement == 6) {
        //x = [1.5*(v-u)+0.5] * R
        //y = [v+u-2*N+1] * r
        pos.x = (1.5*(v-u)+0.5)*RR;
        pos.y = (v+u-2.*NN+1.)*rr;
    }
    if(placement == 7) {
        //x = [1.5*(v-N)+1] * R
        //y = [2*u-v-N] * r
        pos.x = (1.5*(v-NN)+1.)*RR;
        pos.y = (2.*u-v-NN)*rr;
    }
   return pos;
}
@end
