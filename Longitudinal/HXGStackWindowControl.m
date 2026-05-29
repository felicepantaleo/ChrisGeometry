//
//  HXGStackWindowControl.m
//  Hex
//
//  Created by Chris Seez on 02/11/2021.
//  Copyright © 2021 seez. All rights reserved.
//

#import "HXGStackWindowControl.h"

@interface HXGStackWindowControl ()

@end

@implementation HXGStackWindowControl

+ (id) sharedStackControl {
    
    static dispatch_once_t pred;
    static HXGStackWindowControl * theStackControl = nil;
    
    dispatch_once(&pred, ^{ theStackControl = [[self alloc] init]; });
    return theStackControl;

}

- (id) init {
    
    self=[super initWithWindowNibName: @"HXGStackWindowControl"];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(updateResultString:)
               name:HXGNewStackResultStringNotification
             object:nil];


    return self;
}

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    if(!theStack) theStack = [HXGStackUp sharedStackUp];
    
    CEE = YES;
    ncassette = 2;
    theStack.ncassette = ncassette;
    
    [self.window setOpaque:NO];
    NSRect wf = [[self window] frame];
    double top = wf.size.height - 5.;
   
    //------------ section type semented control
    
    NSRect srect = NSMakeRect(wf.size.width*0.5-40.,top-50.,100.,20.);
    stackType = [[NSSegmentedControl alloc] initWithFrame:srect];
    [stackType setSegmentCount:2];
    [stackType setLabel:@"CEE" forSegment:0];
    [stackType setLabel:@"CEH" forSegment:1];
    [stackType setWidth:50 forSegment:0];
    [stackType setWidth:50 forSegment:1];
    [stackType setSelected:CEE forSegment:0];
    [stackType setSelected:!CEE forSegment:1];
    [stackType setAction:NSSelectorFromString(@"changeSection:")];
    [[stackType cell] setFont:[NSFont systemFontOfSize:13]];
    [[stackType cell] setControlSize:NSControlSizeSmall];
    stackType.segmentStyle = NSSegmentStyleRounded;
    [[stackType cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
    [[[self window] contentView] addSubview:stackType];
    

    
    //------------ The results label
    
    srect = NSMakeRect(10.,15.,wf.size.width-20.,105.);
    resultLabel = [[NSTextField alloc]initWithFrame:srect];
    [[[self window] contentView] addSubview:resultLabel];
    [resultLabel setBordered:YES];
    [resultLabel setBezeled:YES];
    [resultLabel setSelectable:NO];
    indigoColor = [NSColor indigoBlue];
    ivoryColor = [NSColor ivoryWhite];
    [resultLabel setBackgroundColor:ivoryColor];
    [resultLabel setTextColor:indigoColor];
    [resultLabel setFont:[NSFont systemFontOfSize:13]];
    [resultLabel setAlignment:-1];

    //------------ The description label
    
    srect = NSMakeRect(20.,top-70.,wf.size.width-160.,20.);
    descriptionLabel = [[NSTextField alloc]initWithFrame:srect];
    [[[self window] contentView] addSubview:descriptionLabel];
    [descriptionLabel setSelectable:NO];
    [descriptionLabel setAlignment:-1];
    [descriptionLabel setEditable:NO];
    [descriptionLabel setDrawsBackground:NO];
    [descriptionLabel setBordered:NO];

    [descriptionLabel setStringValue:@"47-layer geometry: September 2024"];
    
    //-------------- The stepper
    srect = NSMakeRect(wf.size.width-40.,top-60.,18.,28.);
    stepper = [[NSStepper alloc] initWithFrame:srect];
    [stepper setAction:NSSelectorFromString(@"newStepperValue:")];
    [stepper setMinValue:1];
    [stepper setMaxValue:13];
    [stepper setIntegerValue:2];
    [stepper setValueWraps:NO];
    [stepper setIncrement:1];
    [stepper setAutorepeat:YES];
    [[[self window] contentView] addSubview:stepper];

    //------------ The stepper value
    
    srect = NSMakeRect(wf.size.width-145.,top-58.,110.,20.);
    stepperValue = [[NSTextField alloc]initWithFrame:srect];
    [[[self window] contentView] addSubview:stepperValue];
    [stepperValue setSelectable:NO];
    [stepperValue setAlignment:+1];
    [stepperValue setEditable:NO];
    [stepperValue setDrawsBackground:NO];
    [stepperValue setBordered:NO];
    [stepperValue setFont:[NSFont systemFontOfSize:13]];

    NSString * str = [NSString stringWithFormat:@"CEE cassette %d",ncassette];
    [stepperValue setStringValue:str];
/*
    // ------------------- The PDF button
    srect = NSMakeRect(wf.size.width-80.,5.,60.,20.);
    pdfButton = [[NSButton alloc] initWithFrame:srect];
    [pdfButton setTitle:@"PDF"];
    [pdfButton setAction:@selector(makePDF:)];
    [pdfButton setButtonType:NSButtonTypeMomentaryPushIn];
    [pdfButton setBezelStyle:NSBezelStyleRounded];
    [pdfButton setKeyEquivalent:@"p"];
    [pdfButton setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
    //[[pdfButton cell] setBackgroundColor:[NSColor blueColor]];
    [[[self window] contentView] addSubview:pdfButton];
*/
    
}

- (void) showWindow:(id)sender {
    
    [super showWindow:sender];
    
    [_stackView makeDiagramFor:CEE];
  
}

- (void) listStackupInformation {

    [super showWindow:self]; // Required to instantiate _stackView
    [self.window close];

    [_stackView listStackupInformation];

}

- (void) makePDF {
    
    NSSavePanel *export = [NSSavePanel savePanel];
    
    NSString * filename;
    if(CEE) filename = @"StackupCEE.pdf";
    else filename = @"StackupCEH.pdf";
    
    [export setNameFieldStringValue:filename];
    [export setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [export setCanCreateDirectories:YES];
    [export setShowsTagField:NO];
    [export setTitle:@"Save PDF file"];
    // [export setPrompt:@"This is the prompt"]; // i.e. inside the save button
    // [export setMessage:@"This is the message"];

    [export beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK)
        {
            NSString * pdfpath = [[export URL] path];
            NSData * data = [self.window.contentView dataWithPDFInsideRect:self.window.contentLayoutRect];
            [data writeToFile:pdfpath options:0 error:nil];

        }
    }];
    
}

#pragma mark - Notifications
- (void) updateResultString:(NSNotification *) note {

    theStack.ncassette = ncassette;
    [theStack sumOddEvenCassette];
    
    NSString * resultString;
    resultString = [NSString stringWithFormat:@"Thickness: CEE = %.2fmm, CEH = %.2fmm, TOTAL = %.2fmm",theStack.zCEE,theStack.zCEH,theStack.zCEE+theStack.zCEH];
    resultString = [resultString stringByAppendingFormat:@"\nX0: CEE = %.2f, CEH = %.2f, TOTAL = %.2f",theStack.x0CEE,theStack.x0CEH,theStack.x0CEE+theStack.x0CEH];
    resultString = [resultString stringByAppendingFormat:@"\nλ: CEE = %.2f, CEH = %.2f, TOTAL = %.2f, Total + Backdisk = %.2f",theStack.lambdaCEE,theStack.lambdaCEH,theStack.lambdaCEE+theStack.lambdaCEH,theStack.lambdaCEE+theStack.lambdaCEH+theStack.lambdaBackDisk];
    resultString = [resultString stringByAppendingFormat:@"\ndE/dx: CEE = %.2f, CEH = %.2f, TOTAL = %.2f",theStack.dEdxCEE,theStack.dEdxCEH,theStack.dEdxCEE+theStack.dEdxCEH];
   if(CEE) {
        resultString = [resultString stringByAppendingFormat:@"\nCassette %d: Odd: %.2fX0 dEdx = %.2fMeV; Even: %.2fX0, dEdx = %.2fMeV",theStack.ncassette,theStack.x0Odd,theStack.dEdxOdd,theStack.x0Even,theStack.dEdxEven];
        resultString = [resultString stringByAppendingFormat:@"\nCassette thickness = %.2fmm",_stackView.layerThickness];
    } else {
        resultString = [resultString stringByAppendingFormat:@"\nSpace between absorbers = %.2fmm",_stackView.layerThickness];

    }

    [resultLabel setStringValue:resultString];

}

#pragma mark - IB Actions

- (IBAction) changeSection:(id)sender {
    
    CEE = ([sender selectedSegment] == 0);
    [stepperValue setHidden:!CEE];
    [stepper setHidden:!CEE];
    [_stackView makeDiagramFor:CEE];
//    [self updateResultString];

}

- (IBAction) newStepperValue:(id)sender {
    
    ncassette = (int) [stepper integerValue];
    theStack.ncassette = ncassette;

    NSString * str = [NSString stringWithFormat:@"CEE cassette %d",ncassette];
    [stepperValue setStringValue:str];
    [_stackView makeDiagramFor:CEE];
//    [self updateResultString];

}


@end
