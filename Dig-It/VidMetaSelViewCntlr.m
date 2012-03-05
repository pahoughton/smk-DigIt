/**
  File:		VidMetaSelViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  10:53 AM
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
#import "VidMetaSelViewCntlr.h"
#import "VidMetaSelDataSrc.h"
#import "VidMetaSelCellView.h"
#import "VidSelArtPickerViewCntlr.h"
#import "CustUpcViewCntlr.h"
#import "ArtBrowswerItemGatherer.h"
#import "DIDB.h"
#import <SMKLogger.h>
#import <SMKCocoaCommon.h>

static VidMetaSelViewCntlr * me = nil;

@implementation VidMetaSelViewCntlr
@synthesize dataSrc;
@synthesize artPickerViewCntlr;
@synthesize srcMediaType;
@synthesize srcTitle;
@synthesize srcYear;
@synthesize srcUpc;
@synthesize aliveAndWell;
@synthesize mediaTypeRB;
@synthesize audioRB;
@synthesize videoRB;

@synthesize titleTF;
@synthesize yearTF;
@synthesize progressInd;
@synthesize metaTView;
@synthesize searchButton;
@synthesize TMDbButton;

+(VidMetaSelViewCntlr *)showSelfIn:(NSView *)viewToReplace 
                         mediaType:(NSString *)mediaType 
                             title:(NSString *)title 
                              year:(NSString *)year 
                               upc:(NSString *)upc
{
    if( me == nil ) {
        me = [[VidMetaSelViewCntlr alloc] initWithNibName:@"VidMetaSelView"
                                                   bundle:nil 
                                                mediaType:mediaType
                                                    title:title
                                                     year:year 
                                                      upc:upc];
    } else {
        [me setSrcMediaType:mediaType];
        [me setSrcTitle:title];
        [me setSrcYear:year];
        [me setSrcUpc:upc];
    }
    if( [me aliveAndWell] ) {
        [[me titleTF] setStringValue:[me srcTitle]];
        [[me yearTF] setStringValue:[me srcYear]];
        if( [mediaType isEqualToString:@"audio"] ) {
            [[me mediaTypeRB]selectCell:[me audioRB]];
        } else {
            [[me mediaTypeRB]selectCell:[me videoRB]];
        }
        [me searchAction:me];
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

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil 
            mediaType:(NSString *)mediaType
                title:(NSString *)title 
                 year:(NSString *)year
                  upc:(NSString *)upc
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self setAliveAndWell:FALSE];
        [self setSrcMediaType:mediaType];
        [self setSrcTitle:title];
        [self setSrcYear:year];
        [self setSrcUpc:upc];
        [self setDataSrc:[[VidMetaSelDataSrc alloc] init]];
        [dataSrc addObserver:self 
                  forKeyPath:[VidMetaSelDataSrc kvoDataRows]
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        [dataSrc findMeta:[self srcMediaType] 
                      upc:[self srcUpc]
                    title:[self srcTitle] 
                     year:[self srcYear]
                  getMore:FALSE];
    }
    return self;
}

-(void)myTextDidChange:(NSNotification *)note
{
    SMKLogDebug(@"my text did change %@", note);
    [[self searchButton] setTitle:@"Search"];
    [self setSrcUpc:@""];
    [[self searchButton] setEnabled:TRUE];
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                              forKeyPath:NSTextDidChangeNotification];
     */
}

-(void)mtSetDataSrc:(id)trash
{
    [progressInd setHidden:TRUE];
    [progressInd stopAnimation:self];
    if( [dataSrc didMoreSearch] ) {
        [[self searchButton] setTitle:@"Search"];
        [[self searchButton]setEnabled:FALSE];
    } else {
        [[self searchButton] setTitle:@"More"];
        [[self searchButton]setEnabled:TRUE];
    }
    [metaTView setDataSource:dataSrc];
    [metaTView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myTextDidChange:)
                                                 name:NSTextDidBeginEditingNotification
                                               object:nil];
}


-(void)awakeFromNib
{
    SMKLogDebug(@"awake alive %d data: %p", aliveAndWell, [dataSrc dataRows]);
    if( aliveAndWell ) {
        return; // NO idea how hit got here TWICE
    }
    [self setAliveAndWell:TRUE];
    [[self titleTF] setStringValue:[me srcTitle]];
    [[self yearTF] setStringValue:[me srcYear]];
    if( [srcMediaType isEqualToString:@"audio"] ) {
        [[self mediaTypeRB]selectCell:[self audioRB]];
    } else {
        [[self mediaTypeRB]selectCell:[self videoRB]];
    }
    
    if( [dataSrc dataRows] == nil ) {
        [[self progressInd] setHidden:FALSE];
        [[self progressInd] startAnimation:self];
        [[self searchButton] setEnabled:FALSE];
        [[self TMDbButton] setEnabled:FALSE];
    } else {
        [self mtSetDataSrc:nil];
        [dataSrc removeObserver:self forKeyPath:[VidMetaSelDataSrc kvoDataRows]];
    }
}

#pragma mark NSTableViewDelegate
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row 
{
    SMKLogDebug(@"tv v4f %d",row);
    VidMetaSelRowView * rv = 
    [[VidMetaSelRowView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    [rv setObjectValue:[[[self dataSrc] dataRows]objectAtIndex:row]];
    return rv;
}


- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *)tableColumn 
                  row:(NSInteger)row 
{
    VidMetaSelEntity * ent = [[dataSrc dataRows] objectAtIndex:row];
    SMKLogDebug( @"viewForCol row %u\n%@", row,ent );
    
    VidMetaSelCellView * cellView = [tableView makeViewWithIdentifier:@"VidMetaSelCellView" 
                                                                owner:self];
    // base class fields
    // FIXME - noArt?
    [cellView.imageView setImage:       ent.thumb];
    if( [mediaTypeRB selectedCell] == videoRB ) {
        [cellView.imageView setImageScaling:NSScaleToFit];
    } else {
        [cellView.imageView setImageScaling:NSScaleProportionally];        
    }
    [cellView.textField setStringValue: ent.title];
    [cellView.selectButton setEnabled:TRUE];
    
    // DIVidMetaSelCellView fields
#define ENT2CELL( fld_ ) if( ent.fld_ != nil ) cellView.fld_.stringValue = ent.fld_
    ENT2CELL( year );
    ENT2CELL( mpaa );
    ENT2CELL( genres );
    ENT2CELL( actors );
    ENT2CELL( directors );
    cellView.source.stringValue = [DIDB dsForUser:ent.source];
    ENT2CELL( desc );
#undef ENT2CELL    
    
    return cellView;
}   

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    SMKLogDebug(@"kvo keypath %@", keyPath);
    if( object == dataSrc 
       && [keyPath isEqualToString:[VidMetaSelDataSrc kvoDataRows]]
       && [self aliveAndWell] ) {
        [dataSrc removeObserver:self forKeyPath:[VidMetaSelDataSrc kvoDataRows]];
        [self performSelectorOnMainThread:@selector(mtSetDataSrc:) withObject:self waitUntilDone:FALSE];
    }
}

- (IBAction)selectMetaAction:(id)sender 
{
    NSInteger row = [[self metaTView] rowForView:sender];
    VidMetaSelEntity * meta = [[[self dataSrc] dataRows] objectAtIndex:row];
    NSNumber * selId;
    selId = [DIDB set_media_meta:[self srcUpc]
                           title:[[self titleTF] stringValue]
                            year:[[self yearTF] stringValue]
                         metaSrc:[meta source]
                          metaId:[meta sourceId]];
    if( selId != nil ) {
        [sender setEnabled:FALSE];
    }

    SMKLogDebug(@"sel row: %d t: %@ src %@ id %@ selid %@", 
                row,
                [meta title],
                [DIDB dsDesc:[meta source]],
                [meta sourceId], 
                selId);
    /* 
      on to art, but first cancel any 'OTHER' art gatherers
     */
    for( ArtBrowswerItemGatherer * gath in [[self dataSrc]artGatherList] ) {
        // This SHOULD work
        if( gath != [meta artGath] ) {
            [gath cancel];
        }
    }
    if( [meta artGath] 
       && ( ([[meta artGath] isFinished] && [[[meta artGath] artList] count] > 0 )
           || ( ! [[meta artGath] isFinished]) )) {
        ArtBrowswerItemGatherer * gath = [meta artGath];
        SMKLogDebug(@"ag %@",gath);
        
        artPickerViewCntlr = [VidSelArtPickerViewCntlr showSelfIn:[self view] 
                                                        metaSelId:selId 
                                                          artGath:[meta artGath]];
    } else {
        [self cancelAction:self];
    }
}

- (IBAction)searchAction:(id)sender 
{
    SMKLogDebug(@"search win: %@", [[self view]window]);
    [[[self view]window] endEditing];
    
    if( [[[self searchButton] title] isEqualToString:@"Search"] ) {
        [self setDataSrc:[[VidMetaSelDataSrc alloc]init]];
        [[self dataSrc] addObserver:me 
                         forKeyPath:[VidMetaSelDataSrc kvoDataRows]
                            options:NSKeyValueObservingOptionNew
                            context:nil];
        [[self progressInd] setHidden:FALSE];
        [[self progressInd] startAnimation:self];
        NSString * mediaType;
        if( [mediaTypeRB selectedCell] == videoRB ) {
            mediaType = @"video";
        } else {
            mediaType = @"audio";
        }
        [[self dataSrc] findMeta:mediaType 
                             upc:srcUpc
                           title:[titleTF stringValue] 
                            year:[yearTF stringValue]
                         getMore:FALSE];
    } else {
        [[self dataSrc] addObserver:me 
                         forKeyPath:[VidMetaSelDataSrc kvoDataRows]
                            options:NSKeyValueObservingOptionNew
                            context:nil];
        [[self progressInd] setHidden:FALSE];
        [[self progressInd] startAnimation:self];
        NSString * mediaType;
        if( [mediaTypeRB selectedCell] == videoRB ) {
            mediaType = @"video";
        } else {
            mediaType = @"audio";
        }
        [[self dataSrc] findMeta:mediaType
                             upc:srcUpc
                           title:[titleTF stringValue] 
                            year:[yearTF stringValue]
                         getMore:TRUE];
    }
}
    
- (IBAction)cancelAction:(id)sender 
{
    if( ! [[self progressInd] isHidden] ) {
        [dataSrc removeObserver:self forKeyPath:[VidMetaSelDataSrc kvoDataRows]];
    }
    [CustUpcViewCntlr showSelfIn:[self view] custInfo:nil upcData:nil];
}

@end
