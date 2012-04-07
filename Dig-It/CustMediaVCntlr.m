//
//  CustMediaVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "CustMediaVCntlr.h"

@interface CustMediaVCntlr ()

@end

@implementation CustMediaVCntlr
@synthesize cancelAction;
@synthesize searchOrSaveAction;
@synthesize listSearch;
@synthesize searchUpcTF;
@synthesize MediaTypeCB;
@synthesize searchTitleTF;
@synthesize searchYear;
@synthesize stopOrGoIW;
@synthesize progressInd;
@synthesize statusTF;
@synthesize searchOrSaveButton;
@synthesize listView;
@synthesize detailView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (IBAction)listSearchAction:(id)sender {
}

- (IBAction)searchUpcAction:(id)sender {
}

- (IBAction)searchOrSaveAction:(id)sender {
}

- (IBAction)cancelAction:(id)sender {
}
@end
