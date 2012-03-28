/**
  File:		CustUpcViewCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  4:49 PM
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
#import <SMKDB.h>
@class VidMetaSelViewCntlr;
@class CustUpcDataSrc;

@interface CustUpcViewCntlr : NSViewController <SMKDBRecProc>
@property (strong) CustUpcDataSrc * upcDataSrc;
@property (retain) VidMetaSelViewCntlr * metaSelViewCntlr;
@property (strong) SMKDBConnMgr * db;
@property (strong) NSWindow * myWindow;
@property (retain) NSDictionary * custInfo;
@property (retain) NSNumber * custId;

@property (assign) BOOL custHasUPC;
@property (assign) BOOL aliveAndWell;
@property (assign) BOOL needToRip;
@property (assign) BOOL upcIsNew;
@property (strong) NSString * showingUPC;

@property (retain) NSMutableDictionary * upcDetailsCache;
@property (retain) NSSound * goodSound;
@property (retain) NSSound * badSound;
@property (retain) NSImage * noArtImage;
@property (retain) NSImage * goImage;
@property (retain) NSImage * stopImage;
@property (weak) IBOutlet NSComboBox *mediaTypeCB;

@property (weak) IBOutlet NSTableView *upcListTableView;
@property (weak) IBOutlet NSButton *saveSearchButton;
@property (weak) IBOutlet NSImageView *stopOrGoImage;
@property (weak) IBOutlet NSTextField *haveOrRipLabel;
@property (weak) IBOutlet NSTextField *custLabel;
@property (weak) IBOutlet NSTextField *curUpcValue;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSProgressIndicator *progressInd;

@property (weak) IBOutlet NSTextField *upcTitleTF;
@property (weak) IBOutlet NSTextField *upcYearTF;
@property (weak) IBOutlet NSTextField *upcMpaaTF;
@property (weak) IBOutlet NSTextField *upcGenresTF;
@property (weak) IBOutlet NSTextField *upcActorsTF;
@property (weak) IBOutlet NSTextField *upcDescTF;
@property (weak) IBOutlet NSImageView *upcThumbTF;

+(CustUpcViewCntlr *)showSelfIn:(NSView *)viewToReplace 
                       custInfo:(NSDictionary *)cust
                        upcData:(CustUpcDataSrc *)upcData;

-(void) setCust:(NSDictionary *)cust;
-(void) mtUpcDataAvailable;

- (IBAction)upcListSelectAction:(NSTableView *)sender;


- (IBAction)stopOrGoImageAct:(id)sender;
- (IBAction)thumbButton:(id)sender;

- (IBAction)saveSearchAction:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)upcEntered:(id)sender;
- (IBAction)playMedia:(id)sender;
- (IBAction)titleAction:(id)sender;
- (IBAction)mediaTypeAction:(id)sender;

@end
