//
//  FriendsFriendsViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsFriendsViewController : UIViewController
@property (strong, nonatomic) NSArray *friendsFriendsArray;
@property (strong, nonatomic) PFUser *currentFriendUser;

@end
