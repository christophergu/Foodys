//
//  RestaurantMenuTableViewCell.m
//  Foodys
//
//  Created by Christopher Gu on 4/18/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "RestaurantMenuTableViewCell.h"

@implementation RestaurantMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
