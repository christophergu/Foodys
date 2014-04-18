//
//  RestaurantMenuTableViewCell.h
//  Foodys
//
//  Created by Christopher Gu on 4/18/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantMenuTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
