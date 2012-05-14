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
#import "RipQueueMetaDetails.h"
#import "MediaArtSelImageList.h"
#import "SMKLogger.h"
#import "SMKAlertWin.h"

@interface CustMediaVCntlr ()

@end

@implementation CustMediaVCntlr
@synthesize doneVC        = _doneVC;
@synthesize myCustId      = _myCustId;
@synthesize custHasMedia  = _custHasMedia;
@synthesize upcIsNew      = _upcIsNew;
@synthesize metaSearch    = _metaSearch;
@synthesize gath          = _gath;

@synthesize upcFoundObj   = _upcFoundObj;
@synthesize upcFoundSrc   = _upcFoundSrc;

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
    [self loadView];
    NSError * err;
    NSData * noArtImgData = [NSData dataWithContentsOfFile:
                             [bndl pathForImageResource:@"NO ART.tif"]
                                                   options:0 
                                                     error:&err];
    
    [self setNoArtImageData: noArtImgData];
    [self setGoodSound: [NSSound soundNamed:@"Ping.aiff"]];
    [self setBadSound:  [NSSound soundNamed:@"glass.wav"]];
    [self.goodSound setVolume:0.5];
    [self.badSound  setVolume:0.5];
    
    [self setNoArtImage:[[NSImage alloc]initWithData:noArtImgData]];
    [self setGoImage:   [NSImage imageNamed:@"go_button.png"]];
    [self setStopImage: [NSImage imageNamed:@"stop_button.png"]];
    
    [self setCustMediaListVC:[[MetaListViewCntlr alloc]
                              initViewWithDataSrc:
                              [[CustMediaListDataSrc alloc] init]
                              selDelegate:self ]];
    [self.custMediaListVC replaceView:self.listV makeResizable: TRUE];

    [self setMediaMetaDetailVC:[[MediaMetaDetailsView alloc]init]];
    [self.mediaMetaDetailVC setViewToReplace: self.detailV ];
  }
  
  return self;
}

-(id)init
{
  self = [self initWithNibName:@"CustMediaView"
                        bundle:[NSBundle bundleForClass:
                                [CustMediaVCntlr class]]];
  return self;
}

-(id)initWithDoneVC:(ReplacementViewCntlr *)doneVC
{
  self = [self init];
  if( self ) {
    [self setDoneVC: doneVC];
  }
  return self;
}

-(void)awakeFromNib
{
  SMKLogDebug(@"lv: %@  dv: %@",self.listV,self.detailV);
  
  [self.searchUpcTF becomeFirstResponder];
}

-(void)replaceView:(ReplacementView *)vToReplace
{
  id <MetaDataEntity> selMeta = self.metaSelVC.selMeta;
  if( selMeta != nil ) {
    
    [self.searchOrSaveButton setEnabled: FALSE];
    SMKProgStart();
    NSString * selUpc = self.searchUpcTF.stringValue;
    NSString * selTitle = self.searchTitleTF.stringValue;
    SMKLogDebug(@"upc: %@ title: %@ meta:\n%@"
                ,selUpc
                ,selTitle
                ,selMeta );
    id objCmld = self.custMediaListVC.tvDataSrc.origValues;
    if( ! [objCmld isKindOfClass:[CustMediaListDataSrc class]] ) {
      SMKThrow( @"%@ not a CustMediaListData",objCmld );
      return;
    }
    CustMediaListDataSrc * cmld = objCmld;
    id<SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    [db beginTransaction];
    MediaIdMetaDetails * added = nil;
    @try {
      added = [cmld addMediadb: db
                           upc: selUpc
                      upcIsNew: self.upcIsNew
                         title: selTitle
                      foundSrc: self.upcFoundSrc
                          meta: selMeta ];
      
    }
    @catch (NSException *exception) {
      [db rollback];
      NSString * msg = [NSString stringWithFormat:
                        @"add failed %@",exception];
      
      SMKLogError( msg );
      SMKStatus( msg );
      [SMKAlertWin alertWithMsg: msg ];
    }
    if( added ) {
      [db commit];
      [self.custMediaListVC.tvDataSrc 
       insertObj: added atIndex:0 ];
      [self.custMediaListVC.tableView reloadData];
    }
    [self.searchOrSaveButton setEnabled: FALSE];
    [self.searchUpcTF setObjectValue:nil];
    [self.searchTitleTF setObjectValue:nil];
    [self.searchYearTF setObjectValue:nil];
    [self.mediaMetaDetailVC setViewWithMetaData:nil];
    
    SMKProgStop();
  }
  [super replaceView: vToReplace];
  [self.searchUpcTF becomeFirstResponder];

}

-(void)replaceView:(ReplacementView *)viewToReplace custId:(id)cid
{
  SMKLogDebug(@"mmdvc: %@", self.mediaMetaDetailVC);
  
  [self.custMediaListVC changeDataSrcKey: cid];
  [self.mediaMetaDetailVC setViewWithMetaData: nil ];
  
  [self.searchUpcTF   setObjectValue:nil];
  [self.searchTitleTF setObjectValue:nil];
  [self.searchYearTF  setObjectValue:nil];
  [self.mediaTypeCB   setObjectValue:nil];
  [self.searchOrSaveButton setEnabled:FALSE];
  
  [self.searchUpcTF becomeFirstResponder];
  [super replaceView: viewToReplace];
  SMKProgStop();
}

-(void)selected:( id<MetaListDataEntity> )item
{
  SMKProgStart();
  SMKLogDebug(@"selected %@",item);
  SMKStatus( @"Customer has %@ 😄",item.listValue);
  [self setCustHasMedia:TRUE];
  [self.mediaMetaDetailVC setViewWithMetaData: item ];
  [self.searchUpcTF becomeFirstResponder];
  [self.searchOrSaveButton setEnabled:FALSE];
  BOOL needToRip = FALSE;
  if( [item isKindOfClass:[MediaIdMetaDetails class]] ) {
    MediaIdMetaDetails * mim = (MediaIdMetaDetails *)item;
    SMKMetaDataSource itemDS
    = SMKTableNameToMetaDataSource(mim.metaTable);
    if( itemDS == SMK_DS_RipQueue ) {
      needToRip = TRUE;
    }
  }
  if( needToRip ) {
    [self.stopOrGoIW setImage:self.stopImage];
  } else {
    [self.stopOrGoIW setImage:self.goImage];
  }
}

-(void)upcFoundMeta:(id<MetaDataEntity>)it
{
  SMKProgStop();
  SMKLogDebug(@"mms %@",self.metaSearch);
  if( it == nil ) {
    SMKStatus( @"UPC: %@ not found 😥",self.searchUpcTF.stringValue );
    [self.mediaMetaDetailVC setViewWithMetaData:nil];
    [self.searchOrSaveButton setEnabled: FALSE];
    [self.stopOrGoIW setImage: self.stopImage];
    [self setUpcIsNew: TRUE];
  } else {
    [self setUpcIsNew: FALSE];
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
      if( [it conformsToProtocol:@protocol(VideoMetaDetailsEntity)] ) {
        id <VideoMetaDetailsEntity> vmd = (id <VideoMetaDetailsEntity>)it;
        title = [vmd title];
      } else if( [it conformsToProtocol:@protocol(AudioAlbumMetaDetailsEntity)] ) {
        id <AudioAlbumMetaDetailsEntity> aud = (id <AudioAlbumMetaDetailsEntity>)it;
        title = [NSString stringWithFormat:
                 @"%@ - %@"
                 ,[[aud artists]stringValue]
                 ,[aud albName]];
      } else {
        SMKThrow( @"unsupported entity %@", it );
        return;
      }
      SMKStatus( @"SMK Needs to Rip %@ 😥, click Save Button.",title );
    }
  }
  SMKLogDebug(@"mms %@",self.metaSearch);

}
-(void)retrieveDone:(id<DBMetaDataEntity>)obj
{
  SMKLogDebug(@"retr done: obj:%@ mms %@",obj,self.metaSearch);
  if( obj == self.metaSearch ) {
    id<SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    if( self.metaSearch.found.count ) {
      SMKMetaDataSource fndDs;
      fndDs = SMKTableNameToMetaDataSource( self.metaSearch.foundSrc);
      if( fndDs == SMK_DS_MediaIdMeta ) {
        MediaIdMetaDetails * mim;
        mim = [[MediaIdMetaDetails alloc]
               initWithDb: db dataSrcId: self.metaSearch.foundSrcId gath:nil];
        [self setUpcFoundSrc: mim];
        
      } else if( fndDs == SMK_DS_RipQueue ) {
        RipQueueMetaDetails * rq;
        rq = [[RipQueueMetaDetails alloc]
              init];
        [rq retrievedb: db key: self.metaSearch.foundSrcId gathOp: nil ];
        [self setUpcFoundSrc: rq ];
        
      } else if( fndDs == SMK_DS_Upcs ) {
        //
      }
      [self setUpcFoundObj: [self.metaSearch.found objectAtIndex:0] ];
    } else {
      [self setUpcFoundObj: nil ];
    }
    [self setGath: nil];
    [self performSelectorOnMainThread: @selector(upcFoundMeta:) 
                           withObject: self.upcFoundObj
                        waitUntilDone: FALSE];
  }
}

- (IBAction)searchUpcAction:(id)sender 
{
  if( [self.searchUpcTF.stringValue length] < 1 ) {
    return;
  }
  SMKLogDebug(@"upc %@ mms.upc %@"
              ,self.searchUpcTF.stringValue
              ,self.metaSearch );
  
  if( self.searchUpcTF.integerValue == self.metaSearch.searchUpc.integerValue ) {
    return;
  }
  [self setUpcFoundObj: nil ];
  [self setUpcFoundSrc: nil ];
  
  [self.searchOrSaveButton setTitle:@"Search"];
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
  [self setMetaSearch:[[MediaMetaSearch alloc] init]];
  [self.metaSearch searchForUpc: self.searchUpcTF.stringValue ];
  [self setGath:[[MetaDbGatherer alloc] initWithDelegate: self ]];
  [self.gath gatherdb: nil retriever: self.metaSearch key: nil ];
}

- (IBAction)searchTitleAction:(id)sender 
{
  if( [self.searchTitleTF.stringValue length] > 0 
     && SMKStringToMediaType(self.mediaTypeCB.stringValue) != SMK_MT_UNKNOWN ) {
    [self.searchOrSaveButton setTitle:@"Search"];
    [self.searchOrSaveButton setEnabled:TRUE];
  } else {
    [self.searchOrSaveButton setTitle:@"Search"];
    [self.searchOrSaveButton setEnabled: FALSE ];
  }
}
- (IBAction)mediaTypeCB:(id)sender
{
  if( [self.searchTitleTF.stringValue length] > 0 
     && SMKStringToMediaType(self.mediaTypeCB.stringValue) != SMK_MT_UNKNOWN ) {
    [self.searchOrSaveButton setTitle:@"Search"];
    [self.searchOrSaveButton setEnabled:TRUE];
  } else {
    [self.searchOrSaveButton setEnabled: FALSE ];
  }  
}

- (IBAction)searchOrSaveAction:(id)sender 
{
  SMKLogDebug(@"%@",self.searchOrSaveButton.title );
  
  if( [self.searchOrSaveButton.title isEqualToString:@"Save"] ) {
    // do save
    if( self.upcFoundObj != nil ) {
      id objCmld = self.custMediaListVC.tvDataSrc.origValues;
      if( ! [objCmld isKindOfClass:[CustMediaListDataSrc class]] ) {
        SMKThrow( @"%@ not a CustMediaListData",objCmld );
        return;
      }
      CustMediaListDataSrc * cmld = objCmld;
      
      id<SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
      [db beginTransaction];
      MediaIdMetaDetails * added = nil;
      @try {
        added = [cmld addMediaMeta: self.upcFoundSrc db: db];
      }
      @catch (NSException *exception) {
        [db rollback];
        NSString * msg = [NSString stringWithFormat:
                          @"%s add failed %@",__func__,exception];
        
        SMKLogError( msg );
        SMKStatus( msg );
        [SMKAlertWin alertWithMsg: msg ];
      }
      if( added ) {
        [db commit];
        [self.custMediaListVC.tvDataSrc 
         insertObj: added atIndex:0 ];
        [self.custMediaListVC.tableView reloadData];
      }
      [self.searchOrSaveButton setEnabled: FALSE];
      [self.searchUpcTF setObjectValue:nil];
      [self.mediaMetaDetailVC setViewWithMetaData:nil];

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
      MediaMetaSearch * mms = nil;
      if( self.metaSearch == nil ) {
        mms = [[MediaMetaSearch alloc]init];
      } else {
        mms = [self.metaSearch copy];
      }
      
      [mms setSearchTitle: self.searchTitleTF.stringValue ];
      [mms setSearchMediaType: mt ];
      [mms setFound: nil ];
      if( self.metaSelVC == nil ) {
        [self setMetaSelVC:[[MetaDetailListVCntlr alloc] initWithDoneVC: self]];
      }
      [self.metaSelVC replaceView: self.rview metaSearch: mms];
    }
  }
}

- (IBAction)cancelAction:(id)sender 
{
  SMKStatus(@"");
  [self.doneVC replaceView:self.view makeResizable:TRUE];
}

@end
