/**
  File:		CustListViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  10:21 AM
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
#import "CustListViewCntlr.h"
#import "CustListDataSrc.h"
#import "CustUpcViewCntlr.h"
#import "CustEditViewCntlr.h"
#import "DIDB.h"
#import <SMKDB.h>
#import <SMKLogger.h>

static CustListViewCntlr * me;

@implementation CustListViewCntlr
@synthesize custListDataSrc;
@synthesize custListTableView;
@synthesize searchBox;
@synthesize addUPCsButton;
@synthesize editCustButton;

#pragma mark Initialization
+(CustListViewCntlr *)showSelfIn:(NSView *)viewToReplace
{
    if( me == nil ) {
        me = [CustListViewCntlr alloc];
        me = [me initWithNibName:@"CustListView" bundle:nil];
    }
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        SMKLogDebug(@"init");
        custListDataSrc = [[CustListDataSrc alloc] init];
    }
    
    return self;
}

-(void) tableSelectionChanged:(NSNotification *)note;
{
    SMKLogDebug(@"sel changed %@", note);
    NSInteger sel = [custListTableView selectedRow];
    if( sel < 0 ) {
        [addUPCsButton setEnabled:FALSE];
        [editCustButton setEnabled:FALSE];
        SMKLogDebug(@"opps no selection"); 
    } else {
        [addUPCsButton setEnabled:TRUE];
        [editCustButton setEnabled:TRUE];
    }

}

-(void)awakeFromNib
{
    SMKLogDebug(@"awake self %p", self);
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(tableSelectionChanged:) 
               name:NSTableViewSelectionDidChangeNotification 
             object:custListTableView];
    [[custListDataSrc gather] addObserver:self 
                               forKeyPath:[CustListDataSrc kvoKey] 
                                  options:NSKeyValueObservingOptionNew 
                                  context:nil];
    if( custListTableView != nil ) {
        [custListTableView setDataSource:custListDataSrc];
        [custListTableView reloadData];
    } else {
        SMKLogError(@"What, no table view???");
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    SMKLogDebug(@"kvo keypath %@", keyPath);
    if( [keyPath isEqualToString:[CustListDataSrc kvoKey]] ) {
        [custListTableView reloadData];
    }
}

#pragma mark Buttons
- (IBAction)addEditCustAction:(id)sender 
{
    [CustEditViewCntlr showSelfIn:[self view]];
}

- (IBAction)searchAction:(id)sender 
{
}

- (IBAction)addUPCsAction:(id)sender 
{
    NSInteger sel = [custListTableView selectedRow];
    if( sel < 0 ) {
        SMKLogDebug(@"opps no selection"); 
    } else {
        NSDictionary * custInfo = [[custListDataSrc dataRows] objectAtIndex:sel];
        [CustUpcViewCntlr showSelfIn:[self view] custInfo:custInfo];
    }
}
@end
