/**
  File:		VidArtBrowserItem.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/21/12  8:15 AM
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
#import "DIDB.h"

@interface ArtBrowserItem : NSObject // IKImageBrowserItem
@property (strong) NSString * brwsImgUID; 
@property (strong) NSString * brwsImgTitle; // mid size 500x750
@property (strong) NSString * brwsImgSubTitle;
@property (strong) NSImage *  brwsImage;
@property (assign) NSUInteger brwsImgVer;
@property (assign) SMKDigitDS brwsImgSrc;
@property (strong) NSString * brwsImgSrcId;

@property (assign) SMKDigitDS imageSrc;
@property (strong) NSString * imageSrcId;
@property (strong) NSImage *  image;
@property (strong) NSURL *    imageURL;

@property (assign) SMKDigitDS mediaSrc;
@property (strong) NSNumber * mediaSrcId;

@property (strong) NSMutableDictionary * info;

-(id)initWithSource:(SMKDigitDS)src 
              srcId:(NSString *)srcId
                img:(NSImage *)browserImage;

#pragma mark IKImageBrowserItem methods
- (id) imageRepresentation;
- (NSString *) imageRepresentationType;
- (NSString *) imageSubtitle;
- (NSString *) imageTitle;
- (NSString *) imageUID;
- (NSUInteger) imageVersion;


@end
