//
//  FinishViewController.h
//  Connect
//
//  Created by Ethan Yu on 11/16/14.
//  Copyright (c) 2014 Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinishViewController : UITableViewController

@property (nonatomic, copy) NSMutableDictionary *confirmedServicesWithInfo;
@property (nonatomic) BOOL needsReceive;

@end
