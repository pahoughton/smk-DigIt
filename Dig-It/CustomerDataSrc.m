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
#import <SMKDB.h>
#import <SMKCommon.h>
#import <AddressBook/ABAddressBook.h>

NSString * SMK_AbpCustIdPropName         = @"com.SecureMediaKeepers.cust_id";
NSString * SMK_AbpCustEmailIdentPropName = @"com.SecureMediaKeepers.cust_email_ident";
NSString * SMK_AbpCustEmailPropName      = @"com.SecureMediaKeepers.cust_email";


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
@synthesize data = _data;

-(id)init
{
  self = [super init];
  if( self ) {
    [self setData:[[NSMutableArray alloc]init]];
    
    // make sure the Address book has our cust id prop
    NSArray * abpProps = [ABPerson properties];
    BOOL abpHasSMKProps = FALSE;
    for( NSString * propName in abpProps ) {
      if( [SMK_AbpCustEmailIdentPropName isEqualToString:propName] ) {
        abpHasSMKProps = TRUE;
        break;
      }
    }
    if( ! abpHasSMKProps ) {
      
      NSDictionary * apbProp = 
      [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithInt: kABIntegerProperty],
       SMK_AbpCustIdPropName,
       [NSNumber numberWithInt: kABStringProperty],
       SMK_AbpCustEmailPropName,
       [NSNumber numberWithInt: kABStringProperty],
       SMK_AbpCustEmailIdentPropName,
       nil];
      if( [ABPerson addPropertiesAndTypes:apbProp] < 0 ) {
        SMKThrow( @"add cust id prop failed for %@",apbProp );
      }
    }
  }
  return self;
}

-(void)main
{
  /* FYI most of this code is for FIRST run through 
   and the addtion of smk email & email ident values
   */
  NSMutableDictionary * emailDict = [[NSMutableDictionary alloc]init];
  NSMutableDictionary * custIdDict = [[NSMutableDictionary alloc]init];
  
  id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
  id <SMKDBResults> custRslts;
  custRslts = [db query:@"SELECT cust_id, lower(email) from customers"];
  NSMutableArray * rec;
  while((rec = [custRslts fetchRowArray])) {
    NSNumber * custId = [rec objectAtIndex:0];
    NSString * custEmail = [rec objectAtIndex:1];
    
    [emailDict setObject:custId forKey:custEmail];
    [custIdDict setObject:custEmail forKey:custId];
  }
  
  ABAddressBook * myAB = [ABAddressBook addressBook];
  for( ABPerson * abp in [myAB people] ) {
    
    // ONLY work with iCloud records
    NSString * iCloudUUID = [abp valueForProperty:@"com.apple.uuid"];
    if( iCloudUUID == nil ) {
      continue;
    }
    
    CustomerEntity * custEnt = [[CustomerEntity alloc] init];
    NSNumber * abCustId = [abp valueForProperty:SMK_AbpCustIdPropName];
    NSString * abCustEmail = [abp valueForProperty:SMK_AbpCustEmailPropName];
    NSString * abCustEmailIdent = [abp valueForProperty:SMK_AbpCustEmailIdentPropName];
    if( abCustId == nil ) {
      // not a 'known' cust, do search
      ABMultiValue * ebEmailList = [abp valueForProperty:kABEmailProperty];
      if( ebEmailList == nil || ebEmailList.count == 0 ) {
        // no email - can't be a cust
        continue;
      }
      for( NSInteger ei = 0; ei < ebEmailList.count; ++ ei ) {
        NSString * abEmail = [ebEmailList valueAtIndex:ei];
        abEmail = abEmail.lowercaseString;
        
        NSString * abEmailIdent = [ebEmailList identifierAtIndex: ei];
        /*
         SMKLogDebug(@"ab em: %@ %@ %@", 
         [abp valueForProperty:kABFirstNameProperty],
         [abp valueForProperty:kABLastNameProperty],
         abEmail );
         */
        NSNumber * custId = [emailDict objectForKey:abEmail];
        if( custId ) {
          [custEnt setEmailInx: ei ];
          SMKLogDebug(@"ab match em: %@ %@ %@", 
                      [abp valueForProperty:kABFirstNameProperty],
                      [abp valueForProperty:kABLastNameProperty],
                      abEmail );
          
          if( ! [CustomerDataSrc setABPersonSMKProps:abp
                                                 val:custId 
                                          valPropKey:SMK_AbpCustIdPropName 
                                               email:abEmail 
                                          emailIdent:abEmailIdent] ) {
            // wont return on fail - exception
          } else {
            abCustId = [abp valueForProperty:SMK_AbpCustIdPropName];
            abCustEmail = abEmail;
            abCustEmailIdent = abEmailIdent;
          }
        }
      }
    } else if( abCustEmail == nil ) {
      // email not set
      NSString * smkEmail = [custIdDict objectForKey:abCustId];
      SMKLogDebug(@"smk email: %@", smkEmail);
      ABMultiValue * ebEmailList = [abp valueForProperty:kABEmailProperty];
      if( ebEmailList == nil || [ebEmailList count] == 0 ) {
        // add email we have on file
        ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
        [nMulti addValue:smkEmail withLabel:@"smk"];
        NSString * emIdent = [nMulti identifierAtIndex:0];
        if( ! [CustomerDataSrc setABPersonSMKProps:abp
                                    val:nMulti 
                             valPropKey:kABEmailProperty
                                  email:smkEmail 
                             emailIdent:emIdent] ) {
          // wont actually return fail
        }
        if( emIdent == nil ) {
          // lets see if one is autogenerated;
          ebEmailList = [abp valueForProperty:kABEmailProperty];
          if( ebEmailList != nil ) {
            emIdent = [ebEmailList identifierAtIndex:0];
            NSError * err;
            if( emIdent != nil
               && ! [abp setValue:emIdent
                      forProperty:SMK_AbpCustEmailIdentPropName
                            error:&err] ) {
                 // opps
                 SMKThrow( @"set cust error %@",err );
               }
            
          }
        }
        
      } else { // ebEmailList != nil and count > 0
        // search email list for match
        for( NSInteger ei = 0; ei < [ebEmailList count]; ++ ei ) {
          NSString * abEmail = [ebEmailList valueAtIndex:ei];
          abEmail = [abEmail lowercaseString];
          NSString * emIdent = [ebEmailList identifierAtIndex:ei];
          NSError * err;
          if( [abEmail isEqualToString:smkEmail] ) {
            // yay found it
            if( ! [abp setValue:smkEmail
                    forProperty:SMK_AbpCustEmailPropName
                          error:&err] ) {
              // opps
              SMKThrow( @"set cust error %@",err );
              
            } else if( emIdent != nil
                      && ! [abp setValue:emIdent
                             forProperty:SMK_AbpCustEmailIdentPropName
                                   error:&err] ) {
                        // opps
                        SMKThrow( @"set cust error %@",err );
                      }
          }
        }
      }
    }
    [custEnt setAbPersonID:[abp uniqueId]];
    
    NSString * cid;
    if( abCustId != nil ) {
      //cid = [NSString stringWithFormat:@" %ld",[abCustId integerValue]];
      cid = @" *";
    } else {
      cid = @"  ";
    }
    
    NSString * listName;
    NSNumber * abpFlagsNum = [abp valueForProperty:kABPersonFlags];
    NSInteger abpFlags = [abpFlagsNum integerValue];
    
    if( (abpFlags & kABShowAsMask) & kABShowAsCompany ) {
      listName = [[NSString alloc]initWithFormat:
                  @"%@ %@",
                  cid,
                  [abp valueForProperty:kABOrganizationProperty]];
    } else {
      listName = [[NSString alloc]initWithFormat:
                  @"%@ %@ %@",
                  cid,
                  [abp valueForProperty:kABFirstNameProperty],
                  [abp valueForProperty:kABLastNameProperty]];
    }
    [custEnt setListValue:listName];
    [self.data addObject:custEnt];
  }
  if( [myAB hasUnsavedChanges] ) {
    [myAB save];
  }
  [self.data sortUsingComparator:^(id objA, id objB) {
    CustomerEntity * a = objA;
    CustomerEntity * b = objB;
    if( [[a listValue] characterAtIndex:1] == ' ' ) {
      if( [[b listValue] characterAtIndex:1] == ' ' ) {
        return [[a listValue] compare:[b listValue]];
      } else {
        return (NSComparisonResult)NSOrderedDescending;
      }
    } else {
      if( [[b listValue] characterAtIndex:1] != ' ' ) {
        return [[a listValue] compare:[b listValue]];
      } else {
        return (NSComparisonResult)NSOrderedAscending;
      }
    }
  }];
  
  SMKLogDebug(@"gath done %lu", self.data.count);
}
@end

@implementation CustomerDataSrc
@synthesize aBook       = _aBook;
@synthesize filter      = _filter;
@synthesize opQueue     = _opQueue;
@synthesize gath        = _gath;
@synthesize tableData   = _tableData;
@synthesize origData    = _origData;

+(BOOL)setABPersonSMKProps:(ABPerson *)abp
                       val:(NSObject *)val
                valPropKey:(NSString *)valPropKey
                     email:(NSString *)emAddr
                emailIdent:(NSString *)emIdent
{
  NSError * err;
  if( ! [abp setValue:val
          forProperty:valPropKey
                error:&err] ) {
    // opps
    SMKThrow( @"set cust error %@",err );
  } else if( ! [abp setValue:emAddr
                 forProperty:SMK_AbpCustEmailPropName
                       error:&err] ) {
    // opps
    SMKThrow( @"set cust error %@",err );
    
  } else if( emIdent != nil && ! [abp setValue: emIdent
                                   forProperty: SMK_AbpCustEmailIdentPropName
                                         error: &err] ) {
    // opps
    SMKThrow( @"set cust error %@",err );
  }
  return TRUE;
}

-(id)init
{
  self = [super init];
  if( self ) {
    [self setABook: ABAddressBook.sharedAddressBook ];
    [self setTableData: nil];
    [self setOpQueue: [[NSOperationQueue alloc]init]];
    [self setGath:[[CustDataGatherer alloc] init]];
    [self.gath addObserver:self 
                forKeyPath:@"isFinished"
                   options:0 
                   context:nil];
    [self.opQueue addOperation: self.gath];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(addrBookDidChange:) 
                                                 name:kABDatabaseChangedExternallyNotification 
                                               object:nil];
  }
  return self;
}

-(void)addrBookDidChange:(NSNotification *)note
{
  // just reload it
  [self setGath:[[CustDataGatherer alloc] init]];
  [self.gath addObserver:self 
              forKeyPath:@"isFinished"
                 options:0 
                 context:nil];
  [self.opQueue addOperation: self.gath];
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
  if( object == self.gath && [keyPath isEqualToString:@"isFinished" ] ) {
    [self setOrigData: self.gath.data ];
    [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
    [self setTableData: self.gath.data ];
    [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];
  }
}

-(void)sortData
{
  NSArray * sorted = [self.tableData sortedArrayUsingComparator:^(id objA, id objB) {
    CustomerEntity * a = objA;
    CustomerEntity * b = objB;
    if( [[a listValue] characterAtIndex:1] == ' ' ) {
      if( [[b listValue] characterAtIndex:1] == ' ' ) {
        return [[a listValue] compare:[b listValue]];
      } else {
        return (NSComparisonResult)NSOrderedDescending;
      }
    } else {
      if( [[b listValue] characterAtIndex:1] != ' ' ) {
        return [[a listValue] compare:[b listValue]];
      } else {
        return (NSComparisonResult)NSOrderedAscending;
      }
    }
  }];
  
  [self setOrigData: self.gath.data ];
  [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
  [self setTableData:sorted];
  [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];
  
}
-(NSString *)filter
{
  return self->_filter;
}
-(void)setFilter:(NSString *)filter
{
  if( filter != nil && filter.length ) {
    if( ! [filter isEqualToString: self->_filter ] ) {
      NSMutableArray * filtData = [[NSMutableArray alloc]
                                   initWithCapacity:self.origData.count];
      for( CustomerEntity * rec in self.origData ) {
        if( [rec.listValue rangeOfString:filter 
                                 options:NSCaseInsensitiveSearch].location
           != NSNotFound ) {
          [filtData addObject:rec];
        }
      }
      [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
      [self setTableData:filtData];
      [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];            
    }
  } else {
    if( self.tableData != self.origData ) {
      [self willChangeValueForKey:[CustomerDataSrc kvoTableData]];
      [self setTableData: self.origData];
      [self didChangeValueForKey:[CustomerDataSrc kvoTableData]];            
    }
  }
  self->_filter = filter;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return self.tableData.count;
}

- (id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
            row:(NSInteger)row
{
  // SMKLogDebug(@"obj at %d",row);
  return [[self.tableData objectAtIndex:row] listValue];
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
