//
//  BroadcastingViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "BroadcastingViewController.h"

@interface BroadcastingViewController ()

@property (nonatomic) NSMutableArray *availableServices;
@property (nonatomic) NSMutableDictionary *requestedServicesWithInfo;

@end

@implementation BroadcastingViewController

- (void)broadcastMessage {
	NSMutableString *messageToBroadcast = [[NSMutableString alloc] init];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];

	self.availableServices = [[NSMutableArray alloc] initWithArray:@[@"NAME", @"FB"]];
	
	[messageToBroadcast appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	[messageToBroadcast appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];

	if (phone) {
		[messageToBroadcast appendString:@"PHONE"];
		[self.availableServices addObject:@"PHONE"];
	}
	if (twitter) {
		[messageToBroadcast appendString:@"TWITTER\n"];
		[self.availableServices addObject:@"TWITTER"];
	}
	if (yo) {
		[messageToBroadcast appendString:@"YO\n"];
		[self.availableServices addObject:@"YO"];
	}
	
	// broadcast this message
}

- (void)listenForRequests {
	NSString *messageReceived = @""; //change
	self.requestedServicesWithInfo = [[NSMutableDictionary alloc] init];

	NSArray *components = [messageReceived componentsSeparatedByString:@"\n"];
	for (NSString *component in components) {
		if ([component containsString:@"NAME:"]) {
			NSString *name = [component componentsSeparatedByString:@"NAME:"][0];
			[self.requestedServicesWithInfo setObject:name forKey:@"NAME"];
		}
		else if ([component containsString:@"FB:"]) {
			NSString *fb = [component componentsSeparatedByString:@"FB:"][0];
			[self.requestedServicesWithInfo setObject:fb forKey:@"FB"];
		}
		else if ([component containsString:@"PHONE:"] && [self.availableServices containsObject:@"PHONE"]) {
			NSString *fb = [component componentsSeparatedByString:@"PHONE:"][0];
			[self.requestedServicesWithInfo setObject:fb forKey:@"PHONE"];
		}
		
	}
	

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}

@end
