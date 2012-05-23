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
#import "Customer.h"

#import <SMKCocoaCommon.h>
#import <SMKCommon.h>

static CustomerViewCntlr * me;

@implementation CustomerViewCntlr
@synthesize vToRplc     = _vToRplc;
@synthesize dataSrc     = _dataSrc;
@synthesize curCustId   = _curCustId;

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
  if( self.dataSrc.tableData != nil ) {
    [contactListTV reloadData];
  }
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
    SMKLogDebug(@"kvo view %ld", [self.dataSrc numberOfRowsInTableView:contactListTV]);
    [contactListTV reloadData];
  }
}

-(void)setContactDetail:(CustomerEntity *)cEnt
{
  ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                recordForUniqueId:[cEnt abPersonID]];
  
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
      SMKThrow( @"Opps no smk email ident for cust %@",abVal );
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
  NSInteger sel = [contactListTV selectedRow];
  if( 0 <= sel && sel < self.dataSrc.tableData.count ) {
    
    CustomerEntity * cEnt = [self.dataSrc.tableData objectAtIndex:sel];
    ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                  recordForUniqueId: cEnt.abPersonID ];
    ABMultiValue * ebEmailList = [abp valueForProperty:kABEmailProperty];
    id fname = [abp valueForProperty:kABFirstNameProperty];
    id lname = [abp valueForProperty:kABLastNameProperty];
    NSString * email = nil;
    NSString * emailIdent = nil;
    if( cEnt.emailInx >= 0  ) {
      emailIdent = [ebEmailList identifierAtIndex: cEnt.emailInx];
      email = [ebEmailList valueAtIndex: cEnt.emailInx];
      email = email.lowercaseString;
    }

    Customer * cust = [[Customer alloc]init];
    if(  email == nil || fname == nil || lname == nil ) {
      [SMKAlertWin alertWithMsg:
       [NSString stringWithFormat:
        @"Email, first name and last name required for add"]];
    } else {
      [cust setEmail: self.emailTF.stringValue.lowercaseString ];
      [cust setFname: fname ];
      [cust setLname: lname ];
      id<SMKDBConn> db = [SMKDBConnMgr getNewDbConn];
      SMKProgStart();
      [cust updatedb: db gathOp: nil ];
      [CustomerDataSrc setABPersonSMKProps:abp
                                       val:cust.custId
                                valPropKey:SMK_AbpCustIdPropName 
                                     email:cust.email
                                emailIdent:nil];
        
      [smkCustImage setHidden:FALSE];
      [addCustButton setEnabled:FALSE];
      [upcButton setEnabled:TRUE];
      [ordersButton setEnabled:TRUE];
      [mediaButton setEnabled:TRUE];
      SMKProgStop();
      SMKStatus( @"Customer added" );
    }
  }
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
    SMKProgStart();
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
  if( 0 <= sel && sel < self.dataSrc.tableData.count ) {
    CustomerEntity * cust = [self.dataSrc.tableData objectAtIndex:sel];
    ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] 
                                  recordForUniqueId: cust.abPersonID];
    
    NSNumber * custId = [abp valueForProperty:SMK_AbpCustIdPropName] ;
    if( custId != nil ) {
      [smkCustImage setHidden:FALSE];
      [addCustButton setEnabled:FALSE];
      [upcButton setEnabled:TRUE];
      [ordersButton setEnabled:TRUE];
      [mediaButton setEnabled:TRUE];
    } else {
      [smkCustImage setHidden:TRUE];
      [addCustButton setEnabled:TRUE];
      [upcButton setEnabled:FALSE];
      [ordersButton setEnabled:FALSE];
      [mediaButton setEnabled:FALSE];
      
    }
    [self setContactDetail:cust];
  }
}

@end
