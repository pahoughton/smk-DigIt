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
#import "DIDB.h"
#import <SMKLogger.h>
#import <SMKAlertWin.h>

static CustomerViewCntlr * me;

@interface Incremental : NSObject
@property NSInteger value;
-(void)incr;
@end
@implementation Incremental
@synthesize value;
- (id)init {
    self = [super init];
    if (self) {
        value = 0;
    }
    return self;
}
-(void)incr
{
    ++value;
}
-(NSString *)description
{
    return [[NSString alloc]initWithFormat:@"%d",value];
}
@end
@implementation CustomerViewCntlr
@synthesize dataSrc;
@synthesize curCustId;
@synthesize contactListTV;
@synthesize contactSearch;
@synthesize firstNameTF;
@synthesize lastNameTF;
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
        me = [me initWithNibName:@"CustomerView" bundle:nil];
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
        [self setDataSrc:[[CustomerDataSrc alloc]init]];
        // Initialization code here.
    }
    
    return self;
}

-(void) awakeFromNib
{
    [contactListTV setDataSource:dataSrc];
    [smkCustImage setHidden:TRUE];
    [zipCodeNFmt setFormat:@"00000"];
    [dataSrc addObserver:self forKeyPath:[CustomerDataSrc kvoTableData] options:0 context:nil];
    if( [dataSrc tableData] != nil ) {
        [contactListTV reloadData];
    }
}

-(void) textDidChange:(NSNotification *)note
{
    NSLog(@"text change %@",note);
    [saveCustButton setEnabled:TRUE];
    [isSavedLabel setStringValue:@"NOT Saved"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification 
                                                  object:nil];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:[CustomerDataSrc kvoTableData]] ) {
        SMKLogDebug(@"kvo view %d", [dataSrc numberOfRowsInTableView:contactListTV]);
        [contactListTV reloadData];
    }
}

-(void)setContactDetail:(CustomerEntity *)cEnt
{
    ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cEnt abPersonID]];

    id abVal = [abp valueForProperty:kABFirstNameProperty];
    [firstNameTF setStringValue:abVal];
    
    abVal = [abp valueForProperty:kABLastNameProperty];
    [lastNameTF setStringValue:abVal];
    
    ABMultiValue * abMulti = [abp valueForProperty:kABEmailProperty];
    if( abMulti != nil ) {
        NSString * primId = [abMulti primaryIdentifier];
    
        NSString * email = [abMulti valueAtIndex:0];
        [cEnt setEmailInx:0];
        for( NSInteger ei = 0; ei < [abMulti count]; ++ ei ) {
            if( [primId isEqualToString:[abMulti identifierAtIndex:ei]] ) {
                email = [abMulti valueAtIndex:ei];
                [cEnt setEmailInx:ei];
                break;
            }
        }
        [emailTF setStringValue:email];
    } else {
        [emailTF setStringValue:nil];
    }
    
    abMulti = [abp valueForProperty:kABPhoneProperty];
    if( abMulti != nil ) {
        NSString * primId = [abMulti primaryIdentifier];

        NSString * mPhn = [abMulti valueAtIndex:0];
        [cEnt setMPhoneInx:0];
        NSString * aPhn = nil;
        for( NSInteger ei = 1; ei < [abMulti count]; ++ ei ) {
            if( aPhn == nil ) {
                aPhn = [abMulti valueAtIndex:ei];
                [cEnt setAPhoneInx:ei];
            }
            if( [primId isEqualToString:[abMulti identifierAtIndex:ei]] ) {
                aPhn = mPhn;
                [cEnt setAPhoneInx:[cEnt mPhoneInx]];
                mPhn = [abMulti valueAtIndex:ei];
                [cEnt setMPhoneInx:ei];
                break;
            }
        }
        [mainPhoneTF setStringValue:mPhn];
        [altPhoneTF setStringValue:aPhn];
    } else {
        [mainPhoneTF setStringValue:nil];
        [altPhoneTF setStringValue:nil];
    }
            
    abMulti = [abp valueForProperty:kABAddressProperty];
    if( abMulti != nil ) {
        NSString * primId = [abMulti primaryIdentifier];
        NSInteger primInx = 0;
        for( NSInteger ei = 1; ei < [abMulti count]; ++ ei ) {
            if( [primId isEqualToString:[abMulti identifierAtIndex:ei]] ) {
                primInx = ei;
            }
        }
        [cEnt setAddrInx:primInx];
        NSDictionary * addrDict = [abMulti valueAtIndex:primInx];
        [addrStreetTF setStringValue:[addrDict objectForKey:kABAddressStreetKey]];
        [addrCityTF setStringValue:[addrDict objectForKey:kABAddressCityKey]];
        [addrStateTF setStringValue:[addrDict objectForKey:kABAddressStateKey]];
        [zipCodeTF setStringValue:[addrDict objectForKey:kABAddressZIPKey]];
    } else {
        [addrStreetTF setStringValue:nil];
        [addrCityTF setStringValue:nil];
        [addrStateTF setStringValue:nil];
        [zipCodeTF setStringValue:nil];
    }

    abVal = [abp valueForProperty:kABNoteProperty];
    [custNotesTF setStringValue:abVal];
}

-(void)addNewCust
{
    // should NOT be possible
    [SMKAlertWin alertWithMsg:@"addNewCust - add to address book first"];
}
#pragma mark Actions
- (IBAction)searchContactListAct:(NSSearchField *)sender 
{
    [dataSrc setFilter:[sender stringValue]];
}

- (IBAction)addCustAction:(id)sender 
{
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[dataSrc tableData] count] ) {
        CustomerEntity * cust = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cust abPersonID]];
        if( [abp valueForProperty:[DIDB abpCustIdPropName]] != nil ) {
            // this is a cust, so add a fresh one
            [self addNewCust];
        } else {
            // add current record as a cust
            NSMutableDictionary * cust = [[NSMutableDictionary alloc]initWithCapacity:16];
            if( [firstNameTF stringValue] ) {
                [cust setObject:[firstNameTF stringValue] forKey:@"first_name"];
            }
            if( [lastNameTF stringValue] ) {
                [cust setObject:[lastNameTF stringValue] forKey:@"last_name"];
            }
            if( [emailTF stringValue] ) {
                [cust setObject:[emailTF stringValue] forKey:@"email"];
            }
            if( [mainPhoneTF stringValue] ) {
                [cust setObject:[mainPhoneTF stringValue] forKey:@"phone"];
            }
            if( [addrStreetTF stringValue] ) {
                [cust setObject:[addrStreetTF stringValue] forKey:@"addr_streat"];
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
            NSDictionary * newRec = [DIDB ins_cust:cust];
            [abp setValue:[newRec objectForKey:@"cust_id"] forProperty:[DIDB abpCustIdPropName]];
            [[ABAddressBook addressBook] save];
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
}
-(BOOL)updateABMulti:(NSString *)value oInx:(NSInteger)inx person:(ABPerson *)abp key:(NSString *)abKey
{
    if( value != nil && [value length] > 0 ) {
        if( inx >= 0 ) {
            ABMultiValue * abMulti = [abp valueForProperty:abKey];
            if( ! [value isEqualToString:[abMulti valueAtIndex:inx]] ) {
                // changed
                ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
                for( NSInteger mi = 0; mi < [abMulti count]; ++ mi ) {
                    if( mi == inx ) {
                        [nMulti addValue:value withLabel:[abMulti labelAtIndex:mi]];
                    } else {
                        [nMulti addValue:[abMulti valueAtIndex:mi]
                               withLabel:[abMulti labelAtIndex:mi]];
                    }
                }
                [abp setValue:nMulti forProperty:abKey];
                return TRUE;
            } else {
                return FALSE;
            }
        } else {
            // need to add it - asserting there is none
            ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
            [nMulti addValue:value withLabel:[nMulti primaryIdentifier]];
            [abp setValue:nMulti forProperty:abKey];                
            return TRUE;
        }
    }
    return FALSE;
}

- (IBAction)saveCustAction:(id)sender 
{
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[dataSrc tableData] count] ) {
        CustomerEntity * cEnt = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cEnt abPersonID]];
        if( [self updateABMulti:[emailTF stringValue] oInx:[cEnt emailInx] person:abp key:kABEmailProperty] ) {
            // updated email - update the db;
            
        }
        // don't really care about these
        [self updateABMulti:[mainPhoneTF stringValue] oInx:[cEnt mPhoneInx] person:abp key:kABPhoneProperty];
        [self updateABMulti:[altPhoneTF stringValue] oInx:[cEnt aPhoneInx] person:abp key:kABPhoneProperty];
        
        ABMultiValue * abMulti = [abp valueForProperty:kABAddressProperty];
        if( [cEnt addrInx] >= 0 ) {
            BOOL change = FALSE;
            NSDictionary * oAddr = [abMulti valueAtIndex:[cEnt addrInx]];
            NSString * valStreet = [addrStreetTF stringValue];
            NSString * valCity = [addrCityTF stringValue];
            NSString * valState = [addrStateTF stringValue];
            NSString * valZip = [zipCodeTF stringValue];
            if( ( valStreet
                 && [valStreet length] > 0 
                 && [valStreet isEqualToString:[oAddr objectForKey:kABAddressStreetKey]] ) 
               || ( valCity
                   && [valCity length] > 0 
                   && [valCity isEqualToString:[oAddr objectForKey:kABAddressCityKey]] ) 
               || ( valState
                   && [valState length] > 0 
                   && [valState isEqualToString:[oAddr objectForKey:kABAddressStateKey]] ) 
               || ( valZip
                   && [valZip length] > 0 
                   && [valZip isEqualToString:[oAddr objectForKey:kABAddressZIPKey]] ) ) {
                   // ok something changed;
                   NSMutableDictionary * nAddr 
                   = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                      valStreet,kABAddressStreetKey,
                      valCity,kABAddressCityKey,
                      valState,kABAddressStateKey,
                      valZip,kABAddressZIPKey,
                      nil];
                   
                   ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
                   for(NSInteger mi = 0; mi < [abMulti count]; ++ mi) {
                       if( mi == [cEnt addrInx] ) {
                           [nMulti addValue:nAddr 
                                  withLabel:[abMulti labelAtIndex:mi]];
                       } else {
                           [nMulti addValue:[abMulti valueAtIndex:mi] 
                                  withLabel:[abMulti labelAtIndex:mi]];
                       }
                   }
                   [abp setValue:nMulti forProperty:kABAddressProperty];
               }
        } else {
            // no index - if any set add the addr
            NSMutableDictionary * nAddr = [[NSMutableDictionary alloc]initWithCapacity:8];
            NSString * valStreet = [addrStreetTF stringValue];
            NSString * valCity = [addrCityTF stringValue];
            NSString * valState = [addrStateTF stringValue];
            NSString * valZip = [zipCodeTF stringValue];
            BOOL addrData = FALSE;
            if( valStreet != nil && [valStreet length] > 0 ) {
                [nAddr setObject:valStreet forKey:kABAddressStreetKey];
                addrData = TRUE;
            }
            if( valCity != nil && [valCity length] > 0 ) {
                [nAddr setObject:valCity forKey:kABAddressCityKey];
                addrData = TRUE;                
            }
            if( valState != nil && [valState length] > 0 ) {
                [nAddr setObject:valState forKey:kABAddressStateKey];
                addrData = TRUE;                
            }
            if( valZip != nil && [valZip length] > 0 ) {
                [nAddr setObject:valZip forKey:kABAddressZIPKey];
                addrData = TRUE;                                
            }
            ABMutableMultiValue * nMulti = [[ABMutableMultiValue alloc]init];
            [nMulti addValue:nAddr withLabel:[nMulti primaryIdentifier]];
        }
        NSString * val = [firstNameTF stringValue];
        if( val 
           && [val length] > 0 
           && ! [val isEqualToString:[abp valueForProperty:kABFirstNameProperty]] ) {
            [abp setValue:val forProperty:kABFirstNameProperty];
        }
        val = [lastNameTF stringValue];
        if( val 
           && [val length] > 0 
           && ! [val isEqualToString:[abp valueForProperty:kABLastNameProperty]] ) {
            [abp setValue:val forProperty:kABLastNameProperty];
        }
        ABAddressBook * myAB = [ABAddressBook addressBook];
        if( [myAB hasUnsavedChanges] ) {
            [myAB save];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification 
                                               object:nil];
    }
}

- (IBAction)ordersAction:(id)sender 
{
}

- (IBAction)upcsAction:(id)sender 
{
    NSInteger sel = [contactListTV selectedRow];
    if( sel < 0 ) {
        SMKLogDebug(@"opps no selection"); 
    } else {
        CustomerEntity * cust = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cust abPersonID]];
        NSDictionary * custInfo = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   [abp valueForProperty:[DIDB abpCustIdPropName]], @"cust_id",
                                   [firstNameTF stringValue],@"first_name",
                                   [lastNameTF stringValue],@"last_name",
                                   nil];
        [CustUpcViewCntlr showSelfIn:[self view] custInfo:custInfo];
    }
}

- (IBAction)mediaAction:(id)sender {
}

- (IBAction)contactListSelection:(NSTableView *)sender
{
    NSInteger sel = [contactListTV selectedRow];
    if( 0 <= sel && sel < [[dataSrc tableData] count] ) {
        CustomerEntity * cust = [[dataSrc tableData] objectAtIndex:sel];
        ABPerson * abp = (ABPerson *)[[ABAddressBook addressBook] recordForUniqueId:[cust abPersonID]];

        if( [abp valueForProperty:[DIDB abpCustIdPropName]] != nil ) {
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
