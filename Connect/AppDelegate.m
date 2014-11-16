//
//  AppDelegate.m
//  Connect
//
//  Created by Liu on 11/14/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "YO.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:@"7Wljpzbqeo8MV30XjHCMXPvETdKET1JkYG0hjRBo"
                  clientKey:@"Z4RtU3Bre5HSpAzCmz038AVR6JT2iIs4VMPeZZlS"];
	[PFFacebookUtils initializeFacebook];
    [PFTwitterUtils initializeWithConsumerKey:@"krLAz34Uu3f9g2PgHj5DC5CZl"
                            consumerSecret:@"1CkFkQpRdHpZMJDEKUMcBg0lrY59kI0DlyjQODS6x2GntLCU8e"];
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
	
	NSString *UUID = [[NSUUID UUID] UUIDString];
	[[NSUserDefaults standardUserDefaults] setObject:UUID forKey:@"UUID"];
	
	NSString *yoKey = @"6fc93444-9e70-4e61-91f2-1fac50dcc3f8";
	[YO startWithAPIKey:yoKey];
	
	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
	
	if(![[NSUserDefaults standardUserDefaults] boolForKey:@"launchedBefore"]){
		NSLog(@"not launched before");
		UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FirstLaunchViewController"];
		self.window.rootViewController = viewController;
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"launchedBefore"];
	} else {
		NSLog(@"launched before");
		UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];
		self.window.rootViewController = viewController;
	}
	
	[self.window makeKeyAndVisible];
	
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
