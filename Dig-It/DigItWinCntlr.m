/**
  File:		DigItWinCntlr.m
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
#import "DigItWinCntlr.h"
#import "CustListViewCntlr.h"
#import <SMKLogger.h>
@implementation DigItWinCntlr
@synthesize custListViewCntlr;
@synthesize fromColorWell;
@synthesize toColorWell;
@synthesize directionSlider;
@synthesize contentView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        SMKLogDebug( @"%@ (%p) initWithWindow win:%@",[self className], self, [self window]);
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    SMKLogDebug(@"winDidLoad");
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file. 
}

- (void)goodToGo
{
    SMKLogDebug(@"good to Go??");

    custListViewCntlr = [CustListViewCntlr showSelfIn:contentView];
}

- (IBAction)fromColorAction:(id)sender 
{
    SMKLogDebug(@"color Well action color: %@", [fromColorWell color] );
    [[self window] setBackgroundColor:[fromColorWell color]];     
}

- (IBAction)toColorAction:(id)sender 
{
}
- (IBAction)directionAction:(id)sender 
{
}
@end
