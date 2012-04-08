//
//  CustMediaVCntlr.h
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <ReplacementViewCntlr.h>
#import "CustMediaListVCntlr.h"
#import "SMKCocoaDigitizeUI/UpcMetaSelectionDetailsView.h"

@interface CustMediaVCntlr : ReplacementViewCntlr <ListSelectionDelegate>
@property (strong) NSNumber * custId;

@property (weak) IBOutlet NSSearchField *listSearchSF;
@property (weak) IBOutlet NSTextField *searchUpcTF;
@property (weak) IBOutlet NSComboBox *MediaTypeCB;
@property (weak) IBOutlet NSTextField *searchTitleTF;
@property (weak) IBOutlet NSTextField *searchYearTF;
@property (weak) IBOutlet NSImageView *stopOrGoIW;
@property (weak) IBOutlet NSProgressIndicator *progressInd;
@property (weak) IBOutlet NSTextField *statusTF;
@property (weak) IBOutlet NSButton *searchOrSaveButton;

@property (weak) IBOutlet ReplacementView *listView;
@property (weak) IBOutlet ReplacementView *detailView;

@property (strong) CustMediaListVCntlr * custMediaListVC;
@property (strong) UpcMetaSelectionDetailsView * upcDetailsV;

+(CustMediaVCntlr *)createAndReplaceView:(NSView *)viewToReplace;
-(void)selected:(MetaListDataEntity *)item;

- (IBAction)listSearchAction:(id)sender;
- (IBAction)searchUpcAction:(id)sender;
- (IBAction)searchOrSaveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
