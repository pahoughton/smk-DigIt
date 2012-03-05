/**
  File:		CustUpcViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  4:49 PM
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
#import "CustUpcViewCntlr.h"
#import "CustUpcDataSrc.h"
#import "CustomerViewCntlr.h"
#import "VidMetaSelViewCntlr.h"
#import "DIDB.h"
#import <SMKCocoaCommon.h>
#import <SMKLogger.h>
#import <SMKAlertWin.h>
#import <SMKDB.h>

static CustUpcViewCntlr * me;

@implementation CustUpcViewCntlr
@synthesize upcDataSrc;
@synthesize metaSelViewCntlr;
@synthesize db;
@synthesize myWindow;
@synthesize custInfo;
@synthesize custId;
@synthesize custHasUPC;
@synthesize aliveAndWell;
@synthesize needToRip;
@synthesize upcIsNew;
@synthesize showingUPC;

@synthesize upcDetailsCache;
@synthesize goodSound;
@synthesize badSound;
@synthesize noArtImage;
@synthesize goImage;
@synthesize stopImage;
@synthesize mediaTypeCB;

@synthesize upcListTableView;
@synthesize saveButton;
@synthesize searchButton;
@synthesize stopOrGoImage;
@synthesize haveOrRipLabel;
@synthesize custLabel;
@synthesize curUpcValue;
@synthesize playButton;
@synthesize progressInd;
@synthesize upcTitleTF;
@synthesize upcYearTF;
@synthesize upcMpaaTF;
@synthesize upcGenresTF;
@synthesize upcActorsTF;
@synthesize upcDescTF;
@synthesize upcThumbTF;

#pragma mark Initialization
+(CustUpcViewCntlr *)showSelfIn:(NSView *)viewToReplace custInfo:(NSDictionary *)cust upcData:(CustUpcDataSrc *)upcData
{
    SMKLogDebug(@"showSelfIn");
    if( me == nil ){
        me = [CustUpcViewCntlr alloc];
        me = [me initWithNibName:@"CustUpcView" bundle:nil];
        [me setCust:cust];
        [me setUpcDataSrc:upcData];
    } else {
        if( cust != nil ) {
            [me setCust:cust];
            [me setUpcDataSrc:upcData];
            [upcData addObserver:me forKeyPath:[CustUpcDataSrc kvoData] options:NSKeyValueObservingOptionNew context:nil];
            if( [upcData data] != nil ) {
                [upcData removeObserver:me forKeyPath:[CustUpcDataSrc kvoData]];
                [me mtUpcDataAvailable];
            } else {
                [[me progressInd] setHidden:FALSE];
                [[me progressInd] startAnimation:self];
            }
        }
    }
    /// need to library this
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    [me setMyWindow:[curSuper window]];
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];

    [[me myWindow] makeFirstResponder:[me curUpcValue]];
    
    return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    SMKLogDebug(@"initWithNib");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        aliveAndWell = FALSE;
        custInfo = nil;
        metaSelViewCntlr = nil;
        db = [[SMKDBConnMgr alloc]init];
    }
    
    return self;
}

-(void) mtUpcDataAvailable
{
    
    SMKLogDebug( @"mtUpcDataAvailable win %@ resp %@",
                myWindow,
                [myWindow firstResponder] );
                 
    [progressInd stopAnimation:self];
    [progressInd setHidden:TRUE];
    
    [curUpcValue setStringValue:@""];
    [upcTitleTF setStringValue:@""];
    [upcYearTF setStringValue:@""];
    [upcMpaaTF setStringValue:@""];
    [upcGenresTF setStringValue:@""];
    [upcActorsTF setStringValue:@""];
    [upcDescTF setStringValue:@""];
    [upcThumbTF setImage:noArtImage];
    [stopOrGoImage setImage:stopImage];
    [haveOrRipLabel setStringValue:@""];
    [searchButton setEnabled:FALSE];
    [saveButton setEnabled:FALSE];
    
    // reset cache on cust change (don't want the whole db in here)
    upcDetailsCache = [[NSMutableDictionary alloc] init];
    
    [upcListTableView setDataSource:upcDataSrc];
    [upcListTableView reloadData];
    [[self curUpcValue] setEnabled:TRUE];

    [myWindow makeFirstResponder:curUpcValue];
}

#pragma mark Initialization
-(void)awakeFromNib
{
    SMKLogDebug(@"awake alive:%d cust: %@",
                aliveAndWell, 
                custInfo);
    aliveAndWell = TRUE;
    
    goodSound = [NSSound soundNamed:@"Ping.aiff"];
    [goodSound setVolume:0.5];
    badSound = [NSSound soundNamed:@"glass.wav"];
    [badSound setVolume:0.5];
    noArtImage = [NSImage imageNamed:@"NO ART.tif"];
    goImage = [NSImage imageNamed:@"go_button.png"];
    stopImage = [NSImage imageNamed:@"stop_button.png"];
    [mediaTypeCB addItemWithObjectValue:@"video"];
    [mediaTypeCB addItemWithObjectValue:@"audio"];
    
    /*
    SMKLogDebug(@"resources:\n"
                " good %@\n"
                "  bad %@\n"
                "   no %@\n"
                "   go %@\n"
                " stop %@\n",
                goodSound,
                badSound,
                noArtImage,
                goImage,
                stopImage );
    */
    // SMKLogDebug(@"upc acntlr %@", upcListAcntlr);
    if( custInfo ) {
        [self.custLabel setStringValue:
         [NSString stringWithFormat:@"%@ (%@)",
          [custInfo valueForKey:@"full_name"],
          [custInfo valueForKey:@"cust_id"]]];
        
        [[self upcDataSrc] addObserver:me forKeyPath:[CustUpcDataSrc kvoData] options:NSKeyValueObservingOptionNew context:nil];
        if( [[self upcDataSrc] data] != nil ) {
            [[self upcDataSrc] removeObserver:me forKeyPath:[CustUpcDataSrc kvoData]];
            [self mtUpcDataAvailable];
        } else {
            [[self progressInd] setHidden:FALSE];
            [[self progressInd] startAnimation:self];
        }
    }
    [myWindow makeFirstResponder:curUpcValue];
}
-(void) setCust:(NSDictionary *)cust
{
    custInfo = cust;
    
    custId = [[NSNumber alloc]initWithInteger:
              [[custInfo valueForKey:@"cust_id"] integerValue]];
    
    SMKLogDebug(@"alive %d cust %@ %@", aliveAndWell, cust,[[custInfo valueForKey:@"cust_id"] class]);
    if( aliveAndWell ) {
        [self.custLabel setStringValue:
         [NSString stringWithFormat:@"%@ (%@)",
          [custInfo valueForKey:@"full_name"],
          [custInfo valueForKey:@"cust_id"]]];
    }
}

#pragma mark UpcDetails
-(void) textDidChange:(NSNotification *)note
{
    // NSLog(@"text change %@",note);
    // [saveButton setEnabled:TRUE];
    NSString * mType = [[self mediaTypeCB] stringValue];
    NSString * upcVal = [[self curUpcValue] stringValue];
    NSString * title = [upcTitleTF stringValue];
    
    if( [upcVal length] > 1 
       && [title length] > 1 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {           
           [saveButton setEnabled:custHasUPC == FALSE];
           [searchButton setEnabled:TRUE];
       } else {
           [saveButton setEnabled:FALSE];        
           [searchButton setEnabled:FALSE];
       }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification 
                                                  object:nil];
}

-(void)showUpcDetails:(NSDictionary *)upcDetails
{
    // SMKLogDebug(@"uvfDetailts %@", uvfDetails); pcd
    [progressInd setHidden:TRUE];
    [progressInd stopAnimation:self];
    
    
    BOOL haveMedia = FALSE;
    if( [[upcDetails valueForKey:@"have_media"] isEqualToString:@"true"] ) {
        haveMedia = TRUE;
    }
    
    if( haveMedia ) {
        [goodSound play];
        [haveOrRipLabel setStringValue:@"😄 have 😄"];
        [stopOrGoImage setImage:goImage];        
    } else {
        [badSound play];
        [haveOrRipLabel setStringValue:@"😥 RIP 😥"];
        [stopOrGoImage setImage:stopImage];        
    }
    [self setUpcIsNew:FALSE];
    
    NSString * mediaType = [upcDetails objectForKey:@"media_type"];
    if( ! SMKisNULL(mediaType) ) {
        if( [mediaType isEqualToString:@"audio"] ) {
            [mediaTypeCB selectItemWithObjectValue:@"audio"];
        } else if( [mediaType isEqualToString:@"video"] ) {
            [mediaTypeCB selectItemWithObjectValue:@"video"];
        } else if( [mediaType isEqualToString:@"NO UPC"] ) {
            [self setUpcIsNew:TRUE];
        }
    }
    
    [upcTitleTF setStringValue:[upcDetails valueForKey:@"title"]];

    NSObject * valObj;
    NSString * valStr;
    
#define SET_UPC_FLD( _srcFld_, _dstFld_ ) \
    valObj = [upcDetails valueForKey:_srcFld_]; \
    if( [valObj isKindOfClass:[NSNumber class]] ) { \
        NSNumber * valNum = (NSNumber *)valObj; \
        valStr = [valNum stringValue]; \
    } else if( SMKisNULL(valObj) ) { \
        valStr = @""; \
    } else { \
        valStr = (NSString *)valObj;\
    } \
    [_dstFld_ setStringValue:valStr];
    
    SET_UPC_FLD(@"rel_year", upcYearTF);
    SET_UPC_FLD(@"rating", upcMpaaTF);
    SET_UPC_FLD(@"description", upcDescTF);
    SET_UPC_FLD(@"genres", upcGenresTF);
    SET_UPC_FLD(@"artists", upcActorsTF);
    
    NSString * mType = [[self mediaTypeCB] stringValue];

    NSData * thumbData = [upcDetails valueForKey:@"thumb"];
    if( ! SMKisNULL(thumbData) ) {
        if( [mType isEqualToString:@"audio"] ) {
            [upcThumbTF setImageScaling:NSScaleProportionally];        
        } else {
            [upcThumbTF setImageScaling:NSScaleToFit];
        }
        [upcThumbTF setImage:[[NSImage alloc]initWithData:thumbData]];
    } else {
        [upcThumbTF setImageScaling:NSScaleToFit];
        [upcThumbTF setImage:noArtImage];
    }
    
    NSString * upcVal = [[self curUpcValue] stringValue];
    NSString * title = [upcTitleTF stringValue];
    
    if( [upcVal length] > 1 
       && [title length] > 1 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {   
        [saveButton setEnabled:custHasUPC == FALSE];
        [searchButton setEnabled:TRUE];
    } else {
        [saveButton setEnabled:FALSE];        
        [searchButton setEnabled:FALSE];
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];
}

-(void)upcDetailRecProc:(NSDictionary *)rec
{
    if( rec != nil ) {
        [upcDetailsCache setValue:rec forKey:curUpcValue.stringValue];
        [self showUpcDetails:rec];
    }
}
#pragma mark UPC Selection
-(void)getAndShowUpcDetails
{
    NSString * upcStr = [[self curUpcValue]stringValue];
    SMKLogDebug(@"get&show upc: %@", upcStr );
    if( [upcStr length] > 0 
       && ! [upcStr isEqualToString:[self showingUPC]] ) {
        [self setShowingUPC:[[NSString alloc]initWithString:upcStr]];
        
        [[self upcTitleTF] setStringValue:@""];
        NSDictionary * upcDetails = [upcDetailsCache valueForKey: upcStr ];
        [saveButton setEnabled:FALSE];
        [self setNeedToRip:TRUE];
        
        if( upcDetails ) {
            [self showUpcDetails:upcDetails];
        } else {
            [progressInd setHidden:FALSE];
            [progressInd startAnimation:self];
            [db fetchAllRowsDictMtObj:self 
                                 proc:@selector(upcDetailRecProc:) 
                                  sql:[DIDB sel_upc_detailsWithUpc:upcStr ]];
        }
    }
    [myWindow makeFirstResponder:curUpcValue];
}
#pragma mark KVO Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    SMKLogDebug(@"KVO %@", keyPath);
    if( object == [self upcDataSrc] && [keyPath isEqualToString:[CustUpcDataSrc kvoData]] ) {
        [[self upcDataSrc] removeObserver:me forKeyPath:[CustUpcDataSrc kvoData]];
        [self performSelectorOnMainThread:@selector(mtUpcDataAvailable) withObject:nil waitUntilDone:FALSE];
    }
    [myWindow makeFirstResponder:curUpcValue];
}

#pragma mark Actions
- (IBAction)upcListSelectAction:(NSTableView *)sender {

    NSInteger sel = [sender selectedRow];
    if( 0 <= sel && sel < [[self upcDataSrc] numberOfRowsInTableView:sender] ) {
        NSNumber * selUpc = [[[[self upcDataSrc] data] objectAtIndex:sel] objectAtIndex:0];
        [curUpcValue setStringValue:[selUpc stringValue]];
        [self setCustHasUPC:TRUE];
        [[self saveButton]setEnabled:FALSE];
        [self getAndShowUpcDetails];
    }
    [myWindow makeFirstResponder:curUpcValue];
}


- (IBAction)stopOrGoImageAct:(id)sender 
{
    SMKLogDebug(@"stopOrGoButton");
}

- (IBAction)saveButton:(id)sender 
{
    SMKLogDebug(@"saveButton");
    NSString * mType = [[self mediaTypeCB] stringValue];
    NSString * upcVal = [[self curUpcValue] stringValue];
    
    if( [upcVal length] > 0 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {
           BOOL saved = FALSE;
        
           @try {
               saved = [DIDB set_cust:custId
                                  upc:upcVal
                            mediaType:mType
                             isNewUpc:[self upcIsNew]
                            needToRip:needToRip];
               
           }
           @catch (NSException *exception) {
               [SMKAlertWin alertWithMsg:[exception reason]];
               [saveButton setEnabled:FALSE];
               saved = FALSE;
           }
           if( saved ) {
               [saveButton setEnabled:FALSE];
               NSNumber * upcNum = [[NSNumber alloc] initWithInteger:[[curUpcValue stringValue]integerValue]];
               [[self upcDataSrc]addCustUpc:upcNum];
               [upcListTableView reloadData];
           }
       } else {
           [SMKAlertWin alertWithMsg:@"upc value and type must be set"];
       }
}

- (IBAction)cancelButton:(id)sender 
{
    SMKLogDebug(@"cancelButton");
    // [[self curUpcValue] setEnabled:FALSE];
    [CustomerViewCntlr showSelfIn:[self view]];

}

- (IBAction)searchButton:(id)sender 
{
    SMKLogDebug(@"searchButton %@", [upcTitleTF stringValue]);
    // [curUpcValue setEnabled:FALSE];
    NSString * mType = [[self mediaTypeCB] stringValue];
    NSString * upcVal = [[self curUpcValue] stringValue];
    NSString * title = [upcTitleTF stringValue];
    
    if( [upcVal length] > 1 
       && [title length] > 1 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {
           
           [[[self view]window] endEditing];
    
           metaSelViewCntlr = [VidMetaSelViewCntlr showSelfIn:[self view]
                                                    mediaType:mType
                                                        title:title
                                                         year:[upcYearTF stringValue]
                                                          upc:upcVal];
       } else {
           [SMKAlertWin alertWithMsg:@"Need a upc, title and type to search for"];
           [searchButton setEnabled:FALSE];
           [[NSNotificationCenter defaultCenter] addObserver:self
                                                    selector:@selector(textDidChange:)
                                                        name:NSTextDidChangeNotification 
                                                      object:nil];
       }
}

- (IBAction)upcEntered:(id)sender 
{
    SMKLogDebug(@"upcEntered: %@", curUpcValue.stringValue );
    // does cust have this UPC
    NSString * upc = curUpcValue.stringValue;
    NSNumber * upcNum = [NSNumber numberWithInteger:[upc integerValue]];
    
    [self setCustHasUPC:[[[self upcDataSrc] upcDict] objectForKey:upcNum] != nil];
    [self getAndShowUpcDetails];
}

- (IBAction)thumbButton:(id)sender 
{
    SMKLogDebug(@"thumbButton");
}

- (IBAction)playMedia:(id)sender {
}

- (IBAction)titleAction:(id)sender 
{
    NSString * mType = [[self mediaTypeCB] stringValue];
    NSString * upcVal = [[self curUpcValue] stringValue];
    NSString * title = [upcTitleTF stringValue];
    
    if( [upcVal length] > 1 
       && [title length] > 1 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {           
           [saveButton setEnabled:custHasUPC == FALSE];
           [searchButton setEnabled:TRUE];
       } else {
           [saveButton setEnabled:FALSE];        
           [searchButton setEnabled:FALSE];
    }
}

- (IBAction)mediaTypeAction:(id)sender 
{
    NSString * mType = [[self mediaTypeCB] stringValue];
    NSString * upcVal = [[self curUpcValue] stringValue];
    NSString * title = [upcTitleTF stringValue];
    
    if( [upcVal length] > 1 
       && [title length] > 1 
       && ( [mType isEqualToString:@"audio"] 
           || [mType isEqualToString:@"video"] ) ) {           
           [saveButton setEnabled:custHasUPC == FALSE];
           [searchButton setEnabled:TRUE];
       } else {
           [saveButton setEnabled:FALSE];        
           [searchButton setEnabled:FALSE];
       }
}


@end
