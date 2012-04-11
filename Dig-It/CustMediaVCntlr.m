//
//  CustMediaVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "CustMediaVCntlr.h"
#import "CustMediaListDataSrc.h"

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
//@synthesize upcDetailsV = _upcDetailsV;

+(CustMediaVCntlr *)createAndReplaceView:(NSView *)viewToReplace custId:(NSNumber *)cid;
{
  NSBundle * myBundle = [NSBundle bundleForClass:[CustMediaVCntlr class]];
  CustMediaVCntlr * me = [[CustMediaVCntlr alloc]
                          initWithNibName:@"CustMediaView" bundle:myBundle];
  [me setCustId:cid];
  [me replaceView:viewToReplace makeResizable:TRUE];
  return me;
}

-(void)replaceView:(NSView *)viewToReplace custId:(id)cid
{
  [self replaceView:viewToReplace makeResizable:TRUE];
  [self.custMediaListVC changeDataSrcKey:cid];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)awakeFromNib
{
  SMKLogDebug(@"lv: %@  dv: %@",self.listView,self.detailView);
  
  [self setCustMediaListVC:[MetaListViewCntlr 
                          createAndReplaceView:self.listView 
                          dataSrc: [[CustMediaListDataSrc alloc] init ]]];
  [self.custMediaListVC setSelectionDelegate:self];
  [self.custMediaListVC changeDataSrcKey:self.custId];
  /*
   [me setUpcDetailsV:[[UpcMetaSelectionDetailsView alloc]
   initWithViewToReplace:me.detailView]];
   */
}
-(void)selected:( id<MetaListDataEntity>)item
{
  SMKLogDebug(@"selected %@",item);
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
