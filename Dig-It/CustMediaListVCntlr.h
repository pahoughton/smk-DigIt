//
//  CustMediaListVCntlr.h
//  Dig-It
//
//  Created by Paul Houghton on 120408.
//  Copyright (c) 2012 Secure Media Keepers. All rights reserved.
//

#import "SMKCocoaDigitizeUI/MetaListViewCntlr.h"

@interface CustMediaListVCntlr : MetaListViewCntlr
@property (strong) NSNumber * custId;

+(CustMediaListVCntlr *)createAndReplaceView:(NSView *)viewToReplace custId:(NSNumber *)cust;

-(CustMediaListVCntlr *)replaceView:(NSView *)viewToReplace custId:(NSNumber *)cust;

@end
