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
  [excptDesc appendFormat:@"Symbols(%lu)\n",symCnt];
  
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

@synthesize window    = _window;
@synthesize contentV  = _contentV;

@synthesize gradyVC   = _gradyVC;
@synthesize prefsWC   = _prefsWC;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  SMKLogFunct;
  // First things first - init SMKLogger
  SMKLogger * myLogger = [SMKLogger appLogger];
  // [myLogger setTeeLogger:[[SMKLogger alloc]initToStderr]];
  NSLog(@"App LogFile: %@",myLogger.logFileFn );
  SMKLogFunct;
  
  NSUncaughtExceptionHandler * myHndlr = &SMKUncaughtExceptionHandler;
  
  origExcptHndlr = NSGetUncaughtExceptionHandler();
  
  NSSetUncaughtExceptionHandler(myHndlr);

  [[NSUserDefaults standardUserDefaults] 
   setBool:TRUE 
   forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
  
  AppUserValues * aud = [[AppUserValues alloc]init];
  SMKLogDebug(@"%@",[aud description]);
  [SMKDBConnMgr setDefaultInfoProvider:aud];
  
  
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
  }
  [self setGradyVC:[[GradyVCntlr alloc]initWithViewToReplace:self.contentV]];  
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
  SMKLogFunct;
  return TRUE;
}
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  SMKLogFunct;
  return NSTerminateNow;
}

- (IBAction)prefsMenuItem:(id)sender 
{
  SMKLogDebug(@"prefsAction");
  if( self.prefsWC == nil ) {
    [self setPrefsWC: [DigitizePrefsWinCntlr createSelf]];
  }
  
  //[self.prefsWinCntlr showWindow:self]; 
  SMKLogDebug(@"pref win %@", [self.prefsWC window]);
  [[self.prefsWC window] makeKeyAndOrderFront:self];
}

- (IBAction)artPickerMenuItem:(id)sender
{
  /*
  if( artWinCntlr == nil ) {
    artWinCntlr = [[ArtPickerWinCntlr alloc] initWithWindowNibName:@"ArtPickerWin"];
  }
  [artWinCntlr showWindow:prefsWinCntlr];
  if( [artWinCntlr window] ) {
    [[artWinCntlr window] makeKeyAndOrderFront:self];
  }
   */
}

@end
