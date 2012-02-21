/**
  File:		MainWinGradyView.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/16/12  4:03 AM
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
#import <Foundation/Foundation.h>

@interface MainWinGradyView : NSView
{
    NSGradient*	myGradient;
    
    NSColor*	myStartColor;
    NSColor*	myEndColor;
    
    BOOL		forceColorChange;	// this flag indicates that start or end colors were changed, which means
    // we need to re-create the NSGradient
    
    CGFloat		myAngle;			// the angle used when drawing a gradient
    
    BOOL		myIsRadial;			// draw a radial gradient (instead of a linear gradient)
    NSPoint		myOffsetPt;			// the offset point from center to draw the radial gradient
}

- (void)resetGradient;

- (void)setStartColor:(NSColor*)startColor;
- (void)setEndColor:(NSColor*)endColor;

- (void)setAngle:(CGFloat)angle;
- (void)setRadialDraw:(BOOL)isRadial;

@end
