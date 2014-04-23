//
//  ShareViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ShareViewController : UIViewController
@property (strong, nonatomic) NSDictionary *chosenRestaurantDictionary;
@property (strong, nonatomic) PFObject *recommendation;
@property BOOL cameForFriend;
@property BOOL cameToPost;
@property BOOL cameFromProfileRecommendations;
@property (strong, nonatomic) PFObject *chosenRestaurantRecommendationObject;

@end
