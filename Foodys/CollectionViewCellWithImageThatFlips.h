//
//  CollectionViewCellWithImageThatFlips.h
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddFriendButton.h"

@interface CollectionViewCellWithImageThatFlips : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *friendImageView;
//@property BOOL flipped;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIImageView *friendDetailImageView;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet AddFriendButton *addFriendButton;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIView *greenHiderView;
@property (strong, nonatomic) IBOutlet UIImageView *circularFrameImageView;
@property (strong, nonatomic) IBOutlet UILabel *friendRequestPendingLabel;


@end
