//
//  CustMediaVCntlr.h
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import <ReplacementViewCntlr.h>

@interface CustMediaVCntlr : ReplacementViewCntlr
@property (weak) IBOutlet NSSearchField *listSearchSF;
@property (weak) IBOutlet NSTextField *searchUpcTF;
@property (weak) IBOutlet NSComboBox *MediaTypeCB;
@property (weak) IBOutlet NSTextField *searchTitleTF;
@property (weak) IBOutlet NSTextField *searchYear;
@property (weak) IBOutlet NSImageView *stopOrGoIW;
@property (weak) IBOutlet NSProgressIndicator *progressInd;
@property (weak) IBOutlet NSTextField *statusTF;
@property (weak) IBOutlet NSButton *searchOrSaveButton;

@property (weak) IBOutlet ReplacementView *listView;
@property (weak) IBOutlet ReplacementView *detailView;

- (IBAction)listSearchAction:(id)sender;
- (IBAction)searchUpcAction:(id)sender;
- (IBAction)searchOrSaveAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
