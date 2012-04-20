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
@synthesize gath          = _gath;

@synthesize upcFoundObj   = _upcFoundObj;

@synthesize goodSound      = _goodSound;
@synthesize badSound       = _badSound;
@synthesize noArtImageData = _noArtImageData;
@synthesize noArtImage     = _noArtImage;
@synthesize goImage        = _goImage;
@synthesize stopImage      = _stopImage;

@synthesize searchUpcTF    = _searchUpcTF;
@synthesize mediaTypeCB    = _mediaTypeCB;
@synthesize searchTitleTF  = _searchTitleTF;
@synthesize searchYearTF   = _searchYearTF;
@synthesize stopOrGoIW     = _stopOrGoIW;
@synthesize searchOrSaveButton = _searchOrSaveButton;

@synthesize listV              = _listV;
@synthesize detailV            = _detailV;

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
    if( self.mediaMetaDetailVC == nil ) {
      [self setCustMediaListVC:[[MetaListViewCntlr alloc] 
                                initViewWithDataSrc:
                                [[CustMediaListDataSrc alloc] init]
                                selDelegate:self ]
       ];
    }
    if( self.mediaMetaDetailVC == nil ) {
      [self setMediaMetaDetailVC:[[MediaMetaDetailsView alloc]init]];
    }
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
      if( self.mediaMetaDetailVC == nil ) {
        [self setMediaMetaDetailVC:[[MediaMetaDetailsView alloc]init]];        
      }
    }
  }
  return self;
}

-(id)initWithDoneVC:(ReplacementViewCntlr *)doneVC
{
  self = [self init];
  if( self ) {
    [self setDoneVC: doneVC];
    if( self.mediaMetaDetailVC == nil ) {
      [self setCustMediaListVC:[[MetaListViewCntlr alloc] 
                                initViewWithDataSrc:
                                [[CustMediaListDataSrc alloc] init]
                                selDelegate:self ]
       ];
    }
    if( self.mediaMetaDetailVC == nil ) {
      [self setMediaMetaDetailVC:[[MediaMetaDetailsView alloc]init]];
    }
  }
  return self;
}

-(void)awakeFromNib
{
  SMKLogDebug(@"lv: %@  dv: %@",self.listV,self.detailV);
  
  [self.searchUpcTF becomeFirstResponder];
  // [self replaceView: self.doneVC.rview ];
  [self.custMediaListVC replaceView:self.listV makeResizable: TRUE];
  [self.mediaMetaDetailVC setViewToReplace: self.detailV ];
}
-(void)replaceView:(ReplacementView *)vToReplace
{
  [super replaceView:vToReplace];
  
  id <MetaDataEntity> selMeta = self.metaSelVC.selMeta;
  NSString * selUpc = self.searchUpcTF.stringValue;
  NSString * selTitle = self.searchTitleTF.stringValue;
  SMKLogDebug(@"%s upc: %@ title: %@ meta:\n%@"
              ,__func__
              ,selUpc
              ,selTitle
              ,selMeta );
  id objCmld = self.custMediaListVC.tvDataSrc.origValues;
  if( ! [objCmld isKindOfClass:[CustMediaListData class]] ) {
    [NSException raise:self.className
                format:@"%@ not a CustMediaListData",objCmld];
    return;
  }
  CustMediaListData * cmld = objCmld;
  [objCmld.addMediaUpc:selUpc title:selTitle meta:selMeta ];
  [self.custMediaListVC.tableView reloadData];
  [self.searchOrSaveButton setEnabled:FALSE];
}

-(void)replaceView:(ReplacementView *)viewToReplace custId:(id)cid
{
  [self replaceView:viewToReplace];
  [self.custMediaListVC changeDataSrcKey:cid];
  
  SMKLogDebug(@"%s mmdvc: %@",__func__, self.mediaMetaDetailVC);
  [self.mediaMetaDetailVC setViewWithMetaData: nil ];
  [self.searchUpcTF   setObjectValue:nil];
  [self.searchTitleTF setObjectValue:nil];
  [self.searchYearTF  setObjectValue:nil];
  [self.mediaTypeCB   setObjectValue:nil];
  [self.searchOrSaveButton setEnabled:FALSE];
  
  [self.searchUpcTF becomeFirstResponder];
}

-(void)selected:( id<MetaListDataEntity>)item
{
  SMKLogDebug(@"selected %@",item);
  SMKStatus( @"Customer has %@ 😄",item.listValue);
  [self setCustHasMedia:TRUE];
  [self.mediaMetaDetailVC setViewWithMetaData: item ];
  [self.searchUpcTF becomeFirstResponder];
  [self.searchOrSaveButton setEnabled:FALSE];
  [self.stopOrGoIW setImage:self.goImage];
}

-(void)upcFoundMeta:(id<MetaDataEntity>)it
{
  SMKProgStop();
  SMKLogDebug(@"mms %@",self.metaSearch);
  if( it == nil ) {
    SMKStatus( @"UPC: %@ not found 😥",self.searchUpcTF.stringValue );
    [self.mediaMetaDetailVC setViewWithMetaData:nil];
    [self.searchOrSaveButton setEnabled:FALSE];
    [self.stopOrGoIW setImage:self.stopImage];
    
  } else {
    [self.mediaMetaDetailVC setViewWithMetaData: it ];
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
      SMKStatus( @"SMK Has %@ 😄, click Save Button.",title );
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
        SMKStatus( @"%@ needs Ripped 😥, click Search Button.",upcMeta.upc );
      } else {
        [self.searchOrSaveButton setEnabled:TRUE];
        SMKStatus( @"%@ needs Ripped 😥, enter Title and Media Type.", upcMeta.upc );        
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
      SMKStatus( @"SMK Needs to Rip %@ 😥, click Save Button.",title );
    }
  }
  SMKLogDebug(@"mms %@",self.metaSearch);

}
-(void)retrieveDone:(id<MetaDataRetriever>)obj
{
  SMKLogDebug(@"retr done: obj:%@ mms %@",obj,self.metaSearch);
  if( obj == self.metaSearch ) {
    [self setUpcFoundObj: [self.metaSearch.found objectAtIndex:0] ];
    [self setGath:nil];
    [self performSelectorOnMainThread:@selector(upcFoundMeta:) 
                           withObject:self.upcFoundObj
                        waitUntilDone:FALSE];
  }
}

- (IBAction)searchUpcAction:(id)sender 
{
  if( [self.searchUpcTF.stringValue length] < 1 ) {
    return;
  }
  SMKLogDebug(@"%s upc %@ mms.upc %@"
              ,__func__
              ,self.searchUpcTF.stringValue
              ,self.metaSearch );
  
  if( [self.searchUpcTF.stringValue isEqualToString: self.metaSearch.searchUpc] ) {
    return;
  }
  SMKProgStart();
  [self setUpcFoundObj:nil];
  // see if cust has this upc and show meta
  CustMediaListData * cMediaList;
  id lvDataSrc = self.custMediaListVC.tvDataSrc.origValues;
  if( [lvDataSrc isKindOfClass:[CustMediaListData class]] ) {
    cMediaList = (CustMediaListData *)lvDataSrc;
    MediaIdMetaDetails * it = [cMediaList findUpc:self.searchUpcTF.stringValue];
    if( it != nil ) {
      [self selected:it];
      SMKProgStop();
      return;
    }
  }
  SMKStatus( @"Searching meta data for UPC: %@"
            ,self.searchUpcTF.stringValue );
  [self setMetaSearch:[[MediaMetaSearch alloc]
                         init]];
  [self.metaSearch searchForUpc: self.searchUpcTF.stringValue ];
  [self setGath:[[MetaDataGatherer alloc]initWithDelegate:self]];
  [self.gath gather: self.metaSearch key:nil ];
}

- (IBAction)searchTitleAction:(id)sender 
{
}

- (IBAction)searchOrSaveAction:(id)sender 
{
  SMKLogDebug(@"%s %@",__func__,self.searchOrSaveButton.title );
  
  if( [self.searchOrSaveButton.title isEqualToString:@"Save"] ) {
    // do save
    if( self.upcFoundObj != nil ) {
      id objCmld = self.custMediaListVC.tvDataSrc.origValues;
      if( ! [objCmld isKindOfClass:[CustMediaListData class]] ) {
        [NSException raise:self.className
                    format:@"%@ not a CustMediaListData",objCmld];
        return;
      }
      CustMediaListData * cmld = objCmld;
      [objCmld.addMedia: self.upcFoundObj ];
      [self.custMediaListVC.tableView reloadData];

    }
  } else {
    // do search
    SMKMediaType mt = SMKStringToMediaType( self.mediaTypeCB.stringValue );
    if( mt != SMK_MT_Audio && mt != SMK_MT_Video ) {
      SMKStatus( @"Invalid media type (req Video|Audio) %@"
                ,self.mediaTypeCB.stringValue );
    } else if( self.searchTitleTF.stringValue.length < 2 ) {
      SMKStatus( @"Search title not long enough '%@'"
                ,self.searchTitleTF.stringValue );
    } else {
      MediaMetaSearch * mms = [self.metaSearch copy];
      
      [mms setSearchTitle: self.searchTitleTF.stringValue ];
      [mms setSearchMediaType: mt ];
      
      if( self.metaSelVC == nil ) {
        [self setMetaSelVC:[[MetaDetailListVCntlr alloc] init]];
        [self.metaSelVC showWithDoneVC: self 
                         viewToReplace: self.rview 
                            metaSearch: mms ];
      } else {
        [self.metaSelVC showWithViewToReplace: self.rview 
                                   metaSearch: mms ];
      }
    }
  }
}

- (IBAction)cancelAction:(id)sender 
{
  [self.doneVC replaceView:self.view makeResizable:TRUE];
}

@end
