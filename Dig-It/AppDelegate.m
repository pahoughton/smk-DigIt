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
#import "VideoIMDbMetaParser.h"
#import <SMKCommon.h>

@implementation AppDelegate

@synthesize window    = _window;
@synthesize contentV  = _contentV;

@synthesize gradyVC   = _gradyVC;
@synthesize prefsWC   = _prefsWC;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [SMKException setUncaughtHandler];
  AppUserValues * aud = [[AppUserValues alloc]init];
  {
    NSString * logDir
    = [SMKMediaBasedir() stringByAppendingPathComponent:@"SMK/Logs"];
    NSString * err = [SMKLogger setDefaultLogDir: logDir
                                            name: [aud dbApp]
                                            user: [aud dbUser]];
    if( err != nil ) {
      [SMKAlertWin alertWithMsg:err];
      [NSApp terminate:nil];
      exit(2);
    }
  }
  SMKLogDebug(@"Defaults: %@",aud);
  [SMKDBConnMgr setDefaultInfoProvider: aud];
  
  SMKLogger * myLogger = [SMKLogger appLogger];
  NSLog(@"App LogFile: %@",myLogger.logFileFn );
  
  SMKLogFunct;
  
  [[NSUserDefaults standardUserDefaults] 
   setBool:TRUE 
   forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
  
  SMKLogDebug(@"%@",[aud description]);
  [SMKDBConnMgr setDefaultInfoProvider:aud];
  
  [VideoIMDbMetaParser parserInit];
  
  NSString * tmdbApiKey;
  @try {
    tmdbApiKey = [TMDbQuery tmdbApiKey];
  }
  @catch (NSException *exception) {
    [SMKAlertWin alertWithMsg:[exception reason]];
    [NSApp terminate:nil];
    exit(2);
  }

  if( tmdbApiKey == nil || tmdbApiKey.length < 1 ) {
    [SMKAlertWin alertWithMsg:@"tmdbApiKey not found"];
    [NSApp terminate:nil];
    exit(2);
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
