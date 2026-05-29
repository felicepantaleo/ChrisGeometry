//
//  HTDColorControl.m
//  from MandelbrotViewer
//
//  Created by seez on 19/05/16.
//  Copyright (c) 2016 seez. All rights reserved.
//
//
// Values for the colours are stored in cdat as RGBA each value represented as
// a double with a value between 0 and 1
//

#import "HTDColorControl.h"

NSString * const HTDNewColorsNotification = @"HTDNewColors";

NSString * const currentFile = @"/current.cdat";
const unsigned long length = 544;
const unsigned int NLOOK = 512;

struct COL {double r, g, b, a;};

@implementation HTDColorControl


#pragma mark - initialization etc
+ (id) sharedColors
{
    static dispatch_once_t pred;
    static HTDColorControl *theColors = nil;
    
    dispatch_once(&pred, ^{ theColors = [[self alloc] init]; });
    return theColors;
}

- (id)init
{
    self=[super initWithWindowNibName: @"HTDColorControl"];
    NSLog(@"ColorControl ********************************************");

    cdat = [NSMutableData dataWithLength:length];

    htdDirectory = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:hexHome];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm changeCurrentDirectoryPath:htdDirectory]) {
        // --- It is not there!
        
        if([fm createDirectoryAtPath:htdDirectory withIntermediateDirectories:NO attributes:nil error:nil]) {
            NSLog(@"Created %@",htdDirectory);
        } else {
            // The failure state: do an Alert "Working without disk access"
            NSLog(@"***** DIRECTORY ACCESS FAILURE *****");
            return nil;
        }
    }

    NSString * cpath = [htdDirectory stringByAppendingString:currentFile];
    
    if(![self readUsingPath:cpath])
    {
        [self setDefaultCoding:cdat];
        [self writeUsingPath:cpath];
        NSLog(@"New colour code file created");
    }

    [self makeLookup];
       
    changed = NO;

    return self;
}

- (void)windowDidLoad
{                          
    theWells = [NSArray arrayWithObjects:_cw0,_cw1,_cw2,_cw3,_cw4,_cw5,
                _cw6,_cw7,_cw8,_cw9,_cw10,_cw11,_cw12,_cw13,_cw14,_cw15,nil];
        
    [self loadWells];
    
    [super windowDidLoad];
}

- (void) loadWells
{
    double rgba[4];
    for(int i=0; i<16; i++)
    {
        [cdat getBytes:&rgba range:NSMakeRange(i*32,32)];
        NSColor * col = [NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
        [[theWells objectAtIndex:i] setColor:col];
        Verbosity(@"Setting %2d: RGB: %5.3f %5.3f %5.3f; aplha = %5.3f",i,rgba[0],rgba[1],rgba[2],rgba[3]);
        
    }

}

- (void)windowWillClose:(NSNotification *)notification
{
    if(changed)
    {
        [self writeCurrent];
        [self makeLookup];
        [[NSNotificationCenter defaultCenter] postNotificationName:HTDNewColorsNotification object:self];
    }
    changed = NO;
}


#pragma mark - making the lookup table


- (void) makeLookup
{
    
    int nbin = 32;
    
    struct COL c1, c2;
    double rinc = 0.;
    double ginc = 0.;
    double binc = 0.;
    
    NSMutableArray * colArr = [NSMutableArray arrayWithCapacity:NLOOK];
    
    /*
     Not bothering to modify alpha here, but not doing anything that would
     complicate later implementation (e.g. alpha component is saved in disk files
     */
    
    for (int i=0; i<16; i++)
    {
        [cdat getBytes:&c1 range:NSMakeRange(i*32,32)];
        if(i < 15)
        {
            [cdat getBytes:&c2 range:NSMakeRange((i+1)*32,32)];
        }
        else
        {
            c2.r = 0.; c2.g = 0.; c2.b = 0.;
        }
        
        rinc = (c2.r - c1.r)/(double) nbin;
        ginc = (c2.g - c1.g)/(double) nbin;
        binc = (c2.b - c1.b)/(double) nbin;
        
        for (int j=0; j<nbin; j++)
        {
            double dj = (double) j;
            double red   = c1.r +rinc*dj;
            double green = c1.g +ginc*dj;
            double blue  = c1.b +binc*dj;
            double alpha = 1.0;
            NSColor * col = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
            [colArr addObject:col];
        }
    }
    
    _colorArray = [NSArray arrayWithArray:colArr];
    
    changed = YES;
    [_fview drawColorScale];

}

#pragma mark - IBActions

- (IBAction) showWindow: (id) sender
{
    [self loadWells];
    [self makeLookup];
    
    [super showWindow:nil];
    
    [_fview drawColorScale];

}
                        //----------------- newColor
- (IBAction)newColor:(id)sender
{
    for (int i=0; i<16; i++)
    {
        NSColorWell * cw = [theWells objectAtIndex:i];
        if(cw == sender)
        {
            double rgba[4];
            NSColorWell * cw = [theWells objectAtIndex:i];
            NSColor * col = cw.color;
            [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
            [cdat replaceBytesInRange:NSMakeRange(i*32,32) withBytes:&rgba];
            [self makeLookup];
            [_fview drawColorScale];
        }
    } 
    changed = YES;
}

- (IBAction)ok:(id)sender
{        //--------------------------------------- OK
    [self close];
}

- (IBAction)setToDefault:(id)sender
{                                    //----------------------------------------- setToDefault
    [self setDefaultCoding:cdat];
    [self makeLookup];
    [self loadWells];
    [_fview drawColorScale];
    changed = YES;
}

#pragma mark - defaults and persistancy
- (void) setDefaultCoding: (NSMutableData *) data
{
    /* double h = 0.7, s=1.0, b=0.6, a=1.;
    double binc=(1.0-b)/16., sinc=-s/20., hinc=-1./10.; */ //----- Old default

    double h = 0.7, s=1.0, b=0.3, a=1.;
    double binc=(1.0-b)/16., sinc=-s/16., hinc=1./16.;
    
    double rgba[4];
    
    for(int i=0; i<16; i++) {
        int j = 15-i;
        NSColor * col = [NSColor colorWithCalibratedHue:h saturation:s brightness:b alpha:a];
        [col getRed:&rgba[0] green:&rgba[1] blue:&rgba[2] alpha:&rgba[3]];
        [[theWells objectAtIndex:j] setColor:col];
        [data replaceBytesInRange:NSMakeRange(j*32,32) withBytes:&rgba];
        h+=hinc;
        if(h > 1.) h=h-1.;
        if(h < 0.) h=1.+h;
        s+=sinc;
        b+=binc;
    }
                
    // Add black at the end
    rgba[0]=0.; rgba[1]=0.; rgba[2]=0.; rgba[3]=1.;
    [data replaceBytesInRange:NSMakeRange(512,32) withBytes:&rgba];
}

- (void) writeCurrent
{                                       //--------- writeCurrent - writes cdat data to current file
    NSString * path = [htdDirectory stringByAppendingString:currentFile];
    [self writeUsingPath:path];
}

- (BOOL) writeUsingPath: (NSString*) path
{                                   //------------------------------ writeUsingPath
     
    if(![cdat writeToFile:path atomically:NO])
    {
        NSLog(@"Write failure!");
        return NO;
    }
    
    return YES;
}

- (BOOL) readUsingPath: (NSString*) path
{                                          //------------------------------ readUsingPath
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data)
    {
        Verbosity(@"**** Read failure **** for path %@",path);
        return NO;
    }
    if(!(data.length == length))
    {
        NSLog(@"***** ERROR ***** Read %ld bytes in file %@",data.length,path);
        return NO;
    }
    
    [cdat setData:data];
    
    
    return YES;
}

@end
