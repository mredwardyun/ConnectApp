//
//  MainPageContentViewController.m
//  Connect
//
//  Created by Ethan Yu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "MainPageContentViewController.h"
#import "FirstLaunchViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface MainPageContentViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSMutableArray *nearbyContacts;

@end

@implementation MainPageContentViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	if (![PFUser currentUser]) {
		FirstLaunchViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstLaunchViewController"];
		[self presentViewController:vc animated:YES completion:nil];
	}
	[self.nearbyContacts addObject:@"495096907298548"];
	[self.nearbyContacts addObject:@"10152985113324873"];
	
	self.collectionView.dataSource = self;
}

- (NSMutableArray *)nearbyContacts {
	if (!_nearbyContacts) {
		_nearbyContacts = [[NSMutableArray alloc] init];
	}
	return _nearbyContacts;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
	NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture", self.nearbyContacts[indexPath.row]];
	NSURL *url=[NSURL URLWithString:strurl];
	NSData *imageData = [NSData dataWithContentsOfURL:url];
	UIImage *profilePic = [UIImage imageWithData:imageData];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:profilePic];
	imageView.layer.cornerRadius = imageView.frame.size.width / 2;
	imageView.clipsToBounds = YES;
	imageView.frame = cell.bounds;
	[cell addSubview:imageView];
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 2;
}

@end
