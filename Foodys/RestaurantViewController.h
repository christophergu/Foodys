//
//  RestaurantViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantViewController : UIViewController
@property (strong, nonatomic) NSDictionary *chosenRestaurantDictionary;
@property NSString *searchTerm;
@property BOOL cameFromProfileFavorites;

@end
