/**
 File:		AppDelegate.m
 Project:	Dig-It
 Desc:
 
 Notes:
 
 Author(s):   Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
 Created:     02/06/2012 04:36
 Copyright:   Copyright (c) 2012 Secure Media Keepers
 www.SecureMediaKeepers.com
 All rights reserved.
 
 Revision History: (See ChangeLog for details)
 
 $Author$
 $Date$
 $Revision$
 $Name$
 $State$
 
 $Id$
 
 **/

#import "AppDelegate.h"
#import "AppUserValues.h"
#import "PrefsWinCntlr.h"
#import "DigItWinCntlr.h"
#import "ArtPickerWinCntlr.h"

#import <SMKLogger.h>
#import <SMKAlertWin.h>
#import <SMKDB.h>
#import <TMDbQuery.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize digItWinCntlr;
@synthesize prefsWinCntlr;
@synthesize artWinCntlr;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // First things first - init SMKLogger
    SMKLogger * myLogger = [SMKLogger appLogger];
    // [myLogger setTeeLogger:[[SMKLogger alloc]initToStderr]];
    SMKLogDebug(@"App LogFile: %@",[myLogger logFileFn] );
    
    AppUserValues * aud = [[AppUserValues alloc]init];
    SMKLogDebug(@"%@",[aud description]);
    [SMKDBConnMgr setDefaultInfoProvider:aud];
    
    
    NSObject * winDelegate = [[self window]delegate];
    SMKLogDebug(@"ad my win delegate %p %@", winDelegate, [winDelegate className]);
    if( [winDelegate isKindOfClass:[DigItWinCntlr class]] ) {
        digItWinCntlr = (DigItWinCntlr *)winDelegate;
    } else {
        [SMKAlertWin alertWithMsg:@"Bug - deligate is not DigiTWinCntlr"];
        sleep(10);
        exit(1);
    }
    
    NSString * tmdbApiKey;
    @try {
        tmdbApiKey = [TMDbQuery tmdbApiKey];
    }
    @catch (NSException *exception) {
        [SMKAlertWin alertWithMsg:[exception reason]];
        exit(1);
    }
    
    SMKDBConnMgr * db = nil;
    @try {
        db = [[SMKDBConnMgr alloc] init];
        [db connect];        
    }
    @catch (NSException *exception) {
        SMKLogWarn(@"db login failed: %@",[exception reason]);
        db = nil;
    }
    
    if( db == nil ) {
        [self prefsMenuItem:self];
        [[self window] orderOut:self];
    } else {
        SMKLogDebug(@"Woot Connected :)");
        [digItWinCntlr goodToGo];
    }
}

- (IBAction)prefsMenuItem:(id)sender 
{
    if( prefsWinCntlr == nil ) {
        prefsWinCntlr = [[PrefsWinCntlr alloc] initWithWindowNibName:@"PrefsWin"];
        [prefsWinCntlr setMainWinCntlr:digItWinCntlr];
    }
    [prefsWinCntlr showWindow:prefsWinCntlr];
    [[prefsWinCntlr window] makeKeyAndOrderFront:self];
}

- (IBAction)artPickerMenuItem:(id)sender
{
    if( artWinCntlr == nil ) {
        artWinCntlr = [[ArtPickerWinCntlr alloc] initWithWindowNibName:@"ArtPickerWin"];
    }
    [artWinCntlr showWindow:prefsWinCntlr];
    if( [artWinCntlr window] ) {
        [[artWinCntlr window] makeKeyAndOrderFront:self];
    }
}

@end
