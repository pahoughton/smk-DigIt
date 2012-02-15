/**
  File:		CustEditViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  2:29 PM
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
#import "CustEditViewCntlr.h"
#import "CustListViewCntlr.h"
#import "DIDB.h"
#import <SMKLogger.h>

static CustEditViewCntlr * me;

@implementation CustEditViewCntlr
@synthesize aliveAndWell;
@synthesize db;
@synthesize dataRequested;
@synthesize custListTableView;
@synthesize custListAcntlr;
@synthesize saveButton;
@synthesize searchValue;
@synthesize isSavedLabel;
@synthesize firstNameTF;


#pragma mark Initialization
+(CustEditViewCntlr *)showSelfIn:(NSView *)viewToReplace
{
    if( me == nil ) {
        me = [CustEditViewCntlr alloc];
        me = [me initWithNibName:@"CustEditView" bundle:nil];
    }
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    [me refreshData];
    return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAliveAndWell:FALSE];
        [self setDb:[[SMKDBConnMgr alloc]init]];
        [self setDataRequested:FALSE];
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self setAliveAndWell:TRUE];
    [custListAcntlr setSelectsInsertedObjects:FALSE];
    [self refreshData];
}
-(void)custRecProc:(NSDictionary *)rec
{
    if( rec ) {
        [custListAcntlr addObject:rec];
    } else {
        dataRequested = FALSE;
        [self.custListAcntlr addObserver: self
                             forKeyPath: @"selectionIndex"
                                options: NSKeyValueObservingOptionNew
                                context: nil];
    }
}
-(void)refreshData
{
    if( dataRequested == FALSE ) {
        dataRequested = TRUE;
        if( [[custListAcntlr arrangedObjects] count] ) {
            // ugg no remove all objects :(
            NSRange rng;
            rng.location = 0;
            rng.length = [[custListAcntlr arrangedObjects] count];
            [custListAcntlr removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:rng]];
        }
        
        [db fetchAllRowsDictMtObj:self 
                             proc:@selector(custRecProc:) 
                              sql:[DIDB sel_cust_details]];
    }
}
#pragma mark KVO Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    SMKLogDebug(@"KVO %@", keyPath);
    // if( [keyPath isEqualToString:@"selectionIndex"] ) {
    if( [custListAcntlr selectionIndex] != NSNotFound ) {

        [isSavedLabel setStringValue:@""];
        [saveButton setEnabled:FALSE];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:NSTextDidChangeNotification 
                                                   object:nil];
        
        [self.custListAcntlr removeObserver:self forKeyPath:@"selectionIndex"];
    }
}

-(void) textDidChange:(NSNotification *)note
{
    NSLog(@"text change %@",note);
    [saveButton setEnabled:TRUE];
    [isSavedLabel setStringValue:@"NOT Saved"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification 
                                                  object:nil];
    [self.custListAcntlr addObserver: self
                          forKeyPath: @"selectionIndex"
                             options: NSKeyValueObservingOptionNew
                             context: nil];
}

- (IBAction)cancelAction:(id)sender
{
    SMKLogDebug(@"cancelButton");
    [CustListViewCntlr showSelfIn:[self view]];
}

- (IBAction)saveAction:(id)sender 
{
    NSDictionary * curCust = [self.custListAcntlr selection];
    if( [curCust valueForKey:@"cust_id"] != nil ) {
        // update
        [DIDB upd_cust:curCust];
    } else {
        NSUInteger selInx = [[self custListAcntlr] selectionIndex];
        NSDictionary * newRec = [DIDB ins_cust:curCust];
        // insert - remove old (no cust_id, no full_name)
        [[self custListAcntlr] removeObjectAtArrangedObjectIndex:selInx];
        // add new (has cust_id, full_name)
        [custListAcntlr setSelectsInsertedObjects:TRUE];
        [[self custListAcntlr]addObject:newRec];
        [custListAcntlr setSelectsInsertedObjects:FALSE];
    }
    [isSavedLabel setStringValue:@"Saved"];
    [saveButton setEnabled:FALSE];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];
}

- (IBAction)addCustButton:(id)sender 
{
    NSArray * custs = [self.custListAcntlr arrangedObjects];
    if ([[custs lastObject] valueForKey:@"cust_id"] != nil) {
        SMKLogDebug(@"add cust new");
        [custListAcntlr setSelectsInsertedObjects:TRUE];
        [self.custListAcntlr addObject:[[NSMutableDictionary alloc] init]];
        [custListAcntlr setSelectsInsertedObjects:FALSE];
    } else {
        // attemp add w/o save - sellect last object 
        SMKLogDebug(@"add cust again");
        [self.custListAcntlr setSelectionIndex:[custs count]];
    }
    [firstNameTF becomeFirstResponder];
}


- (IBAction)searchAction:(id)sender {
}
@end
