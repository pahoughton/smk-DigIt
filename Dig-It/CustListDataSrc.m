/**
  File:		CustListDataSrc.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/13/12  2:53 AM
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
#import "CustListDataSrc.h"
#import "DIDB.h"
#import <SMKDB.h>

@implementation CustRecGather
@synthesize dataStore;

-(id)initWithDataStore:(CustListDataSrc *)dest
{
    self = [super init];
    if( self ) {
        [self setDataStore:dest];
    }
    return self;
}
-(void)main
{
    id <SMKDBResults> custRslts;
    custRslts = [[[dataStore db]connect]query:[DIDB sel_c_cid_fn_ln_ph_em]];
    NSMutableDictionary * rec;
    while((rec = [custRslts fetchRowDict])) {
        [[dataStore dataRows] addObject:rec];
    }
    [self willChangeValueForKey:[CustListDataSrc kvoKey]];
    [self didChangeValueForKey:[CustListDataSrc kvoKey]];
}
@end

@implementation CustListDataSrc
@synthesize dataRows;
@synthesize db;
@synthesize gather;
+(NSString *)kvoKey
{
    return @"dataStore";
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    SMKLogDebug(@"kvo kp:%@ %u", keyPath, [dataRows count]);
}
-(id)init
{
    self = [super init];
    if( self ) {
        dataRows = [[NSMutableArray alloc]init];
        db = [[SMKDBConnMgr alloc]init];
        gather = [[CustRecGather alloc] initWithDataStore:self];
        [[db opQueue] addOperation:gather];
        [gather addObserver:self forKeyPath:[CustListDataSrc kvoKey]
                  options:NSKeyValueObservingOptionNew
                  context:nil];
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    SMKLogDebug(@"cds # rows %u", [dataRows count]);
    return [dataRows count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary * rec = [dataRows objectAtIndex:row];
    
    // SMKLogDebug(@"vfc row %d id %@ rec %@", row, [tableColumn identifier], rec);
    return [rec objectForKey:[tableColumn identifier]];
}


@end
