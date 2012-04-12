//
//  CustMediaVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120406.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "CustMediaVCntlr.h"
#import "CustMediaListDataSrc.h"
#import "MediaMetaSearch.h"
#import "SMKLogger.h"
#import "MediaArt.h"

@interface CustMediaVCntlr ()

@end

@implementation CustMediaVCntlr
@synthesize custId        = _custId;
@synthesize custHasMedia  = _custHasMedia;
@synthesize gatherer      = _gatherer;

@synthesize foundSrc      = _foundSrc;
@synthesize foundSrcId    = _foundSrcId;

@synthesize goodSound      = _goodSound;
@synthesize badSound       = _badSound;
@synthesize noArtImageData = _noArtImageData;
@synthesize noArtImage     = _noArtImage;
@synthesize goImage        = _goImage;
@synthesize stopImage      = _stopImage;

@synthesize searchUpcTF;
@synthesize MediaTypeCB;
@synthesize searchTitleTF;
@synthesize searchYearTF;
@synthesize stopOrGoIW;
@synthesize progressInd;
@synthesize statusTF;
@synthesize searchOrSaveButton;
@synthesize listView;
@synthesize detailView;

@synthesize custMediaListVC = _custMediaListVC;
@synthesize mediaMetaDetailVC = _mediaMetaDetailVC;

//@synthesize upcDetailsV = _upcDetailsV;

+(CustMediaVCntlr *)createAndReplaceView:(NSView *)viewToReplace custId:(NSNumber *)cid;
{
  NSBundle * myBundle = [NSBundle bundleForClass:[CustMediaVCntlr class]];
  CustMediaVCntlr * me = [[CustMediaVCntlr alloc]
                          initWithNibName:@"CustMediaView" bundle:myBundle];
  [me setCustId:cid];
  [me replaceView:viewToReplace makeResizable:TRUE];
  return me;
}

-(void)replaceView:(NSView *)viewToReplace custId:(id)cid
{
  [self replaceView:viewToReplace makeResizable:TRUE];
  [self.custMediaListVC changeDataSrcKey:cid];
  [self.searchUpcTF becomeFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      NSBundle * myBndl = [NSBundle bundleForClass:[self class]];
      NSError * err;
      NSData * noArtImgData = [NSData dataWithContentsOfFile:
                               [myBndl pathForImageResource:@"NO ART.tif"]
                                                     options:0 
                                                       error:&err];
      [self setNoArtImageData:noArtImgData];
      [self setGoodSound: [NSSound soundNamed:@"Ping.aiff"]];
      [self setBadSound:  [NSSound soundNamed:@"glass.wav"]];
      [self.goodSound setVolume:0.5];
      [self.badSound  setVolume:0.5];
      [self setNoArtImage:[[NSImage alloc]initWithData:noArtImgData]];
      [self setGoImage:   [NSImage imageNamed:@"go_button.png"]];
      [self setStopImage: [NSImage imageNamed:@"stop_button.png"]];
        // Initialization code here.
    }
    
    return self;
}
-(void)awakeFromNib
{
  SMKLogDebug(@"lv: %@  dv: %@",self.listView,self.detailView);
  
  [self setCustMediaListVC:[MetaListViewCntlr 
                          createAndReplaceView:self.listView 
                          dataSrc: [[CustMediaListDataSrc alloc] init ]]];
  [self.custMediaListVC setSelectionDelegate:self];
  [self.custMediaListVC changeDataSrcKey:self.custId];
  [self setMediaMetaDetailVC:[[MediaMetaDetailsView alloc]
                              initWithViewToReplace:self.detailView]];
  [self.searchUpcTF becomeFirstResponder];
                               
  /*
   [me setUpcDetailsV:[[UpcMetaSelectionDetailsView alloc]
   initWithViewToReplace:me.detailView]];
   */
}
-(void)selected:( id<MetaListDataEntity>)item
{
  SMKLogDebug(@"selected %@",item);
  [self setCustHasMedia:TRUE];
  if( [item conformsToProtocol:@protocol(MediaArt)] ) {
    id <MediaArt> mArt = (id <MediaArt>)item;
    if( [mArt thumbData] == nil 
       || [[NSImage alloc]initWithData:[mArt thumbData]] == nil) {
      [mArt setThumbData:self.noArtImageData];
    }
  }
  [self.mediaMetaDetailVC setViewWithMetaData:item];
  [self.searchUpcTF becomeFirstResponder];
  [self.searchOrSaveButton setEnabled:FALSE];
  if( [item isKindOfClass:[MediaIdMetaDetails class]] ) {
    MediaIdMetaDetails * mim = (MediaIdMetaDetails *)item;
    [self.statusTF setStringValue:[NSString stringWithFormat:
                                   @"Customer has %@ 😄"
                                   ,[mim mediaTitle]]];
  }
}

-(void)upcFoundMeta:(id<MetaDataEntity>)it
{
  [self.progressInd stopAnimation:self];
  [self.progressInd setHidden:TRUE];
  if( it == nil ) {
    [self.statusTF setStringValue:
     [NSString stringWithFormat:
      @"UPC: %@ not found 😥",self.searchUpcTF.stringValue]];
    [self.mediaMetaDetailVC setViewWithMetaData:nil];
    [self.searchOrSaveButton setEnabled:FALSE];
    [self.stopOrGoIW setImage:self.stopImage];
    
  } else {
    SMKMetaDataSource ds = [it dataSrc];
    if( ds == SMK_DS_VideoTitles 
       || ds == SMK_DS_AudioAlbums ) {
      // Media is already in library
      [self.goodSound play];

      NSString * title;
      if( ds == SMK_DS_VideoTitles ) {
        id <VideoMetaDetailsEntity> vid = (id <VideoMetaDetailsEntity>)it;
        title = [vid title];
      } else {
        id <AudioAlbumMetaDetailsEntity> aud = (id <AudioAlbumMetaDetailsEntity>)it;
        title = [NSString stringWithFormat:
                 @"%@ - %@"
                 ,[[aud artists]stringValue]
                 ,[aud albName]];
      }
      [self.statusTF setStringValue:
       [NSString stringWithFormat:
        @"SMK Has %@ 😄, click Save Button.",title]];
      [self.searchOrSaveButton setTitle:@"Save"];
      [self.searchOrSaveButton setEnabled:TRUE];
      [self.stopOrGoIW setImage:self.goImage];
        
    } else if( ds == SMK_DS_Upcs ) {
      // Need to search for meta data
      [self.badSound play];
      id <UpcMetaDataEntity> upcMeta = (id <UpcMetaDataEntity>)it;
      
      [self.searchUpcTF setObjectValue:  [upcMeta upc]];
      [self.searchTitleTF setObjectValue:[upcMeta title]];
      [self.searchYearTF setObjectValue: [upcMeta year]];
      [self.MediaTypeCB setObjectValue:  [upcMeta mediaTypeStr]];
      
      [self.searchOrSaveButton setTitle:@"Search"];
      [self.stopOrGoIW setImage:self.stopImage];
      if( [self.searchTitleTF.stringValue length] > 0 
         && SMKStringToMediaType(self.MediaTypeCB.stringValue) != SMK_MT_UNKNOWN ) {
        [self.searchOrSaveButton setEnabled:TRUE];
        [self.statusTF setStringValue:
         [NSString stringWithFormat:
          @"%@ needs Ripped 😥, click Search Button.",[upcMeta upc]]];
      } else {
        [self.searchOrSaveButton setEnabled:TRUE];
        [self.statusTF setStringValue:
         [NSString stringWithFormat:
          @"%@ needs Ripped 😥, enter Title and Media Type.",[upcMeta upc]]];        
      }
    } else { 
      // item SHOULD be in rip queue
      [self.badSound play];
      [self.searchOrSaveButton setTitle:@"Save"];
      [self.searchOrSaveButton setEnabled:TRUE];
      [self.stopOrGoIW setImage:self.stopImage];      
      NSString * title;
      if( ds == SMK_DS_VideoTitles ) {
        id <VideoMetaDetailsEntity> vid = (id <VideoMetaDetailsEntity>)it;
        title = [vid title];
      } else {
        id <AudioAlbumMetaDetailsEntity> aud = (id <AudioAlbumMetaDetailsEntity>)it;
        title = [NSString stringWithFormat:
                 @"%@ - %@"
                 ,[[aud artists]stringValue]
                 ,[aud albName]];
      }
      [self.statusTF setStringValue:
       [NSString stringWithFormat:
        @"SMK Needs to Rip %@ 😥, click Save Button.",title]];
    }
  }
}
-(void)retrieveDone:(id<MetaDataRetriever>)obj
{
  if( [obj isKindOfClass:[MediaMetaSearch class]] ) {
    MediaMetaSearch * mmSearch = (MediaMetaSearch *)obj;
    [self setFoundSrc:[mmSearch foundSrc]];
    [self setFoundSrcId:[mmSearch foundSrcId]];
    
    if( mmSearch.searchMediaType == SMK_MT_UNKNOWN ) {
      // UPC search
      [self upcFoundMeta:[mmSearch.found objectAtIndex:0]];
    }
  }
}
- (IBAction)searchUpcAction:(id)sender 
{
  if( [self.searchUpcTF.stringValue length] < 1 ) {
    return;
  }
  [self setFoundSrc:nil];
  [self setFoundSrcId:nil];
  // see if cust has this upc and show meta
  CustMediaListData * cMediaList;
  id lvDataSrc = self.custMediaListVC.tvDataSrc.origValues;
  if( [lvDataSrc isKindOfClass:[CustMediaListData class]] ) {
    cMediaList = (CustMediaListData *)lvDataSrc;
    MediaIdMetaDetails * it = [cMediaList findUpc:self.searchUpcTF.stringValue];
    if( it != nil ) {
      [self selected:it];
      return;
    }
  }
  if( self.gatherer == nil ) {
    [self setGatherer:[[MetaDataGatherer alloc]initWithDelegate:self]];
  }
  [self.progressInd startAnimation:self];
  [self.progressInd setHidden:FALSE];
  [self.statusTF setStringValue:
   [NSString stringWithFormat:
    @"Searching meta data for UPC: %@"
    ,self.searchUpcTF.stringValue]];
  MediaMetaSearch * mmSearch = [[MediaMetaSearch alloc]init];
  [mmSearch searchForUpc:[self.searchUpcTF stringValue]];
  [self.gatherer gather:mmSearch key:nil];
}

- (IBAction)searchTitleAction:(id)sender 
{
}

- (IBAction)searchOrSaveAction:(id)sender 
{
  if( [[self.searchOrSaveButton title] isEqualToString:@"Save"] ) {
    // do save
    if( self.foundSrc != nil && self.foundSrcId != nil ) {
      
    }
  } else {
    // do search
  }
}

- (IBAction)cancelAction:(id)sender {
}
@end
