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

NSUncaughtExceptionHandler * origExcptHndlr = 0;

void SMKUncaughtExceptionHandler(NSException *exception);

void SMKUncaughtExceptionHandler(NSException *exception)
{
  NSMutableString * excptDesc = [[NSMutableString alloc]initWithFormat:
                                 @"Uncaught Exception: %@ - %@\n",
                                 [exception name],
                                 [exception reason]];
  
  NSArray * callStack = [exception callStackSymbols];
  NSUInteger symCnt = [callStack count];
  [excptDesc appendFormat:@"Symbols(%u)\n",symCnt];
  
  for( NSString * sym in callStack ) {
    [excptDesc appendFormat:@"   %@\n",sym];
  }
  SMKLogError(excptDesc);
  if( origExcptHndlr != nil ) {
    (*origExcptHndlr)(exception);
  } else {
    [NSApp terminate:nil];
    exit(1);
  }
}

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
    
  NSUncaughtExceptionHandler * myHndlr = &SMKUncaughtExceptionHandler;
  
  origExcptHndlr = NSGetUncaughtExceptionHandler();
  
  NSSetUncaughtExceptionHandler(myHndlr);
  
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
  [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
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
