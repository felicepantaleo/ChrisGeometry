//
//  HXGStackView.m
//  Hex
//
//  Created by Chris Seez on 02/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackView.h"

@implementation HXGStackView

- (void)makeDiagramFor:(BOOL)cee {
    
    if(!theStack) theStack = [HXGStackUp sharedStackUp];
    CEE = cee;
    NSRect brect = self.bounds;
    top = brect.size.height;
    width = brect.size.width;
    xzero = brect.origin.x;
    
    cehAbsorbY = 40.;
    cehDiagJump = 8.;

    
    double thick = 0.;
    double viewHeight = top;
    
    if(CEE) {
        for (int i=0; i<theStack.strataCEE.count; i++) {
            HXGStratum * s = theStack.strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [theStack.varyAbsorberCEE[theStack.ncassette-1] doubleValue];
            thick += x;
        }
        if(theStack.ncassette == 13) {
            HXGStratum * s = theStack.extraStrataCEE[0];
            thick += s.thickness;
            s = theStack.extraStrataCEE[1];
            thick += s.thickness;
        } else {
            viewHeight -= 6.; // to allow for the Air label
        }
    } else {
        //------------------------- CEH -------------------------
        for (int i=1; i<theStack.strataCEHsi.count; i++) {
            HXGStratum * s = theStack.strataCEHsi[i];
            thick += s.thickness;
        }
        viewHeight -= cehAbsorbY;
        
        if(!upperAbsorber) {
            upperAbsorber = [[NSImage alloc] initWithSize:NSMakeSize(width,cehAbsorbY)];
            [upperAbsorber lockFocus];
            [[NSColor whiteColor] set];
            NSRectFill(NSMakeRect(0.,0.,width,cehAbsorbY));
            NSBezierPath * bez = [NSBezierPath bezierPath];
            [bez moveToPoint:NSMakePoint(0.,1.)];
            [bez lineToPoint:NSMakePoint(width,1.)];
            double x1 = -cehAbsorbY; double y1 = 1.; double x2 = 0.; double y2 = cehAbsorbY;
            int nloop = (int)((width+2.*cehAbsorbY)/cehDiagJump);
            for (int i=0;i<nloop;i++) {
                [bez moveToPoint:NSMakePoint(x1,y1)];
                [bez lineToPoint:NSMakePoint(x2,y2)];
                x1+=cehDiagJump; x2+=cehDiagJump;
            }
            [[NSColor blackColor] set];
            [bez setLineWidth:2.];
            [bez stroke];
            NSString * str = @"Stainless steel absorber:\n";
            double fine = [theStack.varyAbsorberCEH[1] doubleValue];
            double coarse = [theStack.varyAbsorberCEH[theStack.varyAbsorberCEH.count-1] doubleValue];
            str = [str stringByAppendingFormat:@"fine = %.1fmm; coarse = %.1fmm",fine,coarse];
            NSMutableAttributedString * astr = [[NSMutableAttributedString alloc] initWithString:str];
            [astr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:12]
                        range:NSMakeRange(0,astr.length)];
            NSRect xRect = NSMakeRect(0.5*(width-astr.size.width),6.,astr.size.width,astr.size.height);
            [[NSColor whiteColor] set];
            NSRectFill(xRect);
            [astr drawInRect:xRect];
            [upperAbsorber unlockFocus];
        }
    }
    
    scale = viewHeight/thick;
    
    [self setNeedsDisplay:YES];
}
#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSColor * coolGrey = [NSColor coolGrey];
    NSColor * grassGreen = [NSColor grassGreen];
    NSColor * seaGreen = [NSColor seaGreen];
    NSColor * peachOrange = [NSColor peachOrange];
    NSColor * pastelBlue = [NSColor pastelBlue];
    NSColor * paleBlue = [NSColor paleBlue];
    NSColor * fadedBlue = [NSColor fadedBlue];
    NSColor * sageGreen = [NSColor sageGreen];
    
    HXGStratum * s;
    NSRect sRect;
    NSRect xRect;
    double yzero = top;
    double height = 0.;
    NSString * str;
    NSMutableAttributedString * astr;

    if(CEE) {
        //-------- Pb absorber -----------------------------
        str = @"Pb absorber: ";
        for (int i=0; i<7; i++) {
            s = theStack.strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [theStack.varyAbsorberCEE[theStack.ncassette-1] doubleValue];
            height += x;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,x];
            if(i < 6) str = [str stringByAppendingString:@" + "];
        }
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [coolGrey set];
        NSRectFill(sRect);
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr addAttribute:NSForegroundColorAttributeName
                    value:[NSColor whiteColor]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];

        //---------- Air gap ----------------------
        s = theStack.strataCEE[7];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [pastelBlue set];
        NSRectFill(sRect);
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(width-80.,yzero+0.5*(scale*height)-6.,astr.size.width,12.);

        //---------- PCB (mother board) ----------------------
        s = theStack.strataCEE[8];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [grassGreen set];
        NSRectFill(sRect);
        
        [pastelBlue set]; //--- previous label
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-1.)];

        str = [NSString stringWithFormat:@"Motherboard %@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];

        //---------- component space ----------------------
        s = theStack.strataCEE[9];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [sageGreen set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Component space: %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Module: ";
        height = 0.;
        for (int i=10; i<17; i++) {
            s = theStack.strataCEE[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 16) str = [str stringByAppendingString:@" + "];
        }
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [seaGreen set];
        NSRectFill(sRect);
        
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr addAttribute:NSForegroundColorAttributeName
                    value:[NSColor whiteColor]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Cooling plate ----------------------
        s = theStack.strataCEE[17];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [peachOrange set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Cooling plate: %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Module: ";
        height = 0;
        for (int i=18; i<25; i++) {
            s = theStack.strataCEE[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 24) str = [str stringByAppendingString:@" + "];
        }
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [seaGreen set];
        NSRectFill(sRect);

        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr addAttribute:NSForegroundColorAttributeName
                     value:[NSColor whiteColor]
                     range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- component space ----------------------
        s = theStack.strataCEE[25];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [sageGreen set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Component space: %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- PCB (mother board) ----------------------
        s = theStack.strataCEE[26];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [grassGreen set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Motherboard %@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Air gap ----------------------
        s = theStack.strataCEE[27];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [pastelBlue set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(width-80.,yzero+0.5*(scale*height)-6.,astr.size.width,12.);
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-2.)];
        //----- Add coverplate if cassette 13
        if(theStack.ncassette == 13) {
            s = theStack.extraStrataCEE[0];
            height = s.thickness;
            yzero -= scale*height;
            sRect = NSMakeRect(xzero,yzero,width,scale*height);
            [coolGrey set];
            NSRectFill(sRect);
            
            [pastelBlue set]; //--- previous...
            NSRectFill(xRect);
            [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-2.)];

            str = [NSString stringWithFormat:@"Back cover: %@ %.3f",s.material,s.thickness];
            astr = [[NSMutableAttributedString alloc] initWithString:str];
            [astr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:12]
                        range:NSMakeRange(0,astr.length)];
            [astr addAttribute:NSForegroundColorAttributeName
                        value:[NSColor whiteColor]
                        range:NSMakeRange(0,astr.length)];
            xRect = NSMakeRect(width*0.4,yzero+0.5*(scale*height)-6.,astr.size.width,12.);


            s = theStack.extraStrataCEE[1];
            height = s.thickness;
            yzero -= scale*height;
            sRect = NSMakeRect(xzero,yzero,width,scale*height);
            [pastelBlue set];
            NSRectFill(sRect);

            [coolGrey set];    //--- previous...
            NSRectFill(xRect);
            xRect.origin.y += 2.5;
            [astr drawInRect:xRect];

            str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
            astr = [[NSMutableAttributedString alloc] initWithString:str];
            [astr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:12]
                        range:NSMakeRange(0,astr.length)];
            [astr drawAtPoint:NSMakePoint(sRect.origin.x,sRect.origin.y-1.)];
        }

    } else {
        //------ CEH absorber -------------------------------
        double hwid = 0.5*width;
        [upperAbsorber drawAtPoint:NSMakePoint(0.,top-cehAbsorbY) fromRect:NSMakeRect(0.,0.,width,cehAbsorbY) operation:NSCompositingOperationCopy fraction:1.];
        //------------------------------- CEH (silicon) ----------------------------

        //---------- Air gap ----------------------
        yzero = top - cehAbsorbY;
        s = theStack.strataCEHsi[1];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [pastelBlue set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Cover plate ----------------------
        s = theStack.strataCEHsi[2];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [peachOrange set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Cover plate:  %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Air gap ----------------------
        s = theStack.strataCEHsi[3];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [pastelBlue set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(hwid-70.,yzero+0.5*(scale*height)-6.,astr.size.width,12.);
        //---------- Motherboard ----------------------
        s = theStack.strataCEHsi[4];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [grassGreen set];
        NSRectFill(sRect);
        
        [pastelBlue set];
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-1.)];
        
        str = [NSString stringWithFormat:@"Motherboard:  %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- component space ----------------------
        s = theStack.strataCEHsi[5];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [sageGreen set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Component space: %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Si module: ";
        height = 0;
        for (int i=6; i<13; i++) {
            s = theStack.strataCEHsi[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 12) str = [str stringByAppendingString:@" + "];
        }
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [seaGreen set];
        NSRectFill(sRect);

        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:10]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Cooling plate ----------------------
        s = theStack.strataCEHsi[13];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [peachOrange set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Cooling plate:  %@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //------------------------------- CEH (scintillator) ----------------------------
        //---------- Air gap ----------------------
        yzero = top - cehAbsorbY;
        s = theStack.strataCEHscint[1];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [pastelBlue set];
        NSRectFill(sRect);
        //---------- Cover plate ----------------------
        s = theStack.strataCEHscint[2];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [peachOrange set];
        NSRectFill(sRect);
        //---------- Air gap ----------------------
        s = theStack.strataCEHscint[3];
        height = s.thickness;
        s = theStack.strataCEHscint[4];
        height += s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [fadedBlue set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Fibres and cables: %@ %.3f",s.material,height];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Scintillator module: ";
        height = 0;
        for (int i=5; i<10; i++) {
            s = theStack.strataCEHscint[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 9) str = [str stringByAppendingString:@" + "];
        }
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [paleBlue set];
        NSRectFill(sRect);

        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Cooling plate ----------------------
        s = theStack.strataCEHscint[10];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [peachOrange set];
        NSRectFill(sRect);
   }
}

@end
