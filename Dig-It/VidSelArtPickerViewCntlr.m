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

static VidSelArtPickerViewCntlr * me = nil;

@implementation VidSelArtPickerViewCntlr
@synthesize selectArtAction;
@synthesize artList;
@synthesize artBrowser;
@synthesize artImageView;
@synthesize artListBrowser;

#pragma mark Initialization
+(VidSelArtPickerViewCntlr *)showSelfIn:(NSView *)viewToReplace artList:(NSArray *)art;
{
    if( me == nil ){
        me = [VidSelArtPickerViewCntlr alloc];
        me = [me initWithNibName:@"VidSelArtPickerView" bundle:nil];
    }
    /// need to library this
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    if( art != nil ) {
        [me setArtList:art];
    }
    return me;
}

- (IBAction)cancelAction:(id)sender {
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
