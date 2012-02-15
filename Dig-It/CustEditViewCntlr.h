/**
  File:		CustEditViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  2:29 PM
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
#import <SMKDBConnMgr.h>

@interface CustEditViewCntlr : NSViewController <SMKDBRecProc>
@property (assign) BOOL aliveAndWell;
@property (retain) SMKDBConnMgr * db;
@property (assign) BOOL dataRequested;

@property (strong) IBOutlet NSArrayController *custListAcntlr;
@property (weak) IBOutlet NSTableView *custListTableView;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSSearchField *searchValue;
@property (weak) IBOutlet NSTextField *isSavedLabel;
@property (weak) IBOutlet NSTextField *firstNameTF;

+(CustEditViewCntlr *)showSelfIn:(NSView *)viewToReplace;

- (IBAction)addCustButton:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)searchAction:(id)sender;

-(void)refreshData;

@end
