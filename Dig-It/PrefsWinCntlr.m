/**
  File:		PrefsWinCntlr.m
  Project:	Dig-It
  Desc:
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  9:24 AM
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
#import "PrefsWinCntlr.h"
#import "AppUserValues.h"
#import <SMKLogger.h>
#import <SMKDB.h>
#import <NSWindowAdditions.h>
#import <QuartzCore/CoreAnimation.h>

@implementation PrefsWinCntlr
@synthesize serverTypeSelector;
@synthesize errorMessageTextField;
@synthesize passTextField;
@synthesize useKeyChain;
@synthesize mainWindow;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        SMKLogDebug(@"init win: %@", window);
        // Initialization code here.
    }    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    SMKLogDebug(@"win did load win: %@", [self window]);
    [serverTypeSelector addItemWithObjectValue:@"Postgres"];
    [serverTypeSelector addItemWithObjectValue:@"MySql"];
    AppUserValues * aud = [[AppUserValues alloc] init];
    NSString * pass = [aud dbPass];
    if( pass ) {
        [passTextField setStringValue:pass];
    }
                       
}

static int numberOfShakes = 8;
static float durationOfShake = 0.5f;
static float vigourOfShake = 0.05f;

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
    
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
    int index;
    for (index = 0; index < numberOfShakes; ++index)
    {
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) - frame.size.width * vigourOfShake, NSMinY(frame));
        CGPathAddLineToPoint(shakePath, NULL, NSMinX(frame) + frame.size.width * vigourOfShake, NSMinY(frame));
    }
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}


- (IBAction)okButton:(id)sender {
    
    BOOL didEndEdit = [[self window] endEditing];
    SMKLogDebug(@"ok did end edit: %d", didEndEdit);
    
    AppUserValues * aud = [[AppUserValues alloc]init];
    SMKLogDebug(@"%@",[aud description]);
    if( passTextField.stringValue != nil 
       && [passTextField.stringValue length] > 0 ) {
        [AppUserValues setDbPass:[passTextField stringValue]];
        SMKLogDebug(@"setting pass to: %@", [passTextField stringValue]);
    }

    NSString * errMesg = nil;
    SMKDBConnMgr * db = nil;
    @try {
        db = [[SMKDBConnMgr alloc] init];
        [db connect];        
    }
    @catch (NSException *exception) {
        errMesg = [exception reason];
        SMKLogWarn(@"db login failed: %@", errMesg);
        db = nil;
    }
    if( errMesg != nil ) {
        [errorMessageTextField setStringValue:errMesg];
        [[self window] setAnimations:
         [NSDictionary dictionaryWithObject:
          [self shakeAnimation:[[self window] frame]] forKey:@"frameOrigin"]];
        [[[self window] animator] setFrameOrigin:[[self window] frame].origin];
    } else {
        SMKLogDebug(@"suscess!");
        [[self window] orderOut:self];
        if( mainWindow ) {
            [mainWindow makeKeyAndOrderFront:self];
        }
    }
}
@end
