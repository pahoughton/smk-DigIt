/**
  File:		DIDB.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  ___EMAIL___ <Paul.Houghton@SecureMediaKeepers.com>
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
#import <Foundation/Foundation.h>
#import <SMKDigitDB.h>

@interface DIDB : SMKDigitDB

+(NSString *)abpCustIdPropName;

+(NSNumber *)staff_id;
+(NSString *)dateYear:(NSDate *)date;


+(NSString *)sel_c_cid_fn_ln_ph_em;
+(NSString *)sel_cust_details;
+(NSDictionary *)ins_cust:(NSDictionary *)custDetails;
+(BOOL)upd_cust:(NSDictionary *)custDetails;
+(BOOL)upd_cust:(NSString *)cust_id email:(NSString *)email;

+(NSString *)sel_cust_upc:(NSString *)cid;
+(NSString *)sel_uvf_detailsWithUpc:(NSString *)upc;
+(NSString *)sel_upcs:(NSString *)upc;

+(NSString *)vActors:(NSNumber *)vid_id meta:(BOOL)meta;
+(NSString *)vDirectors:(NSNumber *)vid_id meta:(BOOL)meta;
+(NSString *)vGenres:(NSNumber *)vid_id meta:(BOOL)meta;
+(NSImage *)vThumb:(NSNumber *)vid_id artid:(NSNumber *)art_id meta:(BOOL)meta;

+(NSString *)sel_v_info_title:(NSString *)title 
                          year:(NSString *)year
                         meta:(BOOL)meta;

+(NSString *)sel_vt_info_title:(NSString *)title 
                          year:(NSString *)year;

+(NSString *)sel_vtm_info_title:(NSString *)title 
                           year:(NSString *)year;

+(NSString *)vtActors:(NSNumber *)vid_id;
+(NSString *)vtDirectors:(NSNumber *)vid_id;
+(NSString *)vtGenres:(NSNumber *)vid_id;
+(NSImage *)vtThumb:(NSNumber *)vid_id artid:(NSNumber *)art_id;

+(NSString *)vtmActors:(NSNumber *)vid_id;
+(NSString *)vtmDirectors:(NSNumber *)vid_id;
+(NSString *)vtmGenres:(NSNumber *)vid_id;
+(NSImage *)vtmThumb:(NSNumber *)vid_id artid:(NSString *)art_id;

+(BOOL)set_cust:(NSNumber *)cust_id
            upc:(NSString *)upc
      needToRip:(BOOL)needToRip;

+(BOOL)set_upc:(NSString *)upc
         title:(NSString *)title
          year:(NSString *)year
       metaSrc:(NSString *)metaSrc
        metaId:(NSString *)metaId;

+(NSString *)sel_v_title_yearMeta:(BOOL)meta;
+(NSString *)sel_v_art_thumb_detailsMeta:(BOOL)meta;
+(NSString *)sel_v_art_mid_detailsMeta:(BOOL)meta;

+(NSString *)sel_vm_title_year;
+(NSString *)sel_vm_art_thumb_details;
+(NSString *)sel_vm_art_mid_details;

+(NSString *)sel_vt_title_year;
+(NSString *)sel_vt_art_thumb_details;
+(NSString *)sel_vt_art_mid_details;


@end
