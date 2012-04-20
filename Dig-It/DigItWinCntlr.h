/**
  File:		DigItWinCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  10:02 AM
  Copyright:    Copyright (c) 2012 Secure Media Keepers.
                All rights reserved.

  Revision History: (See ChangeLog for details)
  
    $Author$
    $Date$
    $Revision$
    $Name$
    $State$

  $Id$

**/
#import "GradyView.h"
#import "ReplacementViewCntlr.h"
#import "CustomerViewCntlr.h"

@interface DigItWinCntlr : NSWindowController

@property (weak) IBOutlet GradyView * mainWinGradyView;
@property (weak) IBOutlet ReplacementView *contentV;

@property (retain) CustomerViewCntlr * custViewCntlr;

@property (weak) IBOutlet NSColorWell * fromColorWell;
@property (weak) IBOutlet NSColorWell * toColorWell;
@property (weak) IBOutlet NSSlider *    directionSlider;

-(void)goodToGo;

- (IBAction)fromColorAction:(id)sender;
- (IBAction)toColorAction:(id)sender;
- (IBAction)directionAction:(id)sender;

@end
