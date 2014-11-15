//
//  FirstLaunchViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "FirstLaunchViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PhoneNumberViewController.h"

@interface FirstLaunchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
- (IBAction)fbLoginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumberButton;

@end

@implementation FirstLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)fbLoginButtonPressed:(id)sender {
	[self.fbLoginButton setEnabled:NO];
	[self fbLogin];
}

- (void) fbLogin {
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions]
	[PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email"]
									block:^(PFUser *user, NSError *error) {
		NSLog(@"Initial login permissions: %@", [[PFFacebookUtils session] permissions]);
		if (!user) {
			NSLog(@"Hi1");
			if (!error) {
				NSLog(@"The user cancelled the Facebook login.");
			} else {
				NSLog(@"An error occurred: %@", error.localizedDescription);
			}
			[self fbDidLogin:NO];
		} else {
			NSLog(@"Current user %@", [PFUser currentUser]);
			FBRequest *request = [FBRequest requestForMe];
			[request startWithCompletionHandler:
			 ^(FBRequestConnection *connection, id result, NSError *error) {
				 if (!error) {
					 NSString *facebookUsername = [result objectForKey:@"id"];
					 NSString *realName = [result objectForKey:@"name"];
					 NSLog(@"FB ID %@, real name %@", facebookUsername, realName);
					 [user setObject:facebookUsername forKey:@"fbusername"];
					 [user setObject:realName forKey:@"realName"];
					 [user saveEventually];
				 }
				 }];
			[self fbDidLogin:YES];
			}
	}];
}

- (void) fbDidLogin:(BOOL)loggedIn {
	// Re-enable the Login button
	[self.fbLoginButton setEnabled:YES];
	
	// Did we login successfully ?
	if (!loggedIn) {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
									message:@"Facebook Login failed. Please try again"
								   delegate:nil
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil] show];
		
	}
}



- (IBAction)getUserPhoneNumber:(id)sender {
    PhoneNumberViewController *phoneNumberViewController = (PhoneNumberViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"getPhoneNumber"];
    [self presentViewController:phoneNumberViewController animated:YES completion:nil];
}

- (IBAction)twitterLogin:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        if (![PFTwitterUtils isLinkedWithUser:currentUser]) {
            [PFTwitterUtils linkUser:currentUser block:^(BOOL succeeded, NSError *error) {
                if ([PFTwitterUtils isLinkedWithUser:currentUser]) {
                    NSLog(@"Woohoo, user logged in with Twitter!");
                }
            }];
        }
    } else {
        [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Twitter login.");
                return;
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in with Twitter!");
            } else {
                NSLog(@"User logged in with Twitter!");
            }     
        }];
    }
    
    NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *twitterID = [results objectForKey:@"id"];
    [currentUser setObject:twitterID forKey:@"TwitterID"];
    [currentUser saveInBackground];
}

@end
