//
//  FriendsViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UIViewController
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSArray *userFriendsArray;

@end
