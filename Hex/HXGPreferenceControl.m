//
//  HXGPreferenceControl.m
//  Hex
//
//  Created by seez on 28/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGPreferenceControl.h"

NSString * const HXGNewPreferencesNotification = @"HXGNewPreferences";

NSString * const prefFile = @"/hex.prefs";
const unsigned long plen = 416;

@implementation HXGPreferenceControl

+ (id) sharedPreferences
{
    static dispatch_once_t pred;
    static HXGPreferenceControl * thePreferences = nil;
    
    dispatch_once(&pred, ^{ thePreferences = [[self alloc] init]; });
    return thePreferences;
}

- (id)init
{
    self=[super initWithWindowNibName: @"HXGPreferenceControl"];
    
    self.hexDirectory = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:hexHome];
    //NSLog(@"The directory is %@",self.hexDirectory);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm changeCurrentDirectoryPath:self.hexDirectory]) {
        // --- It is not there!
        
        if([fm createDirectoryAtPath:self.hexDirectory withIntermediateDirectories:NO attributes:nil error:nil]) {
            Verbosity(@"Created %@",self.hexDirectory);
            _buildNewStructure = YES;
        } else {
            // The failure state: do an Alert "Working without disk access"
            Verbosity(@"***** DIRECTORY ACCESS FAILURE *****");
            return nil;
        }
    }
    
    prefdat = [NSMutableData dataWithLength:plen];
    hexcols = [NSMutableArray array];
    
    path = [self.hexDirectory stringByAppendingString:prefFile];
    
    if(![self readPrefs]) {
        [self setDefaultValues];
        [self writePrefs];
        [self simpleAlert:@"New preference file created"];
    }
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(newColourChoice:)
               name:HXGNewColourNotification
             object:nil];

    
    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    theWells = [NSArray arrayWithObjects:_colw0,_colw1,_colw2,_colw3,_colw4,_colw5,nil];

    for(int i=0; i<6; i++) {
        NSColor * col = [hexcols objectAtIndex:i];
        [[theWells objectAtIndex:i] setColor:col];
    }
    
}

- (void) orderBack:(id) sender {
    
    [self.window orderBack:sender];
    
}

- (IBAction) showWindow: (id) sender {
    
    changed = NO;
    [super showWindow:self];
    [self setControls];
    
}

- (IBAction)newcolor:(id)sender {
    
    changed = YES;
    double rgba[4];
    for (int i=0; i<6; i++) {
        NSColorWell * cw = [theWells objectAtIndex:i];
        NSColor * col = cw.color;
        [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
        [prefdat replaceBytesInRange:NSMakeRange(32+i*32,32) withBytes:&rgba];
        [hexcols removeObjectAtIndex:i];
        col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
        [hexcols insertObject:col atIndex:i];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferencesNotification object:self];

}


- (IBAction)newOpacity:(id)sender {
    
    _casAlpha = 0.3 + [sender doubleValue]*0.1;
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferencesNotification object:self];

    changed = YES;

}

- (IBAction)newBackground:(id)sender {
    
    _flags = (int) [sender tag];
    [_plainButton setState:    _flags == 0];
    [_semiTransparentButton setState: _flags == 1];
    [_starsButton setState:    _flags == 2];
    [_reptilesButton setState: _flags == 3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferencesNotification object:self];

    changed = YES;

}

- (IBAction)revertToFactory:(id)sender
{
    [self setDefaultValues];
    [self setControls];
    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferencesNotification object:self];

    changed = YES;
}

- (IBAction)ok:(id)sender {
    
    [[NSColorPanel sharedColorPanel] close];
    [self close];
}

- (void) newColourChoice:(NSNotification *) note {
    
    NSColor * newColor = [[note userInfo] objectForKey:@"newColor"];
    int icol = [[[note userInfo] objectForKey:@"colPoint"] intValue];
    unsigned long hPoint = icol+6;

    [hexcols replaceObjectAtIndex:hPoint withObject:newColor];
    
    [self writePrefs];
}


- (void)windowWillClose:(NSNotification *)notification {
 
    if(changed) {
        double rgba[4];
        for (int i=0; i<6; i++) {
            NSColorWell * cw = [theWells objectAtIndex:i];
            NSColor * col = cw.color;
            [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
            [prefdat replaceBytesInRange:NSMakeRange(32+i*32,32) withBytes:&rgba];
            [hexcols removeObjectAtIndex:i];
            col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
            [hexcols insertObject:col atIndex:i];
        }
        
        [self unloadControls];
        [self writePrefs];
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferencesNotification object:self];

    }
}

- (NSArray *) getColors {
    
    return hexcols;
    
}

- (void) writePrefs
{
    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    [prefdat replaceBytesInRange:NSMakeRange(0,4) withBytes:&version];
    [prefdat replaceBytesInRange:NSMakeRange(4,4) withBytes:&_flags];
    //[prefdat replaceBytesInRange:NSMakeRange(16,8) withBytes:&_ftof8];
    [prefdat replaceBytesInRange:NSMakeRange(24,8) withBytes:&_casAlpha];

    double rgba[4];
    for (int i=0; i<12; i++) {
        NSColor * col = [hexcols objectAtIndex:i];
        [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
        [prefdat replaceBytesInRange:NSMakeRange(32+i*32,32) withBytes:&rgba];
    }

    if(![prefdat writeToFile:path atomically:NO]) {
        NSLog(@"Write failure!");
        return;
    }
    
    changed = NO;

}

- (BOOL) readPrefs
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data) {
        [self simpleAlert:[NSString stringWithFormat:@"Preference file not found\n%@",path]];
        return NO;
    }
    if(!(data.length == plen)) {
        NSLog(@"***** ERROR ***** Read %ld bytes in file %@",data.length,path);
        return NO;
    }
    
    
    [prefdat setData:data];
    float version;
    [prefdat getBytes:&version range:NSMakeRange(0,4)]; // unload the stuff here
                                                        // can do a version check here
    if(version < 15.0) {
        NSString * dir = path.stringByDeletingLastPathComponent;
        NSString * message = [NSString stringWithFormat:@"There is a directory structure from an obsolete version of Hex at: %@; it must be deleted before proceeding with this version",dir];
        [self simpleAlert:message];
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.2];
    }

    [prefdat getBytes:&_flags range:NSMakeRange(4,4)];
    //[prefdat getBytes:&_ftof8 range:NSMakeRange(16,8)];
    [prefdat getBytes:&_casAlpha range:NSMakeRange(24,8)];

    [hexcols removeAllObjects];

    double rgba[4];
    for (int i=0; i<12; i++) {
        [prefdat getBytes:&rgba range:NSMakeRange(32+i*32,32)];
        //NSLog(@"rgba[0]=%.2f; rgba[1]=%.2f; rgba[2]=%.2f; rgba[3]=%.2f;",rgba[0],rgba[1],rgba[2],rgba[3]);
        NSColor * col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
        if(i < 6) [[theWells objectAtIndex:i] setColor:col];
        [hexcols addObject:col];
    }
    
    _waferHighLightColor = hexcols[6];
    _zoneColor1 = hexcols[7];
    _zoneColor2 = hexcols[8];
    _zoneColor3 = hexcols[9];
    _zoneColor4 = hexcols[10];
    _zoneColor5 = hexcols[11];

    return YES;
}

- (void) setControls {
 
    //[_eightftof setDoubleValue:_ftof8];
    [_alphaSlide setDoubleValue:10.*(_casAlpha-0.3)];

    for(int i=0; i<6; i++) [[theWells objectAtIndex:i] setColor:[hexcols objectAtIndex:i]];
    
    [_plainButton setState:    _flags == 0];
    [_semiTransparentButton setState: _flags == 1];
    [_starsButton setState:    _flags == 2];
    [_reptilesButton setState: _flags == 3];

}

- (void) unloadControls {
    
    
}


- (void) setDefaultValues {
    
    [hexcols removeAllObjects];
    
    NSColor * col = [NSColor strawberryRed];
    [hexcols addObject:col];

    col = [NSColor paleViolet];
    [hexcols addObject:col];
    
    col = [NSColor sageGreen];
    [hexcols addObject:col];

    col = [NSColor greyBlue];
    [hexcols addObject:col];

    col = [NSColor paleCream];
    [hexcols addObject:col];

    col = [NSColor driedBlood];
    [hexcols addObject:col];
    
    _waferHighLightColor = [NSColor yellowColor];
    [hexcols addObject:_waferHighLightColor];
    
    _zoneColor1 = [[NSColor wildViolet] colorWithAlphaComponent:0.3];
    [hexcols addObject:_zoneColor1];
    
    _zoneColor2 = [[NSColor strawberryRed] colorWithAlphaComponent:0.3];
    [hexcols addObject:_zoneColor2];
    
    _zoneColor3 = [[NSColor sageGreen] colorWithAlphaComponent:0.3];
    [hexcols addObject:_zoneColor3];
    
    _zoneColor4 = [[NSColor indigoBlue] colorWithAlphaComponent:0.3];
    [hexcols addObject:_zoneColor4];
    
    _zoneColor5 = [[NSColor yellowColor] colorWithAlphaComponent:0.3];
    [hexcols addObject:_zoneColor5];
    
    _casAlpha = 0.5;

    _flags = 2;
 
    changed = YES;
    
}

- (void) simpleAlert: (NSString *) message {
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:message];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setShowsSuppressionButton:NO];
    if ([alert runModal] != NSAlertFirstButtonReturn) {
    }

}


@end
