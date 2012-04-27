/**
  File:		ArtBrowswerItemGatherer.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/21/12  10:12 AM
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
#import "ArtBrowswerItemGatherer.h"
#import "AppUserValues.h"
#import <SMKCocoaCommon.h>
#import <SMKDB.h>
#import <SMKCommon.h>

@interface ABIGathSpec : NSObject
enum ABIGSpec { 
    TMDbArtListSpec,
    VidTitleIdSpec,
    VidMetaIdSpec,
    UNK_ABIGSpec
};
@property (assign) enum ABIGSpec spec;
@property (retain) id data;
+(ABIGathSpec *) opSpec:(enum ABIGSpec)s data:(id)d;

@end

@implementation ABIGathSpec
@synthesize spec;
@synthesize data;
+(ABIGathSpec *) opSpec:(enum ABIGSpec)s data:(id)d
{
    ABIGathSpec * me = [[ABIGathSpec alloc]init];
    [me setSpec:s];
    [me setData:d];
    return me;
}
@end


@implementation ArtBrowswerItemGatherer
@synthesize artList;
@synthesize opQ;
@synthesize gatherSpecsList;

-(void)doInit:(NSOperationQueue *)opQueue
{
    [self setOpQ:opQueue];
    [self setGatherSpecsList:[[NSMutableArray alloc]init]];
    [self setArtList:[[NSMutableArray alloc]init]];
}
-(id)init
{
    self = [super init];
    if( self ) {
        [self doInit:nil];
    }
    return self;
}
-(id)initWithOpQ:(NSOperationQueue *)opQueue
{
    self = [super init];
    if( self ) {
        [self doInit:opQueue];
    }
    return self;
}

-(void)doGather
{
    if( opQ != nil ) {
        [opQ addOperation:self];
    }
}
-(void)gatherTMDb:(NSString *)tmdb_id
{
  SMKFunctUnsup;
}
// a list of TMDbQuery art from getInfo or search;
-(void)gatherTMDBArtDictList:(NSArray *)tmdbArtList
{
    [[self gatherSpecsList]addObject:
     [ABIGathSpec opSpec:TMDbArtListSpec data:tmdbArtList]];
    [self doGather];
}
// a list of ArtBrowserItems
-(void)gatherABItems:(NSMutableArray *)items
{
  SMKFunctUnsup;
}

-(void)gatherDigVidTitleArt:(NSNumber *)vid_id
{
    [[self gatherSpecsList]addObject:
     [ABIGathSpec opSpec:VidTitleIdSpec data:vid_id]];
    [self doGather];
}

-(void)gatherDigVidMetaArt:(NSNumber *)vid_meta_id
{
    [[self gatherSpecsList]addObject:
     [ABIGathSpec opSpec:VidMetaIdSpec data:vid_meta_id]];
    [self doGather];
}

-(void)goWithOpQueue:(NSOperationQueue *)opQueue
{
    [self setOpQ:opQueue];
    [self doGather];
}

-(void)doGatherTMDbArtList:(ABIGathSpec *)spec
{

    NSMutableArray * myArtList = [self artList];
    NSMutableDictionary * tmdbIdLink = [[NSMutableDictionary alloc]init];
    
    TMDbQuery * tmdbq = [[TMDbQuery alloc]init];
    
    NSArray * tmdbArtDictList = [spec data];
    for( NSDictionary * tmdbArtDict in tmdbArtDictList ) {
        if( [self isCancelled] ) {
            return;
        }
        NSString * tmdb_id = [tmdbArtDict objectForKey:@"id"];

        ArtBrowserItem * abi = [tmdbIdLink objectForKey:tmdb_id];
        
        if( abi == nil ) {
            abi = [[ArtBrowserItem alloc]initWithSource:SMKDIDS_TMDb srcId:tmdb_id img:nil];
            [myArtList addObject:abi];
            [tmdbIdLink setObject:abi forKey:tmdb_id];
        }
        
        NSString * size = [tmdbArtDict objectForKey:@"size"];
        NSImage * img = [tmdbArtDict objectForKey:@"art"];
        if( img == nil ) {
            img = [tmdbq getImage:tmdbArtDict];
        }
    
        if( [size isEqualToString:@"w154"] ) {
            [abi setBrwsImage:img];
        } else if ( [size isEqualToString:@"mid"] ) {
            [abi setBrwsImgTitle:[[NSString alloc]initWithFormat:
                                  @"%@x%@",
                                  [tmdbArtDict objectForKey:@"width"],
                                  [tmdbArtDict objectForKey:@"height"]]];
            [abi setImageSrc:SMKDIDS_TMDb];
            [abi setImageSrcId:tmdb_id];
            [abi setImage:img];
            [abi setImageURL:[tmdbArtDict objectForKey:@"url"]];
        }
    }
    // [self setArtList:myArtList];
}

-(void)doGatherVidWithId:(ABIGathSpec *)spec
{
    NSMutableArray * myArtList = [self artList];
    
    NSString * mbdir = [AppUserValues mediaBaseDir];

    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    
    NSString * iqStr;
    SMKDigitDS ds;
    
    if( [spec spec] == VidTitleIdSpec ) {
        iqStr = [DIDB sel_images_art_v_id:[spec data] meta:FALSE];
        ds = SMKDIDS_VidTitles;
    } else {
        iqStr = [DIDB sel_images_art_v_id:[spec data] meta:TRUE];
        ds = SMKDIDS_VidMeta;
    }
    
    id <SMKDBResults> iRslt = [db query:iqStr];
    NSMutableArray * iRec;
    while( (iRec = [iRslt fetchRowArray]) ){
        if( [self isCancelled] ) {
            return;
        }
        
        NSNumber * imgIdNum = [iRec objectAtIndex:1];
        NSData * thumbData = [iRec objectAtIndex:3];
        NSString * thumbFilePath = [iRec objectAtIndex:4];
        NSString * thumbUrl = [iRec objectAtIndex:5];
        NSData * midData = [iRec objectAtIndex:8];
        NSString * midFilePath = [iRec objectAtIndex:9];
        NSString * midUrl = [iRec objectAtIndex:10];
        
        NSImage * thumbImage;
        if( ! SMKisNULL(thumbData) ) {
            thumbImage = [[NSImage alloc] initWithData:thumbData];
        } else if( ! SMKisNULL(thumbFilePath) ) {
            thumbImage = [[NSImage alloc] initWithContentsOfFile:
             [mbdir stringByAppendingPathComponent:
              thumbFilePath]];
        } else if( ! SMKisNULL(thumbUrl) ) {
            thumbImage = [[NSImage alloc] initWithContentsOfURL:
             [[NSURL alloc] initWithString:
              [thumbUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        } else {
            thumbImage = nil;
        }

        // SMKLogDebug(@"thumb: %@ %d", thumbImage, [thumbImage isValid]);
        ArtBrowserItem * abi;
        abi = [[ArtBrowserItem alloc]initWithSource:ds 
                                              srcId:[imgIdNum stringValue] 
                                                img:thumbImage];
        [abi setMediaSrc:ds];
        [abi setMediaSrcId:[iRec objectAtIndex:0]];
        [abi setBrwsImgTitle:[iRec objectAtIndex:2]];
        [abi setImageSrc:ds];
        [abi setImageSrcId:[imgIdNum stringValue]];

        NSImage * midImage;
        if( ! SMKisNULL(midData) ) {
            midImage = [[NSImage alloc] initWithData:midData];
        } else if( ! SMKisNULL(midFilePath) ) {
            midImage = [[NSImage alloc] initWithContentsOfFile:
                          [mbdir stringByAppendingPathComponent:
                           midFilePath]];
        } else if( ! SMKisNULL(midUrl) ) {
            midImage = [[NSImage alloc] initWithContentsOfURL:
                          [[NSURL alloc] initWithString:
                           [midUrl stringByAddingPercentEscapesUsingEncoding:
                            NSUTF8StringEncoding]]];
        } else {
            midImage = nil;
        }
        [abi setImage:midImage];
        [abi setImageURL:[[NSURL alloc] initWithString:
                          [midUrl stringByAddingPercentEscapesUsingEncoding:
                           NSUTF8StringEncoding]]];
        [myArtList addObject:abi];
    }
    // [self setArtList:myArtList];
}
-(void)main
{
    
    for( ABIGathSpec * opSpec in [self gatherSpecsList] ) {
        switch ([opSpec spec]) {
            case TMDbArtListSpec:
                [self doGatherTMDbArtList:opSpec];
                break;
            
            case VidTitleIdSpec:
            case VidMetaIdSpec:
                [self doGatherVidWithId:opSpec];
                break;
                
                
            default:
                break;
        }
    }
    
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"art: %@ %u",[[self artList]class],[[self artList]count]];
}
-(void)dealloc
{
    SMKLogDebug(@"abg dealloc");
}
@end
