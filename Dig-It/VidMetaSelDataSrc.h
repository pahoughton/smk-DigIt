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
@property (retain) NSMutableArray * data;
@property (strong) NSMutableArray  * artGatherList;
@property (retain) SMKDBConnMgr * db;
@property (strong) NSString * searchMediaType;
@property (strong) NSString * searchUpc;
@property (retain) NSString * searchTitle;
@property (retain) NSString * searchYear;
@property (assign) BOOL getMore;
@property (assign) BOOL didMoreSearch;

-(id)initWithType:(NSString *)mediaType
              upc:(NSString *)upc
            title:(NSString *)title 
             year:(NSString *)year
          getMore:(BOOL)more;

-(void)doSearch;

@end

@interface VidMetaSelDataSrc : NSObject <NSTableViewDataSource>
@property (retain) NSMutableArray  * dataRows;
@property (retain) NSMutableArray * artGatherList;
@property (retain) VidMetaRecGather * gather;
@property (assign) BOOL didMoreSearch;

+(NSString *)kvoDataRows;
-(id)init;

-(void)findMeta:(NSString *)mediaType 
            upc:(NSString *)upc
          title:(NSString *)title 
           year:(NSString *)year
        getMore:(BOOL)more;

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

@end
