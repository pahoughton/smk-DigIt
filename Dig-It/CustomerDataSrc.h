/**
  File:		CustomerDataSrc.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <AddressBook/AddressBook.h>

extern NSString * SMK_AbpCustIdPropName;
extern NSString * SMK_AbpCustEmailIdentPropName;
extern NSString * SMK_AbpCustEmailPropName;

@interface CustomerEntity : NSObject
@property (strong) NSString * abPersonID;
@property (strong) NSString * listValue; // i.e. name or email
// the multi value indexes used when displaying a ABPerson
@property (assign) NSInteger emailInx;
@property (assign) NSInteger mPhoneInx;
@property (assign) NSInteger aPhoneInx;
@property (assign) NSInteger addrInx;

@end

@class SMKDBConnMgr;

@interface CustDataGatherer : NSOperation
@property (assign) BOOL gatherComplete;
@property (strong) NSMutableArray * data;
@property (strong) SMKDBConnMgr * dbConn;

+(NSString *)kvoGatherComplete;

-(void)gather;

@end

@interface CustomerDataSrc : NSObject <NSTableViewDataSource>
@property (strong) ABAddressBook * aBook;
@property (strong) NSString * searchFilter;
@property (strong) CustDataGatherer * gath;
@property (strong) NSArray * tableData;

+(NSString *)kvoTableData;
-(void)setFilter:(NSString *)filter;
-(void)sortData;
+(BOOL)setABPersonSMKProps:(ABPerson *)abp
                       val:(NSObject *)val
                valPropKey:(NSString *)valPropKey
                     email:(NSString *)emAddr
                emailIdent:(NSString *)emIdent;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
            row:(NSInteger)row;

- (void)tableView:(NSTableView *)tableView 
   setObjectValue:(id)object 
   forTableColumn:(NSTableColumn *)tableColumn 
              row:(NSInteger)row;

- (void)tableView:(NSTableView *)tableView 
sortDescriptorsDidChange:(NSArray *)oldDescriptors;



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object;
- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item;
- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors;

@end
