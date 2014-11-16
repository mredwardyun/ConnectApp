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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButton:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:self.yoTextField.text forKey:@"YoID"];
    [currentUser saveInBackground];
    [[NSUserDefaults standardUserDefaults] setObject:self.yoTextField.text forKey:@"YoID"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

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
