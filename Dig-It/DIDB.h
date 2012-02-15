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

@interface DIDB : NSObject

+(NSNumber *)staff_id;
+(NSString *)dateYear:(NSDate *)date;


+(NSString *)sel_c_cid_fn_ln_ph_em;
+(NSString *)sel_cust_details;
+(NSDictionary *)ins_cust:(NSDictionary *)custDetails;
+(BOOL)upd_cust:(NSDictionary *)custDetails;

+(NSString *)sel_cust_upc:(NSString *)cid;
+(NSString *)sel_uvf_detailsWithUpc:(NSString *)upc;
+(NSString *)sel_upcs:(NSString *)upc;

+(NSString *)vActors:(NSString *)vid_id meta:(BOOL)meta;
+(NSString *)vDirectors:(NSString *)vid_id meta:(BOOL)meta;
+(NSString *)vGenres:(NSString *)vid_id meta:(BOOL)meta;
+(NSImage *)vThumb:(NSString *)vid_id artid:(NSString *)art_id meta:(BOOL)meta;

+(NSString *)sel_v_info_title:(NSString *)title 
                          year:(NSString *)year
                         meta:(BOOL)meta;

+(NSString *)sel_vt_info_title:(NSString *)title 
                          year:(NSString *)year;

+(NSString *)sel_vtm_info_title:(NSString *)title 
                           year:(NSString *)year;

+(NSString *)vtActors:(NSString *)vid_id;
+(NSString *)vtDirectors:(NSString *)vid_id;
+(NSString *)vtGenres:(NSString *)vid_id;
+(NSImage *)vtThumb:(NSString *)vid_id artid:(NSString *)art_id;

+(NSString *)vtmActors:(NSString *)vid_id;
+(NSString *)vtmDirectors:(NSString *)vid_id;
+(NSString *)vtmGenres:(NSString *)vid_id;
+(NSImage *)vtmThumb:(NSString *)vid_id artid:(NSString *)art_id;

+(BOOL)set_cust:(NSString  *)cust_id
            upc:(NSString *)upc
      needToRip:(BOOL)needToRip;

+(BOOL)set_upc:(NSString *)upc
         title:(NSString *)title
          year:(NSString *)year
       metaSrc:(NSString *)metaSrc
        metaId:(NSString *)metaId;


@end
