/**
  File:		MainWinGradyView.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
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
#import "ReplacementViewCntlr.h"

@interface GradyView : ReplacementView
@property (strong) NSGradient*	myGradient;
@property (strong) NSColor*	myStartColor;
@property (strong) NSColor*	myEndColor;
    
  /*
   this flag indicates that start or end colors were changed, which means
   we need to re-create the NSGradient
   */
@property (assign) BOOL	        forceColorChange;	
// the angle used when drawing a gradient
@property (assign) CGFloat	myAngle;
// draw a radial gradient (instead of a linear gradient)
@property (assign) BOOL	        myIsRadial;
// the offset point from center to draw the radial gradient
@property (assign) NSPoint	myOffsetPt;	


- (void)resetGradient;

- (void)setStartColor:(NSColor *)start
             endColor:(NSColor *)end
                angle:(CGFloat)ang;

- (void)setStartColor:(NSColor*)startColor;
- (void)setEndColor:(NSColor*)endColor;

- (void)setAngle:(CGFloat)angle;
- (void)setRadialDraw:(BOOL)isRadial;

@end
