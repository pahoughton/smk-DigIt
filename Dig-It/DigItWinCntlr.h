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
#import <Cocoa/Cocoa.h>
#import "MainWinGradyView.h"

@class CustomerViewCntlr;

@interface DigItWinCntlr : NSWindowController
@property (retain) CustomerViewCntlr * custViewCntlr;

@property (weak) IBOutlet MainWinGradyView * mainWinGradyView;

@property (weak) IBOutlet NSColorWell *fromColorWell;
@property (weak) IBOutlet NSColorWell *toColorWell;
@property (weak) IBOutlet NSSlider *directionSlider;

-(void)goodToGo;

- (IBAction)fromColorAction:(id)sender;
- (IBAction)toColorAction:(id)sender;
- (IBAction)directionAction:(id)sender;


@property (weak) IBOutlet NSView *contentView;

@end
