//
//  HXGDisplayAbsorbersControl.m
//  Hex
//
//  Created by Chris Seez on 07/11/2024.
//  Copyright © 2024 seez. All rights reserved.
//

#import "HXGDisplayAbsorbersControl.h"

@interface HXGDisplayAbsorbersControl ()

@end


NSString * const HXGNewAbsorberDisplayNotification = @"HXGNewAbsorberDisplay";


@implementation HXGDisplayAbsorbersControl

+ (id) sharedAbsorberControl {
    
    static dispatch_once_t pred;
    static HXGDisplayAbsorbersControl * theAbsorbers = nil;
    
    dispatch_once(&pred, ^{theAbsorbers = [[self alloc] init]; });
    return theAbsorbers;
    
}

- (id)init {
    
    self = [super initWithWindowNibName: @"HXGDisplayAbsorbersControl"];
         
    return self;
}

- (void) windowDidLoad {
    
    [super windowDidLoad];
    
    [_showCEEPbButton setState:showCEEPb];
    [_showCEECuButton setState:showCEECu];
    [_showZbarsButton setState:showZbars];
    
    NSRect wRect;                                // Here we define the window
    double width = 238.; double height = 356.;
    wRect.origin = NSMakePoint([[NSScreen mainScreen] frame].size.width-width,[[NSScreen mainScreen] frame].size.height-height-466.);
    wRect.size = NSMakeSize(width,height);
    [[self window] setFrameOrigin:NSZeroPoint];
    [[self window] setFrame:wRect display:YES];

}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];

    NSColor * veryFaded = [[NSColor sageGreen] blendedColorWithFraction:0.4 ofColor:[NSColor whiteColor]];
    //veryFaded = [veryFaded colorWithAlphaComponent:0.85];
    [self.window setBackgroundColor:veryFaded];
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}


- (IBAction) changeDisplay:(id)sender {

    int addAlpha = 0;

    if([sender tag] == 0 ) {
        flags = 0;
        
        showCEHSpacers = [_showSpacersButton state];
        showCEEPb = [_showCEEPbButton state];
        showCEECu = [_showCEECuButton state];
        showZbars = [_showZbarsButton state];

        if(showCEEPb) flags += 1;
        if(showCEECu) flags += 2;
        if(showCEHSpacers) flags += 4;
        if(showZbars) flags += 8;
        
        addAlpha = [_oddAlphaSlide intValue];
        flags += addAlpha << 18;
    }
    if([sender tag] == 1 ) {
        flags += 2 << 20;
    } else if([sender tag] == 2 ) {
        flags += 2 << 21;
    }


    
    
    NSNumber * controlFlags = [NSNumber numberWithInteger:flags];
    NSDictionary * d = [NSDictionary dictionaryWithObject:controlFlags forKey:@"controlFlags"];
    
    NSNotification * note = [NSNotification notificationWithName: HXGNewAbsorberDisplayNotification object:self userInfo:d];
    NSArray *modes = [NSArray arrayWithObject: NSEventTrackingRunLoopMode];
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostNow
                                               coalesceMask: NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender
                                                   forModes: modes];

    if([sender tag] == 1 ) {
        flags -= 2 << 20;
    } else if([sender tag] == 2 ) {
        flags -= 2 << 21;
    }


}

@end
