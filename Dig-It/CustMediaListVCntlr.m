//
//  CustMediaListVCntlr.m
//  Dig-It
//
//  Created by Paul Houghton on 120408.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "CustMediaListVCntlr.h"

@implementation CustMediaListVCntlr
@synthesize custId = _custId;

+(CustMediaListVCntlr *)createAndReplaceView:(NSView *)viewToReplace custId:(NSNumber *)cust
{
  CustMediaListVCntlr * me;
  me = [[CustMediaListVCntlr alloc] initView];
  return [me replaceView:viewToReplace custId:cust];
}

-(void)setCustId:(NSNumber *)cust
{
  [self setCustId:cust];
  if( self.custId != nil ) {
    NSString * sql;
    sql = [NSString stringWithFormat:
           @"SELECT\n"
           "cast( 'media_id_meta' as text ) as data_source\n"
           ",mimm.meta_id\n"
           ",mim.media_type\n"
           ",NULL as media_kind\n"
           ",mim.media_name\n"
           "FROM cust_media cm, media_id_meta mim\n"
           "WHERE cm.cust_id = %@\n"
           "AND   cm.meta_id = mim.meta_id\n",
           self.custId];
    [self.gath gatherWithQuery:sql];
  }  
}

-(CustMediaListVCntlr *)replaceView:(NSView *)viewToReplace custId:(NSNumber *)cust
{
  [self replaceView:viewToReplace makeResizable:TRUE];
  [self setCustId:cust];
  return self;
}

  
@end
