/**
 File:		AppDelegate.h
 Project:	Dig-It
 Desc:
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/06/2012 04:36
 Copyright:   Copyright (c) 2012 Secure Media Keepers
              www.SecureMediaKeepers.com
              All rights reserved.
 
 Revision History: (See ChangeLog for details)
 
 $Author$
 $Date$
 $Revision$
 $Name$
 $State$
 
 $Id$
 
 **/
#import "ReplacementViewCntlr.h"
#import "GradyVCntlr.h"
#import "SMKCocoaDigitizeUI/DigitizePrefsWinCntlr.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *      window;
@property (weak) IBOutlet ReplacementView * contentV;

@property (strong) GradyVCntlr *            gradyVC;
@property (strong) DigitizePrefsWinCntlr *  prefsWC;

- (IBAction)prefsMenuItem:(id)sender;
- (IBAction)artPickerMenuItem:(id)sender;

@end
