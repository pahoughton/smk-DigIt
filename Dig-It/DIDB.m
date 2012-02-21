/**
  File:		DIDB.m
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/8/12  3:22 PM
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
#import "DIDB.h"
#import <SMKDBConnMgr.h>
#import <SMKAlertWin.h>

static NSInteger int_staff_id = -999;
static NSNumber * staff_id = nil;
static NSDateFormatter * yearFmt = nil;
static NSMutableArray * customersCols = nil;

@implementation DIDB
+(NSString *)abpCustIdPropName
{
    return @"com.SecureMediaKeepers.cust_id";
}

+(NSString *)dateYear:(NSDate *)date
{
    if( yearFmt == nil ) {
        yearFmt = [[NSDateFormatter alloc] init];
        [yearFmt setDateFormat:@"yyyy"];
    }
    return [yearFmt stringFromDate:date];
}
+(NSNumber *)staff_id
{
    if( staff_id == nil ) {
        id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
        id <SMKDBResults> rslt;
        rslt = [db query:@"select user_staff_id()"];
        NSNumber * num = [[rslt fetchRowArray] objectAtIndex:0];
        staff_id = [[NSNumber alloc] initWithInteger:[num integerValue]];
        int_staff_id = [num integerValue];
        SMKLogDebug(@"staff id: %@ %d", staff_id, int_staff_id);
    }
    return staff_id;
}
+(NSArray * )getCustomersCols
{
    if( customersCols == nil ) {
        NSLock * myLock = [[NSLock alloc] init];
        [myLock setName:@"customerCols"];
        [myLock lock];
        @try {
            id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
            id <SMKDBResults> rslt;
            rslt = [db query:@"select column_name\n"
                    "from information_schema.columns\n"
                    "where table_name = 'customers'"];
            customersCols = [[NSMutableArray alloc] initWithCapacity:24];
            NSMutableArray * rec;
            while( (rec = [rslt fetchRowArray]) ) {
                NSString * fld = [rec objectAtIndex:0];
                if( ! [fld isEqualToString:@"login_failures"]
                   && ! [fld isEqualToString:@"last_login_fail"]
                   && ! [fld isEqualToString:@"date_added"]
                   && ! [fld isEqualToString:@"last_modified"] ) {
                    [customersCols addObject:fld];
                }
            }
        }
        @catch (NSException *exception) {
            [SMKAlertWin alertWithMsg:[exception description]];
        }
        @finally {
            [myLock unlock];
        }
    }
    return customersCols;
}
+(NSString *)sel_c_cid_fn_ln_ph_em
{
    return( @"SELECT cust_id, first_name, last_name, phone, email "
           "FROM c_cid_fn_ln_ph_em order by last_modified desc" );
}

+(NSString *)sel_cust_details
{
    (void)[DIDB getCustomersCols];
    return @"SELECT  first_name||' '||last_name as full_name, * \n"
    "from customers order by last_modified desc";
}

+(NSDictionary *)ins_cust:(NSDictionary *)custDetails
{
    SMKLogDebug(@"ins cust: %@",custDetails);
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt;

    NSMutableArray * cols = [[NSMutableArray alloc]initWithCapacity:[customersCols count]];
    NSMutableArray * vals = [[NSMutableArray alloc]initWithCapacity:[customersCols count]];
    
    for( NSString * key in customersCols ) {
        if( [key isEqualToString:@"cust_id"] ) {
            continue;
        } else { 
            id val = [custDetails valueForKey:key];
            if( val != nil && ! [val isKindOfClass:[NSNull class]] ) {
                [cols addObject:key];
                [vals addObject:[db q:val]];
            }
        }
    }
    NSString * sql = [NSString stringWithFormat:
                      @"insert into customers (%@) values (%@)",
                      [cols componentsJoinedByString:@", "],
                      [vals componentsJoinedByString:@", "]];
    if( [db queryBool:sql] ) {
        NSString * cust_id;
        rslt = [db query:@"select currval( 'customers_cust_id_seq' )"];
        cust_id = [[rslt fetchRowArray] objectAtIndex:0];
        rslt = [db queryFormat:
                @"SELECT  first_name||' '||last_name as full_name, *\n"
                "FROM customers\n"
                "WHERE cust_id = %@",cust_id];
        NSDictionary * newRec = [rslt fetchRowDict];        
        // [db commit];
        return newRec;
    }
    return  nil;
}
+(BOOL)upd_cust:(NSDictionary *)custDetails
{
    SMKLogDebug(@"upd cust: %@",custDetails);
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    
    NSString * custId;
    NSMutableArray * flds = [[NSMutableArray alloc]initWithCapacity:[customersCols count]];
    for( NSString * key in customersCols ) {
        if ( [key isEqualToString:@"cust_id"] ) {
            custId = [custDetails valueForKey:key];
        } else { 
            id val = [custDetails valueForKey:key];
            if( val != nil && ! [val isKindOfClass:[NSNull class]] ) {
                [flds addObject:[NSString stringWithFormat:
                                 @"%@ = %@",
                                 key,[db q:[custDetails valueForKey:key]]]];
            }
        }
    }
    if( [db queryBoolFormat:
         @"update customers set %@ where cust_id = %@",
         [flds componentsJoinedByString:@", "],
         custId] ) {
        // [db commit];
        return TRUE;
    }
    return FALSE;
}

+(BOOL)upd_cust:(NSString *)cust_id email:(NSString *)email
{
    SMKLogDebug(@"upd cust: %@ email: %@",cust_id, email);
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    
    NSString * custId;
    if( [db queryBoolFormat:
         @"update customers set email = %@ where cust_id = %@",
         [db q:email], custId] ) {
        // [db commit];
        return TRUE;
    }
    return FALSE;
}
+(NSString *)sel_cust_upc:(NSString *)cid
{
    return [NSString stringWithFormat:
            @"SELECT upc, date_added "
            "from cust_upcs where cust_id = %@",cid];
}

+(NSString *)sel_uvf_detailsWithUpc:(NSString *)upc
{
    return [NSString stringWithFormat:
            @"select * from uvf_details where upc = %@",upc];
    
}
+(NSString *)sel_upcs:(NSString *)upc
{
    return [NSString stringWithFormat:
            @"select * from upcs where upc = %@",upc];
}

+(NSString *)sel_v_title_yearMeta:(BOOL)meta
{
    const char * metaStr = "_";
    if( meta ) {
        metaStr = "_meta_";
    }
    return [NSString stringWithFormat:
            @"select vid%sid as vid_id,\n"
            "title||' ('||extract('year' FROM release_date)||')' as title_year,\n"
            "art_thumb_id\n"
            "from video%stitles",
            metaStr,
            metaStr];
}
+(NSString *)sel_vm_title_year
{
    return [DIDB sel_v_title_yearMeta:TRUE];
}
+(NSString *)sel_vt_title_year
{
    return [DIDB sel_v_title_yearMeta:FALSE];
}


+(NSString *)sel_v_art_thumb_detailsMeta:(BOOL)meta
{
    const char * metaStr = "_";
    if( meta ) {
        metaStr = "_meta_";
    }
    
    return [NSString stringWithFormat:
            @"select vid%sid, art%sid, tmdb_id, art\n"
            "from video%sart\n"
            "where size_desc = 'w154'",
            metaStr,
            metaStr,
            metaStr];
}

+(NSString *)sel_vm_art_thumb_details
{
    return [DIDB sel_v_art_thumb_detailsMeta:TRUE];
}
+(NSString *)sel_vt_art_thumb_details
{
    return [DIDB sel_v_art_thumb_detailsMeta:FALSE];
}

+(NSString *)sel_v_art_mid_detailsMeta:(BOOL)meta
{
    const char * metaStr = "_";
    if( meta ) {
        metaStr = "_meta_";
    }
    
    return [NSString stringWithFormat:
            @"select vid%id, art%sid, tmdb_id, filepath, size_x, size_y\n"
            "from video%sart\n"
            "where size_desc = 'mid'",
            metaStr,
            metaStr,
            metaStr];
}
+(NSString *)sel_vm_art_mid_details
{
    return [DIDB sel_v_art_mid_detailsMeta:TRUE];
}
+(NSString *)sel_vt_art_mid_details
{
    return [DIDB sel_v_art_mid_detailsMeta:FALSE];
}

+(BOOL)setVidTitleArt:(NSNumber *)vidId 
                thumb:(NSNumber *)thumbId
                 main:(NSNumber *)mainId
               isMeta:(BOOL)meta
{
    const char * metaStr = "_";
    if( meta ) {
        metaStr = "_meta_";
    }
    
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [db queryBoolFormat:
            @"update video%stitles\n"
            "set art_thumb_id = %@, art_id = %@\n"
            "where vid_meta_id = %@",
            metaStr,
            thumbId,
            mainId,
            vidId];
}

+(NSString *)sel_v_info_title:(NSString *)title year:(NSString *)year meta:(BOOL)meta
{
    // ignoring year for now
    /*
      0 vid_id, 
      1 title,
      2 kind,
      3 mpaa_rating,
      4 release_date,
      5 desc_short,
      6 desc_long,
      7 run_time,
      8 imdb_id,
      9 tmdb_id,
     10 chimp_id,
     11 netflix_id,
     12 amazon_asin,
     13 tmdb_rating,
     14 imdb_rating,
     15 budget,
     16 revenue,
     17 art_id,
     18 art_thumb_id,
     19 locked,
     20 tv_season,
     21 tv_episode,
     22 tv_network,
     23 tv_series,
     24 date_added,
     25 last_modified,
     */
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    NSString * metaStr = @"";
    if( meta ) {
        metaStr = @"meta_";
    }
    return [NSString stringWithFormat:
            @"SELECT vid_%@id, title, kind, mpaa_rating, release_date,\n"
            "desc_short, desc_long, run_time, imdb_id,\n"
            "tmdb_id, chimp_id, netflix_id, amazon_asin,\n"
            "tmdb_rating, imdb_rating, budget,revenue,\n"
            "art_id, art_thumb_id, locked, tv_season,\n"
            "tv_episode, tv_network, tv_series,\n"
            "date_added, last_modified\n"
            "FROM video_%@titles\n"
            "WHERE title like %@\n",
            metaStr,
            metaStr,
            [db q:title]];
}
+(NSString *)sel_vt_info_title:(NSString *)title year:(NSString *)year
{
    return [DIDB sel_v_info_title:title year:year meta:FALSE];
}
+(NSString *)sel_vtm_info_title:(NSString *)title year:(NSString *)year
{
    return [DIDB sel_v_info_title:title year:year meta:TRUE];
}

+(NSString *)vActors:(NSString *)vid_id meta:(BOOL)meta
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt;
    NSString * query;
    
    if( meta ) {
        query = 
        @"select name from vm_pl_rl "
        "where vid_meta_id = %@ and vid_role = 'actor' "
        "order by role_order limit 3";
    } else {
        query = 
        @"select name from v_pl_rl "
        "where vid_id = %@ and vid_role = 'actor' "
        "order by role_order limit 3";        
    }
    rslt = [db queryFormat:query, vid_id];
    
    NSMutableArray * actorList = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray * rec;
    while( (rec = [rslt fetchRowArray]) ) {
        [actorList addObject:[rec objectAtIndex:0]];
    }
    return [actorList componentsJoinedByString:@", "];
}
+(NSString *)vtActors:(NSString *)vid_id
{
    return [DIDB vActors:vid_id meta:FALSE];
}
+(NSString *)vtmActors:(NSString *)vid_id
{
    return [DIDB vActors:vid_id meta:TRUE];
}


+(NSString *)vDirectors:(NSString *)vid_id meta:(BOOL)meta
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt;
    NSString * query;
    
    if( meta ) {
        query = 
        @"select name from vm_pl_rl "
        "where vid_meta_id = %@ and vid_role = 'director' "
        "order by role_order limit 3";
    } else {
        query = 
        @"select name from v_pl_rl "
        "where vid_id = %@ and vid_role = 'director' "
        "order by role_order limit 3";        
    }
    rslt = [db queryFormat:query, vid_id];
    
    NSMutableArray * actorList = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray * rec;
    while( (rec = [rslt fetchRowArray]) ) {
        [actorList addObject:[rec objectAtIndex:0]];
    }
    return [actorList componentsJoinedByString:@", "];
}
+(NSString *)vtDirectors:(NSString *)vid_id
{
    return[ DIDB vDirectors:vid_id meta:FALSE];
}
+(NSString *)vtmDirectors:(NSString *)vid_id
{
    return[ DIDB vDirectors:vid_id meta:TRUE];
}


+(NSString *)vGenres:(NSString *)vid_id meta:(BOOL)meta;
{
    
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt;
    NSString * query;
    if( meta ) {
        query = 
        @"select genre from video_meta_genres "
        "where vid_meta_id = %@ "
        "order by genre_order limit 3";
    } else {
        query = 
        @"select genre from video_genres "
        "where vid_id = %@ "
        "order by genre_order limit 3";
    }
    rslt = [db queryFormat:query,
            vid_id];
    NSMutableArray * genreList = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray * rec;
    while( (rec = [rslt fetchRowArray]) ) {
        [genreList addObject:[rec objectAtIndex:0]];
    }
    return [genreList componentsJoinedByString:@", "];
}
+(NSString *)vtGenres:(NSString *)vid_id
{
    return [DIDB vGenres:vid_id meta:FALSE];
}
+(NSString *)vtmGenres:(NSString *)vid_id
{
    return [DIDB vGenres:vid_id meta:TRUE];
}

+(NSImage *)vThumb:(NSNumber *)vid_id artid:(NSString *)art_id meta:(BOOL)meta
{
    NSString * query;

    if( meta ) {
        if( art_id != nil && ! [art_id isKindOfClass:[NSNull class]]  ) {
            query = [NSString stringWithFormat:
                     @"select art from video_meta_art where art_meta_id = %@",art_id];
        } else {
            query = [NSString stringWithFormat:
                     @"select art from video_meta_art "
                     "where vid_meta_id = %@ "
                     "and art is not null "
                     "and size_x < 200",
                     vid_id];
        }
     
    } else {
        if( art_id != nil && ! [art_id isKindOfClass:[NSNull class]]  ) {
            query = [NSString stringWithFormat:
                     @"select art from video_art where art_id = %@",art_id];
        } else {
            query = [NSString stringWithFormat:
                     @"select art from video_art "
                     "where vid_id = %@ "
                     "and art is not null "
                     "and size_x < 200",
                     vid_id];
        }
    }
    
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt;
    rslt = [db query:query];
    NSArray * rec = [rslt fetchRowArray];
    if( rec != nil && [rec objectAtIndex:0] != nil ) {
        NSData * imgData = [rec objectAtIndex:0];
        SMKLogDebug(@"obj class %@", [imgData className]);
        if( [imgData length] > 0 ) {
            return [[NSImage alloc] initWithData:imgData];
        } 
    }
    
    return nil;
}

+(NSImage *)vtThumb:(NSString *)vid_id artid:(NSString *)art_id
{
    return [DIDB vThumb:vid_id artid:art_id meta:FALSE];
}
+(NSImage *)vtmThumb:(NSString *)vid_id artid:(NSString *)art_id
{
    return [DIDB vThumb:vid_id artid:art_id meta:TRUE];
}


+(BOOL)set_cust:(NSNumber *)cust_id upc:(NSString *)upc needToRip:(BOOL)needToRip
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [db queryBoolFormat:
            @"select add_cust_upc( %@, %@, %@ )",
            cust_id, 
            upc,
            needToRip];           
}

+(BOOL)set_upc:(NSString *)upc 
         title:(NSString *)title 
          year:(NSString *)year 
       metaSrc:(NSString *)metaSrc 
        metaId:(NSString *)metaId
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [db queryBoolFormat:
            @"insert into video_meta_selection\n"
            "(search_upc, search_title, search_year,\n"
            " sel_source, sel_source_id, sel_staff_id )\n"
            "values ( %@, %@, %@, %@, %@, %@ ) ",
            upc, 
            [db q:title],
            year,
            [db q:metaSrc],
            [db q:metaId],
            [DIDB staff_id]];
}
@end
