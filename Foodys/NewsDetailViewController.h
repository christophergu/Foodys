//
//  NewsDetailViewController.h
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NewsDetailViewController : UIViewController
@property (strong, nonatomic) PFObject *currentPost;

@end
