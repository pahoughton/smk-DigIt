/**
  File:		AppUserValuess.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  1:15 PM
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
#import <SMKDB.h>
// UDK - i.e. user default key
extern NSString * AppUDKdbServer;
extern NSString * AppUDKdbHost;
extern NSString * AppUDKdbPort;
extern NSString * AppUDKdbDatabase;
extern NSString * AppUDKdbUser;
extern NSString * AppUDKdbPassItem;

@interface AppUserValues : NSObject <SMKDBConnInfo>
@property (assign) NSUserDefaults * ud;

-(enum SMKDB_TYPE)dbType;

-(NSString *)dbHost;
-(unsigned int)dbPort;
-(NSString *)dbUser;
-(NSString *)dbPass;
-(NSString *)dbDatabase;
-(NSString *)dbApp;

+(NSString *)dbUser;

+(void)setDbPass:(NSString *)pass;

-(BOOL)recProcOnMainTread;

-(NSString *)description;

@end
