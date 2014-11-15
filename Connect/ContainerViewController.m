//
//  ContainerViewController.m
//  Connect
//
//  Created by Liu on 11/14/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "ContainerViewController.h"
#import "PageContentViewController.h"
#import "CenterPageContentViewController.h"

static NSInteger const kMaxNumberOfViewControllers = 3;

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
	if (index == 1) {
		CenterPageContentViewController *centerPageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CenterPageViewController"];
		centerPageContentViewController.pageIndex = 1;
		return centerPageContentViewController;
	}
	
	PageContentViewController *pageContentViewController = [[PageContentViewController alloc] init];
	pageContentViewController.pageIndex = index;
	
	UILabel *label = [[UILabel alloc] initWithFrame:pageContentViewController.view.bounds];
	label.backgroundColor = [UIColor whiteColor];
	label.text = [NSString stringWithFormat:@"View controller %lu", index];
	label.textAlignment = NSTextAlignmentCenter;
	[pageContentViewController.view addSubview:label];
	
	return pageContentViewController;
}

- (void)displayModalViewController {
	PageContentViewController *modalViewController = [[PageContentViewController alloc] init];
	UILabel *label = [[UILabel alloc] initWithFrame:modalViewController.view.bounds];
	label.backgroundColor = [UIColor greenColor];
	label.text = @"Modal view controller";
	label.textAlignment = NSTextAlignmentCenter;
	[modalViewController.view addSubview:label];
	[self.navigationController presentViewController:modalViewController animated:YES completion:nil];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
	return kMaxNumberOfViewControllers;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
	return 1;
}

@end
