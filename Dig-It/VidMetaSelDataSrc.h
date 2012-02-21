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

@class SMKDBConnMgr;
@class VidMetaSelDataSrc;

@interface VidMetaArtGather : NSOperation
@property (retain) NSArray * tmdbArtList;
@property (assign) BOOL gatherComplete;
-(id)initWithTmdbArtList:(NSArray *)aList opQ:(NSOperationQueue *)opQ;

+(NSString *)kvoGatherComplete;

@end

@interface VidMetaSelEntity : NSObject
@property (retain) NSImage * thumb;
@property (retain) NSString * title;
@property (retain) NSString * year;
@property (retain) NSString * mpaa;
@property (retain) NSString * genres;
@property (retain) NSString * actors;
@property (retain) NSString * directors;
@property (retain) NSString * source;
@property (retain) NSString * sourceId;
@property (retain) NSString * desc;
@property (retain) VidMetaArtGather * tmdbArtGath;

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
@property (retain) SMKDBConnMgr * db;
@property (retain) VidMetaRecGather * gather;

+(NSString *)kvoChangeKey;
+(NSString *)kvoDoneKey;

-(id)initWithTitle:(NSString *)title year:(NSString *)year;
-(void)findTitle:(NSString *)title year:(NSString *)year;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

@end
