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
#import "CustListViewCntlr.h"
#import "VidMetaSelWinCntlr.h"
#import "DIDB.h"
#import <SMKLogger.h>
#import <SMKDB.h>

static CustUpcViewCntlr * me;

@implementation CustUpcViewCntlr
@synthesize db;
@synthesize myContainerView;
@synthesize metaSelWinCntlr;
@synthesize custInfo;
@synthesize custHasUPC;
@synthesize aliveAndWell;
@synthesize needToRip;
@synthesize uvfDetailsCache;
@synthesize goodSound;
@synthesize badSound;
@synthesize noArtImage;
@synthesize goImage;
@synthesize stopImage;

@synthesize upcListAcntlr;
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
+(CustUpcViewCntlr *)showSelfIn:(NSView *)viewToReplace custInfo:(NSDictionary *)cust
{
    if( me == nil ){
        me = [CustUpcViewCntlr alloc];
        me = [me initWithNibName:@"CustUpcView" bundle:nil];
    }
    /// need to library this
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    [me setCust:cust];
    return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        aliveAndWell = FALSE;
        custInfo = nil;
        [self setDb:[[SMKDBConnMgr alloc] init]];
        metaSelWinCntlr = nil;
        SMKLogDebug(@"initWithNib");
    }
    
    return self;
}

#pragma mark UpcList
-(void)upcRecProc:(NSDictionary *)rec
{
    // SMKLogDebug(@"upc rec: %@", rec);
    
    if( rec != nil ) {
        [upcListAcntlr addObject:rec];
    } else {
        // all done;
        [[self curUpcValue] setEnabled:TRUE];
        [self.curUpcValue becomeFirstResponder];
        [self.upcListAcntlr addObserver: self
                             forKeyPath: @"selectionIndex"
                                options: NSKeyValueObservingOptionNew
                                context: nil];

    }
}
-(void)getCustUpcs
{
    SMKLogDebug(@"getCustUpcs");
    [[self.view window] makeFirstResponder:self.curUpcValue];
    [self.curUpcValue becomeFirstResponder];

    // reset cache on cust change (don't want the whole db in here)
    uvfDetailsCache = [[NSMutableDictionary alloc] init];
    if( [[upcListAcntlr arrangedObjects] count] ) {
        // ugg no remove all objects :(
        NSRange rng;
        rng.location = 0;
        rng.length = [[upcListAcntlr arrangedObjects] count];
        [upcListAcntlr removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:rng]];
    }
    
    
    [db fetchAllRowsDictMtObj:self 
                         proc:@selector(upcRecProc:) 
                          sql:[DIDB sel_cust_upc:
                               [custInfo valueForKey:@"cust_id"]]];
    
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
    [upcListAcntlr setSelectsInsertedObjects:FALSE];
    [[self.view window] makeFirstResponder:curUpcValue];
    
    SMKLogDebug(@"upc acntlr %@", upcListAcntlr);
    if( custInfo ) {
        [self.custLabel setStringValue:
         [NSString stringWithFormat:@"%@ %@ (%@)",
          [custInfo valueForKey:@"first_name"],
          [custInfo valueForKey:@"last_name"],
          [custInfo valueForKey:@"cust_id"]]];
        [self getCustUpcs];
    }
}
-(void) setCust:(NSDictionary *)cust
{
    custInfo = cust;
    
    if( aliveAndWell ) {
        [self.custLabel setStringValue:
         [NSString stringWithFormat:@"%@ %@ (%@)",
          [custInfo valueForKey:@"first_name"],
          [custInfo valueForKey:@"last_name"],
          [custInfo valueForKey:@"cust_id"]]];
        [self getCustUpcs];
    }
}

#pragma mark UpcDetails
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
    if( [[upcTitleTF stringValue]length] > 0 ) {
        [searchButton setEnabled:TRUE];
    } else {
        [searchButton setEnabled:FALSE];
    }
    [stopOrGoImage setImage:stopImage];
    [haveOrRipLabel setStringValue:@"😥 RIP 😥"];
    [badSound play];
    [progressInd setHidden:TRUE];
    [progressInd stopAnimation:self];

    // NEED to RIP
}

-(void)upcDetailRecProc:(NSDictionary *)rec
{
    if( rec != nil ) {
        [self showUpcDetails:rec];
    } else {
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
    NSString * vid_id = [uvfDetails valueForKey:@"vid_id"];
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
        NSDictionary * uvfDetails = [uvfDetailsCache valueForKey:
                                     curUpcValue.stringValue];
        [saveButton setEnabled:FALSE];
        [self setNeedToRip:TRUE];
        
        if( uvfDetails ) {
            [self showUvfDetails:uvfDetails];
        } else {
            
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
    // if( [keyPath isEqualToString:@"selectionIndex"] ) {
    if( [upcListAcntlr selectionIndex] != NSNotFound ) {
        NSDictionary * selectedUpc = [upcListAcntlr selection];
        [curUpcValue setStringValue:[selectedUpc valueForKey:@"upc"]];
        [self setCustHasUPC:TRUE];
        [progressInd setHidden:FALSE];
        [progressInd startAnimation:self];
        [self getAndShowUpcDetails];
    }
    [self.curUpcValue becomeFirstResponder];
}

#pragma mark Actions
- (IBAction)stopOrGoImageAct:(id)sender 
{
    SMKLogDebug(@"stopOrGoButton");
}

- (IBAction)saveButton:(id)sender 
{
    SMKLogDebug(@"saveButton");
    if( [DIDB set_cust:[custInfo valueForKey:@"cust_id"]
                   upc:[curUpcValue stringValue]
             needToRip:needToRip] ) {
        [saveButton setEnabled:FALSE];
    }
}

- (IBAction)cancelButton:(id)sender 
{
    SMKLogDebug(@"cancelButton");
    [CustListViewCntlr showSelfIn:[self view]];
}

- (IBAction)searchButton:(id)sender 
{
    SMKLogDebug(@"searchButton");
    if( [[upcTitleTF stringValue] length] > 1 ) {
        [self setMetaSelWinCntlr:[VidMetaSelWinCntlr 
                                  showSelfWithTitle:[upcTitleTF stringValue]
                                  year:[upcYearTF stringValue]
                                  upc:[curUpcValue stringValue]]];
    } else {
        [searchButton setEnabled:FALSE];
    }
}

- (IBAction)upcEntered:(id)sender 
{
    SMKLogDebug(@"upcEntered: %@", curUpcValue.stringValue );
    // does cust have this UPC
    NSString * upc = curUpcValue.stringValue;
    [self setCustHasUPC:FALSE];
    NSNumber * upcNum = [NSNumber numberWithInteger:[upc integerValue]];
    for( NSDictionary * upcRec in [upcListAcntlr arrangedObjects] ) {
        NSDecimalNumber * upcVal = [upcRec valueForKey:@"upc"];
        BOOL same = [upcNum isEqualToNumber:upcVal];
        /*
        SMKLogDebug(@"upc: %@ %s %@", 
                    upcNum,
                    same ? "==" : "<>",
                    upcVal );
         */          
        if( same ) {
            [self setCustHasUPC:TRUE];
            break;
        }
    }
    [progressInd setHidden:FALSE];
    [progressInd startAnimation:self];
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
