/**
  File:		VidArtBrowserItem.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
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
#import "ArtBrowserItem.h"
#import <Quartz/Quartz.h>
#import <SMKLogger.h>

@implementation ArtBrowserItem
@synthesize brwsImgUID;
@synthesize brwsImgTitle;
@synthesize brwsImgSubTitle;
@synthesize brwsImage;
@synthesize brwsImgVer;
@synthesize brwsImgSrc;
@synthesize brwsImgSrcId;

@synthesize imageSrc;
@synthesize imageSrcId;
@synthesize image;
@synthesize imageURL;

@synthesize mediaSrc;
@synthesize mediaSrcId;
@synthesize info;

-(id)initWithSource:(SMKDigitDS)src srcId:(NSString *)srcId img:(NSImage *)browserImage
{
    self = [super init];
    if( self ) {
        [self setBrwsImgSrc:src];
        [self setBrwsImgSrcId:srcId];
        [self setBrwsImage:browserImage];
        [self setBrwsImgUID:[[NSString alloc]initWithFormat:
                             @"%@.%@",
                             [DIDB dsDesc:[self brwsImgSrc]],
                             [self brwsImgSrcId]]];
        [self setBrwsImgTitle:@""];
        [self setBrwsImgSubTitle:@""];
        [self setBrwsImgVer:1];
        //SMKLogDebug(@"img: %@",brwsImage);
    }
    return self;
}

- (id) imageRepresentation
{
    return  [self brwsImage];
}
- (NSString *) imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}
- (NSString *) imageSubtitle
{
    return [self brwsImgSubTitle];
}
- (NSString *) imageTitle
{
    return [self brwsImgTitle];
}
- (NSString *) imageUID
{
    return [self brwsImgUID];
}
- (NSUInteger) imageVersion
{
    return [self brwsImgVer];
}
-(NSString *)description
{
    NSSize sz;
    NSString * brSize = @"(none)";
    if( [self brwsImage] ) {
        sz = [[self brwsImage]size];
        brSize = [NSString stringWithFormat:@"%.0fx%.0f",sz.width,sz.height];
    }
    NSString * imgSize = @"(none)";
    if( [self image] ) {
        sz = [[self image]size];
        imgSize = [NSString stringWithFormat:@"%.0fx%.0f",sz.width,sz.height];
        
    }
    return [NSString stringWithFormat:
            @"%@<%p>\n"
            "      uid: %@\n"
            "      src: %@\n"
            "    srcId: %@\n"
            "    title: %@\n"
            "     subt: %@\n"
            "      ver: %u\n"
            "      res: %@\n"
            "   imgsrc: %@\n"
            " imgsrcid: %@\n"
            "   imgres: %@\n"
            "   imgURL: %@\n"
            "     msrc: %@\n"
            "   msrcid: %@\n"
            "     info: %@\n",
            [self class],self,
            [self brwsImgUID],
            [DIDB dsDesc:[self brwsImgSrc]],
            [self brwsImgSrcId],
            [self brwsImgTitle],
            [self brwsImgSubTitle],
            [self brwsImgVer],
            brSize,
            [DIDB dsDesc:[self imageSrc]],
            [self imageSrcId],
            imgSize,
            [self imageURL],
            [DIDB dsDesc:[self mediaSrc]],
            [self mediaSrcId],
            [self info]];
}

@end
