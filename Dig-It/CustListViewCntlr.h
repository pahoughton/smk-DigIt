/**
  File:		CustListViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  10:21 AM
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

@class SMKDBConnMgr;
@class CustUpcViewCntlr;
@class CustListDataSrc;

@interface CustListViewCntlr : NSViewController
@property (strong) CustListDataSrc * custListDataSrc;
@property (weak) IBOutlet NSTableView *custListTableView;

@property (weak) IBOutlet NSSearchField *searchBox;
@property (weak) IBOutlet NSButton *addUPCsButton;
@property (weak) IBOutlet NSButton *editCustButton;

+(CustListViewCntlr *)showSelfIn:(NSView *)viewToReplace;

- (IBAction)addEditCustAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)addUPCsAction:(id)sender;

@end
