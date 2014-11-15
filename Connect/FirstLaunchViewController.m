//
//  FirstLaunchViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "FirstLaunchViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface FirstLaunchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
- (IBAction)fbLoginButtonPressed:(id)sender;

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
	// so there is no reason to ask for additional permissions
	[PFFacebookUtils initializeFacebook];
	[PFFacebookUtils logInWithPermissions:nil block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
			if (!error) {
				NSLog(@"The user cancelled the Facebook login.");
			} else {
				NSLog(@"An error occurred: %@", error.localizedDescription);
			}
			// Callback - login failed
				[self fbDidLogin:NO];
		} else {
			if (user.isNew) {
				NSLog(@"User signed up and logged in through Facebook!");
			} else {
				NSLog(@"User logged in through Facebook!");
			}
			
			[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
				if (!error) {
					NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
					// Store the Facebook Id
					[[PFUser currentUser] setObject:me.id forKey:@"fbId"];
					[[PFUser currentUser] saveInBackground];
				}
				
				// Callback - login successful
				[self fbDidLogin:YES];
			}];
		}
	}];
}

- (void) fbDidLogin:(BOOL)loggedIn {
	// Re-enable the Login button
	[self.fbLoginButton setEnabled:YES];
	
	// Did we login successfully ?
	if (loggedIn) {
		// Seque to the Image Wall
		[self performSegueWithIdentifier:@"FinishedAllLogins" sender:self];
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
									message:@"Facebook Login failed. Please try again"
								   delegate:nil
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil] show];
	}
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
