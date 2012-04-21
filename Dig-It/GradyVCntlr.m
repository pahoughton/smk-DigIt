//
//  GradyVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120417.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "GradyVCntlr.h"
#import "SMKLogger.h"

static NSString * udkFromColorKey  = @"smk.grady.from.color";
static NSString * udkToColorKey    = @"smk.grady.to.color";
static NSString * udkGradyAngleKey = @"smk.grady.angle";


@interface GradyVCntlr ()

@end

NSColor * UDColor( NSString * udk, NSColor * dfltColor );

NSColor * UDColor( NSString * udk, NSColor * dfltColor )
{
  NSColor * udColor = nil;
  
  NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
  NSData * udData;
  udData = [ud dataForKey:udk];
  if( udData ) {
    udColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData: udData];
  } else {
    udColor = dfltColor;
  }
  return udColor;
}

@implementation GradyVCntlr
@synthesize gradyV            = _gradyV;
@synthesize gradyFromCW       = _gradyFromCW;
@synthesize gradyToCW         = _gradyToCW;
@synthesize gradyDirSlider    = _gradyDirSlider;
@synthesize fontCW            = _fontCW;
@synthesize gradyStatusTF     = _gradyStatusTF;
@synthesize progPI            = _progPI;
@synthesize contentV          = _contentV;
@synthesize custVC            = _custVC;
//@synthesize tvc               = _tvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  SMKLogFunct;
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

-(id)init
{
  SMKLogFunct;
//  self = [super init];
  self = [[super init] initWithNibName:@"GradyView" 
                        bundle:[NSBundle bundleForClass:[GradyVCntlr class]]];
  if( self ) {
  }
  return self;
}

-(id)initWithViewToReplace:(NSView *)vtr
{
  self = [self init];
  if( self ) {
    SMKLogDebug(@"%s vtr %@(%@) v %@(%@) cv %@(%@)",__func__
                ,vtr, vtr.identifier
                ,self.view, self.view.identifier
                ,self.contentV, self.contentV.identifier );
    [self replaceView:vtr makeResizable:TRUE];
  }
  return self;
}
-(void)awakeFromNib
{
  SMKLogFunct;   
  [self setCustVC:[[CustomerViewCntlr alloc]init ]];
  [self.custVC replaceView:self.contentV makeResizable:TRUE];
  //[self setTvc:[[TestVCntlr alloc]initCustUpc]];
  //[self.tvc replaceView:self.contentV makeResizable:TRUE];

  SMKSetProgInd( self.progPI );
  SMKSetStatusField( self.gradyStatusTF );
  NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
  [self.gradyFromCW setColor: UDColor(udkFromColorKey
                                      ,[NSColor lightGrayColor] )];
  [self.gradyToCW   setColor: UDColor(udkToColorKey
                                      ,[NSColor darkGrayColor] )];
  [self.gradyDirSlider setFloatValue: [ud floatForKey:udkGradyAngleKey]];
  [self.gradyV setStartColor:self.gradyFromCW.color
                    endColor:self.gradyToCW.color
                       angle:self.gradyDirSlider.floatValue];
}

- (IBAction)fromColorAction:(NSColorWell *)sender 
{
  [[NSUserDefaults standardUserDefaults]
   setObject: [NSArchiver archivedDataWithRootObject:sender.color]
   forKey: udkFromColorKey];
  [self.gradyV setStartColor: sender.color];
}

- (IBAction)toColorAction:(NSColorWell *)sender 
{
  [[NSUserDefaults standardUserDefaults]
   setObject: [NSArchiver archivedDataWithRootObject:sender.color]
   forKey: udkToColorKey];
  [self.gradyV setEndColor: sender.color];
}

- (IBAction)gradyDirAction:(NSSlider *)sender 
{
  [[NSUserDefaults standardUserDefaults]
   setFloat:sender.floatValue forKey:udkGradyAngleKey];
  [self.gradyV setAngle: sender.floatValue];
}

- (IBAction)fontColorAction:(NSColorWell *)sender 
{
}
@end
