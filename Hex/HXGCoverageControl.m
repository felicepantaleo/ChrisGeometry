//
//  HXGCoverageControl.m
//  Hex
//
//  Created by Chris Seez on 21/01/2025.
//  Copyright © 2025 seez. All rights reserved.
//

#import "HXGCoverageControl.h"

@interface HXGCoverageControl ()

@end


NSString * const HXGCoverageStudyNotification = @"HXGCoverageStudy";

@implementation HXGCoverageControl

+ (id) sharedCoverageControl {
    
    static dispatch_once_t pred;
    static HXGCoverageControl * theCoverage = nil;
    
    dispatch_once(&pred, ^{ theCoverage = [[self alloc] init]; });
    return theCoverage;

}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGCoverageControl"];
    
    _first = 1;
    _last = 26;
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_firststring setStringValue:[NSString stringWithFormat:@"%d",_first]];
    [_laststring setStringValue:[NSString stringWithFormat:@"%d",_last]];

    
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}

- (IBAction) changeValue:(id)sender {
    
    if([sender tag] == 0) {
        _first = [sender intValue];
        if(_first > _last) _last = _first;
    } else {
        _last = [sender intValue];
        if(_last < _first) _first = _last;
    }
    
    [_firststepper setIntValue:_first];
    [_laststepper setIntValue:_last];
    
    [_firststring setStringValue:[NSString stringWithFormat:@"%d",_first]];
    [_laststring setStringValue:[NSString stringWithFormat:@"%d",_last]];

}

- (IBAction) closeDialogue:(id)sender {
    
    if([sender tag] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGCoverageStudyNotification object:nil];
    }
    
    [self.window close];
    
}


@end
