/**
  File:		CustomerDataSrc.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/20/12  12:53 AM
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
#import "CustomerDataSrc.h"
#import "DIDB.h"
#import <SMKLogger.h>
#import <SMKDB.h>
#import <AddressBook/ABAddressBook.h>

@implementation CustomerEntity
@synthesize abPersonID;
@synthesize listValue;
@synthesize emailInx;
@synthesize mPhoneInx;
@synthesize aPhoneInx;
@synthesize addrInx;

-(id)init
{
    self = [super init];
    if( self ) {
        emailInx = -1;
        mPhoneInx = -1;
        aPhoneInx = -1;
        addrInx = -1;
    }
    return  self;
}
-(NSString *)description
{
    return [NSString stringWithFormat:
            @"  person: %@\n"
            "    listv: %@\n",
            abPersonID,
            listValue];
}
@end

@implementation CustDataGatherer
@synthesize gatherComplete;
@synthesize data;
@synthesize dbConn;

-(id)init
{
    self = [super init];
    if( self ) {
        [self setGatherComplete:FALSE];
        [self setData:[[NSMutableArray alloc]init]];
        [self setDbConn:[[SMKDBConnMgr alloc]init]];
        
        // make sure the Address book has our cust id prop
        NSArray * abpProps = [ABPerson properties];
        BOOL abpHasCustId = FALSE;
        for( NSString * propName in abpProps ) {
            if( [[DIDB abpCustIdPropName] isEqualToString:propName] ) {
                abpHasCustId = TRUE;
                break;
            }
        }
        if( ! abpHasCustId ) {
            
            NSDictionary * apbProp = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt: kABIntegerProperty], [DIDB abpCustIdPropName],
                                      nil];
            if( [ABPerson addPropertiesAndTypes:apbProp] < 0 ) {
                [NSException raise:@"ABPerson" format:@"add cust id prop failed for %@",apbProp];
            }
        }
    }
    return self;
}
-(void)gather
{
    [self setGatherComplete:FALSE];
    
    [[dbConn opQueue] addOperation:self];
}

+(NSString *)kvoGatherComplete
{
    return @"gatherComplete";
}

-(void)main
{
    NSMutableDictionary * emailDict = [[NSMutableDictionary alloc]init];
    
    id <SMKDBConn> db = [dbConn getNewDbConn];
    id <SMKDBResults> custRslts;
    custRslts = [db query:[DIDB sel_cust_details]];
    NSMutableDictionary * rec;
    while((rec = [custRslts fetchRowDict])) {
        NSString * custEmail = [[rec objectForKey:@"email"] lowercaseString];
        SMKLogDebug(@"em: %@", custEmail);
        [emailDict setObject:rec forKey:custEmail];
    }
    ABAddressBook * myAB = [ABAddressBook addressBook];
    for( ABPerson * abp in [myAB people] ) {
        CustomerEntity * custEnt = [[CustomerEntity alloc] init];
        NSNumber * abCustId = [abp valueForProperty:[DIDB abpCustIdPropName]];
        if( abCustId == nil ) {
            // not a 'known' cust, search
            ABMultiValue * ebEmailList = [abp valueForProperty:kABEmailProperty];
            if( ebEmailList == nil || [ebEmailList count] == 0 ) {
                // no email - can't be a cust
                continue;
            }
            for( NSInteger ei = 0; ei < [ebEmailList count]; ++ ei ) {
                NSString * abEmail = [ebEmailList valueAtIndex:ei];
                /*
                SMKLogDebug(@"ab em: %@ %@ %@", 
                            [abp valueForProperty:kABFirstNameProperty],
                            [abp valueForProperty:kABLastNameProperty],
                            abEmail );
                 */
                NSDictionary * custRec = [emailDict objectForKey:[abEmail lowercaseString]];
                if( custRec ) {
                    SMKLogDebug(@"ab match em: %@ %@ %@", 
                                [abp valueForProperty:kABFirstNameProperty],
                                [abp valueForProperty:kABLastNameProperty],
                                abEmail );

                    NSError * err;
                    if( ! [abp setValue:[custRec objectForKey:@"cust_id"]
                           forProperty:[DIDB abpCustIdPropName]
                                  error:&err] ) {
                        // opps
                        [NSException raise:@"ABPerson" format:@"set cust error %@",err];
                        break; // done with this record
                    } else {
                        abCustId = [abp valueForProperty:[DIDB abpCustIdPropName]];
                    }
                }
            }
        }
        [custEnt setAbPersonID:[abp uniqueId]];

        NSString * cid;
        if( abCustId != nil ) {
            cid = [NSString stringWithFormat:@"(%d)",[abCustId integerValue]];
        } else {
            cid = @"   ";
        }
        NSString * listName = [[NSString alloc]initWithFormat:
                               @"%@ %@ %@",
                               cid,
                               [abp valueForProperty:kABFirstNameProperty],
                               [abp valueForProperty:kABLastNameProperty]];
        
        [custEnt setListValue:listName];
        [data addObject:custEnt];
    }
    if( [myAB hasUnsavedChanges] ) {
        [myAB save];
    }
    [data sortUsingComparator:^(id objA, id objB) {
        CustomerEntity * a = objA;
        CustomerEntity * b = objB;
        if( [[a listValue] characterAtIndex:0] == ' ' ) {
            if( [[b listValue] characterAtIndex:0] == ' ' ) {
                return [[a listValue] compare:[b listValue]];
            } else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        } else {
            if( [[b listValue] characterAtIndex:0] != ' ' ) {
                return [[a listValue] compare:[b listValue]];
            } else {
                return (NSComparisonResult)NSOrderedAscending;
            }
        }
    }];

    SMKLogDebug(@"gath done %d", [data count]);
    [self willChangeValueForKey:[CustDataGatherer kvoGatherComplete]];
    [self setGatherComplete:TRUE];
    [self didChangeValueForKey:[CustDataGatherer kvoGatherComplete]];
}
@end

@implementation CustomerDataSrc
@synthesize aBook;
@synthesize searchFilter;
@synthesize gath;
@synthesize tableData;

     
-(void)addrBookDidChange:(NSNotification *)note
{
    // just reload it
    [gath gather];
}
-(id)init
{
    self = [super init];
    if( self ) {
        searchFilter = nil;
        aBook = [ABAddressBook sharedAddressBook];
        tableData = nil;
        [self setGath:[[CustDataGatherer alloc] init]];
        [gath addObserver:self 
               forKeyPath:[CustDataGatherer kvoGatherComplete]
                  options:0 
                  context:nil];
        [gath gather];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(addrBookDidChange:) 
                                                     name:kABDatabaseChangedExternallyNotification 
                                                   object:nil];
    }
    return self;
}

+(NSString *)kvoTableData
{
    return @"tableData";
}

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context
{
    if( [keyPath isEqualToString:[CustDataGatherer kvoGatherComplete]] ) {
        [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
        [self setTableData:[gath data]];
        [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];
    }
}

-(void)setFilter:(NSString *)filter
{
    if( filter != nil && [filter length] ) {
        NSMutableArray * filtData = [[NSMutableArray alloc]initWithCapacity:[tableData count]];
        for( CustomerEntity * rec in tableData ) {
            NSRange rng = [[rec listValue] rangeOfString:filter options:NSCaseInsensitiveSearch];
            if( rng.location != NSNotFound ) {
                [filtData addObject:rec];
            }
        }
        [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
        [self setTableData:filtData];
        [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];            
        
    } else {
        if( tableData != [gath data] ) {
            [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
            [self setTableData:[gath data]];
            [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];            
        }
    }
    [self setSearchFilter:filter];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    // SMKLogDebug(@"num row %d",( tableData != nil ? [tableData count] : 0 ));
    if( tableData != nil ) {
        return [tableData count];
    } else {
        return 0;
    }
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
            row:(NSInteger)row
{
    // SMKLogDebug(@"obj at %d",row);
    return [[tableData objectAtIndex:row] listValue];
}

- (void)tableView:(NSTableView *)tableView 
   setObjectValue:(id)object 
   forTableColumn:(NSTableColumn *)tableColumn 
              row:(NSInteger)row
{
    // Edit ... (think about this)
}

- (void)tableView:(NSTableView *)tableView 
sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    ;
}

#pragma mark OutlineView
- (NSInteger)outlineView:(NSOutlineView *)outlineView 
  numberOfChildrenOfItem:(id)item
{
    return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView 
            child:(NSInteger)index 
           ofItem:(id)item
{
    return nil;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView 
   isItemExpandable:(id)item
{
    return FALSE;
}
- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
           byItem:(id)item
{
    return nil;
}
- (void)outlineView:(NSOutlineView *)outlineView 
     setObjectValue:(id)object 
     forTableColumn:(NSTableColumn *)tableColumn 
             byItem:(id)item
{

}
- (id)outlineView:(NSOutlineView *)outlineView 
itemForPersistentObject:(id)object
{
    return nil;
}
- (id)outlineView:(NSOutlineView *)outlineView 
persistentObjectForItem:(id)item
{
    return nil;
}
- (void)outlineView:(NSOutlineView *)outlineView 
sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    
}


@end
