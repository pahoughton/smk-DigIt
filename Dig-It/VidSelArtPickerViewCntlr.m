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
#import "CustUpcViewCntlr.h"
#import "AppUserValues.h"
#import <SMKLogger.h>

static VidSelArtPickerViewCntlr * me = nil;

@implementation VidSelArtDataSrc
@synthesize artList;
-(id)initWithArt:(NSMutableArray *)list
{
    self = [super init];
    if( self ) {
        [self setArtList:list];
        if( [[self artList] count] > 0 ) {
            SMKLogDebug(@"abi 0: %@", [[self artList]objectAtIndex:0]);
        }
        SMKLogDebug(@"init %p %u", [self artList], ([self artList] != nil ? [[self artList]count] : 0));
    }
    return  self;
}
- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    ArtBrowserItem * rec = [[self artList] objectAtIndex:index];
    SMKLogDebug(@"abi: %@", rec );
    return rec;
}
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    
    SMKLogDebug(@"ds num %p %u", artList, [artList count]);
    return ([self artList] != nil ? [[self artList]count] : 0 );
}
@end

@implementation VidSelArtPickerViewCntlr
@synthesize artGath;
@synthesize metaSelId;
@synthesize aliveAndWell;
@synthesize artBrowser;
@synthesize artImageView;
@synthesize selectButton;
@synthesize thumbSizeSlider;

#pragma mark SetDataSource
-(void)setBrowserDataSource:(id)trash
{
    SMKLogDebug(@"setDS cnt: %@ %d", [[[self artGath]artList] class], [[artGath artList] count]);
    VidSelArtDataSrc * ds = [[VidSelArtDataSrc alloc]initWithArt:[artGath artList]];
    [[self artBrowser] setDataSource:ds];
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
        SMKLogDebug(@"agath %@", artGather);
        [me setArtGath:artGather];
    } else {
        [me setArtGath:artGather];
        [[me artGath] addObserver:me forKeyPath:@"isFinished" options:0 context:0];
        if( [[me artGath] isFinished] ) {
            [[me artGath ] removeObserver:me forKeyPath:@"isFinished"];
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
    SMKLogDebug(@"awake finish: %d", [artGath isFinished]);
    [self setAliveAndWell:TRUE];
    NSSize cellSize;
    cellSize.width = [AppUserValues artBrowserImgWidth];
    cellSize.height = cellSize.width * 1.5;
    [[self artBrowser] setCellSize:cellSize];
    [[self thumbSizeSlider] setIntegerValue:[AppUserValues artBrowserImgWidth]];
    [[self artGath] addObserver:me forKeyPath:@"isFinished" options:0 context:0];
    if( [[self artGath] isFinished] ) {
        [[self artGath ] removeObserver:me forKeyPath:@"isFinished"];
        [self performSelectorOnMainThread:@selector(setBrowserDataSource:) withObject:nil waitUntilDone:FALSE];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context
{
    if( object == artGath 
       && [keyPath isEqualToString:@"isFinished"] ) {
        [artGath removeObserver:me forKeyPath:@"isFinished"];
        if( [self aliveAndWell] ) {
            [me performSelectorOnMainThread:@selector(setBrowserDataSource:) withObject:nil waitUntilDone:FALSE];
        }
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
    NSArray * aList = [[self artGath]artList];
    
    // [selectedImageView setImage:nil imageProperties:nil];
    if( selCell < [aList count] ) {
        ArtBrowserItem * artRec = [aList objectAtIndex:selCell];
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
- (IBAction)thumbSizeSlider:(NSSlider *)sender 
{
    NSSize cellSize;
    cellSize.width = [sender intValue];
    cellSize.height = cellSize.width * 1.5;
    [artBrowser setCellSize:cellSize];
    [AppUserValues setArtBrowserImgWidth:[sender intValue]];

}

- (IBAction)cancelAction:(id)sender 
{
    [CustUpcViewCntlr showSelfIn:[self view] custInfo:nil upcData:nil];
}

- (IBAction)selectAction:(id)sender 
{
    NSIndexSet * selSet = [artBrowser selectionIndexes];
    NSUInteger selCell = [selSet firstIndex];
    NSArray * aList = [[self artGath]artList];

    SMKLogDebug(@"select: %u cnt %u",selCell, [aList count] );
    // [selectedImageView setImage:nil imageProperties:nil];
    if( selCell < [aList count] ) {
        ArtBrowserItem * artRec = [aList objectAtIndex:selCell];
        if( [DIDB set_meta_sel_art:metaSelId 
                         artSource:[artRec brwsImgSrc] 
                             artId:[artRec brwsImgSrcId]] ) {
            [self cancelAction:self];
        }
    }
}


@end
