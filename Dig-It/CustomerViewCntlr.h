/**
  File:		CustomerViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  12:01 PM
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
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPersonView.h>
@class CustomerDataSrc;
@class CustUpcDataSrc;

@interface CustomerViewCntlr : NSViewController
@property (strong) CustomerDataSrc * dataSrc;
@property (strong) NSNumber * curCustId;
@property (strong) CustUpcDataSrc * upcDataSrc;

@property (weak) IBOutlet NSTableView *contactListTV;
@property (weak) IBOutlet NSSearchField *contactSearch;

@property (weak) IBOutlet NSTextField *fullNameTF;
@property (weak) IBOutlet NSTextField *orginizationTF;
@property (weak) IBOutlet NSTextField *emailTF;
@property (weak) IBOutlet NSTextField *mainPhoneTF;
@property (weak) IBOutlet NSTextField *altPhoneTF;
@property (weak) IBOutlet NSTextField *addrStreetTF;
@property (weak) IBOutlet NSTextField *addrCityTF;
@property (weak) IBOutlet NSTextField *addrStateTF;
@property (weak) IBOutlet NSTextField *zipCodeTF;
@property (weak) IBOutlet NSNumberFormatter *zipCodeNFmt;
@property (weak) IBOutlet NSTextField *custNotesTF;

@property (weak) IBOutlet NSImageView *smkCustImage;
@property (weak) IBOutlet NSTextField *isSavedLabel;

@property (weak) IBOutlet NSButton *addCustButton;
@property (weak) IBOutlet NSButton *saveCustButton;
@property (weak) IBOutlet NSButton *ordersButton;
@property (weak) IBOutlet NSButton *upcButton;
@property (weak) IBOutlet NSButton *mediaButton;

+(CustomerViewCntlr *)showSelfIn:(NSView *)viewToReplace;
- (IBAction)contactListSelection:(NSTableView *)sender;
- (IBAction)searchContactListAct:(NSSearchField *)sender;
- (IBAction)addCustAction:(id)sender;
- (IBAction)saveCustAction:(id)sender;
- (IBAction)ordersAction:(id)sender;
- (IBAction)upcsAction:(id)sender;
- (IBAction)mediaAction:(id)sender;

@end
