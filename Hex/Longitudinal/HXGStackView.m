//
//  HXGStackView.m
//  Hex
//
//  Created by Chris Seez on 02/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackView.h"

NSString * const HXGNewStackResultStringNotification = @"HXGStackResults";

@implementation HXGStackView

- (void)makeDiagramFor:(BOOL)cee {
    
    if(!theStack) theStack = [HXGStackUp sharedStackUp];
    CEE = cee;
    NSRect brect = self.bounds;
    top = brect.size.height;
    width = brect.size.width;
    xzero = brect.origin.x;
    //NSLog(@"makeDiagramFor: bounds = %.0f, %.0f, %.0f, %.0f",brect.origin.x,brect.origin.y,brect.size.width,brect.size.height);
    
    cehAbsorbY = 40.;
    cehDiagJump = 8.;

    
    double thick = 0.;
    double viewHeight = top;
    
    if(CEE) {
        for (int i=0; i<theStack.strataCEE.count; i++) {
            HXGStratum * s = theStack.strataCEE[i];
            double x = s.thickness;
            if([s.material isEqualToString:@"Pb"]) x = [theStack.varyAbsorberCEE[theStack.ncassette-1] doubleValue];
            if([s.material isEqualToString:@"Air"]) x = [theStack.varyAirTolCEE[theStack.ncassette-1] doubleValue];
            thick += x;
        }
        if(theStack.ncassette == 13) {
            for (int i=0; i<theStack.extraStrataCEE.count; i++) {
                HXGStratum * s = theStack.extraStrataCEE[i];
                thick += s.thickness;
            }
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
            NSString * str = @"Stainless steel absorber: ";
            double fine = [theStack.varyAbsorberCEH[1] doubleValue];
            double coarse = [theStack.varyAbsorberCEH[theStack.varyAbsorberCEH.count-1] doubleValue];
            int ncoarse = 0;
            double CEEback = [theStack.varyAbsorberCEH[0] doubleValue];
            for (int i=0; i<theStack.varyAbsorberCEH.count; i++) {
                if([theStack.varyAbsorberCEH[i] doubleValue] > [theStack.varyAbsorberCEH[0] doubleValue]) ncoarse++;
            }
            int nfine = (int) theStack.varyAbsorberCEH.count - ncoarse;
            str = [str stringByAppendingFormat:@"first of %.1fmm, then\n%d fine of %.1fmm; %d coarse of %.1fmm",CEEback,nfine-1, fine,ncoarse, coarse];
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

- (void) listStackupInformation {

    /* ------------------------------------------------------------------------------------
       27 Sept 2024 - Correct as far as it goes.
       Possible improvements:
       1. List variation of air gaps in CEE
       2. List thicknesses of cassettes
       ------------------------------------------------------------------------------------ */
    
    if(!theStack) theStack = [HXGStackUp sharedStackUp];
    if(!theTerminal) theTerminal = [HGCTerminalControl sharedTerminal];
    theTerminal.suggestedName = @"StackupListing";
    [theTerminal makeWindowBig];
    [theTerminal clearString];
    [theTerminal displayString:@"====> CE-E stackup <====\n\n"];
    [theTerminal showWindow:nil];

    // -------------------------- CE-E -------------
    double height = 0.;
    HXGStratum * s;
    NSString * str = @"Pb absorber:\n";
    int ipb = 0;
    int ipbref = 1;
    for (int i=0; i<7; i++) {
        s = theStack.strataCEE[i];
        double x = s.thickness;
        NSString * matstr = [s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0];
        if([s.material isEqualToString:@"Pb"]) {
            x = [theStack.varyAbsorberCEE[ipbref] doubleValue];
            ipb = i;
            matstr = [@"Pb [*]" stringByPaddingToLength:16 withString:@" " startingAtIndex:0];
        }
        height += x;
        if(x > 0.) str = [str stringByAppendingFormat:@"%@ %.3f\n",matstr,x];
        if(i == 6) str = [str stringByAppendingFormat:@"  total = %.2fmm\n\n",height];
    }
    [theTerminal displayString:str];
    double tval = [theStack.varyAbsorberCEE[0] doubleValue];
    str = @"[*] Pb thickness:\nCassette 1";
    s = theStack.strataCEE[ipb];
    for (int i=0; i<theStack.varyAbsorberCEE.count; i++) {
        if(tval != [theStack.varyAbsorberCEE[i] doubleValue]){
            str = [str stringByAppendingFormat:@": %.3fmm",tval];
            [theTerminal displayString:str];
            str = [NSString stringWithFormat:@"\nCassette %d",i+1];
            tval = [theStack.varyAbsorberCEE[i] doubleValue];
        } else if(i != 0) str = [str stringByAppendingFormat:@",%d",i+1];
    }
    str = [str stringByAppendingFormat:@": %.3fmm\n\n",tval];
    [theTerminal displayString:str];

    _layerThickness = height;
    //---------- Air gap ----------------------
    s = theStack.strataCEE[7];
    double x = s.thickness;
    if([s.material isEqualToString:@"Air"]) x = [theStack.varyAirTolCEE[theStack.ncassette-1] doubleValue];
    height = x;
    _layerThickness += height;
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],x];
    [theTerminal displayString:str];

    //---------- Services ----------------------
    s = theStack.strataCEE[8];
    height = s.thickness;
    _layerThickness += height;
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //-------- Module -----------------------------
    str = @"\nModule:\n";
    height = 0.;
    for (int i=9; i<14; i++) {
        s = theStack.strataCEE[i];
        height += s.thickness;
        str = [str stringByAppendingFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    }
    str = [str stringByAppendingFormat:@"   total = %.3fmm\n\n",height];
    [theTerminal displayString:str];

    _layerThickness += height;
    //---------- Cooling plate ----------------------
    s = theStack.strataCEE[14];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"Cooling plate:\n%@ %.3f\n\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];
    
    //-------- Module -----------------------------
    str = @"Module:\n";
    height = 0;
    for (int i=15; i<20; i++) {
        s = theStack.strataCEE[i];
        height += s.thickness;
        str = [str stringByAppendingFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    }
    str = [str stringByAppendingFormat:@"   total = %.3fmm\n\n",height];
    _layerThickness += height;
    [theTerminal displayString:str];
    
    s = theStack.strataCEE[20];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];
    
    //---------- Air gap ----------------------
    s = theStack.strataCEE[21];
    x = s.thickness;
    if([s.material isEqualToString:@"Air"]) x = [theStack.varyAirTolCEE[theStack.ncassette-1] doubleValue];
    height = x;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"%@ %.3f\n\n",[s.material stringByPaddingToLength:6 withString:@" " startingAtIndex:0],x];
    [theTerminal displayString:str];

    //--------- Totals ------------------------
    
    tval = [theStack.varyAbsorberCEE[0] doubleValue];
    double casref = _layerThickness - [theStack.varyAbsorberCEE[ipbref] doubleValue] - 2.*x;
    double aval = [theStack.varyAirTolCEE[0] doubleValue];
    str = @"TOTAL CASSETTE thickness:\nCassette 1";
    s = theStack.strataCEE[0];
    for (int i=0; i<theStack.varyAbsorberCEE.count; i++) {
        if(tval != [theStack.varyAbsorberCEE[i] doubleValue]){
            str = [str stringByAppendingFormat:@": %.3fmm",casref+tval+2.*aval];
            [theTerminal displayString:str];
            str = [NSString stringWithFormat:@"\nCassette %d",i+1];
        } else if(i != 0) str = [str stringByAppendingFormat:@",%d",i+1];
        tval = [theStack.varyAbsorberCEE[i] doubleValue];
        aval = [theStack.varyAirTolCEE[i] doubleValue];
    }
    str = [str stringByAppendingFormat:@": %.3fmm\n\n",casref+tval+2.*aval];
    [theTerminal displayString:str];

    //----- Back cover if cassette 13
    s = theStack.extraStrataCEE[0];
    height = s.thickness;
    //_layerThickness += height;

    str = [NSString stringWithFormat:@"After cassette 13:\nBack cover: %@ %.3f\n",s.material,s.thickness];
    [theTerminal displayString:str];


    //------------------------------- CEH (silicon) ----------------------------

    [theTerminal displayString:@"\n\n====> CE-H stackup (Si) <====\n\n"];

    //---------- Air gap ----------------------
    s = theStack.strataCEHsi[1];
    height = s.thickness;
    _layerThickness = height;
    
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //---------- Cover plate ----------------------
    s = theStack.strataCEHsi[2];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"\nCover plate:\n%@ %.3f\n\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //---------- Air and services ----------------------
    s = theStack.strataCEHsi[3];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];
    
    s = theStack.strataCEHsi[4];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //-------- Module -----------------------------
    str = @"\nSi module:\n";
    height = 0;
    for (int i=5; i<10; i++) {
        s = theStack.strataCEHsi[i];
        height += s.thickness;
        str = [str stringByAppendingFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    }
    str = [str stringByAppendingFormat:@"   total = %.3fmm\n\n",height];
    [theTerminal displayString:str];
    _layerThickness += height;

    //---------- Cooling plate ----------------------
    s = theStack.strataCEHsi[10];
    height = s.thickness;
    _layerThickness += height;
    
    str = [NSString stringWithFormat:@"Cooling plate:\n%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];
    
    str = [NSString stringWithFormat:@"\nTOTAL between absorber plates = %7.3f\n",_layerThickness];
    [theTerminal displayString:str];

    //----------------------------- CEH (scintillator) --------------------------
    
    [theTerminal displayString:@"\n\n====> CE-H stackup (Scintillator) <====\n\n"];
    
    //---------- Air gap ----------------------
    s = theStack.strataCEHscint[1];
    height = s.thickness;
    str = [NSString stringWithFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //---------- Cover plate ----------------------
    s = theStack.strataCEHscint[2];
    height = s.thickness;
    str = [NSString stringWithFormat:@"\nCover plate:\n%@ %.3f\n\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    //---------- Air gap ----------------------
    s = theStack.strataCEHscint[3];
    height = s.thickness;
    str = [NSString stringWithFormat:@"Fibres and cables:\n%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    s = theStack.strataCEHscint[4];
    height += s.thickness;
    str = [str stringByAppendingFormat:@"%@ %.3f\n",[@"Tile services" stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];


    //-------- Module -----------------------------
    str = @"\nScintillator module:\n";
    height = 0;
    for (int i=5; i<10; i++) {
        s = theStack.strataCEHscint[i];
        height += s.thickness;
        str = [str stringByAppendingFormat:@"%@ %.3f\n",[s.material stringByPaddingToLength:16 withString:@" " startingAtIndex:0],s.thickness];
    }
    str = [str stringByAppendingFormat:@"   total = %.3fmm\n",height];
    [theTerminal displayString:str];

    //---------- Cooling plate ----------------------
    s = theStack.strataCEHscint[10];
    height = s.thickness;
    str = [NSString stringWithFormat:@"\nCooling plate:\n%@ %.3f\n",[s.material stringByPaddingToLength:6 withString:@" " startingAtIndex:0],s.thickness];
    [theTerminal displayString:str];

    str = [NSString stringWithFormat:@"\nTOTAL between absorber plates = %7.3f\n",_layerThickness];
    [theTerminal displayString:str];

    //                  ------ CEH absorber -------
    
    str = @"\n +----------------------------------------+\n | CE-H stainless steel absorber:         |\n";
    double fine = [theStack.varyAbsorberCEH[1] doubleValue];
    double coarse = [theStack.varyAbsorberCEH[theStack.varyAbsorberCEH.count-1] doubleValue];
    int ncoarse = 0;
    double CEEback = [theStack.varyAbsorberCEH[0] doubleValue];
    for (int i=0; i<theStack.varyAbsorberCEH.count; i++) {
        if([theStack.varyAbsorberCEH[i] doubleValue] > [theStack.varyAbsorberCEH[0] doubleValue]) ncoarse++;
    }
    int nfine = (int) theStack.varyAbsorberCEH.count - ncoarse;
    str = [str stringByAppendingFormat:@" | First (CE-E backplate) of %.1fmm, then |\n | %d fine of %.1fmm; %d coarse of %.1fmm |\n | Space between absorbers = %.3fmm     |\n +----------------------------------------+\n\n",CEEback,nfine-1, fine,ncoarse, coarse,_layerThickness];
    [theTerminal displayString:str];
    
    str = [NSString stringWithFormat:@"Thickness: CE-E = %.2fmm, CE-H = %.2fmm, TOTAL = %.2fmm\n",theStack.zCEE,theStack.zCEH,theStack.zCEE+theStack.zCEH];
    str = [str stringByAppendingString:@"(CE-E backplate is categorized as first absorber of CE-H)"];
    [theTerminal displayString:str];

}

#pragma mark - drawRect

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSColor * coolGrey = [NSColor coolGrey];
    NSColor * paleGrey = [NSColor paleGrey];
//    NSColor * grassGreen = [NSColor grassGreen];
    NSColor * seaGreen = [NSColor seaGreen];
    NSColor * peachOrange = [NSColor peachOrange];
    NSColor * servicesColor = [NSColor pastelBlue];
    NSColor * paleBlue = [NSColor paleBlue];
    NSColor * fadedBlue = [NSColor fadedBlue];
    NSColor * airColor = [NSColor sageGreen];
    
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
            if(x > 0.) {
                str = [str stringByAppendingFormat:@"%@ %.3f",s.material,x];
                if(i < 5) str = [str stringByAppendingString:@" + "];
            }
        }
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [coolGrey set];
        NSRectFill(sRect);
        str = [str stringByAppendingFormat:@"\nTotal = %.3fmm",height];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr addAttribute:NSForegroundColorAttributeName
                    value:[NSColor whiteColor]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];

        _layerThickness = height;
        //---------- Air gap ----------------------
        s = theStack.strataCEE[7];
        height = [theStack.varyAirTolCEE[theStack.ncassette-1] doubleValue];
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [airColor set];
        NSRectFill(sRect);
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,height];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(width-80.,yzero+0.5*(scale*height)-6.,astr.size.width,12.);
        

        //---------- Si services ----------------------
        s = theStack.strataCEE[8];
        height = s.thickness;
        _layerThickness += height;
        yzero -= scale*height;
        
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [servicesColor set];
        NSRectFill(sRect);
        
        [airColor set]; //--- previous label
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-1.)];

        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];

        //-------- Module -----------------------------
        str = @"Module: ";
        height = 0.;
        for (int i=9; i<14; i++) {
            s = theStack.strataCEE[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 13) str = [str stringByAppendingString:@" + "];
        }
        str = [str stringByAppendingFormat:@"; Total = %.3fmm",height];

        yzero -= scale*height;
        _layerThickness += height;
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
        s = theStack.strataCEE[14];
        height = s.thickness;
        _layerThickness += height;
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
        for (int i=15; i<20; i++) {
            s = theStack.strataCEE[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 19) str = [str stringByAppendingString:@" + "];
        }
        str = [str stringByAppendingFormat:@"; Total = %.3fmm",height];
        _layerThickness += height;
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

        //---------- Services ----------------------
        s = theStack.strataCEE[20];
        height = s.thickness;
        //stot += height;
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [servicesColor set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //---------- Air gap ----------------------
        s = theStack.strataCEE[21];
        height = [theStack.varyAirTolCEE[theStack.ncassette-1] doubleValue];
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,width,scale*height);
        [airColor set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,height];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(width-80.,yzero+0.5*(scale*height)-6.,astr.size.width,12.);
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-2.)];
        //----- Add extra-strata if cassette 13

        if(theStack.ncassette == 13) {
            s = theStack.extraStrataCEE[0];
            height = s.thickness;
             yzero -= scale*height;
            sRect = NSMakeRect(xzero,yzero,width,scale*height);
            [[NSColor paleBlue] set];
            NSRectFill(sRect);
            
            [airColor set]; // --- previous label
            NSRectFill(xRect);
            [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-2.)];

            str = [NSString stringWithFormat:@"Extra: %@: %.3f",s.material,s.thickness];
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
        _layerThickness = height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [airColor set];
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
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [paleGrey set];
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
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [airColor set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(xzero,yzero+0.5*(scale*height)-6.,astr.size.width,12.); //hwid-70.
        //---------- Motherboard ----------------------
        s = theStack.strataCEHsi[4];
        height = s.thickness;
        _layerThickness += height;
        yzero -= scale*height;
        sRect = NSMakeRect(xzero,yzero,hwid,scale*height);
        [servicesColor set];
        NSRectFill(sRect);
        
        [airColor set];
        NSRectFill(xRect);
        [astr drawAtPoint:NSMakePoint(xRect.origin.x,xRect.origin.y-1.)];
        
        str = [NSString stringWithFormat:@"%@ %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Si module: ";
        height = 0;
        for (int i=5; i<10; i++) {
            s = theStack.strataCEHsi[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 9) str = [str stringByAppendingString:@" + "];
        }
        str = [str stringByAppendingFormat:@"\nTotal = %.3fmm",height];
        _layerThickness += height;
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
        s = theStack.strataCEHsi[10];
        height = s.thickness;
        _layerThickness += height;
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
        //----------------------------- CEH (scintillator) --------------------------
        //---------- Air gap ----------------------
        yzero = top - cehAbsorbY;
        s = theStack.strataCEHscint[1];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [airColor set];
        NSRectFill(sRect);
        //---------- Cover plate ----------------------
        s = theStack.strataCEHscint[2];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [paleGrey set];
        NSRectFill(sRect);
        //---------- Air gap ----------------------
        s = theStack.strataCEHscint[3];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [airColor set];
        NSRectFill(sRect); // ????????
        str = [NSString stringWithFormat:@"%@: %.3f",s.material,s.thickness];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        xRect = NSMakeRect(xzero,yzero+0.5*(scale*height)-6.,astr.size.width,12.); //hwid-70.

        //---------------- Services ----------------
        s = theStack.strataCEHscint[4];
        height = s.thickness;
        yzero -= scale*height;
        sRect = NSMakeRect(hwid,yzero,hwid,scale*height);
        [fadedBlue set];
        NSRectFill(sRect);
        
        str = [NSString stringWithFormat:@"Tile services: %.3f",height];
        astr = [[NSMutableAttributedString alloc] initWithString:str];
        [astr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:12]
                    range:NSMakeRange(0,astr.length)];
        [astr drawInRect:sRect];
        //-------- Module -----------------------------
        str = @"Tile board: ";
        height = 0;
        for (int i=5; i<10; i++) {
            s = theStack.strataCEHscint[i];
            height += s.thickness;
            str = [str stringByAppendingFormat:@"%@ %.3f",s.material,s.thickness];
            if(i < 9) str = [str stringByAppendingString:@" + "];
        }
        str = [str stringByAppendingFormat:@"; Total = %.3fmm",height];
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

    [[NSNotificationCenter defaultCenter] postNotificationName:HXGNewStackResultStringNotification object:self];

}

@end
