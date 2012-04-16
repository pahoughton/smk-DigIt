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
@synthesize doneVC        = _doneVC;
@synthesize myCustId      = _myCustId;
@synthesize custHasMedia  = _custHasMedia;
@synthesize metaSearch    = _metaSearch;

@synthesize foundSrc      = _foundSrc;
@synthesize foundSrcId    = _foundSrcId;

@synthesize goodSound      = _goodSound;
@synthesize badSound       = _badSound;
@synthesize noArtImageData = _noArtImageData;
@synthesize noArtImage     = _noArtImage;
@synthesize goImage        = _goImage;
@synthesize stopImage      = _stopImage;

@synthesize searchUpcTF;
@synthesize mediaTypeCB;
@synthesize searchTitleTF;
@synthesize searchYearTF;
@synthesize stopOrGoIW;
@synthesize progressInd;
@synthesize statusTF;
@synthesize searchOrSaveButton;
@synthesize listView;
@synthesize detailView;

@synthesize custMediaListVC   = _custMediaListVC;
@synthesize mediaMetaDetailVC = _mediaMetaDetailVC;
@synthesize metaSelVC         = _metaSelVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bndl
{
  self = [super initWithNibName: nibNameOrNil bundle: bndl];
  if (self) {
    NSError * err;
    NSData * noArtImgData = [NSData dataWithContentsOfFile:
                             [bndl pathForImageResource:@"NO ART.tif"]
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
  }
  
  return self;
}

-(id)init
{
  self = [self initWithNibName:@"CustMediaView"
                        bundle:[NSBundle bundleForClass:
                                [CustMediaVCntlr class]]];
  if( self ) {
    if( self.custMediaListVC == nil ) {
      [self setCustMediaListVC:[[MetaListViewCntlr alloc] 
                                initViewWithDataSrc:
                                [[CustMediaListDataSrc alloc] init]
                                selDelegate:self ]
       ];
    }
  }
  return self;
}

-(id)initWithDoneVC:(ReplacementViewCntlr *)doneVC
{
  self = [self init];
  if( self ) {
    [self setDoneVC: doneVC];
    [self setCustMediaListVC:[[MetaListViewCntlr alloc] 
                              initViewWithDataSrc:
                              [[CustMediaListDataSrc alloc] init]
                              selDelegate:self ]
     ];
  }
  return self;
}

-(void)awakeFromNib
{
  SMKLogDebug(@"lv: %@  dv: %@",self.listView,self.detailView);
  
  [self.searchUpcTF becomeFirstResponder];
  [self replaceView: self.doneVC.rview ];
  [self.custMediaListVC replaceView:self.listView makeResizable:FALSE];
  [self setMediaMetaDetailVC:
   [[MediaMetaDetailsView alloc]
    initWithViewToReplace:self.detailView]];
  /*
   [me setUpcDetailsV:[[UpcMetaSelectionDetailsView alloc]
   initWithViewToReplace:me.detailView]];
   */
}
-(void)replaceView:(ReplacementView *)vToReplace
{
  [super replaceView:vToReplace makeResizable:FALSE];
}

-(void)replaceView:(ReplacementView *)viewToReplace custId:(id)cid
{
  [self replaceView:viewToReplace];
  [self.custMediaListVC changeDataSrcKey:cid];
  [self.searchUpcTF becomeFirstResponder];
}

-(void)selected:( id<MetaListDataEntity>)item
{
  SMKLogDebug(@"selected %@",item);
  [self setCustHasMedia:TRUE];
  [self.mediaMetaDetailVC setViewWithMetaData: item ];
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
      
      [self.searchUpcTF   setObjectValue: [upcMeta upc]];
      [self.searchTitleTF setObjectValue: [upcMeta title]];
      [self.searchYearTF  setObjectValue: [upcMeta year]];
      [self.mediaTypeCB   setObjectValue: [upcMeta mediaTypeStr]];
      
      [self.searchOrSaveButton setTitle:@"Search"];
      [self.stopOrGoIW setImage:self.stopImage];
      if( [self.searchTitleTF.stringValue length] > 0 
         && SMKStringToMediaType(self.mediaTypeCB.stringValue) != SMK_MT_UNKNOWN ) {
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
  if( obj == self.metaSearch ) {
    [self setFoundSrc:   self.metaSearch.foundSrc];
    [self setFoundSrcId: self.metaSearch.foundSrcId];
    [self upcFoundMeta:  [self.metaSearch.found objectAtIndex:0]];
  }
}

- (IBAction)searchUpcAction:(id)sender 
{
  if( [self.searchUpcTF.stringValue length] < 1 ) {
    return;
  }
  [self.progressInd startAnimation:self];
  [self.progressInd setHidden:FALSE];
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
      [self.progressInd stopAnimation:self];
      [self.progressInd setHidden:TRUE];
      return;
    }
  }
  [self.statusTF setStringValue:
   [NSString stringWithFormat:
    @"Searching meta data for UPC: %@"
    ,self.searchUpcTF.stringValue]];
  if( self.metaSearch == nil ) {
    [self setMetaSearch:[[MetaSearchDataSrc alloc]
                         init]];
  }
  [self.metaSearch setGathDelegate: self ];
  [self.metaSearch searchForUpc: self.searchUpcTF.stringValue ];
  [self.metaSearch gather:nil ];
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
    SMKMediaType mt = SMKStringToMediaType( self.mediaTypeCB.stringValue );
    if( mt != SMK_MT_Audio && mt != SMK_MT_Video ) {
      [self.statusTF setObjectValue:
       [NSString stringWithFormat:
        @"Invalid media type (req Video|Audio) %@"
        ,self.mediaTypeCB.stringValue]];
    } else if( self.searchTitleTF.stringValue.length < 2 ) {
      [self.statusTF setObjectValue:
       [NSString stringWithFormat:
        @"Search title not long enough '%@'"
        ,self.searchTitleTF.stringValue ]];
    } else {
      if( self.metaSelVC == nil ) {
        [self setMetaSelVC:[[MetaDetailListVCntlr alloc]
                            initWithDoneVC: self
                            metaSearchDS:self.metaSearch]];
      }
      [self.metaSearch setSearchTitle: self.searchTitleTF.stringValue ];
      [self.metaSearch setSearchMediaType: mt ];
      [self.metaSearch setGathDelegate: self.metaSelVC ];
      [self.metaSearch gather:nil];
      [self.metaSelVC replaceView:self.rview];
    }
  }
}

- (IBAction)cancelAction:(id)sender 
{
  [self.doneVC replaceView:self.view makeResizable:TRUE];
}

@end
