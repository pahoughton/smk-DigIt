//
//  CustMediaVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "CustMediaVCntlr.h"
#import "SMKLogger.h"

@interface CustMediaVCntlr ()

@end

@implementation CustMediaVCntlr
@synthesize custId = _custId;
@synthesize searchUpcTF;
@synthesize MediaTypeCB;
@synthesize searchTitleTF;
@synthesize searchYearTF;
@synthesize stopOrGoIW;
@synthesize progressInd;
@synthesize statusTF;
@synthesize searchOrSaveButton;
@synthesize listView;
@synthesize detailView;
@synthesize custMediaListVC = _custMediaListVC;
@synthesize upcDetailsV = _upcDetailsV;

+(CustMediaVCntlr *)createAndReplaceView:(NSView *)viewToReplace custId:(NSNumber *)cid;
{
  NSBundle * myBundle = [NSBundle bundleForClass:[CustMediaVCntlr class]];
  CustMediaVCntlr * me = [[CustMediaVCntlr alloc]
                          initWithNibName:@"CustMediaView" bundle:myBundle];
  [me setCustId:cid];
  SMKLogDebug(@"lv: %@  dv: %@",me.listView,me.detailView);
  
  [me setCustMediaListVC:
   [CustMediaListVCntlr createAndReplaceView:[me listView] 
                                      custId:me.custId]];
  [me.custMediaListVC setSelectionDelegate:me];
  [me setUpcDetailsV:[[UpcMetaSelectionDetailsView alloc]
                      initWithViewToReplace:me.detailView]];
  
  [me replaceView:viewToReplace makeResizable:TRUE];
  return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)selected:(MetaListDataEntity *)item
{
  
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
