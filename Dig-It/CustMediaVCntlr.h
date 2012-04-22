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
#import "SMKCocoaDigitizeUI/MetaDetailListVCntlr.h"
#import "MetaSearchDataSrc.h"

@interface CustMediaVCntlr : ReplacementViewCntlr 
<ListSelectionDelegate
,MetaDataRetrieverDelegate>

@property (strong) ReplacementViewCntlr * doneVC;
@property (strong) NSNumber *             myCustId;
@property (assign) BOOL                   custHasMedia;
@property (strong) MediaMetaSearch *      metaSearch;
@property (strong) MetaDataGatherer *     gath;

@property (strong) id<MetaDataRetriever>  upcFoundObj;
@property (strong) id<MetaDataEntity>     upcFoundSrc;

@property (retain) NSSound * goodSound;
@property (retain) NSSound * badSound;
@property (retain) NSData  * noArtImageData;
@property (retain) NSImage * noArtImage;
@property (retain) NSImage * goImage;
@property (retain) NSImage * stopImage;

@property (weak) IBOutlet NSTextField *   searchUpcTF;
@property (weak) IBOutlet NSComboBox *    mediaTypeCB;
@property (weak) IBOutlet NSTextField *   searchTitleTF;
@property (weak) IBOutlet NSTextField *   searchYearTF;
@property (weak) IBOutlet NSImageView *   stopOrGoIW;
@property (weak) IBOutlet NSButton *      searchOrSaveButton;


@property (weak) IBOutlet ReplacementView * listV;
@property (weak) IBOutlet ReplacementView * detailV;


@property (strong) MetaListViewCntlr *           custMediaListVC;
@property (strong) MediaMetaDetailsView *        mediaMetaDetailVC;
@property (strong) MetaDetailListVCntlr *        metaSelVC;

-(id)initWithDoneVC:(ReplacementViewCntlr *)doneVC;

-(void)replaceView:(ReplacementView *)vToReplace;
-(void)replaceView:(ReplacementView *)vToReplace custId:(NSNumber *)cid;



-(void)selected:(id <MetaListDataEntity>)item;

- (IBAction)searchUpcAction:(id)sender;
- (IBAction)searchTitleAction:(id)sender;

- (IBAction)searchOrSaveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
