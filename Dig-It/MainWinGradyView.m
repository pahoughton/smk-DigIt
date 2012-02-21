/**
  File:		MainWinGradyView.m
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
#import "MainWinGradyView.h"
#import <SMKLogger.h>

@implementation MainWinGradyView

- (id)init
{
    self = [super init];
    if( self ) {
        myOffsetPt = NSMakePoint(0.0, 0.0);	// initialize the radial relative center position
    }
    SMKLogDebug(@"grady view init %@", self);
    
    return self;
}

// -------------------------------------------------------------------------------
//	resetGradient:
//
//	Remove the current NSGradient and set one up again with the current start
//	and end colors.
// -------------------------------------------------------------------------------
- (void)resetGradient
{
    if (forceColorChange && myGradient != nil)
    {
        myGradient = nil;
    }
    
    if (myGradient == nil)
    {
        myGradient = [[NSGradient alloc] initWithStartingColor:myStartColor endingColor:myEndColor];
        forceColorChange = NO;
    }
}

// -------------------------------------------------------------------------------
//	setStartColor:startColor
//
//	This method is called when the user changes the start color swatch,
//	which requires that the NSGradient be re-created.
// -------------------------------------------------------------------------------
- (void)setStartColor:(NSColor*)startColor
{
    myStartColor = startColor;
    forceColorChange = YES;
    [self setNeedsDisplay:YES];	// make sure we update the change
}

// -------------------------------------------------------------------------------
//	setEndColor:endColor
//
//	This method is called when the user changes the end color swatch,
//	which requires that the NSGradient be re-created.
// -------------------------------------------------------------------------------
- (void)setEndColor:(NSColor*)endColor
{
    myEndColor = endColor;
    forceColorChange = YES;
    [self setNeedsDisplay:YES];	// make sure we update the change
}

// -------------------------------------------------------------------------------
//	setAngle:angle
//
//	This method is called when the user changes the angle indicator,
//	which requires a re-display or update on this view.
// -------------------------------------------------------------------------------
- (void)setAngle:(CGFloat)angle
{
    myAngle = angle;
    [self setNeedsDisplay:YES];	// make sure we update the change
}

// -------------------------------------------------------------------------------
//	setRadialDraw:isRadial
//
//	This method is called when the user changes the radial flag (checkbox state),
//	which requires a re-display or update on this view.
// -------------------------------------------------------------------------------
- (void)setRadialDraw:(BOOL)isRadial
{
    myIsRadial = isRadial;
    [self setNeedsDisplay:YES];	// make sure we update the change
}

// -------------------------------------------------------------------------------
//	getRelativeCenterPositionFromEvent:theEvent
//
//	Computes the offset point for the radial NSGradient based on the mouse position.
// -------------------------------------------------------------------------------
- (NSPoint)getRelativeCenterPositionFromEvent:(NSEvent*)theEvent
{
    NSPoint curMousePt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint pt = NSMakePoint( (curMousePt.x - NSMidX([self bounds])) / ([self bounds].size.width / 2.0),
                             (curMousePt.y - NSMidY([self bounds])) / ([self bounds].size.height / 2.0));
    return pt;
}

// -------------------------------------------------------------------------------
//	mouseDown:theEvent
//
//	If the user mouseDowns in this view and we are drawing a radial NSGradient,
//	update the view's gradient with the current mouse position as the offset.
// -------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent*)theEvent
{
    if (myIsRadial)
    {
        myOffsetPt = [self getRelativeCenterPositionFromEvent: theEvent];
        [self setNeedsDisplay:YES];	// make sure we update the change
    }
}

// -------------------------------------------------------------------------------
//	mouseDragged:theEvent
//
//	If the user drags the mouse inside this view and we are drawing a radial NSGradient,
//	update the view's gradient with the current mouse position as the offset.
// -------------------------------------------------------------------------------
- (void)mouseDragged:(NSEvent*)theEvent
{
    if (myIsRadial)
    {
        myOffsetPt = [self getRelativeCenterPositionFromEvent: theEvent];
        [self setNeedsDisplay:YES];	// make sure we update the change
    }
}

// -------------------------------------------------------------------------------
//	drawRect:rect
// -------------------------------------------------------------------------------
- (void)drawRect:(NSRect)rect
{
    [self resetGradient];
    
    // if the "Radial Gradient" checkbox is turned on, draw using 'myOffsetPt'
    if (myIsRadial)
    {
        [myGradient drawInRect:[self bounds] relativeCenterPosition:myOffsetPt];
    }
    else
    {
        [myGradient drawInRect:[self bounds] angle:myAngle];
    }
}


@end
