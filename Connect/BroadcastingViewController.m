//
//  BroadcastingViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "BroadcastingViewController.h"

@implementation BroadcastingViewController

- (void)broadcastMessage {
	NSMutableString *messageToBroadcast = [[NSMutableString alloc] init];
	NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"realname"];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *yo = [[NSUserDefaults standardUserDefaults] objectForKey:@"YoID"];
	if (name) {
		[messageToBroadcast appendString:[NSString stringWithFormat:@"NAME:%@\n", name]];
	}
	if (fb) {
		[messageToBroadcast appendString:[NSString stringWithFormat:@"FB:%@\n", fb]];
	}
	if (phone) {
		[messageToBroadcast appendString:@"PHONE"];
	}
	if (twitter) {
		[messageToBroadcast appendString:@"TWITTER\n"];
	}
	if (yo) {
		[messageToBroadcast appendString:@"YO\n"];
	}
	
	// broadcast this message
}

- (void)listenForRequests {
	
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
}

@end
