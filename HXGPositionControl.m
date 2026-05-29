//
//  HXGPositionControl.m
//  Hex
//
//  Created by Chris Seez on 14/04/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "HXGPositionControl.h"

NSString * const HXGNewPositionNotification = @"HXGNewPosition";

@interface HXGPositionControl ()

@end

@implementation HXGPositionControl

+ (id) sharedPositionControl {
    
    static dispatch_once_t pred;
    static HXGPositionControl * thePosition = nil;
    
    dispatch_once(&pred, ^{ thePosition = [[self alloc] init]; });
    return thePosition;

}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGPositionControl"];
    
    _eta = 1.5;
    _phi = 60.;
    _showposition = YES;
    
    return self;
}


- (void) windowDidLoad {
    [super windowDidLoad];
    
    [_showButton setState:_showposition];
    [_etastring setStringValue:[NSString stringWithFormat:@"%.3f",_eta]];
    [_phistring setStringValue:[NSString stringWithFormat:@"%.1f",_phi]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    _showposition = [_showButton state];
    _eta = [_etastring doubleValue];
    _eta = MAX(_eta,1.4);
    _eta = MIN(_eta,3.2);
    _phi = [_phistring doubleValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPositionNotification object:self];

}

- (void) notify {
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPositionNotification object:self];
}

- (void) setState:(BOOL)on eta:(double)e phi:(double)p {
    _showposition = on;
    _eta = e;
    _phi = p;
    [_showButton setState:_showposition];
    [_etastring setStringValue:[NSString stringWithFormat:@"%.3f",_eta]];
    [_phistring setStringValue:[NSString stringWithFormat:@"%.1f",_phi]];
}


- (IBAction) changeState:(id)sender {
    _showposition = [_showButton state];
    _eta = [_etastring doubleValue];
    _eta = MAX(_eta,1.4);
    _eta = MIN(_eta,3.2);
    [_etastring setStringValue:[NSString stringWithFormat:@"%.4f",_eta]];
    _phi = [_phistring doubleValue];
}

- (IBAction)ok:(id)sender {
    [self close];
}

@end
