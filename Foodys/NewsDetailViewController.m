//
//  NewsDetailViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "NewsDetailViewController.h"

@interface NewsDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UILabel *yesNoLabel;
@property (strong, nonatomic) IBOutlet UILabel *averageRating;
@property (strong, nonatomic) IBOutlet UILabel *restaurantTitle;
@property (strong, nonatomic) IBOutlet UILabel *reviewerNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.reviewerNameLabel.text = self.currentPost[@"author"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *postDate = self.currentPost[@"date"];
    NSString *postString = [dateFormat stringFromDate:postDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@",postString];
    self.restaurantTitle.text = self.currentPost[@"title"];
    self.myTextView.text = self.currentPost[@"body"];
    self.yesNoLabel.text = self.currentPost[@"wouldGoAgain"];
    self.averageRating.text = [NSString stringWithFormat:@"%@%%",self.currentPost[@"rating"]];//[NSNumber numberWithInt:@"%i,rating"];
    
    self.avatarImageView.clipsToBounds = YES;
    PFFile *userImageFile = self.currentPost[@"avatar"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.avatarImageView.image = [UIImage imageWithData:imageData];
        }
    }];
    
    NSLog(@"%@",self.currentPost[@"rating"]);
    
    if ([self.yesNoLabel.text isEqualToString:@"YES"])
    {
        self.yesNoLabel.textColor = [UIColor greenColor];
    }
    else if ([self.yesNoLabel.text isEqualToString:@"NO"])
    {
        self.yesNoLabel.textColor = [UIColor redColor];
    }
    
}



@end