/**
  File:		VidMetaSelDataSrc.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
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
#import "VidMetaSelDataSrc.h"
#import "VidMetaSelCellView.h"
#import "DIDB.h"
#import <SMKLogger.h>
#import <SMKDB.h>
#import <TMDbQuery.h>
#import <SMKAlertWin.h>


@implementation VidMetaSelEntity
@synthesize title;
@synthesize thumb;
@synthesize year;
@synthesize mpaa;
@synthesize genres;
@synthesize actors;
@synthesize directors;
@synthesize source;
@synthesize desc;
@synthesize sourceId;


-(NSString *)description
{
    CGFloat tWidth = 0;
    CGFloat tHeight = 0;
    if( thumb ) {
        tWidth = [thumb size].width;
        tHeight = [thumb size].height;
    }
    return 
    [NSString stringWithFormat:
     @"DIVidMetaEntity: \n"
     "     thumb: %0.1fx%0.1f %@\n"
     "     title: %@\n"
     "      year: %@\n"
     "      mpaa: %@\n"
     "    genres: %@\n"
     "    actors: %@\n"
     " directors: %@\n"
     "    source: %@\n"
     "  sourceId: %@\n"
     "      desc: %@\n",
     tWidth,tHeight, thumb,
     title,
     year,
     mpaa,
     genres,
     actors,
     directors,
     source,
     sourceId,
     desc];
}
@end
    
@implementation VidMetaRecGather
@synthesize dataStore;
@synthesize searchTitle;
@synthesize searchYear;

-(id)initWithDataStore:(VidMetaSelDataSrc *)dest
                 title:(NSString *)title 
                  year:(NSString *)year
{
    self = [super init];
    if( self ) {
        [self setDataStore:dest];
        [self setSearchTitle:title];
        [self setSearchYear:year];
    }
    return self;
}

-(void)main
{
    id <SMKDBResults> metaRslts;
    NSMutableArray * rec;
    NSInteger rowCount = [[dataStore dataRows] count];
    // first Titles
    metaRslts = [[[dataStore db] connect]
                 query:[DIDB sel_vt_info_title:searchTitle 
                                          year:searchYear]];
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];

        NSNumber * vid_id_num = [rec objectAtIndex:0];
        NSString * vid_id = [vid_id_num stringValue];
        
        [meta setThumb:[DIDB vtThumb:vid_id
                              artid:[rec objectAtIndex:18]]];
        [meta setTitle:[rec objectAtIndex:1]];
        [meta setYear:[DIDB dateYear:[rec objectAtIndex:4]]];
        [meta setMpaa:[rec objectAtIndex:3]];
        [meta setGenres:[DIDB vtGenres:vid_id]];
        [meta setActors:[DIDB vtActors:vid_id]];
        [meta setDirectors:[DIDB vtDirectors:vid_id]];
        [meta setSource:@"Titles"];
        [meta setSourceId:vid_id];
        [meta setDesc:[rec objectAtIndex:6]];
        [[dataStore dataRows] addObject:meta];
    }
    if( [[dataStore dataRows] count] != rowCount ) {
        [self willChangeValueForKey:[VidMetaSelDataSrc kvoChangeKey]];
        [self didChangeValueForKey:[VidMetaSelDataSrc kvoChangeKey]];
        rowCount = [[dataStore dataRows] count];
    }
    // Now Meta
    metaRslts = [[[dataStore db] connect]
                 query:[DIDB sel_vtm_info_title:searchTitle 
                                          year:searchYear]];
    
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
        
        NSNumber * vid_meta_id_num = [rec objectAtIndex:0];
        NSString * vid_meta_id = [vid_meta_id_num stringValue];
        
        [meta setThumb:[DIDB vtmThumb:vid_meta_id
                              artid:[rec objectAtIndex:18]]];
        [meta setTitle:[rec objectAtIndex:1]];
        [meta setYear:[DIDB dateYear:[rec objectAtIndex:4]]];
        [meta setMpaa:[rec objectAtIndex:3]];
        [meta setGenres:[DIDB vtmGenres:vid_meta_id]];
        [meta setActors:[DIDB vtmActors:vid_meta_id]];
        [meta setDirectors:[DIDB vtmDirectors:vid_meta_id]];
        [meta setSource:@"Meta"];
        [meta setSourceId:vid_meta_id];
        [meta setDesc:[rec objectAtIndex:6]];
        [[dataStore dataRows] addObject:meta];
    }
    if( [[dataStore dataRows] count] != rowCount ) {
        [self willChangeValueForKey:[VidMetaSelDataSrc kvoChangeKey]];
        [self didChangeValueForKey:[VidMetaSelDataSrc kvoChangeKey]];
        rowCount = [[dataStore dataRows] count];
    }
    // now TMDB
    TMDbQuery * tmdb = [[TMDbQuery alloc] init];
    if( [tmdb search:searchTitle getDetail:TRUE] ) {
        for( NSDictionary * movie in [tmdb data] ) {
            VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];

            NSArray * artlist = [movie valueForKey:@"artlist"];
            for( NSDictionary * art in artlist ) {
                if( [art valueForKey:@"art"] != nil ) {
                    [meta setThumb:[art valueForKey:@"art"]];
                }
            }
            [meta setTitle:[movie valueForKey:@"title"]];
            NSString * reldt = [movie valueForKey:@"release_date"];
            if( reldt && [reldt length] > 4 )  {
                NSString * reldt = [movie valueForKey:@"release_date"];
                [meta setYear:[reldt substringToIndex:4]];
            }
            [meta setMpaa:[movie valueForKey:@"mpaa_rating"]];
            NSMutableArray * actList = [[NSMutableArray alloc]initWithCapacity:3];
            NSMutableArray * dirList = [[NSMutableArray alloc]initWithCapacity:3];
            NSArray * people = [movie valueForKey:@"people"];
            if( people != nil ) {
                for( NSDictionary * person in people ) {
                    if( [[person valueForKey:@"job"] isEqualToString:@"Actor"] ) {
                        [actList addObject:[person valueForKey:@"name"]];
                    } else if( [[person valueForKey:@"job"] isEqualToString:@"Director"] ) {
                        [dirList addObject:[person valueForKey:@"name"]];
                    } 
                    if( [actList count] == 3 && [dirList count] == 3 ) {
                        break;
                    }
                }
            }
            [meta setActors: [actList componentsJoinedByString:@", "]];
            [meta setDirectors:[dirList componentsJoinedByString:@", "]];

            NSMutableArray * genreList = [[NSMutableArray alloc]initWithCapacity:3];
            NSArray * genres = [movie valueForKey:@"genres"];
            if( genres != nil ) {
                for( NSDictionary * genre in genres ) {
                    [genreList addObject:[genre valueForKey:@"genre"]];
                    if( [genreList count] >= 3 ) {
                        break;
                    }
                }
            }
            [meta setGenres:[genreList componentsJoinedByString:@", "]];
            [meta setDesc:[movie valueForKey:@"desc_long"]];
            [meta setSource:@"TMDb"];
            [meta setSourceId:[movie valueForKey:@"tmdb_id"]];
            
            [[dataStore dataRows] addObject:meta];
        }
        
        if( [[dataStore dataRows] count] != rowCount ) {
            [self.dataStore willChangeValueForKey:[VidMetaSelDataSrc kvoDoneKey]];
            [self.dataStore didChangeValueForKey:[VidMetaSelDataSrc kvoDoneKey]];
            rowCount = [[dataStore dataRows] count];
        }
    }
}
@end

@implementation VidMetaSelDataSrc
@synthesize dataRows;
@synthesize db;
@synthesize gather;
+(NSString *)kvoChangeKey
{
    return @"dataStore";
}

+(NSString *)kvoDoneKey
{
    return @"MetaSearchComplete";
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
        gather = [[VidMetaRecGather alloc] init];
        [gather addObserver:self forKeyPath:[VidMetaSelDataSrc kvoChangeKey]
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    }
    return self;    
}
-(id)initWithTitle:(NSString *)title year:(NSString *)year
{
    self = [super init];
    if( self ) {
        dataRows = [[NSMutableArray alloc]init];
        db = [[SMKDBConnMgr alloc]init];
        gather = [[VidMetaRecGather alloc] initWithDataStore:self title:title year:year];
        [[db opQueue] addOperation:gather];
        [gather addObserver:self forKeyPath:[VidMetaSelDataSrc kvoChangeKey]
                    options:0
                    context:nil];
    }
    return self;
}

-(void)findTitle:(NSString *)title year:(NSString *)year
{
    if( [title length] < 2 ) {
        [SMKAlertWin alertWithMsg:
         [NSString stringWithFormat:@"Title must be 2 or more chars wide '%@'",title]];
        return;
    }
    [dataRows removeAllObjects];
    [gather setDataStore:self];
    [gather setSearchTitle:title];
    [gather setSearchYear:year];
    [[db opQueue] addOperation:gather];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    SMKLogDebug(@"mds # rows %u", [dataRows count]);
    return [dataRows count];
}


@end
