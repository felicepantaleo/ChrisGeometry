//
//  CSColours.m
//  Hex
//
//  Created by Chris Seez on 15/06/2018.
//  Copyright © 2018 seez. All rights reserved.
//

#import "CSColours.h"

@implementation NSColor (CSColours)

// titaniumWhite solves the problem of [NSColor whiteColor] being in some weird
// colorSpace (greyscale space?) such that unpacking the RGBA components becomes problematic
+ (NSColor *) titaniumWhite {
    return [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}
+ (NSColor *) paleCream {
    return [NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.86 alpha:1.0];
}
+ (NSColor *) ivoryWhite {
    return [NSColor colorWithCalibratedRed:0.93 green:0.95 blue:0.79 alpha:1.0];
}
+ (NSColor *) coolGrey {
    return [NSColor colorWithCalibratedRed:0.50 green:0.50 blue:0.50 alpha:1.0];
}
+ (NSColor *) paleGrey {
    return [NSColor colorWithCalibratedRed:0.70 green:0.70 blue:0.70 alpha:1.0];
}
+ (NSColor *) fadedBlue {
    return [NSColor colorWithCalibratedRed:0.80 green:0.90 blue:1.00 alpha:1.0];
}
+ (NSColor *) paleBlue {
    return [NSColor colorWithCalibratedRed:0.62 green:0.75 blue:0.89 alpha:1.0];
}
+ (NSColor *) pastelBlue {
    return [NSColor colorWithCalibratedRed:0.28 green:0.65 blue:1.0 alpha:1.0];
}
+ (NSColor *) greyBlue {
    return [NSColor colorWithCalibratedRed:0.613 green:0.724 blue:0.814 alpha:1.0];
}
+ (NSColor *) indigoBlue {
    return [NSColor colorWithCalibratedRed:0.10 green:0.10 blue:0.45 alpha:1.0];
}
+ (NSColor *) purpleHaze {
    return [NSColor colorWithCalibratedRed:0.75 green:0.00 blue:1.00 alpha:1.0];
}
+ (NSColor *) paleViolet {
    return [NSColor colorWithCalibratedRed:0.85 green:0.60 blue:0.80 alpha:1.0];
}
+ (NSColor *) wildViolet {
    return [NSColor colorWithCalibratedRed:0.50 green:0.16 blue:0.89 alpha:1.0];
}
+ (NSColor *) tameViolet {
    return [NSColor colorWithCalibratedRed:0.84 green:0.72 blue:0.93 alpha:1.0];
}
+ (NSColor *) grassGreen {
    return [NSColor colorWithCalibratedRed:0.40 green:0.70 blue:0.25 alpha:1.0];
}
+ (NSColor *) seaGreen {
    return [NSColor colorWithCalibratedRed:0.12 green:0.52 blue:0.42 alpha:1.0];
}
+ (NSColor *) sageGreen {
    return [NSColor colorWithCalibratedRed:0.63 green:0.78 blue:0.63 alpha:1.0];
}
+ (NSColor *) greyGreen {
    return [NSColor colorWithCalibratedRed:0.76 green:0.78 blue:0.76 alpha:1.0];
}
+ (NSColor *) kharkiBrown {
    return [NSColor colorWithCalibratedRed:0.70 green:0.70 blue:0.50 alpha:1.0];
}
+ (NSColor *) siliconBrown {
    return [NSColor colorWithCalibratedRed:0.78 green:0.60 blue:0.48 alpha:1.0];
}
+ (NSColor *) orchidPink {
    return [NSColor colorWithCalibratedRed:0.90 green:0.65 blue:0.80 alpha:1.0];
}
+ (NSColor *) driedBlood {
    return [NSColor colorWithCalibratedRed:0.72 green:0.17 blue:0.17 alpha:1.0];
}
+ (NSColor *) dullRed {
    return [NSColor colorWithCalibratedRed:0.75 green:0.55 blue:0.55 alpha:1.0];
}
+ (NSColor *) raspberryRed {
    return [NSColor colorWithCalibratedRed:0.85 green:0.50 blue:0.75 alpha:1.0];
}
+ (NSColor *) strawberryRed {
    return [NSColor colorWithCalibratedRed:1.00 green:0.45 blue:0.38 alpha:1.0];
}
+ (NSColor *) peachOrange {
    return [NSColor colorWithCalibratedRed:1.00 green:0.80 blue:0.38 alpha:1.0];
}
+ (NSColor *) palePeach {
    return [NSColor colorWithCalibratedRed:0.937 green:0.894 blue:0.800 alpha:1.0];
}

@end
