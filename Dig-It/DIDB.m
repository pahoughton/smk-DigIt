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

+(NSString *)abpCustEmailPropName
{
    return @"com.SecureMediaKeepers.cust_email";
}
+(NSString *)abpCustEmailIdentPropName
{
    return @"com.SecureMediaKeepers.cust_email_ident";
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

+(NSString *)sel_cid_email
{
    return @"SELECT cust_id, lower(email) from customers";
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
    
    for( NSString * key in [DIDB getCustomersCols] ) {
        if( [key isEqualToString:@"cust_id"] ) {
            continue;
        } else { 
            id val = [custDetails valueForKey:key];
            if( ! SMKisNULL(val) ) {
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

+(BOOL)upd_cust:(NSNumber *)cust_id email:(NSString *)email
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
+(BOOL)add_cust_note:(NSNumber *)cust_id note:(NSString *)note
{
    SMKLogDebug(@"add cust note: %@ note: %@",cust_id, note);
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    
    if( [db queryBoolFormat:
         @"insert into cust_notes (cust_id, note) values (%@, %@)",
         cust_id, [db q:note]] ) {
        // [db commit];
        return TRUE;
    }
    return FALSE;
    
}
+(NSString *)sel_cust_upc:(NSNumber *)cid
{
    return [NSString stringWithFormat:
            @"SELECT upc, date_added\n"
            "from cust_upcs where cust_id = %@\n"
            "order by date_added desc",
            cid];
}

+(NSString *)sel_upc_detailsWithUpc:(NSString *)upc
{
    return [NSString stringWithFormat:
            @"select * from sel_upc_details_art( %@ )",upc];
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

+(NSString *)sel_images_art_v_id:(NSString *)vid_id meta:(BOOL)isMeta
{
    const char * metaStr = "_";
    const char * mtStr = "t";
    if( isMeta ) {
        metaStr = "_meta_";
        mtStr = "m";
    }
    /*
      0 vid_id
      1 vid_img_id
      2 title
      3 thumb_art
      4 thumb_filepath
      5 thumb_url
      6 thumb_width
      7 thumb_height
      8 mid_art
      9 mid_filepath
     10 mid_url
     11 mid_width
     12 mid_height
     */
    
    return [NSString stringWithFormat:
            @"SELECT vid%sid,\n"
            "vid%simg_id,\n"
            "title,\n"
            "thumb_art,\n"
            "thumb_filepath,\n"
            "thumb_url,\n"
            "thumb_width,\n"
            "thumb_height,\n"
            "mid_art,\n"
            "mid_filepath,\n"
            "mid_url,\n"
            "mid_width,\n"
            "mid_height\n"
            "FROM v_v%s_image_thumb_mid\n"
            "WHERE vid%sid = %@",
            metaStr,
            metaStr,
            mtStr,
            metaStr,
            vid_id];
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

+(NSString *)sel_vid_meta_sel_details:(NSString *)title year:(NSString *)year
{
    // ignoring year for now
    /*
      0 source
      1 source_id
      2 title
      3 rating
      4 description
      5 rel_year
      6 genres
      7 artists
      8 supporters (i.e. director, composer)
      9 thumb
     10 slmr
     */
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [NSString stringWithFormat:
            @"SELECT source,\n"
            "source_id,\n"
            "title,\n"
            "rating,\n"
            "description,\n"
            "rel_year,\n"
            "genres,\n"
            "artists,\n"
            "supporters,\n"
            "thumb,\n"
            "similarity( search_value, %@ ) as smlr\n"
            "FROM v_vid_meta_sel_details\n"
            "WHERE search_value %% %@"
            "ORDER BY smlr DESC",
            [db q:title],
            [db q:title]];
}

+(NSString *)sel_aud_meta_sel_details:(NSString *)upc
                                title:(NSString *)title 
                                 year:(NSString *)year
                              getMore:(BOOL)more
{
    // ignoring year for now
    /*
     0 source
     1 source_id
     2 title
     3 rating
     4 description
     5 rel_year
     6 genres
     7 artists
     8 supporters (i.e. director, composer)
     9 thumb
     10 slmr
     */

    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [NSString stringWithFormat:
            @"SELECT source,\n"
            "source_id,\n"
            "title,\n"
            "rating,\n"
            "description,\n"
            "rel_year,\n"
            "genres,\n"
            "artists,\n"
            "supporters,\n"
            "thumb,\n"
            "smlr\n"
            "FROM sel_aud_meta_sel_details( %@, %@, %s )",
            upc,
            [db q:title],
            (more ? "true" : "false")];
    
    /*
    return [NSString stringWithFormat:
            @"SELECT source,\n"
            "source_id,\n"
            "title,\n"
            "rating,\n"
            "description,\n"
            "rel_year,\n"
            "genres,\n"
            "artists,\n"
            "supporters,\n"
            "thumb,\n"
            "similarity( search_value, %@ ) as smlr\n"
            "FROM v_aud_meta_sel_details\n"
            "WHERE search_value %% %@"
            "ORDER BY smlr DESC LIMIT 25",
            [db q:title],
            [db q:title]];
     */
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
            "WHERE title %% %@\n",
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

+(BOOL)set_cust:(NSNumber *)cust_id 
            upc:(NSString *)upc 
      mediaType:(NSString *)mediaType
       isNewUpc:(BOOL)upcIsNew
      needToRip:(BOOL)needToRip
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    // Postgres Specific value - need somthing for BOOL in SMKDB
    return [db queryBoolFormat:
            @"select add_cust_upc( %@, %@, %@, %s, %s )",
            cust_id, 
            upc,
            [db q:mediaType],
            upcIsNew ? "true" : "false",
            needToRip ? "true" : "false"];           
}

+(NSNumber *)set_media_meta:(NSString *)upc 
                     title:(NSString *)title 
                      year:(NSString *)year 
                   metaSrc:(SMKDigitDS)metaSrc 
                    metaId:(NSString *)metaId
{
    NSString * myYear;
    if( [year length] == 4 ) {
        myYear = year;
    } else {
        myYear = @"NULL";
    }
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    id <SMKDBResults> rslt = 
    [db queryFormat:
     @"select set_media_meta( %@, %@, %@, %@, %@ )",
     upc,
     [db q:title],
     myYear,
     [db q:[DIDB dsTable:metaSrc]],
     [db q:metaId]];
    NSArray * rec = [rslt fetchRowArray];
    NSNumber * selid = [rec objectAtIndex:0];
    return selid;
}

+(BOOL)set_meta_sel_art:(NSNumber *)selId artSource:(SMKDigitDS)artSrc artId:(NSString *)artId
{
    id <SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
    return [db queryBoolFormat:
            @"update media_meta_selection set\n"
            "sel_art_source = %@,\n"
            "sel_art_source_id = %@\n"
            "where meta_sel_id = %@\n",
            [db q:selId],
            [db q:[DIDB dsTable:artSrc]],
            [db q:artId]];
            
}
@end
