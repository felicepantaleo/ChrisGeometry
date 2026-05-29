//
//  HXGrawDataMapView.m
//  Hex
//
//  Created by Chris Seez on 22/04/2022.
//  Copyright © 2022 seez. All rights reserved.
//

#import "HXGrawDataMapView.h"

@implementation HXGrawDataMapView
- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    for(int i=0;i<37;i++) {
        int ii = i;
        if(i != 18) {
            if(i>18) ii--;
            rocPinName[0][i] = [NSString stringWithFormat:@"%8d",ii];
            rocPinName[1][i] = [NSString stringWithFormat:@"%8d",ii+36];
        } else {
            rocPinName[0][i] = @"  CALIB0";
            rocPinName[1][i] = @"  CALIB1";
        }
    }
    return self;
}

- (NSString *) rocPinNameForHroc: (int) hroc andChan: (int) ch {
    return rocPinName[hroc][ch];
}

- (void) setUpFormats {
    
    NSString * fontName = @"Helvetica";
    NSFont * font = [NSFont fontWithName:fontName size:14.];
   
    standardText =  [NSMutableDictionary
                      dictionaryWithObjectsAndKeys:
                      font,NSFontAttributeName,
                      [NSColor blackColor],NSForegroundColorAttributeName,
                      nil];
    [standardText setObject:font
                      forKey:NSFontAttributeName];
    
    headerText =  [NSMutableDictionary
                      dictionaryWithObjectsAndKeys:
                      font,NSFontAttributeName,
                      [NSColor blackColor],NSForegroundColorAttributeName,
                      nil];
    [headerText setObject:font
                      forKey:NSFontAttributeName];


    font = [NSFont fontWithName:fontName size:18.];
    titleText =  [NSMutableDictionary
                      dictionaryWithObjectsAndKeys:
                      font,NSFontAttributeName,
                      [NSColor blackColor],NSForegroundColorAttributeName,
                      nil];

    font = [NSFont fontWithName:fontName size:10.];
    pdfText =  [NSMutableDictionary
                      dictionaryWithObjectsAndKeys:
                      font,NSFontAttributeName,
                      [NSColor blackColor],NSForegroundColorAttributeName,
                      nil];

}
- (void) savePDF:(NSString *)path {
    
    NSRect pdfrect = self.frame;
    pdfrect.origin.y += 52.;
    pdfrect.size.height -= 42.;
    NSData * data = [self dataWithPDFInsideRect:pdfrect];
    [data writeToFile:path options:0 error:nil];
}

// ------------------------------------------------------------------------------
#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.bounds];
    
    [NSBezierPath setDefaultLineWidth:1.];

    xleft = 6.;
    int roc = _halfroc/2;
    int half = _halfroc%2;
    NSString * title;
    if(_partial) {
        title = _partialName;
        title = [title stringByAppendingFormat:@", ROC %1d.%1d",roc,half];
    } else {
        title = @"Low density full wafer";
        if(_dense) title = @"High density full wafer";
        title = [title stringByAppendingFormat:@", ROC %1d.%1d",roc,half];
    }
    
    double ytop = self.bounds.size.height;
    double xcentre = 0.5*self.bounds.size.width;
    ytop -= 30.;
    
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:title];
    [str addAttributes:titleText range:NSMakeRange(0,str.length)];
    [str drawAtPoint:NSMakePoint(xcentre-0.5*str.size.width,ytop)];
    
    ytop -= 42.;
    
    double bhgt;
    NSString * header[5] = {@"Readout\nsequence",@"HGCROC\npin/chan",@"  Si  \n cell  ",@"   (iu, iv)   ",@"  Trigger \n link  cell  "};
    double x = xleft;
    for(int i=0; i<5; i++) {
        str = [[NSMutableAttributedString alloc] initWithString:header[i]];
        [str addAttributes:headerText range:NSMakeRange(0,str.length)];
        blen[i] = str.size.width + 8.;
        if(i == 0) bhgt = str.size.height + 2.;
        NSRect box = NSMakeRect(x,ytop,blen[i],bhgt);
        [[NSColor fadedBlue] set];
        [NSBezierPath fillRect:box];
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:box];
        box = NSMakeRect(x+4.,ytop+1.,blen[i]-4.,bhgt-1.);
        [str drawInRect:box];
        x += blen[i];
    }
    
    for (int line = 0; line < 37; line++) {
        double x = xleft;
        NSString * entry = [NSString stringWithFormat:@"%2d",line];
        str = [[NSMutableAttributedString alloc] initWithString:entry];
        [str addAttributes:standardText range:NSMakeRange(0,str.length)];
        bhgt = str.size.height + 2.;
        ytop -= bhgt;
        NSRect box = NSMakeRect(x,ytop,blen[0],bhgt);
        [[NSColor peachOrange] set];
        [NSBezierPath fillRect:box];
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:box];
        [str drawAtPoint:NSMakePoint(x+0.5*(blen[0]-str.size.width),ytop+1.)];
        x += blen[0];

        entry = [rocPinName[half][line] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        str = [[NSMutableAttributedString alloc] initWithString:entry];
        [str addAttributes:standardText range:NSMakeRange(0,str.length)];
        box = NSMakeRect(x,ytop,blen[1],bhgt);
        [[NSColor peachOrange] set];
        [NSBezierPath fillRect:box];
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:box];
        [str drawAtPoint:NSMakePoint(x+0.5*(blen[1]-str.size.width),ytop+1.)];
        x += blen[1];

        if(_unconnected[line]) {
            for (int i=2; i<4; i++) {
                box = NSMakeRect(x,ytop,blen[i],bhgt);
                [[NSColor peachOrange] set];
                [NSBezierPath fillRect:box];
                [[NSColor blackColor] set];
                [NSBezierPath strokeRect:box];
                x += blen[i];
            }
            //str = [[NSMutableAttributedString alloc] initWithString:@"Unconnected"];
            //[str addAttributes:standardText range:NSMakeRange(0,str.length)];
            box = NSMakeRect(x,ytop,blen[4],bhgt);
            [[NSColor peachOrange] set];
            [NSBezierPath fillRect:box];
            [[NSColor blackColor] set];
            [NSBezierPath strokeRect:box];
            //[str drawAtPoint:NSMakePoint(x+0.5*(blen[4]-str.size.width),ytop+1.)];
        } else {
            //entry = [NSString stringWithFormat:@"%2d",_rocPin[line]];
            //if(_calib[line]) entry = _calibName;
 /*           entry = [rocPinName[half][line] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            str = [[NSMutableAttributedString alloc] initWithString:entry];
            [str addAttributes:standardText range:NSMakeRange(0,str.length)];
            box = NSMakeRect(x,ytop,blen[1],bhgt);
            [[NSColor peachOrange] set];
            [NSBezierPath fillRect:box];
            [[NSColor blackColor] set];
            [NSBezierPath strokeRect:box];
            [str drawAtPoint:NSMakePoint(x+0.5*(blen[1]-str.size.width),ytop+1.)];
            x += blen[1]; */

            entry = [NSString stringWithFormat:@"%3d",_siCell[line]];
            if(_partial) if(_split[line]) entry = [entry stringByAppendingString:@"+"];
            str = [[NSMutableAttributedString alloc] initWithString:entry];
            [str addAttributes:standardText range:NSMakeRange(0,str.length)];
            if(_partial) if(_split[line]) [str addAttribute:NSBaselineOffsetAttributeName
                                             value:[NSNumber numberWithDouble:1.5]
                                             range:NSMakeRange(str.length-1,1)];
            box = NSMakeRect(x,ytop,blen[2],bhgt);
            [[NSColor peachOrange] set];
            [NSBezierPath fillRect:box];
            [[NSColor blackColor] set];
            [NSBezierPath strokeRect:box];
            [str drawAtPoint:NSMakePoint(x+0.5*(blen[2]-str.size.width),ytop+1.)];
            x += blen[2];

            entry = [NSString stringWithFormat:@"(%2d",_iu[line]];
            if(_calib[line]) entry = [entry stringByAppendingString:@"*"];
            entry = [entry stringByAppendingFormat:@",%3d",_iv[line]];
            if(_calib[line]) entry = [entry stringByAppendingString:@"*"];
            entry = [entry stringByAppendingString:@")"];
            str = [[NSMutableAttributedString alloc] initWithString:entry];
            [str addAttributes:standardText range:NSMakeRange(0,str.length)];
            box = NSMakeRect(x,ytop,blen[3],bhgt);
            [[NSColor peachOrange] set];
            [NSBezierPath fillRect:box];
            [[NSColor blackColor] set];
            [NSBezierPath strokeRect:box];
            [str drawAtPoint:NSMakePoint(x+0.5*(blen[3]-str.size.width),ytop+1.)];
            x += blen[3];
            
            box = NSMakeRect(x,ytop,blen[4],bhgt);
            [[NSColor peachOrange] set];
            [NSBezierPath fillRect:box];
            [[NSColor blackColor] set];
            [NSBezierPath strokeRect:box];
            if(_tlink[line] != -1) {
                entry = [NSString stringWithFormat:@"%2d  %2d",_tlink[line],_tcell[line]];
                str = [[NSMutableAttributedString alloc] initWithString:entry];
                [str addAttributes:standardText range:NSMakeRange(0,str.length)];
                [str drawAtPoint:NSMakePoint(x+0.5*(blen[4]-str.size.width),ytop+1.)];
            }
/* ----------------------------------------------
            if(_calib[line]) {
                str = [[NSMutableAttributedString alloc] initWithString:@"Calib cell"];
                [str addAttributes:standardText range:NSMakeRange(0,str.length)];
                [str drawAtPoint:NSMakePoint(x+0.5*(blen[4]-str.size.width),ytop+1.)];
            }
             
            if(_partial) {
                if(_split[line]) {
                    entry = [NSString stringWithFormat:@"Cells %3d+%3d",_siCell[line],_siCell[line]+1];
                    str = [[NSMutableAttributedString alloc] initWithString:entry];
                    [str addAttributes:standardText range:NSMakeRange(0,str.length)];
                    [str drawAtPoint:NSMakePoint(x+0.5*(blen[4]-str.size.width),ytop+1.)];
                }
            }
    ----------------------------------------------------- */
        }
    }
    
    if (_pdf)    {

        float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
        int build = (int) [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] integerValue];
        
        NSString * vstamp = [NSString stringWithFormat:@"Hex version %.2f(%d), ",version,build];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MMM-Y"];
        vstamp = [vstamp stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
        [vstamp drawAtPoint:NSMakePoint(xleft+154.,ytop-16.) withAttributes:pdfText];
    }


}

@end
