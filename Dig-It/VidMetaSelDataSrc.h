/**
  File:		VidMetaSelDataSrc.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  9:07 AM
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
#import "DIDB.h"
@class SMKDBConnMgr;
@class VidMetaSelDataSrc;
@class ArtBrowswerItemGatherer;

@interface VidMetaSelEntity : NSObject
@property (retain) NSImage * thumb;
@property (retain) NSString * title;
@property (retain) NSString * year;
@property (retain) NSString * mpaa;
@property (retain) NSString * genres;
@property (retain) NSString * actors;
@property (retain) NSString * directors;
@property (assign) SMKDigitDS source;
@property (retain) NSString * sourceId;
@property (retain) NSString * desc;
@property (retain) ArtBrowswerItemGatherer * artGath;

@end

@interface VidMetaRecGather : NSOperation
@property (weak) VidMetaSelDataSrc * dataStore;
@property (retain) NSString * searchTitle;
@property (retain) NSString * searchYear;

-(id)initWithDataStore:(VidMetaSelDataSrc *)dest 
                 title:(NSString *)title 
                  year:(NSString *)year;

@end

@interface VidMetaSelDataSrc : NSObject <NSTableViewDataSource>
@property (retain) NSMutableArray  * dataRows;
@property (strong) NSMutableArray  * artGatherList;
@property (retain) SMKDBConnMgr * db;
@property (retain) VidMetaRecGather * gather;

+(NSString *)kvoChangeKey;
+(NSString *)kvoDoneKey;

-(id)initWithTitle:(NSString *)title year:(NSString *)year;
-(void)findTitle:(NSString *)title year:(NSString *)year;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

@end
