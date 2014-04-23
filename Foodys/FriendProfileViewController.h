//
//  FriendProfileViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *currentFriendUser;
@property (strong, nonatomic) NSString *rankingStringForLabel;

@end
