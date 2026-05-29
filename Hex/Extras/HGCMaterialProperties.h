//
//  HGCMaterialProperties.h
//
//  Created by Chris Seez on 21/05/2018.
//  Adapted/revised/renamed 30/08/2024
//  Copyright © 2018 Chris Seez. All rights reserved.
//

#import "CSColours.h"
#import "HGCTerminalControl.h"
#import <Cocoa/Cocoa.h>

@interface HGCMaterialProperties : NSWindowController {
    
    HGCTerminalControl * theTerminal;

    NSMutableArray * material;
    NSMutableArray * X0;
    NSMutableArray * lambda;
    NSMutableArray * dEdx;
    NSMutableArray * rho;
    NSMutableArray * cmsswname;

    NSString * textstring;
    NSColor * indigoColor;
    NSColor * ivoryColor;

}

@property (assign) IBOutlet NSTextView * textview;

+ (id) sharedMaterials;

- (double) x0For:(NSString *) mat;

- (double) lambdaFor:(NSString *) mat;

- (double) dEdxFor:(NSString *) mat;

- (double) rhoFor:(NSString *) mat;

- (void) showMaterials;

@end
