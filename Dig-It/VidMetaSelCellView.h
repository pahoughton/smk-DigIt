/**
  File:		VidMetaSelCellView.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <Foundation/Foundation.h>

@interface VidMetaSelRowView : NSTableRowView

@property (retain) id objectValue;

@end

@interface VidMetaSelCellView : NSTableCellView

// REMINDER The next two are from the base class
// IBOutlet            imageView (pic)
// IBOotlet            textField (title)
@property (assign) IBOutlet NSTextField * year;
@property (assign) IBOutlet NSTextField * mpaa;
@property (assign) IBOutlet NSTextField * genres;
@property (assign) IBOutlet NSTextField * actors;
@property (assign) IBOutlet NSTextField * directors;
@property (assign) IBOutlet NSTextField * source;
@property (assign) IBOutlet NSTextField * desc;
@property (assign) IBOutlet NSTextField * selected;
@property (assign) IBOutlet NSButton *    selectButton;

@end
