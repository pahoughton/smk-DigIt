/**
  File:		CustListDataSrc.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <Foundation/Foundation.h>
@class SMKDBConnMgr;
@class CustListDataSrc;

@interface CustRecGather : NSOperation
@property (weak) CustListDataSrc * dataStore;

-(id)initWithDataStore:(CustListDataSrc *)dest;

@end


@interface CustListDataSrc : NSObject <NSTableViewDataSource>
@property (retain) NSMutableArray  * dataRows;
@property (retain) SMKDBConnMgr * db;
@property (retain) CustRecGather * gather;

+(NSString *)kvoKey;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

@end
