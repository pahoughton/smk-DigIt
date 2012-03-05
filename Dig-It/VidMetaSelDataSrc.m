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
@synthesize searchMediaType;
@synthesize searchUpc;
@synthesize searchTitle;
@synthesize searchYear;
@synthesize getMore;
@synthesize didMoreSearch;

-(id)initWithType:(NSString *)mediaType
              upc:(NSString *)upc
            title:(NSString *)title 
             year:(NSString *)year
          getMore:(BOOL)more
{
    self = [super init];
    if( self ) {
        [self setData:[[NSMutableArray alloc] init]];
        [self setArtGatherList:[[NSMutableArray alloc]init]];
        [self setDb:[[SMKDBConnMgr alloc]init]];

        [self setSearchMediaType:mediaType];
        [self setSearchUpc:upc];
        [self setSearchTitle:title];
        [self setSearchYear:year];
        [self setGetMore:more];
        [self setDidMoreSearch:FALSE];
    }
    return self;
}

-(void)searchVideoMeta
{
    id <SMKDBResults> metaRslts;
    NSMutableArray * rec;
    
    SMKLogDebug(@"sql: %@", [DIDB sel_vid_meta_sel_details:searchTitle 
                                                      year:searchYear] );
    // first Titles
    metaRslts = [[db connect]
                 query:[DIDB sel_vid_meta_sel_details:searchTitle 
                                                 year:searchYear]];
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
        
        NSString * metaSource = [rec objectAtIndex:0];
        NSNumber * vid_id_num = [rec objectAtIndex:1];
        NSString * vid_id = [vid_id_num stringValue];
        
        if( [metaSource isEqualToString:@"Vid Meta"] ) {
            [meta setSource:SMKDIDS_VidMeta];
        } else {
            [meta setSource:SMKDIDS_VidTitles];
        }
        [meta setSourceId:vid_id];
        
        // thumb is 9
        NSData * thumbData = [rec objectAtIndex:9];
        if( ! SMKisNULL(thumbData) ) {
            [meta setThumb:[[NSImage alloc]initWithData:thumbData]];
        } else {
            [meta setArtGath:[[ArtBrowswerItemGatherer alloc]initWithOpQ:nil]];
            if( [meta source] == SMKDIDS_VidMeta ) {
                [[meta artGath]gatherDigVidMetaArt:vid_id_num];
            } else if( [meta source] == SMKDIDS_VidTitles ) {
                [[meta artGath]gatherDigVidTitleArt:vid_id_num];
            }
            [artGatherList addObject:[meta artGath]];
        }
        [meta setTitle:[rec objectAtIndex:2]];
        id recValObj;
        NSNumber * recValNum = [rec objectAtIndex:5];
        NSString * recValStr;
        if( ! SMKisNULL(recValNum) ) {
            recValStr = [recValNum stringValue];
        } else {
            recValStr = @"";
        }
        [meta setYear:recValStr];
        
#define SETVAL( _sInx_, _dest_ ) \
        recValObj = [rec objectAtIndex:_sInx_]; \
        recValStr = (SMKisNULL(recValObj) ? @"" : recValObj);\
        [meta _dest_:recValStr] \
        
        SETVAL(3, setMpaa);
        SETVAL(4, setDesc);
        SETVAL(6, setGenres);
        SETVAL(7, setActors);
        SETVAL(8, setDirectors);
        
        [data addObject:meta];
    }    
}


-(void)searchAudioMeta
{
    id <SMKDBResults> metaRslts;
    NSMutableArray * rec;
    SMKLogDebug(@"sql: %@", [DIDB sel_aud_meta_sel_details:searchUpc
                                                     title:searchTitle 
                                                      year:searchYear
                                                   getMore:getMore] );
    
    // first Titles
    metaRslts = [[db connect]
                 query:[DIDB sel_aud_meta_sel_details:searchUpc
                                                title:searchTitle 
                                                 year:searchYear
                                              getMore:getMore]];
    while((rec = [metaRslts fetchRowArray])) {
        VidMetaSelEntity * meta = [[VidMetaSelEntity alloc] init];
        
        NSString * metaSource = [rec objectAtIndex:0];
        NSNumber * aud_id_num = [rec objectAtIndex:1];
        NSString * aud_id = [aud_id_num stringValue];
        
        if( [metaSource isEqualToString:@"Aud FDB"] ) {
            [meta setSource:SMKDIDS_AudFdb];
        } else {
            [meta setSource:SMKDIDS_AudAlbums];
        }
        [meta setSourceId:aud_id];
        
        // thumb is 9
        NSData * thumbData = [rec objectAtIndex:9];
        if( ! SMKisNULL(thumbData) ) {
            [meta setThumb:[[NSImage alloc]initWithData:thumbData]];
        }
        /*
        else {
            [meta setArtGath:[[ArtBrowswerItemGatherer alloc]initWithOpQ:nil]];
            if( [metaSource isEqualToString:@"Vid Meta"] ) {
                [[meta artGath]gatherDigVidMetaArt:vid_id_num];
            } else if( [metaSource isEqualToString:@"Video"] ) {
                [[meta artGath]gatherDigVidTitleArt:vid_id_num];
            }
            [artGatherList addObject:[meta artGath]];
        }
        */
        [meta setTitle:[rec objectAtIndex:2]];
        id recValObj;
        NSNumber * recValNum = [rec objectAtIndex:5];
        NSString * recValStr;
        if( ! SMKisNULL(recValNum) ) {
            recValStr = [recValNum stringValue];
        } else {
            recValStr = @"";
        }
        [meta setYear:recValStr];
        
        SETVAL(3, setMpaa);
        SETVAL(4, setDesc);
        SETVAL(6, setGenres);
        SETVAL(7, setActors);
        SETVAL(8, setDirectors);
        
        [data addObject:meta];
    }    
}

-(void)searchTMDb
{
    [self setDidMoreSearch:TRUE];
    
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
    if( [[self searchMediaType] isEqualToString:@"video"] ) {
        [self searchVideoMeta];
        if( [data count] < 1 ) {
            [self searchTMDb];
        }
        
    } else if( [[self searchMediaType] isEqualToString:@"TMDb"] ) {
        [self searchTMDb];                
    
    } else if( [[self searchMediaType] isEqualToString:@"audio"] ) {
        [self searchAudioMeta];
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
@synthesize didMoreSearch;

+(NSString *)kvoDataRows
{
    return @"dataRows";
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( object == gather && [keyPath isEqualToString:@"isFinished"] ) {
        [self setDidMoreSearch:[gather didMoreSearch]];
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

-(void)findMeta:(NSString *)mediaType 
            upc:(NSString *)upc
          title:(NSString *)title 
           year:(NSString *)year
        getMore:(BOOL)more
{
    if( [title length] < 2 ) {
        [SMKAlertWin alertWithMsg:
         [NSString stringWithFormat:@"Title must be 2 or more chars wide '%@'",title]];
        return;
    }
    SMKLogDebug(@"findMeta %@ %@", mediaType, title);
    [self setGather:[[VidMetaRecGather alloc] initWithType:mediaType 
                                                       upc:upc
                                                     title:title 
                                                      year:year 
                                                   getMore:more]];
    [gather addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    [gather doSearch];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    SMKLogDebug(@"mds # rows %u", (dataRows ? [dataRows count] : 0) );
    return (dataRows ? [dataRows count] : 0);
}


@end
