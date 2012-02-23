/**
  File:		VidSelArtPickerViewCntlr.h
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
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ArtBrowswerItemGatherer.h"

@interface VidSelArtDataSrc :  NSObject // IKImageBrowserDataSource
@property (strong) NSArray * artList;
-(id)initWithArt:(NSArray *)list;
-(id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index;
-(NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser;

@end

@interface VidSelArtPickerViewCntlr : NSViewController // IKImageBrowserDelegate
@property (strong) ArtBrowswerItemGatherer * artGath;
@property (strong) NSNumber * metaSelId;
@property (assign) BOOL aliveAndWell;
@property (weak) IBOutlet IKImageBrowserView *artBrowser;
@property (weak) IBOutlet IKImageView *artImageView;
@property (weak) IBOutlet NSButton *selectButton;
@property (weak) IBOutlet NSSlider *thumbSizeSlider;

+(VidSelArtPickerViewCntlr *)showSelfIn:(NSView *)viewToReplace 
                              metaSelId:(NSNumber *)selId
                                artGath:(ArtBrowswerItemGatherer *)artGather;

// IKImageBrowserDelegate methods
- (void) imageBrowser:(IKImageBrowserView *) aBrowser backgroundWasRightClickedWithEvent:(NSEvent *) event;
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index;
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *) event;
- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser;


- (IBAction)cancelAction:(id)sender;
- (IBAction)selectAction:(id)sender;
- (IBAction)thumbSizeSlider:(NSSlider *)sender;


@end
