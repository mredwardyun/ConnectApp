//
//  MainPageContentViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ListeningViewController.h"
#import "FirstLaunchViewController.h"
#import "ServicesViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface ListeningViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic) NSString *contactRealname;
@property (nonatomic) NSString *contactUsername;
@property (nonatomic) NSMutableArray *contactServices;

@end

@implementation ListeningViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Head picture in image view
	self.label.text = @"";
	self.imageView.layer.cornerRadius = self.imageView.frame.size.width/2;
	self.imageView.clipsToBounds = YES;
	self.contactServices = [[NSMutableArray alloc] initWithArray:@[@"FB"]];
}

- (void)listenToBroadcasts {
	NSString *messageReceived = @"";
	if ([messageReceived containsString:@"PHONE"]) {
		[self.contactServices addObject:@"PHONE"];
	}
	if ([messageReceived containsString:@"TWITTER"]) {
		[self.contactServices addObject:@"TWITTER"];
	}
	if ([messageReceived containsString:@"YO"]) {
		[self.contactServices addObject:@"YO"];
	}
	NSArray *components = [messageReceived componentsSeparatedByString:@"\n"];
	for (NSString *component in components) {
		if ([component containsString:@"NAME:"]) {
			self.contactRealname = [component componentsSeparatedByString:@"NAME:"][0];
		}
		if ([component containsString:@"FB:"]) {
			self.contactUsername = [component componentsSeparatedByString:@"FB:"][0];
		}
	}
	
	self.label.text = self.contactRealname;
	NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?width=9999", self.contactUsername];
	NSURL *url=[NSURL URLWithString:strurl];
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	UIImage *profilePic = [UIImage imageWithData:imageData];
	self.imageView.image = profilePic;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue destinationViewController] isKindOfClass:[ServicesViewController class]]) {
		((ServicesViewController *)[segue destinationViewController]).availableServices = self.contactServices;
	}
}

@end
