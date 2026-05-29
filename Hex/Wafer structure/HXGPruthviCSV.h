//
//  HXGPruthviCSV.h
//  Hex
//
//  Created by Chris Seez on 26/11/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXGPruthviCSV : NSObject {
    
    NSArray * lines;
    NSArray * columns;
    
    int iLine;
    
}

@property (readonly) NSString * csvFile;
@property (readonly) int nLines;

//ctype,cpos,lay,wu,wv,cu,cv,cox,coy
@property (readonly) int ctype;
@property (readonly) int cpos;
@property (readonly) int layer;
@property (readonly) int wiu;
@property (readonly) int wiv;
@property (readonly) int ciu;
@property (readonly) int civ;
@property (readonly) double cellx;
@property (readonly) double celly;


+ (id) sharedPruthviCSV;

- (void) readCSVfile: (NSString *) fullPath;

- (BOOL) setCurrentLine: (int) i;

@end

NS_ASSUME_NONNULL_END
