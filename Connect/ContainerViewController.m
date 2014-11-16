//
//  ContainerViewController.m
//  Connect
//
//  Created by Liu on 11/14/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ContainerViewController.h"
#import "PageContentViewController.h"
#import "SettingsViewController.h"
#import "BroadcastingViewController.h"

static NSInteger const kMaxNumberOfViewControllers = 2;

@interface ContainerViewController ()

@property (nonatomic) UIPageViewController *pageController;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	
	self.pageController.dataSource = self;
	[self.pageController.view setFrame:[self.view bounds]];
	
	PageContentViewController *viewControllerObject = [self viewControllerAtIndex:1];
	
	[self.pageController setViewControllers:@[viewControllerObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	[self addChildViewController:self.pageController];
	[[self view] addSubview:[self.pageController view]];
	[self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	NSInteger pageIndex = ((PageContentViewController *)viewController).pageIndex;
	if (pageIndex == 0) {
		return nil;
	} else {
		return [self viewControllerAtIndex:pageIndex - 1];
	}
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	NSInteger pageIndex = ((PageContentViewController *)viewController).pageIndex;
	++pageIndex;
	if (pageIndex == kMaxNumberOfViewControllers) {
		return nil;
	} else {
		return [self viewControllerAtIndex:pageIndex];
	}
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
	if (index == 0) {
		SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
		settingsViewController.pageIndex = 0;
		return settingsViewController;
	}
	if (index == 1) {
		BroadcastingViewController *broadcastingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BroadcastingViewController"];
		broadcastingViewController.pageIndex = 1;
		return broadcastingViewController;
	}
	return nil;
}

@end
