//
//  ServicesViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ServicesViewController.h"
#import "FinishViewController.h"

@interface ServicesViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *phoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *yoSwitch;

@property (nonatomic) NSMutableDictionary *confirmedServicesWithInfo;

@end

@implementation ServicesViewController

- (void)viewDidLoad {
	if (![self.availableServices containsObject:@"PHONE"]) {
		[self.phoneSwitch setEnabled:NO];
	}
	if (![self.availableServices containsObject:@"TWITTER"]) {
		[self.twitterSwitch setEnabled:NO];
	}
	if (![self.availableServices containsObject:@"YO"]) {
		[self.yoSwitch setEnabled:NO];
	}
}

- (void)sendRequestForServices {
	NSMutableString *stringToSend = [[NSMutableString alloc] init];

	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *fbmanual = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbmanual"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	[stringToSend appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	if (self.facebookSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
		if (fbmanual) {
			[stringToSend appendString:[NSString stringWithFormat:@"FBMANUAL:%@\n", fbmanual]];
		}
	}
	if (phone && self.phoneSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"PHONE:%@\n", phone]];
	}
	if (twitter && self.twitterSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"TWITTER:%@\n", twitter]];
	}
	if (yo && self.yoSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"YO:%@\n", yo]];
	}
	
	//send request string
}

- (void)listenForConfirmation {
	NSString *messageReceived = @""; //change
	self.confirmedServicesWithInfo = [[NSMutableDictionary alloc] init];
	
	NSArray *components = [messageReceived componentsSeparatedByString:@"\n"];
	for (NSString *component in components) {
		if ([component containsString:@"NAME:"]) {
			NSString *name = [component componentsSeparatedByString:@"NAME:"][0];
			[self.confirmedServicesWithInfo setObject:name forKey:@"NAME"];
		}
		else if ([component containsString:@"FB:"]) {
			NSString *fb = [component componentsSeparatedByString:@"FB:"][0];
			[self.confirmedServicesWithInfo setObject:fb forKey:@"FB"];
		}
		else if ([component containsString:@"FBMANUAL:"]) {
			NSString *fbmanual = [component componentsSeparatedByString:@"FBMANUAL:"][0];
			[self.confirmedServicesWithInfo setObject:fbmanual forKey:@"FBMANUAL"];
		}
		else if ([component containsString:@"PHONE:"] && [self.availableServices containsObject:@"PHONE"]) {
			NSString *phone = [component componentsSeparatedByString:@"PHONE:"][0];
			[self.confirmedServicesWithInfo setObject:phone forKey:@"PHONE"];
		}
		else if ([component containsString:@"TWITTER:"] && [self.availableServices containsObject:@"TWITTER"]) {
			NSString *twitter = [component componentsSeparatedByString:@"TWITTER:"][0];
			[self.confirmedServicesWithInfo setObject:twitter forKey:@"TWITTER"];
		}
		else if ([component containsString:@"YO:"] && [self.availableServices containsObject:@"YO"]) {
			NSString *yo = [component componentsSeparatedByString:@"YO:"][0];
			[self.confirmedServicesWithInfo setObject:yo forKey:@"YO"];
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue destinationViewController] isKindOfClass:[FinishViewController class]]) {
		((FinishViewController *)[segue destinationViewController]).confirmedServicesWithInfo = self.confirmedServicesWithInfo;
	}
}

@end
