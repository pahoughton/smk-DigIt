/**
  File:		AppUserValuess.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
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
#import "AppUserValues.h"
#import <SMKLogin.h>

// these much match the values in the PrefsWin.xib
//   (UDK = User Defaults Key)
NSString * AppUDKdbServer   = @"digitDBserver";
NSString * AppUDKdbHost     = @"digitDBhost";
NSString * AppUDKdbPort     = @"digitDBport";
NSString * AppUDKdbDatabase = @"digitDBdatabase";
NSString * AppUDKdbUser     = @"digitDBuser";
NSString * AppUDKdbPassItem = @"DititzeDB";
// Note password is either not stored or kept in keychain

// we don't want to keep fetching this from the key chain
static NSString * dbPassCache = nil;

@implementation AppUserValues
@synthesize ud;

-(id) init
{
    self = [super init];
    if( self ) {
        ud = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(enum SMKDB_TYPE)dbType
{
    NSString * svr = [ud stringForKey:AppUDKdbServer];
    
    if( [svr isEqualToString:@"Postgres"] ) {
        return DB_Postgess;
    } else if( [svr isEqualToString:@"MySql"] ) {
        return DB_MySql;
    } else if( [svr isEqualToString:@"SqlLite"] ) {
        return DB_SqlLite;
    } else {
        return DB_Postgess;
    }
}

-(NSString *)dbHost
{
    return [ud stringForKey:AppUDKdbHost];
}

-(unsigned int)dbPort
{
    NSString * val = [ud stringForKey:AppUDKdbHost];
    return (unsigned int)[val integerValue];
}


-(NSString *)dbUser
{
    return [ud stringForKey:AppUDKdbUser];
}

-(NSString *)dbPass
{
    if( dbPassCache == nil ) {
        dbPassCache = [SMKLogin getPassForItem:AppUDKdbPassItem user:[self dbUser]];
    }
    return dbPassCache;
}
-(NSString *)dbDatabase
{
    return [ud stringForKey:AppUDKdbDatabase];
}

-(NSString *)dbApp
{
    return @"Dig-It";
}

+(NSString *)dbUser
{
    return [[NSUserDefaults standardUserDefaults] 
            stringForKey:AppUDKdbUser];
}

+(void)setDbPass:(NSString *)pass
{
    if( [SMKLogin setUserPassForItem:AppUDKdbPassItem
                                user:[AppUserValues dbUser]
                                pass:pass] ) {
        dbPassCache = pass;
    }
}

-(BOOL)recProcOnMainTread
{
    return  TRUE;
}

-(NSString *)description
{
    NSString * desc = [NSString stringWithFormat:
                       @"%@ Values\n"
                       "   %@: %@\n"
                       "   %@: %@\n"
                       "   %@: %@\n"
                       "   %@: %@\n"
                       "   %@: %@\n"
                       "   %@: %@\n",
                       [self className],
                       @"    DB Type",[ud stringForKey:AppUDKdbServer],
                       @"    DB Host",[self dbHost],
                       @"    DB Port",[ud stringForKey:AppUDKdbPort],
                       @"DB Database",[self dbDatabase],
                       @"    DB User",[self dbUser],
                       @"     DB App",[self dbApp] ];
    return desc;
}

@end
