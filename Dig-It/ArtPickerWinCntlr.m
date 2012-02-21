/**
  File:		ArtPickerWinCntlr.m
  Project:	Dig-It
  Desc:
  
  Notes:
    
 Load Data Struct
 titleData - Array;
 midData - dict
     key vidId
     Array - list of art recs
 thumbData - dict
     key vidId
     Array - list of art recs
 
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/18/12  10:25 AM
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
#import "ArtPickerWinCntlr.h"
#import "DIDB.h"
#import "AppUserValues.h"
#import <SMKDB.h>
#import <SMKLogger.h>
static NSString * kvoAllDoneKey = @"allDataDone";

@implementation VidArtRec
@synthesize imgUID;
@synthesize tmdb_id;
@synthesize thumb_art_id;
@synthesize mid_art_id;
@synthesize thumbImage;
@synthesize midURL;
@synthesize mid_size_x;
@synthesize mid_size_y;
@synthesize imgTitle;
@synthesize vidId;
- (id) imageRepresentation
{
    return  thumbImage;
}
- (NSString *) imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}
- (NSString *) imageSubtitle
{
    return @"";
}
- (NSString *) imageTitle
{
    return imgTitle;
}
- (NSString *) imageUID
{
    return tmdb_id;
}
- (NSUInteger) imageVersion
{
    return 1;
}
- (BOOL) isSelectable
{
    return TRUE;
}

-(NSString *)description
{
    return [NSString stringWithFormat:
            @"VidArtRec: %@\n" // vid_id
             "  tmdb_id: %@\n"
             "   th aid: %@\n"
             "  mid aid: %@\n"
             "     size: %@\n",
            vidId,
            tmdb_id,
            thumb_art_id,
            mid_art_id,
            imgTitle];
}
@end

@implementation ArtBrowserDataSrc
@synthesize artList;
@synthesize selectedImage;

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    VidArtRec * rec = [artList objectAtIndex:index];
    return rec;
}
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return [artList count];
}
-(NSURL *)selImgMidUrl
{
    if( selectedImage >= 0 ) {
        VidArtRec * arec = [artList objectAtIndex:selectedImage];
        return[arec midURL];
    }
    return nil;
}
@end

@implementation ArtPickerWinCntlr
@synthesize titleData;
@synthesize thumbData;
@synthesize midData;
@synthesize db;
@synthesize titleDataDone;
@synthesize thumbDataDone;
@synthesize midDataDone;
@synthesize allDataDone;
@synthesize allDoneLock;
@synthesize titleListAcntlr;
@synthesize titleTableView;
@synthesize thumbBrowserView;
@synthesize selectedImageView;
@synthesize titleOrMetaPopup;
@synthesize progressIndicator;

#pragma mark DataRetrieval
-(void)midRecProc:(NSArray *)rec
{
    if( rec ) {
        NSNumber * vidId = [rec objectAtIndex:0];
        if( [[self midData] objectForKey:vidId] == nil ) {
            NSMutableDictionary * artList = [[NSMutableDictionary alloc]init];
            [artList setObject:rec forKey:[rec objectAtIndex:2]]; // tmdb_id
            [[self midData] setObject:artList forKey:vidId];
        } else {
            NSMutableDictionary * artList = [[self midData] objectForKey:vidId];
            [artList setObject:rec forKey:[rec objectAtIndex:2]]; // tmdb_id
        }
    } else {
        SMKLogDebug(@"mid done");
        [self setMidDataDone:TRUE];
        if( ! [self allDataDone] 
           && [self thumbDataDone]
           && [self titleDataDone] 
           && [allDoneLock tryLock] ) {
            [self willChangeValueForKey:kvoAllDoneKey];
            [self setAllDataDone:TRUE];
            [self didChangeValueForKey:kvoAllDoneKey];
            [allDoneLock unlock];
        }
    }        
}
-(void)thumbRecProc:(NSArray *)rec
{
    if( rec ) {
        NSNumber * vidId = [rec objectAtIndex:0];
        if( [[self thumbData] objectForKey:vidId] == nil ) {
            NSMutableArray * artList = [[NSMutableArray alloc]init];
            [artList addObject:rec];
            [[self thumbData] setObject:artList forKey:vidId];
        } else {
            NSMutableArray * artList = [[self thumbData] objectForKey:vidId];
            [artList addObject:rec];            
        }
    } else {
        SMKLogDebug(@"thumb done");

        [self setThumbDataDone:TRUE];
        if( ! [self allDataDone] 
           && [self midDataDone]
           && [self titleDataDone] 
           && [allDoneLock tryLock] ) {
            [self willChangeValueForKey:kvoAllDoneKey];
            [self setAllDataDone:TRUE];
            [self didChangeValueForKey:kvoAllDoneKey];
            [allDoneLock unlock];
        }
    }    
}
-(void)vidTitleRecProc:(NSMutableDictionary *)rec
{
    if( rec ) {
        [titleData addObject:rec];
    } else {
        SMKLogDebug(@"title done");
        [self setTitleDataDone:TRUE];
        if( ! [self allDataDone] 
           && [self midDataDone]
           && [self thumbDataDone] 
           && [allDoneLock tryLock] ) {
            [self willChangeValueForKey:kvoAllDoneKey];
            [self setAllDataDone:TRUE];
            [self didChangeValueForKey:kvoAllDoneKey];
            [allDoneLock unlock];
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( [keyPath isEqualToString:kvoAllDoneKey] ) {
        SMKLogDebug(@"Art Rec Counts:\n"
                    "   title: %u\n"
                    "   thumb: %u\n"
                    "     mid: %u\n",
                    [titleData count],
                    [midData count],
                    [thumbData count] );
        NSString * mbdir = [AppUserValues mediaBaseDir];
        for( NSMutableDictionary * rec in titleData) {
            NSNumber * vidId = [rec objectForKey:@"vid_id"];
            NSArray * thumbList = [thumbData objectForKey:vidId];
            if( ! thumbList ) {
                SMKLogDebug(@":( no thumb for %@", vidId);
                continue;
            }
            NSUInteger artCnt = 0;
            {
                artCnt = [thumbList count];
            }
            NSMutableArray * vidArtList = [[NSMutableArray alloc] initWithCapacity:artCnt];

            NSNumber * artThumbId = [rec valueForKey:@"art_thumb_id"];
            if( ![artThumbId isKindOfClass:[NSNumber class]] ) {
                artThumbId = nil;
            }

            /* tie thumb to mid and both to titles */
            ArtBrowserDataSrc * artData = [[ArtBrowserDataSrc alloc]init];
            NSDictionary * mids = [midData objectForKey:vidId];
            for( NSArray * thumb in thumbList ) {
                NSArray * mid = [mids objectForKey:[thumb objectAtIndex:2]];
                
                VidArtRec * vaRec = [[VidArtRec alloc]init];
                [vaRec setImgUID:[[NSString alloc]initWithFormat:@"%u",[vidArtList count]]];
                [vaRec setTmdb_id:[thumb objectAtIndex:2]];
                [vaRec setThumb_art_id:[thumb objectAtIndex:1]];
                [vaRec setMid_art_id:[mid objectAtIndex:1]];
                [vaRec setThumbImage:[[NSImage alloc]initWithData:[thumb objectAtIndex:3]]];
                NSURL * midURL = [[NSURL alloc] initFileURLWithPath:
                                  [mbdir stringByAppendingPathComponent:[mid objectAtIndex:3]]];
                
                [vaRec setMidURL:midURL];
                [vaRec setMid_size_x:[mid objectAtIndex:4]];
                [vaRec setMid_size_y:[mid objectAtIndex:5]];
                [vaRec setImgTitle:[[NSString alloc]initWithFormat:
                                    @"%@x%@",[vaRec mid_size_x],[vaRec mid_size_y]]];
                [vaRec setVidId:vidId];
                
                if( artThumbId != nil && [artThumbId isEqualToNumber:[thumb objectAtIndex:1]] ) {
                    [artData setSelectedImage:[vidArtList count]];
                }
                
                [vidArtList addObject:vaRec];
            }
            [artData setSelectedImage:-1];
            [artData setArtList:vidArtList];
            [rec setObject:artData forKey:@"artList"];
            [titleListAcntlr addObject:rec];
        }
        [[self progressIndicator] setHidden:TRUE];
        [[self progressIndicator] stopAnimation:self];
        [titleTableView reloadData];
        SMKLogDebug(@"data loaded");
    }
}

#pragma mark Initialization
- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if( self ) {
        [self setTitleDataDone:FALSE];
        [self setThumbDataDone:FALSE];
        [self setMidDataDone:FALSE];
        [self setAllDataDone:FALSE];
        [self setTitleData:[[NSMutableArray alloc]init]];
        [self setThumbData:[[NSMutableDictionary alloc]init]];
        [self setMidData:[[NSMutableDictionary alloc]init]];
        [self setDb:[[SMKDBConnMgr alloc]init]];
        [self setAllDoneLock:[[NSLock alloc]init]];
        [[self db] fetchAllRowsDictObj:self 
                                    proc:@selector(vidTitleRecProc:)
                                     sql:[DIDB sel_vm_title_year]]; 
        [[self db] fetchAllRowsArrayObj:self
                                    proc:@selector(thumbRecProc:)
                                     sql:[DIDB sel_vm_art_thumb_details]]; 
        [[self db] fetchAllRowsArrayObj:self 
                                    proc:@selector(midRecProc:)
                                     sql:[DIDB sel_vm_art_mid_details]]; 
 
        SMKLogDebug(@"initWNib");
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        SMKLogDebug(@"initWithWindow");
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    SMKLogDebug(@"win did load win %@",[self window]);
    [[self window] makeKeyAndOrderFront:self];
    [[self thumbBrowserView] setDelegate:self];
    [thumbBrowserView setDelegate:self];
    NSSize cellSize;
    cellSize.width = [AppUserValues artBrowserImgWidth];
    cellSize.height = cellSize.width * 1.5;
    [thumbBrowserView setCellSize:cellSize];
    if( ! allDataDone ) {
        [[self progressIndicator] setHidden:FALSE];
        [[self progressIndicator] startAnimation:self];
        [self addObserver:self forKeyPath:kvoAllDoneKey options:0 context:nil];
    } else {
        [[self progressIndicator] setHidden:TRUE];
        [[self progressIndicator] stopAnimation:self];        
        [self observeValueForKeyPath:kvoAllDoneKey ofObject:self change:0 context:nil];        
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


// IKImageBrowserDelegate methods
#pragma mark IKImageBrowserDelegate
- (void) imageBrowser:(IKImageBrowserView *) aBrowser backgroundWasRightClickedWithEvent:(NSEvent *) event
{
    SMKLogDebug(@"bg rclick");
    
}
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    SMKLogDebug(@"cel dclick %d",index);
    
}
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *) event
{
    SMKLogDebug(@"cel rclick %d",index);
    
}
- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser
{
    NSIndexSet * selSet = [aBrowser selectionIndexes];
    NSUInteger selCell = [selSet firstIndex];
    ArtBrowserDataSrc * dsrc = [aBrowser dataSource];
    SMKLogDebug(@"cel sel chg %d",selCell,[[dsrc artList] count ]);
    // [selectedImageView setImage:nil imageProperties:nil];
    if( selCell < [[dsrc artList]count] ) {
        VidArtRec * artRec = [[dsrc artList]objectAtIndex:selCell];
        SMKLogDebug(@"mid url: %@", [artRec midURL]);
        [selectedImageView setImageWithURL:[artRec midURL]];
    }
                              
}

- (IBAction)titleOrMetaAction:(id)sender 
{
    SMKLogDebug(@"titles or meta action");
    
}

- (IBAction)selectAction:(id)sender 
{
    NSIndexSet * selSet = [thumbBrowserView selectionIndexes];
    if( selSet == nil ) {
        SMKLogDebug(@"image no selection");
        return;
    }
    ArtBrowserDataSrc * dsrc = [thumbBrowserView dataSource];
    NSUInteger selCell = [selSet firstIndex];
    SMKLogDebug(@"image selected %u",selCell);
    if( selCell < [[dsrc artList]count] ) {
        VidArtRec * artRec = [[dsrc artList]objectAtIndex:selCell];
        SMKLogDebug(@"artRec %@", artRec);
        [dsrc setSelectedImage:selCell];
        
    }
}

- (IBAction)popUpMetaSelected:(id)sender 
{
    SMKLogDebug(@"meta selected");
}

- (IBAction)popUpTitlesSelected:(id)sender 
{
    SMKLogDebug(@"titles selected");
}

- (IBAction)titleTableSelectorAct:(NSTableView *)sender
{
    NSInteger sel = [sender selectedRow];
    if( sel >= 0 && sel < [titleData count]) {
        NSDictionary * tRec = [titleData objectAtIndex:sel];
        ArtBrowserDataSrc * artList = [tRec objectForKey:@"artList"];
        NSUInteger artCnt = [[artList artList] count]; 
        SMKLogDebug(@"sel %d t:%@ c:%u", sel, [tRec objectForKey:@"title_year"], artCnt);
        [thumbBrowserView setDataSource:artList];
        [thumbBrowserView reloadData];
        [selectedImageView setImage:nil imageProperties:nil];
        if( [artList selectedImage] >= 0 ) {
            NSIndexSet * selSet = [[NSIndexSet alloc] initWithIndex:[artList selectedImage]];

            SMKLogDebug(@"mid url: %@", [artList selImgMidUrl]);
            [thumbBrowserView setSelectionIndexes:selSet byExtendingSelection:FALSE];
            // [selectedImageView setImageWithURL:[artList selImgMidUrl]];
        }
    } else {
        SMKLogDebug(@"tv sel out of range: %d", sel );
    }    
}

- (IBAction)browserCellSizeSlider:(NSSlider *)sender 
{
    NSSize cellSize;
    cellSize.width = [sender intValue];
    cellSize.height = cellSize.width * 1.5;
    [thumbBrowserView setCellSize:cellSize];
    [AppUserValues setArtBrowserImgWidth:[sender intValue]];
    // SMKLogDebug(@"size: %d", [sender intValue]);
}

@end
