//
//  HXGExamineVolumes.h
//  Hex
//
//  Created by Chris Seez on 16/09/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HGCTerminalControl.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGExamineVolumes : NSObject {
    
    HGCTerminalControl * theTerminal;
    NSString * filepath;
    NSArray * trackVolumes[20];
    double Z0;
}

+ (id) sharedVolumes;

//- (void) loadFile: (NSWindow *) mainwindow;

- (void) loadFileAndDoIt: (NSWindow *) mainwindow;

//- (void) dEdxOnePass;

//- (void) readFileAndAnalyse;

//- (void) readVolumesFile;

//- (void) analyseVolumes;
//- (void) analyseVolumesNew;

- (void) birthdayNonsense;
@end

NS_ASSUME_NONNULL_END
