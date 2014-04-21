//
//  ShowMoreResultsViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ShowMoreResultsViewController : UIViewController

@property (strong, nonatomic) NSArray *searchResultsArray;
@property (strong, nonatomic) CLLocation* currentLocation;

@property BOOL cameFromAdvancedSearch;

@end
