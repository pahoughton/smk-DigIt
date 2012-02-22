/**
  File:		VidMetaSelWinCntlr.m
  Project:	Dig-It
  Desc:
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/14/12  8:28 AM
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
#import "VidMetaSelWinCntlr.h"
#import "VidMetaSelDataSrc.h"
#import "VidMetaSelCellView.h"
#import "DIDB.h"
#import <SMKLogger.h>
#import <TMDbQuery.h>
#import <SMKAlertWin.h>

static VidMetaSelWinCntlr * me = nil;

@implementation VidMetaSelWinCntlr
@synthesize dataSource;
@synthesize srcTitle;
@synthesize srcYear;
@synthesize srcUpc;
@synthesize aliveAndWell;

@synthesize metaSearchTitle;
@synthesize metaSearchYear;
@synthesize searchProgressInd;
@synthesize searchButton;
@synthesize cancelButton;
@synthesize metaTableView;

+(VidMetaSelWinCntlr *)showSelfWithTitle:(NSString *)title year:(NSString *)year upc:(NSString *)upc
{
    if( me == nil ) {
        me = [[VidMetaSelWinCntlr alloc] initWithWindowNibName:@"VidMetaSelWin"];
    }
    [me setSrcTitle:title];
    [me setSrcYear:year];
    [me setSrcUpc:upc];
    if( [me aliveAndWell] ) {
        [[me metaSearchTitle] setStringValue:[me srcTitle]];
        [[me metaSearchYear] setStringValue:[me srcYear]];
        [me searchMetaButton:me];
    }
    [me showWindow:me];
    return me;
}

-(id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if( self ) {
        [self setAliveAndWell:FALSE];
    }
    return  self;
}
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self setAliveAndWell:FALSE];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self setAliveAndWell:TRUE];
    [[self metaSearchTitle] setStringValue:[self srcTitle]];
    [[self metaSearchYear] setStringValue:[self srcYear]];
    [self searchMetaButton:self];
    
    SMKLogDebug(@"win: %@", [self window]);
    [[self window] orderFront:self];
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSInteger rows = [[dataSource dataRows] count];
    SMKLogDebug(@"num rows %u",rows);
    return rows;
}
#pragma mark NSTableViewDelegate
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row 
{
    SMKLogDebug(@"tv v4f %d",row);
    VidMetaSelRowView * rv = 
    [[VidMetaSelRowView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    [rv setObjectValue:[[[self dataSource] dataRows]objectAtIndex:row]];
    return rv;
}


- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *)tableColumn 
                  row:(NSInteger)row 
{
    VidMetaSelEntity * ent = [[dataSource dataRows] objectAtIndex:row];
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
    if( [keyPath isEqualToString:[VidMetaSelDataSrc kvoChangeKey]] ) {
        SMKLogDebug(@"kvo keypath %@", keyPath);
        if( [[dataSource dataRows] count] > 0 ) {
            [metaTableView reloadData];
        
            SMKLogDebug(@"reloading %u", [[[self dataSource] dataRows] count]);
        }
    } else if( [keyPath isEqualToString:[VidMetaSelDataSrc kvoDoneKey]] ) {
        [searchProgressInd setHidden:TRUE];
        [searchProgressInd stopAnimation:self];
        if( [[dataSource dataRows] count] > 0 ) {
            [metaTableView reloadData];
            
            SMKLogDebug(@"DONE reloading %u", [[[self dataSource] dataRows] count]);
        }
    }
}


- (IBAction)searchMetaButton:(id)sender 
{
    @try {
        [TMDbQuery tmdbApiKey];
        
        [self setDataSource:[[VidMetaSelDataSrc alloc] init]];
        [[[self dataSource] gather] addObserver:self
                                     forKeyPath:[VidMetaSelDataSrc kvoChangeKey] 
                                        options:0
                                        context:nil];
        [[self dataSource] addObserver:self
                            forKeyPath:[VidMetaSelDataSrc kvoDoneKey] 
                               options:0
                               context:nil];
        [[self dataSource] findTitle:[[self metaSearchTitle] stringValue]
                                year:[[self metaSearchYear] stringValue]];
        
        [searchProgressInd setHidden:FALSE];
        [searchProgressInd startAnimation:self];
    }
    @catch (NSException *exception) {
        [SMKAlertWin alertWithMsg:[exception reason]];
    }
}

- (IBAction)cancelButton:(id)sender 
{
    [[self window] orderOut:sender];
}

- (IBAction)selectMetaButton:(id)sender 
{/*
    NSInteger row = [[self metaTableView] rowForView:sender];
    VidMetaSelEntity * meta = [[[self dataSource] dataRows] objectAtIndex:row];
    if( [DIDB set_upc:[self srcUpc]
                title:[[self metaSearchTitle] stringValue]
                 year:[[self metaSearchYear] stringValue]
              metaSrc:[meta source]
               metaId:[meta sourceId]] ) {
        [sender setEnabled:FALSE];
    }
    [self cancelButton:self];
  */
}

@end
