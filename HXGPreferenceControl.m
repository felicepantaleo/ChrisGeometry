//
//  HXGPreferenceControl.m
//  Hex
//
//  Created by seez on 28/04/16.
//  Copyright (c) 2016 seez. All rights reserved.
//

#import "HXGPreferenceControl.h"

NSString * const HXGNewPreferecesNotification = @"HXGNewPreferences";

NSString * const prefFile = @"/hex.prefs";
const unsigned long plen = 168;

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
    
    self.hexDirectory = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/Hex"];
    //NSLog(@"The directory is %@",self.hexDirectory);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm changeCurrentDirectoryPath:self.hexDirectory]) {
        // --- It is not there!
        
        if([fm createDirectoryAtPath:self.hexDirectory withIntermediateDirectories:NO attributes:nil error:nil]) {
            Verbosity(@"Created %@",self.hexDirectory);
        } else {
            // The failure state: do an Alert "Working without disk access"
            Verbosity(@"***** DIRECTORY ACCESS FAILURE *****");
            return nil;
        }
    }
    
    prefdat = [NSMutableData dataWithLength:plen];
    hexcols = [NSMutableArray array];
    
    path = [self.hexDirectory stringByAppendingString:prefFile];
    
    if(![self readPrefs])
    {
        [self setDefaultValues];
        [self writePrefs];
        NSLog(@"New preference file created");
    }
    else
    {
        double rgba[4];
        for(int i=0; i<4; i++)
        {
            [prefdat getBytes:&rgba range:NSMakeRange(40+i*32,32)];
            NSColor * col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
            [hexcols addObject:col];
        }
    }
    
    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    theWells = [NSArray arrayWithObjects:_colw0,_colw1,_colw2,_colw3,nil];

    for(int i=0; i<4; i++) {
        NSColor * col = [hexcols objectAtIndex:i];
        [[theWells objectAtIndex:i] setColor:col];
    }
    
    
}

- (IBAction) showWindow: (id) sender
{
    changed = NO;
    [super showWindow:self];
    [self setControls];
    //[[_sixftof window] makeFirstResponder:nil];
    [[_eightftof window] makeFirstResponder:nil];
    //[[_cassetteValue window] makeFirstResponder:nil];
}

- (IBAction)newcolor:(id)sender {
    changed = YES;
}

- (IBAction)newvalue:(id)sender {
    
    double defaultValue[3] = {123.7,164.9, 10.0};
    double upperlimit[3] = {130.0, 170.0, 35.0};
    double lowerlimit[3] = {115.0,150.0, 2.0};

    int itag = (int) [sender tag];
    double value = [sender doubleValue];
    if( value > upperlimit[itag] || value < lowerlimit[itag])
    {
        [sender setDoubleValue:defaultValue[itag]];
    }
    changed = YES;
}

- (IBAction)revertToFactory:(id)sender
{
    [self setDefaultValues];
    [self setControls];
    
    changed = YES;
}

- (IBAction)ok:(id)sender
{
    
    [self close];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if(changed)
    {
        double rgba[4];
        for (int i=0; i<4; i++)
        {
            NSColorWell * cw = [theWells objectAtIndex:i];
            NSColor * col = cw.color;
            [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
            [prefdat replaceBytesInRange:NSMakeRange(40+i*32,32) withBytes:&rgba];
            [hexcols removeObjectAtIndex:i];
            col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
            [hexcols insertObject:col atIndex:i];
        }
        
        [self unloadControls];
        [self writePrefs];
        [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewPreferecesNotification object:self];

    }
}

- (NSArray *) getColors
{
    return hexcols;
}

- (BOOL) writePrefs
{
    
    float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
    [prefdat replaceBytesInRange:NSMakeRange(0,4) withBytes:&version];
    [prefdat replaceBytesInRange:NSMakeRange(4,4) withBytes:&_flags];
    [prefdat replaceBytesInRange:NSMakeRange(16,8) withBytes:&_ftof8];
    [prefdat replaceBytesInRange:NSMakeRange(24,8) withBytes:&_spare2];
    [prefdat replaceBytesInRange:NSMakeRange(32,8) withBytes:&_spare];

    double rgba[4];
    for (int i=0; i<4; i++)
    {
        NSColor * col = [hexcols objectAtIndex:i];
        [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
        [prefdat replaceBytesInRange:NSMakeRange(40+i*32,32) withBytes:&rgba];
    }

    if(![prefdat writeToFile:path atomically:NO])
    {
        NSLog(@"Write failure!");
        return NO;
    }
    
    changed = NO;

    return YES;
}

- (BOOL) readPrefs
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data)
    {
        Verbosity(@"**** Read failure **** for path %@",path);
        return NO;
    }
    if(!(data.length == plen))
    {
        NSLog(@"***** ERROR ***** Read %ld bytes in file %@",data.length,path);
        return NO;
    }
    
    
    [prefdat setData:data];
    float version;
    [prefdat getBytes:&version range:NSMakeRange(0,4)]; // unload the stuff here
                                                        // can do a version check here
    
    if(version < 3.0) return NO;

    [prefdat getBytes:&_flags range:NSMakeRange(4,4)];
    [prefdat getBytes:&_ftof8 range:NSMakeRange(16,8)];
    [prefdat getBytes:&_spare2 range:NSMakeRange(24,8)];
    [prefdat getBytes:&_spare range:NSMakeRange(32,8)];
    
    if(version < 1.809)
    {
        _flags = 3;
        //_cassettegap = 4.0;
        NSLog(@"Setting flags to 3, and cassettegap to 4.0");
    }
    
    double rgba[4];
    for (int i=0; i<4; i++)
    {
        [prefdat getBytes:&rgba range:NSMakeRange(40+i*32,32)];
        //NSLog(@"rgba[0]=%.2f; rgba[1]=%.2f; rgba[2]=%.2f; rgba[3]=%.2f;",rgba[0],rgba[1],rgba[2],rgba[3]);
        NSColor * col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];        
        [[theWells objectAtIndex:i] setColor:col];
    }
    
       
    return YES;
}

- (void) setControls {
 
    [_eightftof setDoubleValue:_ftof8];

    for(int i=0; i<4; i++) [[theWells objectAtIndex:i] setColor:[hexcols objectAtIndex:i]];
}

- (void) unloadControls {
    
    _flags = 0;
    _ftof8 = [_eightftof doubleValue];
    
}


- (void) setDefaultValues
{
    [hexcols removeAllObjects];
    double rgba[4];
    
    rgba[0]=0.25; rgba[1]=0.22; rgba[2]=0.86; rgba[3]=1.00;
    NSColor * col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
    [hexcols addObject:col];

    rgba[0]=0.24; rgba[1]=0.52; rgba[2]=0.85; rgba[3]=1.00;
    col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
    [hexcols addObject:col];
    
    rgba[0]=0.74; rgba[1]=0.12; rgba[2]=0.13; rgba[3]=1.00;
    col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
    [hexcols addObject:col];
    

    rgba[0]=0.33; rgba[1]=0.82; rgba[2]=0.40; rgba[3]=1.00;
    col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
    [hexcols addObject:col];
    
    _ftof8 = 167.441;
    _spare2 = 0.0;
    _spare = 0.0;
    _flags = 3;
    
    changed = YES;
    
}


@end
