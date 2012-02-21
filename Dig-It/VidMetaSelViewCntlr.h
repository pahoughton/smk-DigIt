/**
  File:		VidMetaSelViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  10:53 AM
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
@class VidMetaSelDataSrc;

@interface VidMetaSelViewCntlr : NSViewController <NSTabViewDelegate>
@property (strong) VidMetaSelDataSrc * dataSrc;
@property (strong) NSString * srcTitle;
@property (strong) NSString * srcYear;
@property (strong) NSString * srcUpc;
@property (assign) BOOL aliveAndWell;


@property (weak) IBOutlet NSTextField *titleTF;
@property (weak) IBOutlet NSTextField *yearTF;
@property (weak) IBOutlet NSProgressIndicator *progressInd;
@property (weak) IBOutlet NSTableView *metaTView;

+(VidMetaSelViewCntlr *)showSelfIn:(NSView *)viewToReplace 
                             title:(NSString *)title 
                              year:(NSString *)year 
                               upc:(NSString *)upc;

- (IBAction)selectMetaAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
