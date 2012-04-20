/**
  File:		CustomerViewCntlr.m
  Project:	Dig-It
  Desc:

  Notes:
    
  Author(s):    Paul Houghton <Paul.Houghton@SecureMediaKeepers.com>
  Created:      2/19/12  12:01 PM
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
#import "CustomerViewCntlr.h"
#import "CustomerDataSrc.h"
#import "CustUpcViewCntlr.h"
#import "CustUpcDataSrc.h"

#import <SMKCocoaCommon.h>
#import <SMKCommon.h>

static CustomerViewCntlr * me;

@implementation CustomerViewCntlr
@synthesize vToRplc     = _vToRplc;
@synthesize dataSrc     = _dataSrc;
@synthesize curCustId;

@synthesize custMediaVC = _custMediaVC;
@synthesize splitView;

@synthesize contactListTV;
@synthesize contactSearch;
@synthesize fullNameTF;
@synthesize orginizationTF;
@synthesize emailTF;
@synthesize mainPhoneTF;
@synthesize altPhoneTF;
@synthesize addrStreetTF;
@synthesize addrCityTF;
@synthesize addrStateTF;
@synthesize zipCodeTF;
@synthesize zipCodeNFmt;
@synthesize custNotesTF;
@synthesize smkCustImage;
@synthesize isSavedLabel;
@synthesize addCustButton;
@synthesize saveCustButton;
@synthesize ordersButton;
@synthesize upcButton;
@synthesize mediaButton;

#pragma mark Initialization
+(CustomerViewCntlr *)showSelfIn:(NSView *)viewToReplace
{
    if( me == nil ) {
        me = [CustomerViewCntlr alloc];
        me = [me initWithNibName:@"CustomerViewX" bundle:nil];
    }
    NSView * curSuper = [viewToReplace superview];
    NSRect viewFrame = [viewToReplace frame];
    
    [viewToReplace removeFromSuperview];
    [curSuper addSubview:[me view]];
    [[me view] setFrame:viewFrame];
    [me setRepresentedObject:
     [NSNumber numberWithUnsignedLong:[[ [me view ] subviews ] count ]]];
    
    return me;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self setDebug:TRUE];
        [self setDataSrc:[[CustomerDataSrc alloc]init]];
        // Initialization code here.
    }
    
    return self;
}
-(id)init
{
  self = [self initWithNibName:@"CustomerView" bundle:nil];
  return self;
}
-(id)initWithViewToReplace:(NSView *)vtr
{
  self = [self init];
  if( self ) {
    SMKLogDebug(@"%s vtr %@(%@) v %@(%@)",__func__
                ,vtr, vtr.identifier
                ,self.view, self.view.identifier);
    for( NSLayoutConstraint * lc in self.view.constraints ) {
      SMKLogDebug(@"pre vlc: %@",lc);
    }
    [self replaceView:vtr makeResizable:TRUE];
  }
  return self;
}
-(void) awakeFromNib
{
  [contactListTV setDataSource: self.dataSrc];
  [smkCustImage setHidden:TRUE];
  [zipCodeNFmt setFormat:@"00000"];
  [self.dataSrc addObserver:self forKeyPath:[CustomerDataSrc kvoTableData] options:0 context:nil];
  if( [self.dataSrc tableData] != nil ) {
    [contactListTV reloadData];
  }
  /*
  for( NSLayoutConstraint * lc in self.view.superview.constraints ) {
    SMKLogDebug(@"Slc: %@",lc);
  }
  for( NSLayoutConstraint * lc in self.view.constraints ) {
    SMKLogDebug(@"vlc: %@",lc);
  }
   */
}
-(void)viewIsInWindow
{
  /*
  SMKLogDebug(@"%s",__func__);
  NSLog(@"VINWIN %s",__func__);
  for( NSLayoutConstraint * lc in self.view.superview.constraints ) {
    SMKLogDebug(@"Slc: %@",lc);
  }
  for( NSLayoutConstraint * lc in self.view.constraints ) {
    SMKLogDebug(@"vlc: %@",lc);
  }
   */
}
-(void) textDidChange:(NSNotification *)note
{
    // NSLog(@"text change %@",note);
    [saveCustButton setEnabled:TRUE];
    [isSavedLabel setStringValue:@"NOT Saved"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification 
                                                  object:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:[CustomerDataSrc kvoTableData]] ) {
        SMKLogDebug(@"kvo view %d", [self.dataSrc numberOfRowsInTableView:contactListTV]);
        [contactListTV reloadData];
    }
}

-(void)setContactDetail:(CustomerEntity *)cEnt
{
    ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cEnt abPersonID]];

    id abVal = [abp valueForProperty:kABFirstNameProperty];
    
    id lastName = [abp valueForProperty:kABLastNameProperty];
    [fullNameTF setStringValue:[[NSString alloc]initWithFormat:
                                @"%@ %@",
                                NonNilString(abVal),
                                NonNilString(lastName)]];

    abVal = [abp valueForProperty:kABOrganizationProperty];
    [orginizationTF setStringValue:NonNilString(abVal)];
    
    ABMultiValue * abMulti = nil;
    NSString * email = nil;
    abVal = [abp valueForProperty:SMK_AbpCustIdPropName];
    if( abVal == nil ) {
        abMulti = [abp valueForProperty:kABEmailProperty];
        if( abMulti != nil ) {
            NSInteger mi = 0;
            NSString * primId = [abMulti primaryIdentifier];
            if( primId ) {
                mi = [abMulti indexForIdentifier:primId];
                if( mi == NSNotFound ) {
                    mi = 0;
                }
            }
            email = [abMulti valueAtIndex:mi];
            [cEnt setEmailInx:mi];
        }
    } else {
        // existing cust - check email match and resolve changes
        NSString * smkEmIdent = [abp valueForProperty:SMK_AbpCustEmailIdentPropName];
        if( ! smkEmIdent ) {
            [NSException raise:@"customer" 
                         format:@"Opps no smk email ident for cust %@",abVal];
        }
        ABMultiValue * abMulti = [abp valueForProperty:kABEmailProperty];
        if( abMulti != nil ) {
            NSInteger mi = [abMulti indexForIdentifier:smkEmIdent];
            if( mi != NSNotFound ) {
                email = [abMulti valueAtIndex:mi];
                [cEnt setEmailInx:mi];
            }
        }
    }
    [emailTF setStringValue:NonNilString(email)];
    
    abMulti = [abp valueForProperty:kABPhoneProperty];
    if( abMulti != nil ) {
        NSInteger mi = 0;
        NSString * primId = [abMulti primaryIdentifier];
        if( primId ) {
            mi = [abMulti indexForIdentifier:primId];
            if( mi == NSNotFound ) {
                mi = 0;
            }
        }
        NSString * mPhn = [abMulti valueAtIndex:mi];
        [cEnt setMPhoneInx:mi];
        NSString * aPhn = nil;
        for( NSInteger ai = 0; ai < [abMulti count]; ++ ai ) {
            if( ai != mi && aPhn == nil ) {
                aPhn = [abMulti valueAtIndex:ai];
                [cEnt setAPhoneInx:ai];
            }
        }
        [mainPhoneTF setStringValue:NonNilString(mPhn)];
        [altPhoneTF setStringValue:NonNilString(aPhn)];
    } else {
        [mainPhoneTF setStringValue:@""];
        [altPhoneTF setStringValue:@""];
    }
            
    abMulti = [abp valueForProperty:kABAddressProperty];
    if( abMulti != nil ) {
        NSInteger mi = 0;
        NSString * primId = [abMulti primaryIdentifier];
        if( primId ) {
            mi = [abMulti indexForIdentifier:primId];
            if( mi == NSNotFound ) {
                mi = 0;
            }
        }
        [cEnt setAddrInx:mi];
        NSDictionary * addrDict = [abMulti valueAtIndex:mi];
        if( addrDict != nil ) {
            [addrStreetTF setStringValue:NonNilString([addrDict objectForKey:kABAddressStreetKey])];
            [addrCityTF setStringValue:NonNilString([addrDict objectForKey:kABAddressCityKey])];
            [addrStateTF setStringValue:NonNilString([addrDict objectForKey:kABAddressStateKey])];
            [zipCodeTF setStringValue:NonNilString([addrDict objectForKey:kABAddressZIPKey])];
        } else {
            [addrStreetTF setStringValue:@""];
            [addrCityTF setStringValue:@""];
            [addrStateTF setStringValue:@""];
            [zipCodeTF setStringValue:@""];
        }
    } else {
        [addrStreetTF setStringValue:@""];
        [addrCityTF setStringValue:@""];
        [addrStateTF setStringValue:@""];
        [zipCodeTF setStringValue:@""];
    }

    abVal = [abp valueForProperty:kABNoteProperty];
    [custNotesTF setStringValue:NonNilString(abVal)];
}

-(void)addNewCust
{
    // should NOT be possible
    [SMKAlertWin alertWithMsg:@"addNewCust - add to address book first"];
}
#pragma mark Actions
- (IBAction)searchContactListAct:(NSSearchField *)sender 
{
    [self.dataSrc setFilter:[sender stringValue]];
}

- (IBAction)addCustAction:(id)sender 
{
  SMKFunctUnsup;
#if defined( EDIT_SUPPORT )
  /* FIXME */
  
    //c++[[[self view] window] endEditing];
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[dataSrc tableData] count] ) {
        CustomerEntity * cEnt = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                      recordForUniqueId:[cEnt abPersonID]];
        
        if( [abp valueForProperty:SMK_AbpCustIdPropName] != nil ) {
            // this is a cust, so add a fresh one
            [self addNewCust];
        } else {
            // add current record as a cust
        
            NSMutableDictionary * cust = [[NSMutableDictionary alloc]initWithCapacity:16];
            if( [emailTF stringValue] ) {
                [cust setObject:[emailTF stringValue] forKey:@"email"];
            } else {
                [SMKAlertWin alertWithMsg:@"Email address required"];
                return;
            }
            id abVal;
            abVal = [abp valueForProperty:kABFirstNameProperty];
            if( abVal != nil ) {
                [cust setObject:abVal forKey:@"first_name"];
            }
            abVal = [abp valueForProperty:kABLastNameProperty];
            if( abVal != nil ) {
                [cust setObject:abVal forKey:@"last_name"];
            }
            if( [mainPhoneTF stringValue] ) {
                [cust setObject:[mainPhoneTF stringValue] forKey:@"phone"];
            }
            if( [addrStreetTF stringValue] ) {
                [cust setObject:[addrStreetTF stringValue] forKey:@"addr_street"];
            }
            if( [addrCityTF stringValue] ) {
                [cust setObject:[addrCityTF stringValue] forKey:@"addr_city"];
            }
            if( [addrStateTF stringValue] ) {
                [cust setObject:[addrStateTF stringValue] forKey:@"addr_state"];
            }
            if( [zipCodeTF stringValue] ) {
                [cust setObject:[zipCodeTF stringValue] forKey:@"addr_zip"];
            }
            NSDictionary * newRec;
            @try {
                newRec = [DIDB ins_cust:cust];
            }
            @catch (NSException *exception) {
                [SMKAlertWin alertWithMsg:[exception reason]];
                return;
            }
            if( [saveCustButton isEnabled] ) {
                [self saveCustAction:self];
            }
            [abp setValue:[newRec objectForKey:@"cust_id"] forProperty:SMK_AbpCustIdPropName];
            SMKLogDebug(@"new cust id: %@", [newRec objectForKey:@"cust_id"] );
            if( [cEnt emailInx] >= 0 ) {
                ABMultiValue * abMulti = nil;
                abMulti = [abp valueForProperty:kABEmailProperty];
                if( abMulti ) {
                    NSString * email;
                    NSString * emIdent;
                    email = [abMulti valueAtIndex:[cEnt emailInx]];
                    emIdent = [abMulti identifierAtIndex:[cEnt emailInx]];
                    [abp setValue:email forProperty:SMK_AbpCustEmailPropName];
                    [abp setValue:emIdent forProperty:SMK_AbpCustEmailIdentPropName];
                } else {
                    [NSException raise:@"cust" format:@"UGG em inx w/o em prop"];
                }
            } else {
                NSString * email = [[self emailTF] stringValue];
                ABMultiValue * abMulti = [abp valueForProperty:kABEmailProperty];
                NSInteger mi = 0;
                for( ; mi < [abMulti count]; ++ mi ){
                    if( [ email isEqualToString:[abMulti valueAtIndex:mi]] ) {
                        break;
                    }
                }
                if( mi < [abMulti count] ) {
                    [abp setValue:[abMulti identifierAtIndex:mi] 
                      forProperty:SMK_AbpCustEmailIdentPropName];
                    [abp setValue:email 
                      forProperty:SMK_AbpCustEmailPropName];
                } else { 
                    [NSException raise:@"cust" format:@"UGG where did the email addr go!"];
                }
            }
            [[ABAddressBook addressBook] save];
            NSString * listName;
            NSNumber * abpFlagsNum = [abp valueForProperty:kABPersonFlags];
            NSInteger abpFlags = [abpFlagsNum integerValue];
            
            if( (abpFlags & kABShowAsMask) & kABShowAsCompany ) {
                listName = [[NSString alloc]initWithFormat:
                            @" * %@",
                            [abp valueForProperty:kABOrganizationProperty]];
            } else {
                listName = [[NSString alloc]initWithFormat:
                            @" * %@ %@",
                            [abp valueForProperty:kABFirstNameProperty],
                            [abp valueForProperty:kABLastNameProperty]];
            }
            [cEnt setListValue:listName];
            [dataSrc sortData];
            [smkCustImage setHidden:FALSE];
            [addCustButton setEnabled:FALSE];
            [upcButton setEnabled:TRUE];
            [ordersButton setEnabled:TRUE];
            [mediaButton setEnabled:TRUE];
            [isSavedLabel setStringValue:@"* Saved *"];
        }
    } else {
        [self addNewCust];    
    }
#endif
  
}
-(BOOL)updateABMulti:(NSString *)value oInx:(NSInteger)inx person:(ABPerson *)abp key:(NSString *)abKey
{
    if( value != nil && [value length] > 0 ) {
        if( inx >= 0 ) {
            ABMutableMultiValue * abMulti = [[abp valueForProperty:abKey] mutableCopy];
            if( [value isEqualToString:[abMulti valueAtIndex:inx]] ) {
                return FALSE; // no change
            }
            [abMulti replaceValueAtIndex:inx withValue:value];
            [abp setValue:abMulti forProperty:abKey];
            return TRUE;
        } else {
            // need to add it - asserting there is none
            ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
            [nMulti addValue:value withLabel:@"home"];
            [abp setValue:nMulti forProperty:abKey];                
            return TRUE;
        }
    }
  
    return FALSE;
}

- (IBAction)saveCustAction:(id)sender 
{
  SMKFunctUnsup;
#if defined( EDIT_SUPPORT )
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[dataSrc tableData] count] ) {
        CustomerEntity * cEnt = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                      recordForUniqueId:[cEnt abPersonID]];
        
        if( [self updateABMulti:[emailTF stringValue] 
                           oInx:[cEnt emailInx] 
                         person:abp 
                            key:kABEmailProperty] ) {
            // updated email - update the db;
            NSNumber * custId = [abp valueForProperty:SMK_AbpCustIdPropName];
            if( custId != nil ) {
                [DIDB upd_cust:custId email:[[self emailTF]stringValue]];
            }
        }
        // don't really care about these
        [self updateABMulti:[mainPhoneTF stringValue] oInx:[cEnt mPhoneInx] person:abp key:kABPhoneProperty];
        [self updateABMulti:[altPhoneTF stringValue] oInx:[cEnt aPhoneInx] person:abp key:kABPhoneProperty];

        NSString * val;
        val = [[self custNotesTF] stringValue];
        if( val 
           && [val length] > 0 
           && ! [val isEqualToString:[abp valueForProperty:kABNoteProperty ]] ) {
            [abp setValue:val forProperty:kABNoteProperty ];
            NSNumber * custId = [abp valueForProperty:SMK_AbpCustIdPropName];
            if( custId != nil ) {
                [DIDB add_cust_note:custId note:[[self custNotesTF]stringValue]];
            }
        }
        
        ABAddressBook * myAB = [ABAddressBook addressBook];
        if( [myAB hasUnsavedChanges] ) {
            [myAB save];
        }
        [saveCustButton setEnabled:FALSE];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];
    }
#endif
}

- (IBAction)ordersAction:(id)sender 
{
}

- (IBAction)mediaAction:(id)sender 
{
  NSInteger sel = [contactListTV selectedRow];
  if( sel < 0 ) {
    SMKLogDebug(@"opps no selection"); 
  } else {
    CustomerEntity * cust = [[self.dataSrc tableData] objectAtIndex:sel];
    ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                  recordForUniqueId:[cust abPersonID]];
    NSNumber * custId = [abp valueForProperty:SMK_AbpCustIdPropName];
    if( self.custMediaVC == nil ) {
      [self setCustMediaVC: [[CustMediaVCntlr alloc]
                             initWithDoneVC: self ]];
      
    } 
    [self.custMediaVC replaceView: self.rview custId: custId];
  }
}

- (IBAction)contactListSelection:(NSTableView *)sender
{
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[self.dataSrc tableData] count] ) {
        CustomerEntity * cust = [[self.dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cust abPersonID]];

        NSNumber * custId = [abp valueForProperty:SMK_AbpCustIdPropName] ;
        if( custId != nil ) {
            [smkCustImage setHidden:FALSE];
            [addCustButton setEnabled:FALSE];
            [upcButton setEnabled:TRUE];
            [ordersButton setEnabled:TRUE];
            [mediaButton setEnabled:TRUE];
            [self setContactDetail:cust];
        } else {
            [smkCustImage setHidden:TRUE];
            [addCustButton setEnabled:TRUE];
            [upcButton setEnabled:FALSE];
            [ordersButton setEnabled:FALSE];
            [mediaButton setEnabled:FALSE];
            
            [self setContactDetail:cust];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:)
                                                     name:NSTextDidChangeNotification 
                                                   object:nil];
    }
}

@end
