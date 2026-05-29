//
//  HXGPruthviCSV.m
//  Hex
//
//  Created by Chris Seez on 26/11/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGPruthviCSV.h"

@implementation HXGPruthviCSV

+ (id) sharedPruthviCSV {
    
    static dispatch_once_t pred;
    static HXGPruthviCSV * theCSV = nil;
    
    dispatch_once(&pred, ^{ theCSV = [[self alloc] init]; });
    return theCSV;
    
}

- (id)init {
  
    self = [super init];
    
    lines = [NSArray array];
    _nLines = 0;
    _csvFile = @"*No file chosen*";

/* -------------------------------------------------------

 NSString * file = @"pruthviCells";
 NSString * fullPath = [[NSBundle mainBundle] pathForResource:file ofType:@"csv"];

----------------------------------------------------------------------------------- */
    return self;
}

- (void) readCSVfile: (NSString *) fullPath {
    
    _csvFile = fullPath;
    NSError * err = nil;

    NSString * fileContents = [NSString stringWithContentsOfFile:_csvFile
                                                        encoding:NSUTF8StringEncoding error:&err];
    if(err) {
        lines = [NSArray array];
        _nLines = 0;
        [self csvAlert:[NSString stringWithFormat:@"Read error for file: <%@>\n%@",_csvFile.lastPathComponent,err.localizedFailureReason] andInfo:@"Probably not a csv file!"];
        return;
    }
    lines = [fileContents componentsSeparatedByCharactersInSet:
             [NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    _nLines = (int) lines.count - 1;
    
}

- (BOOL) setCurrentLine: (int) i {
    
    if(i < _nLines) {
        columns = [lines[i+1] componentsSeparatedByCharactersInSet:
                   [NSCharacterSet characterSetWithCharactersInString:@","]];
    } else return NO;
  
    if(columns.count != 9) return NO;
    
    _ctype = [columns[0] intValue];
    _cpos  = [columns[1] intValue];
    _layer = [columns[2] intValue];
    _wiu   = [columns[3] intValue];
    _wiv   = [columns[4] intValue];
    _ciu   = [columns[5] intValue];
    _civ   = [columns[6] intValue];
    _cellx = [columns[7] doubleValue];
    _celly = [columns[8] doubleValue];

    return YES;
}

- (void) csvAlert: (NSString *) message andInfo: (NSString *) info {
  
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setInformativeText:info];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];

}

@end
