/**
  File:		VidMetaSelCellView.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  8:43 AM
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
#import "VidMetaSelCellView.h"


@implementation VidMetaSelRowView
@synthesize objectValue = _objectValue;

- (void)dealloc 
{
    self.objectValue = nil;
}
@end

@implementation VidMetaSelCellView
@synthesize year;
@synthesize mpaa;
@synthesize genres;
@synthesize actors;
@synthesize directors;
@synthesize source;
@synthesize desc;
@synthesize selected;
@synthesize selectButton;

@end
