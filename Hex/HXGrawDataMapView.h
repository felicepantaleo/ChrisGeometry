//
//  HXGrawDataMapView.h
//  Hex
//
//  Created by Chris Seez on 22/04/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "CSColours.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGrawDataMapView : NSView {
    
    NSMutableDictionary * titleText;
    NSMutableDictionary * headerText;
    NSMutableDictionary * standardText;
    NSMutableDictionary * pdfText;

    double blen[5];
    double xleft;
    
    NSString * rocPinName[2][37];

}

@property int halfroc;
@property BOOL dense;
@property int * rocPin;
@property int * siCell;
@property int * iu;
@property int * iv;
@property int * tlink;
@property int * tcell;
@property BOOL * calib;
@property NSString * calibName;
@property BOOL * unconnected;
@property BOOL * split;
@property BOOL partial;
@property NSString * partialName;
@property BOOL pdf;


- (void) setUpFormats;
- (NSString *) rocPinNameForHroc: (int) hroc andChan: (int) ch;
- (void) savePDF:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
