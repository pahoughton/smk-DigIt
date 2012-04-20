/**
  File:		DigItWinCntlr.m
  Project:	Dig-It
  Desc:
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  10:02 AM
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
#import "DigItWinCntlr.h"
#import "CustomerViewCntlr.h"
#import <SMKLogger.h>

static NSString * udFromColorKey  = @"digit-winFromColorKey";
static NSString * udToColorKey    = @"digit-winToColorKey";
static NSString * udGradyAngleKey = @"digit-winGradyAngle";


@implementation DigItWinCntlr
@synthesize mainWinGradyView;
@synthesize contentV;
@synthesize custViewCntlr;
@synthesize fromColorWell;
@synthesize toColorWell;
@synthesize directionSlider;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        SMKLogDebug( @"%@ (%p) initWithWindow win:%@",[self className], self, [self window]);
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    SMKLogDebug(@"winDidLoad");

}

- (void)goodToGo
{
  
  NSColor *  fromColor = nil;
  NSColor *  toColor   = nil;
  NSData *   colorData = nil;
  colorData =[[NSUserDefaults standardUserDefaults] dataForKey:udFromColorKey];
  if (colorData != nil) {
    fromColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:colorData];
  } else {
    fromColor = [NSColor lightGrayColor];
  }
  colorData =[[NSUserDefaults standardUserDefaults] dataForKey:udToColorKey];
  if (colorData != nil) {
    toColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:colorData];
  } else {
    toColor = [NSColor darkGrayColor];
  }
  float gradyAngle = [[NSUserDefaults standardUserDefaults] floatForKey:udGradyAngleKey];
  if( gradyAngle == 0.0 ) {
    gradyAngle = 90.0;
  }
  
  [self.mainWinGradyView setStartColor:fromColor];
  [fromColorWell setColor:fromColor];
  [self.mainWinGradyView setEndColor:toColor];
  [toColorWell setColor:toColor];
  [self.mainWinGradyView setAngle:gradyAngle];
  [directionSlider setFloatValue:gradyAngle];
  
  [self setCustViewCntlr:[[CustomerViewCntlr alloc]init]];
  [self.custViewCntlr replaceView:self.contentV makeResizable:TRUE];
}

- (IBAction)fromColorAction:(id)sender 
{
  SMKLogDebug(@"color Well action color: %@", [fromColorWell color] );
  NSColor* newColor = [sender color];
  [self.mainWinGradyView setStartColor: newColor];
  NSData * colorData=[NSArchiver archivedDataWithRootObject:newColor];
  [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:udFromColorKey];
  
    //[[self window] setBackgroundColor:[fromColorWell color]];     
}

- (IBAction)toColorAction:(id)sender 
{
    NSColor* newColor = [sender color];
    [self.mainWinGradyView setEndColor: newColor];
    NSData * colorData=[NSArchiver archivedDataWithRootObject:newColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:udToColorKey];

}
- (IBAction)directionAction:(id)sender 
{
    float angleValue = [sender floatValue];
    [self.mainWinGradyView setAngle: angleValue];
    [[NSUserDefaults standardUserDefaults] setFloat:angleValue forKey:udGradyAngleKey];
}
@end
