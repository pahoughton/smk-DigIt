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
#import "ArtBrowswerItemGatherer.h"
#import "DIDB.h"
#import <SMKCocoaCommon.h>
#import <SMKDB.h>

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
@synthesize artGath;


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
     [DIDB dsForUser:source],
     sourceId,
     desc]; 
}
@end
    
@implementation VidMetaRecGather
@synthesize data;
@synthesize artGatherList;
@synthesize db;
@synthesize searchTitle;
@synthesize searchYear;
@synthesize doTMDbSearch;

-(id)initWithTitle:(NSString *)title 
              year:(NSString *)year
        TMDbSearch:(BOOL)doTMDb
{
    self = [super init];
    if( self ) {
        [self setData:[[NSMutableArray alloc] init]];
        [self setArtGatherList:[[NSMutableArray alloc]init]];
        [self setDb:[[SMKDBConnMgr alloc]init]];

        [self setSearchTitle:title];
        [self setSearchYear:year];
        [self setDoTMDbSearch:doTMDb];
    }
    return self;
}

-(void)searchTitles
{
    id <SMKDBResults> metaRslts;
    NSMutableArray * rec;
    
    // first Titles
    metaRslts = [[db connect]
                 query:[DIDB sel_vt_info_title:searchTitle 
                                          year:searchYear]];
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
        
        NSNumber * vid_id_num = [rec objectAtIndex:0];
        NSString * vid_id = [vid_id_num stringValue];
        
        // art_thumb_id 18
        NSNumber * art_thumb_id = [rec objectAtIndex:18];
        if( ! SMKisNULL( art_thumb_id ) ) {
            [meta setThumb:[DIDB vtThumb:vid_id_num
                                   artid:art_thumb_id]];
        } else {
            [meta setArtGath:[[ArtBrowswerItemGatherer alloc]initWithOpQ:nil]];
            [[meta artGath]gatherDigVidTitleArt:vid_id_num];
            [artGatherList addObject:[meta artGath]];
        }
        [meta setTitle:[rec objectAtIndex:1]];
        [meta setYear:[DIDB dateYear:[rec objectAtIndex:4]]];
        [meta setMpaa:[rec objectAtIndex:3]];
        [meta setGenres:[DIDB vtGenres:vid_id_num]];
        [meta setActors:[DIDB vtActors:vid_id_num]];
        [meta setDirectors:[DIDB vtDirectors:vid_id_num]];
        [meta setSource:SMKDIDS_VidTitles];
        [meta setSourceId:vid_id];
        [meta setDesc:[rec objectAtIndex:6]];
        [data addObject:meta];
    }    
}
-(void)searchMeta
{
    id <SMKDBResults> metaRslts;
    NSMutableArray * rec;
    // Now Meta
    metaRslts = [[db connect]
                 query:[DIDB sel_vtm_info_title:searchTitle 
                                           year:searchYear]];
    
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
        
        NSNumber * vid_meta_id_num = [rec objectAtIndex:0];
        NSString * vid_meta_id = [vid_meta_id_num stringValue];
        
        NSNumber * art_thumb_id = [rec objectAtIndex:18];
        if( ! SMKisNULL( art_thumb_id ) ) {
            [meta setThumb:[DIDB vtThumb:vid_meta_id_num
                                   artid:art_thumb_id]];
        } else {
            [meta setArtGath:[[ArtBrowswerItemGatherer alloc]initWithOpQ:nil]];
            [[meta artGath]gatherDigVidMetaArt:vid_meta_id_num];
            [artGatherList addObject:[meta artGath]];
        }
        [meta setTitle:[rec objectAtIndex:1]];
        [meta setYear:[DIDB dateYear:[rec objectAtIndex:4]]];
        [meta setMpaa:[rec objectAtIndex:3]];
        [meta setGenres:[DIDB vtmGenres:vid_meta_id_num]];
        [meta setActors:[DIDB vtmActors:vid_meta_id_num]];
        [meta setDirectors:[DIDB vtmDirectors:vid_meta_id_num]];
        [meta setSource:SMKDIDS_VidMeta];
        [meta setSourceId:vid_meta_id];
        [meta setDesc:[rec objectAtIndex:6]];
        [data addObject:meta];
    }
    
}
-(void)searchTMDb
{
    [self setDoTMDbSearch:TRUE];
    
    TMDbQuery * tmdb = [[TMDbQuery alloc] init];
    if( [tmdb search:searchTitle getDetail:TRUE] ) {
        for( NSDictionary * movie in [tmdb data] ) {
            VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
            
            [meta setSource:SMKDIDS_TMDb];
            [meta setSourceId:[movie valueForKey:@"tmdb_id"]];
            
            NSArray * artlist = [movie valueForKey:@"artlist"];
            for( NSMutableDictionary * art in artlist ) {
                if( [[art valueForKey:@"size"] isEqualToString:@"w154"] ) {
                    NSImage * img = [tmdb getImage:art];
                    if( img == nil ) {
                        [art setObject:img forKey:@"art"];
                        [meta setThumb:img];
                        break;
                    }
                }
            }
            [meta setArtGath:[[ArtBrowswerItemGatherer alloc]initWithOpQ:nil]];
            [[meta artGath]gatherTMDBArtDictList:artlist];
            [artGatherList addObject:[meta artGath]];
            
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
            
            [data addObject:meta];
        }
    }

}

-(void)doSearch
{
    [[db opQueue] addOperation:self];
}
-(void)main
{
    if(!  doTMDbSearch ) {
        [self searchTitles];
        [self searchMeta];
        if( [data count] < 1 ) {
            [self searchTMDb];
        }
    } else {
        [self searchTMDb];        
    }
    for( ArtBrowswerItemGatherer * gath in artGatherList ) {
        [gath goWithOpQueue:[db opQueue]];
    }
}
@end

@implementation VidMetaSelDataSrc
@synthesize dataRows;
@synthesize artGatherList;
@synthesize gather;
@synthesize didTMDbSearch;

+(NSString *)kvoDataRows
{
    return @"dataRows";
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( object == gather && [keyPath isEqualToString:@"isFinished"] ) {
        [self setDidTMDbSearch:[gather doTMDbSearch]];
        [self setArtGatherList:[gather artGatherList]];
        [self willChangeValueForKey:[VidMetaSelDataSrc kvoDataRows]];
        [self setDataRows:[gather data]];
        [self didChangeValueForKey:[VidMetaSelDataSrc kvoDataRows]];
        [gather removeObserver:self forKeyPath:@"isFinished"];
        [self setGather:nil];
    }
    SMKLogDebug(@"kvo kp:%@ %u", keyPath, [dataRows count]);
}
-(id)init
{
    self = [super init];
    if( self ) {
        dataRows = nil;
        artGatherList = nil;
        gather = nil;
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
    [self setGather:[[VidMetaRecGather alloc] initWithTitle:title year:year TMDbSearch:FALSE]];
    [gather addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    [gather doSearch];
}

-(void)searchTMDb:(NSString *)title year:(NSString *)year
{
    if( [title length] < 2 ) {
        [SMKAlertWin alertWithMsg:
         [NSString stringWithFormat:@"Title must be 2 or more chars wide '%@'",title]];
        return;
    }
    [self setGather:[[VidMetaRecGather alloc] initWithTitle:title year:year TMDbSearch:TRUE]];
    [gather addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    [gather doSearch];    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    SMKLogDebug(@"mds # rows %u", (dataRows ? [dataRows count] : 0) );
    return (dataRows ? [dataRows count] : 0);
}


@end
