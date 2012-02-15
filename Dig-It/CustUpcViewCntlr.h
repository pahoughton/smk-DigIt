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
@class VidMetaSelWinCntlr;

@interface CustUpcViewCntlr : NSViewController <SMKDBRecProc>
@property (retain) SMKDBConnMgr * db;
@property (assign) NSView * myContainerView;
@property (retain) VidMetaSelWinCntlr * metaSelWinCntlr;
@property (retain) NSDictionary * custInfo;
@property (assign) BOOL custHasUPC;
@property (assign) BOOL aliveAndWell;
@property (assign) BOOL needToRip;
@property (retain) NSMutableDictionary * uvfDetailsCache;
@property (retain) NSSound * goodSound;
@property (retain) NSSound * badSound;
@property (retain) NSImage * noArtImage;
@property (retain) NSImage * goImage;
@property (retain) NSImage * stopImage;

@property (strong) IBOutlet NSArrayController *upcListAcntlr;
@property (weak) IBOutlet NSScrollView *upcListTableView;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSButton *searchButton;
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

+(CustUpcViewCntlr *)showSelfIn:(NSView *)viewToReplace custInfo:(NSDictionary *)cust;

-(void) setCust:(NSDictionary *)cust;

- (IBAction)stopOrGoImageAct:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)searchButton:(id)sender;
- (IBAction)upcEntered:(id)sender;
- (IBAction)thumbButton:(id)sender;
- (IBAction)playMedia:(id)sender;
- (IBAction)titleAction:(id)sender;

@end
