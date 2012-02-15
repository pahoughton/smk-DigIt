/**
  File:		VidMetaSelWinCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  8:28 AM
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

@interface VidMetaSelWinCntlr : NSWindowController  
                                <NSTableViewDelegate,
                                 NSTableViewDataSource>
@property (strong) VidMetaSelDataSrc * dataSource;
@property (strong) NSString * srcTitle;
@property (strong) NSString * srcYear;
@property (strong) NSString * srcUpc;
@property (assign) BOOL aliveAndWell;

@property (weak) IBOutlet NSTextField *metaSearchTitle;
@property (weak) IBOutlet NSTextField *metaSearchYear;
@property (weak) IBOutlet NSProgressIndicator *searchProgressInd;

@property (weak) IBOutlet NSButton *searchButton;
@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSTableView *metaTableView;

+(VidMetaSelWinCntlr *)showSelfWithTitle:(NSString *)title year:(NSString *)year upc:(NSString *)upc;

- (IBAction)searchMetaButton:(id)sender;
- (IBAction)cancelButton:(id)sender;

@end
