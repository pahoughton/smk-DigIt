/**
  File:		CustUpcDataSrc.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/23/12  3:58 AM
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
#import "CustUpcDataSrc.h"
#import "DIDB.h"
#import <SMKDB.h>
#import <SMKCommon.h>

@implementation CustUpcGatherer
@synthesize records;
@synthesize cid;

-(id)initWithCid:(NSNumber *)custId
{
    self = [super init];
    if( self ) {
        [self setCid:custId];
    }
    return self;
}
-(void)main
{
    NSMutableArray * myData = [[NSMutableArray alloc]init];
    
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslts;
    if( [self isCancelled] ) {
        return;
    }
    rslts = [db query:[DIDB sel_cust_upc:cid]];
    NSMutableArray * rec;
    while( (rec = [rslts fetchRowArray]) ) {
        if( [self isCancelled] ) {
            return;
        } else {
            [myData addObject:rec];
        }
    }
    [self setRecords:myData];
}
@end

@implementation CustUpcDataSrc
@synthesize opQueue;
@synthesize data;
@synthesize upcDict;
@synthesize upcGath;
+(NSString *)kvoData
{
    return @"data";
}

-(id)init
{
    self = [super init];
    if( self ) {
        [self setOpQueue:[[NSOperationQueue alloc]init]];
        [self setData:nil];
    }
    return self;
}
-(void)getCustUpcs:(NSNumber *)custId
{
    [self setUpcGath:[[CustUpcGatherer alloc]initWithCid:custId]];
    [[self upcGath] addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
    [[self opQueue] addOperation:[self upcGath]];
}
-(void)addCustUpc:(NSNumber *)upc
{
    if( [self data] == nil ) {
        [self setData:[[NSMutableArray alloc]init]];
        [self setUpcDict:[[NSMutableDictionary alloc]init]];
    }
    NSArray * upcRec = [[NSArray alloc] initWithObjects:upc, [NSDate date], nil];
    
    [[self data]insertObject:upcRec atIndex:0];
    [[self upcDict] setObject:[upcRec objectAtIndex:1] forKey:[upcRec objectAtIndex:0]];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CustUpcGatherer * gath = object;
    [gath removeObserver:self forKeyPath:keyPath];
    [self setUpcGath:nil];
    NSMutableDictionary * ldDict = [[NSMutableDictionary alloc]initWithCapacity:[[gath records] count]];
    for( NSArray * rec in [gath records] ){
        [ldDict setObject:[rec objectAtIndex:1] forKey:[rec objectAtIndex:0]];
    }
    [self setUpcDict:ldDict];
    [self willChangeValueForKey:[CustUpcDataSrc kvoData]];
    [self setData:[gath records]];
    [self didChangeValueForKey:[CustUpcDataSrc kvoData]];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return (data ? [data count] : 0);
}

-(id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [[data objectAtIndex:rowIndex] objectAtIndex:0];
}

-(void)dealloc
{
    if( upcGath ) {
        [upcGath removeObserver:self forKeyPath:@"isFinished"];
        upcGath = nil;
    }
}
@end
