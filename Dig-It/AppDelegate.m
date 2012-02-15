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

#import <SMKLogger.h>
#import <SMKDB.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize digItWinCntlr;
@synthesize prefsWinCntlr;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // First things first - init SMKLogger
    SMKLogger * myLogger = [SMKLogger appLogger];
    [myLogger setTeeLogger:[[SMKLogger alloc]initToStderr]];
    SMKLogDebug(@"App LogFile: %@",[myLogger logFileFn] );
    
    AppUserValues * aud = [[AppUserValues alloc]init];
    SMKLogDebug(@"%@",[aud description]);
    
    [SMKDBConnMgr setDefaultInfoProvider:aud];
    
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
        //hmmm ...
        NSObject * hmm = [[self window]delegate];
        SMKLogDebug(@"ad my win delegate %p %@", hmm, [hmm className]);
        if( [hmm isKindOfClass:[DigItWinCntlr class]] ) {
            digItWinCntlr = (DigItWinCntlr *)hmm;
            [digItWinCntlr goodToGo];
        }
    }
}

- (IBAction)prefsMenuItem:(id)sender 
{
    if( prefsWinCntlr == nil ) {
        prefsWinCntlr = [[PrefsWinCntlr alloc] initWithWindowNibName:@"PrefsWin"];
        [prefsWinCntlr setMainWindow:[self window]];
    }
    [prefsWinCntlr showWindow:prefsWinCntlr];
}

@end
