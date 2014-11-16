//
//  SettingsViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	NSString *fb = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbusername"];
	NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:@"phonenumber"];
	NSString *twitter = [[NSUserDefaults standardUserDefaults] objectForKey:@"twitterID"];
	NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"];
	self.label.text = [NSString stringWithFormat:@"Facebook: %@\nPhone: %@\nTwitter: %@\nUUID: %@", fb, phone, twitter, uuid];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
