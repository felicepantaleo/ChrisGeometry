//
//  HXGScanControl.m
//  Hex
//
//  Created by Chris Seez on 19/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGScanControl.h"

@interface HXGScanControl ()

@end

NSString * const HXGStartScanNotification = @"HXGStartScan";

@implementation HXGScanControl

+ (id) sharedScanControl {
    
    static dispatch_once_t pred;
    static HXGScanControl * theScan = nil;
    
    dispatch_once(&pred, ^{ theScan = [[self alloc] init]; });
    
    return theScan;
    
}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGScanControl"];
    
    nlayers = 36;
    removePb = NO;
    trimCEH = NO;
    CEHtrim = 0.0;

    return self;
}

- (void) initializeScanTypeOuter:(BOOL) outer {

    outerscan = outer;
    
    if(outerscan) {
        self.window.title = @"Outer boundary scan";
        nlayers = 37;
    } else {
        nlayers = 40.;
        self.window.title = @"Inner boundary scan";
    }
    [_layerstepper setMaxValue:52.];
    
    [_layerslabel setStringValue:[NSString stringWithFormat:@"Number of layers to scan: %d",nlayers]];
    [_layerstepper setIntegerValue:nlayers];
    [_Pbbutton setState:removePb];
    [_CEHbutton setState:trimCEH];
    [_CEHlabel setStringValue:[NSString stringWithFormat:@"mm of CE-H Fe to trim: %.0f",CEHtrim]];
    [_CEHstepper setDoubleValue:CEHtrim];
    radiationLengths = YES;
    [_X0button setState:radiationLengths];
    [_Lambutton setState:!radiationLengths];
    
    NSMutableAttributedString * strX0 = [[NSMutableAttributedString alloc] initWithString:@"X0"];
    [strX0 addAttribute:NSFontAttributeName
                  value:[NSFont systemFontOfSize:13]
                  range:NSMakeRange(0,2)];
    [strX0 setAlignment:+1 range:NSMakeRange(0,2)];
    [strX0 addAttribute:NSSuperscriptAttributeName
                  value:[NSNumber numberWithInt:-1]
                  range:NSMakeRange(1,1)];
    [_X0button setAttributedTitle:strX0];
    
    //NSAccessibilityTextAlignmentAttribute
    
    NSMutableAttributedString * strLam = [[NSMutableAttributedString alloc] initWithString:@"λint"];
    [strLam addAttribute:NSFontAttributeName
                   value:[NSFont systemFontOfSize:13]
                   range:NSMakeRange(0,4)];
    [strLam setAlignment:+1 range:NSMakeRange(0,4)];
    [strLam addAttribute:NSSuperscriptAttributeName
                   value:[NSNumber numberWithInt:-1]
                   range:NSMakeRange(1,3)];
    [_Lambutton setAttributedTitle:strLam];
    

}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
}


#pragma mark - IBActions

- (IBAction) changeLayers:(id)sender {
    
    nlayers = (int) [_layerstepper integerValue];
    [_layerslabel setStringValue:[NSString stringWithFormat:@"Number of layers to scan: %d",nlayers]];

}

- (IBAction) changeThickUnit:(id)sender {
    BOOL wasX0 = [sender tag] == 1;
    radiationLengths = [sender state] == wasX0;
    [_X0button setState:radiationLengths];
    [_Lambutton setState:!radiationLengths];
}


- (IBAction) changeCEH:(id)sender {
    
    CEHtrim = [_CEHstepper doubleValue];
    [_CEHlabel setStringValue:[NSString stringWithFormat:@"mm of CE-H Fe to trim: %.0f",CEHtrim]];
    trimCEH = [_CEHbutton state];

}

- (IBAction) changePb:(id)sender {
    
    removePb = [_Pbbutton state];
    
}

- (IBAction) scan:(id)sender {
    
    NSMutableData * data = [NSMutableData dataWithLength:16];
    [data replaceBytesInRange:NSMakeRange(0,4) withBytes:&nlayers];
    [data replaceBytesInRange:NSMakeRange(4,1) withBytes:&radiationLengths];
    [data replaceBytesInRange:NSMakeRange(5,1) withBytes:&removePb];
    [data replaceBytesInRange:NSMakeRange(6,1) withBytes:&trimCEH];
    [data replaceBytesInRange:NSMakeRange(7,1) withBytes:&outerscan];
    [data replaceBytesInRange:NSMakeRange(8,8) withBytes:&CEHtrim];

    NSDictionary * d = [NSDictionary dictionaryWithObject:data forKey:@"scandata"];
 
    NSNotification *note = [NSNotification notificationWithName: HXGStartScanNotification object:self userInfo:d];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note postingStyle: NSPostASAP];
    
    [self close];
}

- (IBAction) cancel:(id)sender {
    
    [self close];
    
}

@end
