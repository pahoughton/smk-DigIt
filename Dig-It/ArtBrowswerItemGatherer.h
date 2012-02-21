/**
  File:		ArtBrowswerItemGatherer.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <Foundation/Foundation.h>
#import "ArtBrowserItem.h"

// Gather Art Items into an NSArray of ArtBrowserItems
@interface ArtBrowswerItemGatherer : NSOperation
@property (strong) NSMutableArray * artList;
@property (strong) NSOperationQueue * opQ;
@property (strong) NSMutableArray * gatherSpecsList;

-(id)initWithOpQ:(NSOperationQueue *)opQueue;

-(void)gatherTMDb:(NSString *)tmdb_id;
// a list of TMDbQuery art from getInfo or search;
-(void)gatherTMDBArtDictList:(NSArray *)tmdbArtList;
// a list of ArtBrowserItems
-(void)gatherABItems:(NSMutableArray *)items;
-(void)gatherDigVidTitleArt:(NSNumber *)vid_id;
-(void)gatherDigVidMetaArt:(NSNumber *)vid_meta_id;

-(void)goWithOpQueue:(NSOperationQueue *)opQueue;
@end
