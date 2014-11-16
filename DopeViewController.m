//
//  DopeViewController.m
//  Connect
//
//  Created by Edward Yun on 11/16/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import "DopeViewController.h"

@interface DopeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *facebookImage;
@property (weak, nonatomic) IBOutlet UIImageView *twitterImage;
@property (weak, nonatomic) IBOutlet UIImageView *yoImage;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImage;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *yoButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (nonatomic, assign) BOOL fbAvail;
@property (nonatomic, assign) BOOL twAvail;
@property (nonatomic, assign) BOOL yoAvail;
@property (nonatomic, assign) BOOL phAvail;


@end

@implementation DopeViewController
@synthesize realNameLabel;

- (IBAction)facebookButtonPressed:(id)sender {
    if(self.facebookImage.alpha == 0.5){
        self.facebookImage.alpha = 1.0;
    }else{
        self.facebookImage.alpha = 0.5;
    }
}
- (IBAction)twitterButtonPressed:(id)sender {
    if (self.twitterImage.alpha == 0.5){
        self.twitterImage.alpha = 1.0;
    }else{
        self.twitterImage.alpha = 0.5;
    }
}
- (IBAction)yoButtonPressed:(id)sender {
    if(self.yoImage.alpha == 0.5){
        self.yoImage.alpha = 1.0;
    }else{
        self.yoImage.alpha = 0.5;
    }
}
- (IBAction)phoneButtonPressed:(id)sender {
    if(self.phoneImage.alpha == 0.5){
        self.phoneImage.alpha = 1.0;
    }else{
        self.phoneImage.alpha = 0.5;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad]; 
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *realName = [defaults objectForKey:@"realname"];
    NSString *fbUserName = [defaults objectForKey:@"realname"];
    NSString *phoneNumber = [defaults objectForKey:@"phonenumber"];
    NSString *twitterHandle = [defaults objectForKey:@"twitterID"];
    NSString *yoID = [defaults objectForKey:@"YoID"];
    realNameLabel.text = realName;
    NSString *strurl = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture?width=9999", fbUserName];
    NSURL *url=[NSURL URLWithString:strurl];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *profilePic = [UIImage imageWithData:imageData];
    _profilePicture.image = profilePic;
    if(fbUserName == nil){
        _fbAvail = NO;
    }
    if(twitterHandle == nil){
        _twAvail = NO;
    }
    if(yoID == nil){
        _yoAvail = NO;
    }
    if(phoneNumber == nil){
        
        _phAvail = NO;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    realNameLabel = nil;
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
