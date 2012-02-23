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

static NSString * udFromColorKey = @"digit-winFromColorKey";
static NSString * udToColorKey = @"digit-winToColorKey";
static NSString * udGradyAngleKey = @"digit-winGradyAngle";


@implementation DigItWinCntlr
@synthesize custViewCntlr;
@synthesize mainWinGradyView;
@synthesize fromColorWell;
@synthesize toColorWell;
@synthesize directionSlider;
@synthesize contentView;

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

    SMKLogDebug(@"good to Go?? win %@ view %@ grady %@", 
                [self window],
                [[contentView superview] class],
                mainWinGradyView);

    // note these vals would be good in user defaults
    NSColor * fromColor = nil;
    NSColor * toColor = nil;
    NSData * colorData = nil;
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
    mainWinGradyView = (MainWinGradyView *)[contentView superview];
    [mainWinGradyView setStartColor:fromColor];
    [fromColorWell setColor:fromColor];
    [mainWinGradyView setEndColor:toColor];
    [toColorWell setColor:toColor];
    [mainWinGradyView setAngle:gradyAngle];
    [directionSlider setFloatValue:gradyAngle];
    
    custViewCntlr = [CustomerViewCntlr showSelfIn:contentView];
}

- (IBAction)fromColorAction:(id)sender 
{
    SMKLogDebug(@"color Well action color: %@", [fromColorWell color] );
    NSColor* newColor = [sender color];
    [mainWinGradyView setStartColor: newColor];
    NSData * colorData=[NSArchiver archivedDataWithRootObject:newColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:udFromColorKey];
    //[[self window] setBackgroundColor:[fromColorWell color]];     
}

- (IBAction)toColorAction:(id)sender 
{
    NSColor* newColor = [sender color];
    [mainWinGradyView setEndColor: newColor];
    NSData * colorData=[NSArchiver archivedDataWithRootObject:newColor];
    [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:udToColorKey];

}
- (IBAction)directionAction:(id)sender 
{
    float angleValue = [sender floatValue];
    [mainWinGradyView setAngle: angleValue];
    [[NSUserDefaults standardUserDefaults] setFloat:angleValue forKey:udGradyAngleKey];
}
@end
