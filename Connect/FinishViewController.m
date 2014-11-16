//
//  WaitingForConfirmationViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/16/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "FinishViewController.h"
#import "YO.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>

@interface FinishViewController ()

@end

@implementation FinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *name = self.confirmedServicesWithInfo[@"NAME"];
	NSString *firstName = [name componentsSeparatedByString:@" "][0];
	NSString *lastName = [name componentsSeparatedByString:@" "][1];
	
	if (self.confirmedServicesWithInfo[@"PHONE"]) {
		ABPeoplePickerNavigationController *peoplePicker=[[ABPeoplePickerNavigationController alloc] init];
		ABAddressBookRef addressBook = [peoplePicker addressBook];
		
		// create person record
		
		ABRecordRef person = ABPersonCreate();
		// set name and other string values
		
		NSString *phoneNo= self.confirmedServicesWithInfo[@"PHONE"];
		
		
		CFErrorRef cfError=nil;
		
		if (firstName) {
			ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName) , nil);
		}
		
		if (lastName) {
			ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName) , nil);
		}
		
		if (phoneNo)
		{
			ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			NSArray *venuePhoneNumbers = [phoneNo componentsSeparatedByString:@" or "];
			for (NSString *venuePhoneNumberString in venuePhoneNumbers)
				ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFStringRef) venuePhoneNumberString, kABPersonPhoneMainLabel, NULL);
			ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
			CFRelease(phoneNumberMultiValue);
		}
		
		
		//Add person Object to addressbook Object.
		ABAddressBookAddRecord(addressBook, person, &cfError);
		
		if (ABAddressBookSave(addressBook, nil)) {
			NSLog(@"\nPerson Saved successfuly");
		} else {
			NSLog(@"\n Error Saving person to AddressBook");
		}
	}
	if (self.confirmedServicesWithInfo[@"TWITTER"]) {
		NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friendships/create.json?user_id=%@&follow=true", self.confirmedServicesWithInfo[@"TWITTER"]];
		NSURL *verify = [NSURL URLWithString:urlString];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
		[[PFTwitterUtils twitter] signRequest:request];
		NSURLResponse *response = nil;
		NSError *error;
		[NSURLConnection sendSynchronousRequest:request
											 returningResponse:&response
														 error:&error];
	}
	if (self.confirmedServicesWithInfo[@"YO"]) {
		[YO sendYOToIndividualUser:self.confirmedServicesWithInfo[@"YO"]];
	}
	if (self.confirmedServicesWithInfo[@"FBMANUAL"]) {
		NSString *urlString = [NSString stringWithFormat:@"fb://profile/%@", self.confirmedServicesWithInfo[@"FBMANUAL"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];
	}
	else if (self.confirmedServicesWithInfo[@"FB"]) {
		NSString *urlString = [NSString stringWithFormat:@"http://facebook.com/%@", self.confirmedServicesWithInfo[@"FB"]];
		NSURL *url = [NSURL URLWithString:urlString];
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end
