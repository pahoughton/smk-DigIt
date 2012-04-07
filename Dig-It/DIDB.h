/**
  File:		DIDB.h
  Project:	Dig-It
  Desc:

    
  
  Notes:
    
  Author(s):    Paul Houghton  <Paul.Houghton@SecureMediaKeepers.com>
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
+(NSString *)abpCustEmailPropName;
+(NSString *)abpCustEmailIdentPropName;

+(NSNumber *)staff_id;
+(NSString *)dateYear:(NSDate *)date;

+(NSString *)sel_cid_email;

+(NSString *)sel_c_cid_fn_ln_ph_em;
+(NSString *)sel_cust_details;
+(NSDictionary *)ins_cust:(NSDictionary *)custDetails;
+(BOOL)upd_cust:(NSDictionary *)custDetails;
+(BOOL)upd_cust:(NSNumber *)cust_id email:(NSString *)email;
+(BOOL)add_cust_note:(NSNumber *)cust_id note:(NSString *)note;

+(NSString *)sel_cust_upc:(NSNumber *)cid;
+(NSString *)sel_upc_detailsWithUpc:(NSString *)upc;
+(NSString *)sel_upcs:(NSString *)upc;


+(NSString *)sel_vid_meta_sel_details:(NSString *)title year:(NSString *)year;
+(NSString *)sel_aud_meta_sel_details:(NSString *)upc
                                title:(NSString *)title 
                                 year:(NSString *)year
                              getMore:(BOOL)more;

+(NSNumber *)set_cust:(NSNumber *)cust_id
                  upc:(NSString *)upc
            mediaType:(NSString *)mediaType
             isNewUpc:(BOOL)upcIsNew
            needToRip:(BOOL)needToRip;

+(NSNumber *)set_rip_media_meta:(NSString *)upc
                          title:(NSString *)title
                           year:(NSString *)year
                      mediaType:(NSString *)type
                        metaSrc:(SMKDigitDS)metaSrc
                         metaId:(NSString *)metaId;

+(BOOL)set_meta_sel_art:(NSNumber *)selId
              artSource:(SMKDigitDS)artSrc
                  artId:(NSString *)artId;

+(NSString *)sel_v_title_yearMeta:(BOOL)meta;
+(NSString *)sel_v_art_thumb_detailsMeta:(BOOL)meta;
+(NSString *)sel_v_art_mid_detailsMeta:(BOOL)meta;
// here
+(NSString *)sel_images_art_v_id:(NSString *)vid_id meta:(BOOL)isMeta;

+(NSString *)sel_vm_title_year;
+(NSString *)sel_vm_art_thumb_details;
+(NSString *)sel_vm_art_mid_details;

+(NSString *)sel_vt_title_year;
+(NSString *)sel_vt_art_thumb_details;
+(NSString *)sel_vt_art_mid_details;


@end
