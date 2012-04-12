//
//  CustMediaVCntlr.h
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <ReplacementViewCntlr.h>
#import "SMKCocoaDigitizeUI/MetaListViewCntlr.h"
#import "SMKCocoaDigitizeUI/MediaMetaDetailsView.h"
#import "MetaDataGatherer.h"

@interface CustMediaVCntlr : ReplacementViewCntlr 
<ListSelectionDelegate
,MetaDataRetrieverDelegate>

@property (strong) NSNumber *          custId;
@property (assign) BOOL                custHasMedia;
@property (strong) MetaDataGatherer *  gatherer;

@property (strong) NSString *          foundSrc;
@property (strong) NSNumber *          foundSrcId;

@property (retain) NSSound * goodSound;
@property (retain) NSSound * badSound;
@property (retain) NSData  * noArtImageData;
@property (retain) NSImage * noArtImage;
@property (retain) NSImage * goImage;
@property (retain) NSImage * stopImage;

@property (weak) IBOutlet NSTextField *   searchUpcTF;
@property (weak) IBOutlet NSComboBox *    MediaTypeCB;
@property (weak) IBOutlet NSTextField *   searchTitleTF;
@property (weak) IBOutlet NSTextField *   searchYearTF;
@property (weak) IBOutlet NSImageView *   stopOrGoIW;
@property (weak) IBOutlet NSProgressIndicator * progressInd;
@property (weak) IBOutlet NSTextField *   statusTF;
@property (weak) IBOutlet NSButton *      searchOrSaveButton;

@property (weak) IBOutlet ReplacementView * listView;
@property (weak) IBOutlet ReplacementView * detailView;

@property (strong) MetaListViewCntlr *           custMediaListVC;
@property (strong) MediaMetaDetailsView *        mediaMetaDetailVC;


// @property (strong) UpcMetaSelectionDetailsView * upcDetailsV;

+(CustMediaVCntlr *)createAndReplaceView:(NSView *)viewToReplace
                                  custId:(NSNumber *)cid;
-(void)replaceView:(NSView *)viewToReplace custId:cid;

-(void)selected:(id <MetaListDataEntity>)item;

- (IBAction)searchUpcAction:(id)sender;
- (IBAction)searchTitleAction:(id)sender;

- (IBAction)searchOrSaveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
