/**
  File:		ArtPickerWinCntlr.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
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
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <SMKDB.h>

@interface VidArtRec : NSObject // IKImageBrowserItem
@property (strong) NSString * imgUID; // string rep of array index num;
@property (strong) NSString * tmdb_id;
@property (strong) NSNumber * thumb_art_id;
@property (strong) NSNumber * mid_art_id;
@property (strong) NSImage *  thumbImage;
@property (strong) NSURL *    midURL;
@property (strong) NSNumber * mid_size_x;
@property (strong) NSNumber * mid_size_y;
@property (strong) NSString * imgTitle; // mid size 500x750
@property (strong) NSNumber * vidId;
- (id) imageRepresentation;
- (NSString *) imageRepresentationType;
- (NSString *) imageSubtitle;
- (NSString *) imageTitle;
- (NSString *) imageUID;
- (NSUInteger) imageVersion;
- (BOOL) isSelectable;

@end

@interface ArtBrowserDataSrc :  NSObject // IKImageBrowserDataSource
@property (strong) NSArray * artList;
@property (assign) NSInteger selectedImage;
- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index;
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser;
-(NSURL *)selImgMidUrl;

@end

@interface ArtPickerWinCntlr : NSWindowController <SMKDBRecProc> // IKImageBrowserDelegate
@property (strong) NSMutableArray * titleData;
@property (strong) NSMutableDictionary * thumbData;
@property (strong) NSMutableDictionary * midData;
@property (strong) SMKDBConnMgr * db;
@property (assign) BOOL titleDataDone;
@property (assign) BOOL thumbDataDone;
@property (assign) BOOL midDataDone;
@property (assign) BOOL allDataDone;
@property (strong) NSLock * allDoneLock;

@property (strong) IBOutlet NSArrayController *titleListAcntlr;

// UI Outlets
@property (weak) IBOutlet NSTableView *titleTableView;
@property (weak) IBOutlet IKImageBrowserView *thumbBrowserView;
@property (weak) IBOutlet IKImageView *selectedImageView;

@property (weak) IBOutlet NSPopUpButton *titleOrMetaPopup;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;


// IKImageBrowserDelegate methods
- (void) imageBrowser:(IKImageBrowserView *) aBrowser backgroundWasRightClickedWithEvent:(NSEvent *) event;
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index;
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *) event;
- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser;

- (IBAction)titleOrMetaAction:(id)sender;
- (IBAction)selectAction:(id)sender;
- (IBAction)popUpMetaSelected:(id)sender;
- (IBAction)popUpTitlesSelected:(id)sender;
- (IBAction)titleTableSelectorAct:(NSTableView *)sender;
- (IBAction)browserCellSizeSlider:(NSSlider *)sender;


@end
