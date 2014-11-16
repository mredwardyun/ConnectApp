//
//  ServicesViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ServicesViewController.h"

@interface ServicesViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *phoneSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *yoSwitch;

@property (nonatomic) NSMutableArray *selectedServices;
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
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	[stringToSend appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	[stringToSend appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
	if (phone && self.phoneSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"PHONE:%@\n", phone]];
	}
	if (twitter && self.twitterSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"TWITTER:%@\n", twitter]];
	}
	if (yo && self.yoSwitch.on) {
		[stringToSend appendString:[NSString stringWithFormat:@"YO:%@\n", yo]];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}

@end
