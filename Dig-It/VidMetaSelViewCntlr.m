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
#import "DIDB.h"
#import <SMKLogger.h>

static VidMetaSelViewCntlr * me = nil;

@implementation VidMetaSelViewCntlr
@synthesize dataSrc;
@synthesize artPickerViewCntlr;
@synthesize srcTitle;
@synthesize srcYear;
@synthesize srcUpc;
@synthesize aliveAndWell;

@synthesize titleTF;
@synthesize yearTF;
@synthesize progressInd;
@synthesize metaTView;

+(VidMetaSelViewCntlr *)showSelfIn:(NSView *)viewToReplace title:(NSString *)title year:(NSString *)year upc:(NSString *)upc
{
    if( me == nil ) {
        me = [[VidMetaSelViewCntlr alloc] initWithNibName:@"VidMetaSelView" bundle:nil];
    }
    /// need to library this
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    [me setSrcTitle:title];
    [me setSrcYear:year];
    [me setSrcUpc:upc];
    if( [me aliveAndWell] ) {
        [[me titleTF] setStringValue:[me srcTitle]];
        [[me yearTF] setStringValue:[me srcYear]];
        [me searchAction:me];
    }

    return me;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self setAliveAndWell:FALSE];
        [self setDataSrc:[[VidMetaSelDataSrc alloc]initWithTitle:srcTitle year:srcYear]];
        [[self dataSrc] findTitle:srcTitle
                             year:srcYear];
    }
    return self;
}

-(void)awakeFromNib
{

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
    [cellView.textField setStringValue: ent.title];
    
    // DIVidMetaSelCellView fields
#define ENT2CELL( fld_ ) if( ent.fld_ != nil ) cellView.fld_.stringValue = ent.fld_
    ENT2CELL( year );
    ENT2CELL( mpaa );
    ENT2CELL( genres );
    ENT2CELL( actors );
    ENT2CELL( directors );
    ENT2CELL( source );
    ENT2CELL( desc );
#undef ENT2CELL    
    
    return cellView;
}   


- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    if( [keyPath isEqualToString:[VidMetaSelDataSrc kvoChangeKey]] ) {
        SMKLogDebug(@"kvo keypath %@", keyPath);
        if( [[dataSrc dataRows] count] > 0 ) {
            [metaTView reloadData];
            
            SMKLogDebug(@"reloading %u", [[[self dataSrc] dataRows] count]);
        }
    } else if( [keyPath isEqualToString:[VidMetaSelDataSrc kvoDoneKey]] ) {
        [progressInd setHidden:TRUE];
        [progressInd stopAnimation:self];
        if( [[dataSrc dataRows] count] > 0 ) {
            [metaTView reloadData];
            
            SMKLogDebug(@"DONE reloading %u", [[[self dataSrc] dataRows] count]);
        }
    }
}

- (IBAction)selectMetaAction:(id)sender 
{
    NSInteger row = [[self metaTView] rowForView:sender];
    VidMetaSelEntity * meta = [[[self dataSrc] dataRows] objectAtIndex:row];
    if( [DIDB set_upc:[self srcUpc]
                title:[[self titleTF] stringValue]
                 year:[[self yearTF] stringValue]
              metaSrc:[meta source]
               metaId:[meta sourceId]] ) {
        [sender setEnabled:FALSE];
    }
    if( [meta tmdbArtGath] != nil ) {
        artPickerViewCntlr = [VidSelArtPickerViewCntlr showSelfIn:[self view] artGath:[meta tmdbArtGath]];
    } else {
        [self cancelAction:self];
    }
    
}

- (IBAction)searchAction:(id)sender 
{
}

- (IBAction)cancelAction:(id)sender 
{
    [CustUpcViewCntlr showSelfIn:[self view] custInfo:nil];
}
@end
