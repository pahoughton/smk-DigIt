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
#import "CustUpcViewCntlr.h"
#import <SMKLogger.h>

static VidSelArtPickerViewCntlr * me = nil;

@implementation VidSelArtDataSrc
@synthesize artList;
-(id)initWithArt:(NSMutableArray *)list
{
    self = [super init];
    if( self ) {
        [self setArtList:list];
    }
    return  self;
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
@synthesize metaSelId;
@synthesize aliveAndWell;
@synthesize artBrowser;
@synthesize artImageView;
@synthesize selectButton;

#pragma mark SetDataSource
-(void)setBrowserDataSource:(id)trash
{
    [[self artBrowser]setDataSource:[[VidSelArtDataSrc alloc] initWithArt:[artGath artList]]];
    [[self artBrowser] reloadData];        
}

#pragma mark Initialization
+(VidSelArtPickerViewCntlr *)showSelfIn:(NSView *)viewToReplace 
                              metaSelId:(NSNumber *)selId 
                                artGath:(ArtBrowswerItemGatherer *)artGather
{
    if( me == nil ){
        me = [VidSelArtPickerViewCntlr alloc];
        me = [me initWithNibName:@"VidSelArtPickerView" bundle:nil];
        [me setArtGath:artGather];
    } else {
        [artGather addObserver:me forKeyPath:@"isFinished" options:0 context:0];
        if( [artGather isFinished] ) {
            [artGather removeObserver:me forKeyPath:@"isFinished"];
            [me performSelectorOnMainThread:@selector(setBrowserDataSource:) withObject:nil waitUntilDone:FALSE];
        }
    }
    [me setMetaSelId:selId];
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
}


-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context
{
    if( object == artGath && [keyPath isEqualToString:@"isFinished"] ) {
        [artGath removeObserver:me forKeyPath:@"isFinished"];
        [me performSelectorOnMainThread:@selector(setBrowserDataSource:) withObject:nil waitUntilDone:FALSE];
    }
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
    [CustUpcViewCntlr showSelfIn:[self view] custInfo:nil];
}

- (IBAction)selectAction:(id)sender 
{
    NSIndexSet * selSet = [artBrowser selectionIndexes];
    NSUInteger selCell = [selSet firstIndex];
    VidSelArtDataSrc * dsrc = [artBrowser dataSource];
    SMKLogDebug(@"cel sel chg %d",selCell,[[dsrc artList] count ]);
    // [selectedImageView setImage:nil imageProperties:nil];
    if( selCell < [[dsrc artList]count] ) {
        ArtBrowserItem * artRec = [[dsrc artList]objectAtIndex:selCell];
        if( [DIDB set_meta_sel_art:metaSelId 
                         artSource:[artRec brwsImgSrc] 
                             artId:[artRec brwsImgSrcId]] ) {
            [self cancelAction:self];
        }
    }
}


@end
