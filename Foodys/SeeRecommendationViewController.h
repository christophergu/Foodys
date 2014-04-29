//
//  SeeRecommendationViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SeeRecommendationViewController : UIViewController
@property (strong, nonatomic) NSDictionary *chosenRestaurantDictionary;
@property (strong, nonatomic) PFObject *chosenRestaurantRecommendationObject;

@end
