//
//  AddFriendButton.h
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddFriendButton : UIButton
@property (strong, nonatomic) PFUser *friendUser;

@end
