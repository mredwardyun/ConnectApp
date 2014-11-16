//
//  ConfirmViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ConfirmViewController.h"
#import "FinishViewController.h"

@interface ConfirmViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *phoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *yoSwitch;

@property (nonatomic) NSMutableDictionary *confirmedServicesWithInfo;

@end

@implementation ConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSArray *requestedServices = [self.requestedServicesWithInfo allKeys];
	if (![requestedServices containsObject:@"FB"]) {
		[self.facebookSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"PHONE"]) {
		[self.phoneSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"TWITTER"]) {
		[self.twitterSwitch setEnabled:NO];
	}
	if (![requestedServices containsObject:@"YO"]) {
		[self.yoSwitch setEnabled:NO];
	}
}

- (void)sendConfirmation {
	NSMutableString *stringToSend = [[NSMutableString alloc] init];
	self.confirmedServicesWithInfo = [[NSMutableDictionary alloc] init];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *fbmanual = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbmanual"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	[stringToSend appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"NAME"] forKey:@"NAME"];
	if (self.facebookSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"FB"] forKey:@"FB"];
		if (fbmanual) {
			[stringToSend appendString:[NSString stringWithFormat:@"FBMANUAL:%@\n", fbmanual]];
		}
		if (self.requestedServicesWithInfo[@"FBMANUAL"]) {
			[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"FBMANUAL"] forKey:@"FBMANUAL"];
		}
	}
	if (phone && self.phoneSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"PHONE:%@\n", phone]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"PHONE"] forKey:@"PHONE"];
	}
	if (twitter && self.twitterSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"TWITTER:%@\n", twitter]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"TWITTER"] forKey:@"TWITTER"];
	}
	if (yo && self.yoSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"YO:%@\n", yo]];
		[self.confirmedServicesWithInfo setObject:self.requestedServicesWithInfo[@"YO"] forKey:@"YO"];
	}
	NSLog(@"sendconfirmation stringToSend %@", stringToSend);
	NSLog(@"sendconfirmation confirmedServicesWithInfo %@", self.confirmedServicesWithInfo);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue destinationViewController] isKindOfClass:[FinishViewController class]]) {
		((FinishViewController *)[segue destinationViewController]).confirmedServicesWithInfo = self.confirmedServicesWithInfo;
	}
}


@end
