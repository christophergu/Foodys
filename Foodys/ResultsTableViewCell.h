//
//  ResultsTableViewCell.h
//  Foodys
//
//  Created by Matt Brax on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *restaurantTitle;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end
