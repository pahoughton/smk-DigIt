/**
  File:		VidSelArtPickerViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  10:51 AM
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
#import "VidSelArtPickerViewCntlr.h"
#import "VidMetaSelDataSrc.h"
#import "ArtBrowserItem.h"
static VidSelArtPickerViewCntlr * me = nil;

@implementation VidSelArtDataSrc
@synthesize artList;
@synthesize selectedImage;

-(id)initWithTmdbGath:(VidMetaArtGather *)artGath
{
    self = [super init];
    if( self ) {
        artList = [[NSMutableArray alloc]initWithCapacity:[[artGath tmdbArtList] count]];
        
        NSMutableDictionary * tmdbIdDict = [[NSMutableDictionary alloc]init];
        
        for( NSDictionary * art in [artGath tmdbArtList] ) {
            ArtBrowserItem * selArt;
            if( (selArt = [tmdbIdDict objectForKey:[art objectForKey:@"id"]]) != nil ) {
                if( [[art objectForKey:@"size"] isEqualToString:@"w154"] ) {
                    // thumb
                    [selArt setBrwsImage:[art objectForKey:@"art"]];
                } else {
                    [selArt setImage:[art objectForKey:@"art"]];
                    NSString * title = [[NSString alloc] initWithFormat:
                                        @"%@x%@", 
                                        [art objectForKey:@"width"],
                                        [art objectForKey:@"height"]];
                    [selArt setBrwsImgTitle:title];
                }
            } else {
                selArt = [[ArtBrowserItem alloc] initWithSource:@"TMDb" 
                                                          srcId:[art objectForKey:@"id"] 
                                                            img:nil];
                [selArt setBrwsImgSrc:@"TMDb"];
                [selArt setBrwsImgSrcId:[art objectForKey:@"id"]];
                if( [[art objectForKey:@"size"] isEqualToString:@"w154"] ) {
                    // thumb
                    [selArt setBrwsImage:[art objectForKey:@"art"]];
                } else {
                    [selArt setImage:[art objectForKey:@"art"]];
                    NSString * title = [[NSString alloc] initWithFormat:
                                        @"%@x%@", 
                                        [art objectForKey:@"width"],
                                        [art objectForKey:@"height"]];
                    [selArt setBrwsImgTitle:title];
                }
                [tmdbIdDict setValue:selArt forKey:[selArt brwsImgSrcId]];
                [artList addObject:selArt];
            }
        }
    }
    return self;
}

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    ArtBrowserItem * rec = [artList objectAtIndex:index];
    return rec;
}
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return [artList count];
}
@end

@implementation VidSelArtPickerViewCntlr
@synthesize artGath;
@synthesize aliveAndWell;
@synthesize artBrowser;
@synthesize artImageView;
@synthesize selectButton;

#pragma mark Initialization
+(VidSelArtPickerViewCntlr *)showSelfIn:(NSView *)viewToReplace artGath:(TMDbArtGather *)artGather
{
    if( me == nil ){
        me = [VidSelArtPickerViewCntlr alloc];
        me = [me initWithNibName:@"VidSelArtPickerView" bundle:nil];
        [me setArtGath:artGather];
    } else {
        [[me artBrowser] setDataSource:[[VidSelArtDataSrc alloc] initWithGath:artGather]];
        [[me artBrowser] reloadData];        
    }
    /// need to library this
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    return me;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setAliveAndWell:FALSE];
        // Initialization code here.
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self setAliveAndWell:TRUE];  // FIXME there is probably something else available
    [[self artBrowser] setDataSource:[[VidSelArtDataSrc alloc] initWithGath:[self artGath]]];
    [[self artBrowser] reloadData];        
}


-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context
{
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
    VidSelArtDataSrc * dsrc = [aBrowser dataSource];
    SMKLogDebug(@"cel sel chg %d",selCell,[[dsrc artList] count ]);
    // [selectedImageView setImage:nil imageProperties:nil];
    if( selCell < [[dsrc artList]count] ) {
        ArtBrowserItem * artRec = [[dsrc artList]objectAtIndex:selCell];
        SMKLogDebug(@"img url: %@", [artRec imageURL]);
        if( [artRec image] ) {
            NSRect viewRect = [[self artImageView]bounds];
            CGImageRef imgRef = [[artRec image]CGImageForProposedRect:&viewRect context:nil hints:nil];
            [[self artImageView]setImage:imgRef imageProperties:nil];
        } else if( [artRec imageURL] ) {
            [[self artImageView]setImageWithURL:[artRec imageURL]];
        }
        [[self selectButton]setEnabled:TRUE];
    }
    
}


#pragma mark Actions
- (IBAction)cancelAction:(id)sender 
{
}

- (IBAction)selectAction:(id)sender 
{
}


@end
