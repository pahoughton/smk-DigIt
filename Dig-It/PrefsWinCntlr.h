/**
  File:		PrefsWinCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  9:24 AM
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
@class DigItWinCntlr;

@interface PrefsWinCntlr : NSWindowController
@property (assign) DigItWinCntlr * mainWinCntlr;
@property (weak) IBOutlet NSTextField *errorMessageTextField;
@property (weak) IBOutlet NSComboBox *serverTypeSelector;

@property (weak) IBOutlet NSSecureTextField *passTextField;
@property (weak) IBOutlet NSButton *useKeyChain;

- (IBAction)okButton:(id)sender;

@end
