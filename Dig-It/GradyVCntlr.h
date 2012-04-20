//
//  GradyVCntlr.h
//  Dig-It
//
//  Created by Paul Houghton on 120417.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "ReplacementViewCntlr.h"
#import "GradyView.h"
#import "TestVCntlr.h"
#import "CustomerViewCntlr.h"

@interface GradyVCntlr : ReplacementViewCntlr
@property (strong) IBOutlet GradyView *         gradyV;
@property (weak) IBOutlet NSColorWell *         gradyFromCW;
@property (weak) IBOutlet NSColorWell *         gradyToCW;
@property (weak) IBOutlet NSSlider *            gradyDirSlider;
@property (weak) IBOutlet NSColorWell *         fontCW;
@property (weak) IBOutlet NSTextField *         gradyStatusTF;
@property (weak) IBOutlet NSProgressIndicator * progPI;

@property (weak) IBOutlet ReplacementView *     contentV;

@property (strong) CustomerViewCntlr *          custVC;
@property (strong) TestVCntlr * tvc;

-(id)initWithViewToReplace:(NSView *)vtr;

- (IBAction)fromColorAction:(NSColorWell *)sender;
- (IBAction)toColorAction:(NSColorWell *)sender;
- (IBAction)gradyDirAction:(NSSlider *)sender;
- (IBAction)fontColorAction:(NSColorWell *)sender;

@end
