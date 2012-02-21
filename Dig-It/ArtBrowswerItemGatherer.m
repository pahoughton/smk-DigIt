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
#import <SMKDB.h>
#import <SMKLogger.h>
#import <TMDbQuery.h>

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
    [self setArtList:nil];
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
    [NSException raise:@"ArtBrowerItemGatherer" format:@"Opps, not implemented"];
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
    [NSException raise:@"ArtBrowerItemGatherer" format:@"Opps, not implemented"];    
}

-(void)gatherDigVidTitleArt:(NSNumber *)vid_id
{
    [[self gatherSpecsList]addObject:
     [ABIGathSpec opSpec:VidTitleIdSpec data:vid_id]];
    [self doGather];
}
static NSString * MetaIdSpec = @"VidMetaIdSpec";

-(void)gatherDigVidMetaArt:(NSNumber *)vid_meta_id
{
    [[self gatherSpecsList]addObject:
     [ABIGathSpec opSpec:VidMetaIdSpec data:vid_meta_id]];
    [self doGather];
}

-(void)goWithOpQueue:(NSOperationQueue *)opQueue
{
    [NSException raise:@"ArtBrowerItemGatherer" format:@"Opps, not implemented"];
}

-(void)doGatherTMDbArtList:(ABIGathSpec *)spec
{

    NSMutableArray * myArtList = [[NSMutableArray alloc] init];
    NSMutableDictionary * tmdbIdLink = [[NSMutableDictionary alloc]init];
    
    TMDbQuery * tmdbq = [[TMDbQuery alloc]init];
    
    NSArray * tmdbArtDictList = [spec data];
    for( NSDictionary * tmdbArtDict in tmdbArtDictList ) {

        NSString * tmdb_id = [tmdbArtDict objectForKey:@"id"];

        ArtBrowserItem * abi = [tmdbIdLink objectForKey:tmdb_id];
        
        if( abi == nil ) {
            abi = [[ArtBrowserItem alloc]initWithSource:SMKDIDS_TMDb srcId:tmdb_id img:nil];
            [tmdbIdLink setObject:abi forKey:tmdb_id];
            [myArtList addObject:abi];
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
    [self setArtList:myArtList];
}

-(void)doGatherVidWithId:(ABIGathSpec *)spec
{
    NSMutableArray * myArtList = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * tmdbIdLink = [[NSMutableDictionary alloc]init];
    NSString * mbdir = [AppUserValues mediaBaseDir];

    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    
    NSString * qStr;
    SMKDigitDS ds;
    
    if( [spec spec] == VidTitleIdSpec ) {
        qStr = [DIDB sel_vt_art_details:[spec data]];
        ds = SMKDIDS_VidTitles;
    } else {
        qStr = [DIDB sel_vm_art_details:[spec data]];
        ds = SMKDIDS_VidMeta;
    }
    
    id <SMKDBResults> rslt = [db query:qStr];
    NSMutableArray * aRec;
    while( (aRec = [rslt fetchRowArray]) ){
        NSString * tmdb_id = [aRec objectAtIndex:7];
        ArtBrowserItem * abi = [tmdbIdLink objectForKey:tmdb_id];
        
        if( abi == nil ) {
            abi = [[ArtBrowserItem alloc]initWithSource:ds srcId:nil img:nil];
            [tmdbIdLink setObject:abi forKey:tmdb_id];
            [myArtList addObject:abi];
        }
        NSNumber * srcId = [aRec objectAtIndex:0];
        NSString * sizeDesc = [aRec objectAtIndex:8];
        if( [sizeDesc isEqualToString:@"w154"] ) {
            [abi setBrwsImgSrcId:[srcId stringValue]];
            [abi setBrwsImgUID:[[NSString alloc]initWithFormat:
                                @"%@.%@",[DIDB dsDesc:[abi brwsImgSrc]],srcId]];
            [abi setBrwsImage:[aRec objectAtIndex:3]];
            [abi setMediaSrc:ds];
            [abi setMediaSrcId:[aRec objectAtIndex:1]];
        } else {
            NSURL * url;
            NSString * filepath = [aRec objectAtIndex:5];
            if( ! SMKisNULL(filepath) ) {
                url = [[NSURL alloc] initFileURLWithPath:
                       [mbdir stringByAppendingPathComponent:filepath]];
            } else {
                url = [aRec objectAtIndex:6];
            }
            [abi setImageSrc:ds];
            [abi setImageSrcId:[aRec objectAtIndex:0]];
            NSImage * img = [aRec objectAtIndex:3];
            if( SMKisNULL(img) ) {
                [abi setImage:nil];
            } else {
                [abi setImage:[aRec objectAtIndex:3]];
            }
        }
    }
    [self setArtList:myArtList];
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
@end
