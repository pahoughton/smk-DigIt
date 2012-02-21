/**
  File:		VidSelArtPickerViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  10:51 AM
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
#import <Quartz/Quartz.h>

@interface VidSelArtPickerViewCntlr : NSViewController
@property (strong) NSArray * artList;
@property (weak) IBOutlet IKImageBrowserView *artBrowser;
@property (weak) IBOutlet IKImageView *artImageView;


+(VidSelArtPickerViewCntlr *)showSelfIn:(NSView *)viewToReplace artList:(NSArray *)art;

@property (weak) IBOutlet NSButton *selectArtAction;

- (IBAction)cancelAction:(id)sender;

@end
