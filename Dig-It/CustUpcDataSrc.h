/**
  File:		CustUpcDataSrc.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <Foundation/Foundation.h>
@interface CustUpcGatherer : NSOperation
@property (strong) NSMutableArray * records;
@property (strong) NSNumber * cid;

-(id)initWithCid:(NSNumber *)custId;

@end

@interface CustUpcDataSrc : NSObject <NSTableViewDataSource>
@property (strong) NSOperationQueue * opQueue;
@property (strong) NSMutableArray * data;
@property (strong) NSMutableDictionary * upcDict;
@property (strong) CustUpcGatherer * upcGath;

+(NSString *)kvoData;

-(void)getCustUpcs:(NSNumber *)custId;
-(void)addCustUpc:(NSNumber *)upc;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
            row:(NSInteger)rowIndex;

@end
