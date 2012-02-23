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
@synthesize custInfo;
@synthesize custId;
@synthesize custHasUPC;
@synthesize aliveAndWell;
@synthesize needToRip;
@synthesize uvfDetailsCache;
@synthesize goodSound;
@synthesize badSound;
@synthesize noArtImage;
@synthesize goImage;
@synthesize stopImage;

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
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
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
    uvfDetailsCache = [[NSMutableDictionary alloc] init];
    
    [upcListTableView setDataSource:upcDataSrc];
    [upcListTableView reloadData];
    [[self curUpcValue] setEnabled:TRUE];
    [self.curUpcValue becomeFirstResponder];
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
            [self mtUpcDataAvailable];
        } else {
            [[self progressInd] setHidden:FALSE];
            [[self progressInd] startAnimation:self];
        }
    }
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
    NSLog(@"text change %@",note);
    // [saveButton setEnabled:TRUE];
    [searchButton setEnabled:TRUE];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification 
                                                  object:nil];
}


-(void)showUpcDetails:(NSDictionary *)upcDetails
{
    NSString * uTitle = [upcDetails valueForKey:@"upc_title"];
    NSString * uDesc = [upcDetails valueForKey:@"upc_desc"];
    [upcTitleTF setStringValue:
     uTitle != nil ? uTitle : uDesc != nil ? uDesc : @""];
    [upcYearTF setStringValue:[upcDetails valueForKey:@"upc_year"]];
    [upcMpaaTF setStringValue:[upcDetails valueForKey:@"upc_rating"]];
    [upcGenresTF setStringValue:[upcDetails valueForKey:@"upc_genres"]];
    [upcActorsTF setStringValue:@""];
    [upcDescTF setStringValue:uDesc];
    [upcThumbTF setImage:noArtImage];
    
    if( ! [self custHasUPC] ) {
        [saveButton setEnabled:TRUE];
    } else {
        [saveButton setEnabled:FALSE];        
    }
    if( [[upcTitleTF stringValue]length] < 1 ) {
        [upcTitleTF setStringValue:@"UNKNOWN - Enter Title"];
    } else {
        [searchButton setEnabled:TRUE];
    }
    [stopOrGoImage setImage:stopImage];
    [haveOrRipLabel setStringValue:@"😥 RIP 😥"];
    [badSound play];
    [progressInd setHidden:TRUE];
    [progressInd stopAnimation:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];

    // NEED to RIP
}

-(void)upcDetailRecProc:(NSDictionary *)rec
{
    if( rec != nil ) {
        [self showUpcDetails:rec];
    } else {
        if( [[upcTitleTF stringValue] length] < 1 ) {
            if( ! [self custHasUPC] ) {
                [saveButton setEnabled:TRUE];
            } else {
                [saveButton setEnabled:FALSE];        
            }
            if( [[upcTitleTF stringValue]length] < 1 ) {
                [upcTitleTF setStringValue:@"UNKNOWN - Enter Title"];
            } else {
                [searchButton setEnabled:TRUE];
            }
            [[self curUpcValue] setEnabled:TRUE];
            [stopOrGoImage setImage:stopImage];
            [haveOrRipLabel setStringValue:@"😥 RIP 😥"];
            [badSound play];
            [progressInd setHidden:TRUE];
            [progressInd stopAnimation:self];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(textDidChange:)
                                                         name:NSTextDidChangeNotification 
                                                       object:nil];
        }
        // all done
    }
}
-(void)showUvfDetails:(NSDictionary *)uvfDetails
{
    // SMKLogDebug(@"uvfDetailts %@", uvfDetails);
    [upcTitleTF setStringValue:[uvfDetails valueForKey:@"title"]];
    [upcYearTF setStringValue:[uvfDetails valueForKey:@"vt_year"]];
    [upcMpaaTF setStringValue:[uvfDetails valueForKey:@"mpaa_rating"]];
    if( [uvfDetails valueForKey:@"desc_long"] != nil ) {
        [upcDescTF setStringValue:[uvfDetails valueForKey:@"desc_long"]];
    } else if( [uvfDetails valueForKey:@"desc_short"] != nil ) {
        [upcDescTF setStringValue:[uvfDetails valueForKey:@"desc_short"]];        
    } else {
        [upcDescTF setStringValue:@""];
    }
    NSNumber * vid_id = [uvfDetails valueForKey:@"vid_id"];
    [upcGenresTF setStringValue:[DIDB vtGenres:vid_id]];
    [upcActorsTF setStringValue:[DIDB vtActors:vid_id]];
    NSImage * thumb = [DIDB vtThumb:vid_id artid:[uvfDetails valueForKey:@"art_thumb_id"]];
    if( thumb != nil) {
        [upcThumbTF setImage:thumb];
    } else {
        [upcThumbTF setImage:noArtImage];
    }
    
    if( ! [self custHasUPC] ) {
        [saveButton setEnabled:TRUE];
    } else {
        [saveButton setEnabled:FALSE];        
    }
    if( [[upcTitleTF stringValue]length] > 0 ) {
        [searchButton setEnabled:TRUE];
    } else {
        [searchButton setEnabled:FALSE];
    }
    [stopOrGoImage setImage:goImage];
    [haveOrRipLabel setStringValue:@"😄 have 😄"];
    [goodSound play];
    [progressInd setHidden:TRUE];
    [progressInd stopAnimation:self];
    [self setNeedToRip:FALSE];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];
    // ALREADY have media
}
-(void)uvfDetailRecProc:(NSDictionary *)rec
{
    if( rec != nil ) {
        [uvfDetailsCache setValue:rec forKey:curUpcValue.stringValue];
        [self showUvfDetails:rec];
    } else {
        if( [uvfDetailsCache valueForKey:curUpcValue.stringValue] == nil ) {
            // no uvfDetails - get what we can from upcs table
            [db fetchAllRowsDictMtObj:self 
                                 proc:@selector(upcDetailRecProc:) 
                                  sql:[DIDB sel_upcs:curUpcValue.stringValue]];
            
        }
    }
}
#pragma mark UPC Selection
-(void)getAndShowUpcDetails
{
    SMKLogDebug(@"get&show upc: %@", curUpcValue.stringValue );
    if( [curUpcValue.stringValue length] > 0 ) {
        [[self upcTitleTF] setStringValue:@""];
        NSDictionary * uvfDetails = [uvfDetailsCache valueForKey:
                                     curUpcValue.stringValue];
        [saveButton setEnabled:FALSE];
        [self setNeedToRip:TRUE];
        
        if( uvfDetails ) {
            [self showUvfDetails:uvfDetails];
        } else {
            [progressInd setHidden:FALSE];
            [progressInd startAnimation:self];
            [db fetchAllRowsDictMtObj:self 
                                 proc:@selector(uvfDetailRecProc:) 
                                  sql:[DIDB sel_uvf_detailsWithUpc:
                                       [curUpcValue stringValue]]];
        }
    }
}
#pragma mark KVO Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    SMKLogDebug(@"KVO %@", keyPath);
    if( object == [self upcDataSrc] && [keyPath isEqualToString:[CustUpcDataSrc kvoData]] ) {
        [[self upcDataSrc] removeObserver:me forKeyPath:[CustUpcDataSrc kvoData]];
        [self performSelectorOnMainThread:@selector(mtUpcDataAvailable) withObject:nil waitUntilDone:FALSE];
    }
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
    [self.curUpcValue becomeFirstResponder];
}


- (IBAction)stopOrGoImageAct:(id)sender 
{
    SMKLogDebug(@"stopOrGoButton");
}

- (IBAction)saveButton:(id)sender 
{
    SMKLogDebug(@"saveButton");
    if( [[curUpcValue stringValue] length] > 0 ) {
        BOOL saved = FALSE;
        
        @try {
            saved = [DIDB set_cust:custId
                               upc:[curUpcValue stringValue]
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
    }
}

- (IBAction)cancelButton:(id)sender 
{
    SMKLogDebug(@"cancelButton");
    [[self curUpcValue] setEnabled:FALSE];
    [CustomerViewCntlr showSelfIn:[self view]];

}

- (IBAction)searchButton:(id)sender 
{
    SMKLogDebug(@"searchButton %@", [upcTitleTF stringValue]);
    [curUpcValue setEnabled:FALSE];
    [[[self view]window] endEditing];
    
    if( [[upcTitleTF stringValue] length] > 1 ) {
        metaSelViewCntlr = [VidMetaSelViewCntlr showSelfIn:[self view]
                                                     title:[upcTitleTF stringValue]
                                                      year:[upcYearTF stringValue]
                                                       upc:[curUpcValue stringValue]];
    } else {
        [SMKAlertWin alertWithMsg:@"Need a title to search for"];
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
    if( [[upcTitleTF stringValue]length] > 0 ) {
        [searchButton setEnabled:TRUE];
    } else {
        [searchButton setEnabled:FALSE];
    }
}


@end
