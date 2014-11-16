//
//  YoViewController.m
//  Connect
//
//  Created by Liu on 11/15/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "YoViewController.h"
#import <Parse/Parse.h>

@interface YoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *yoTextField;

@end

@implementation YoViewController

- (IBAction)doneButton:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.yoTextField.text forKey:@"YoID"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
