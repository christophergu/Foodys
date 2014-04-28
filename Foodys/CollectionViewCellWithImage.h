//
//  CollectionViewCellWithImage.h
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCellWithImage : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *friendImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@end
