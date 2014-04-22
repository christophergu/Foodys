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

@end

@implementation NewsDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.myTextView.layer.cornerRadius=8.0f;
    self.myTextView.layer.masksToBounds=YES;
    self.myTextView.layer.borderColor=[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.myTextView.layer.borderWidth= 1.0f;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *postDate = self.currentPost[@"date"];
    NSString *postString = [dateFormat stringFromDate:postDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@",postString];
    self.restaurantTitle.text = self.currentPost[@"title"];
    self.myTextView.text = self.currentPost[@"body"];
    self.yesNoLabel.text = self.currentPost[@"wouldGoAgain"];
    self.averageRating.text = [NSString stringWithFormat:@"%@%%",self.currentPost[@"rating"]];//[NSNumber numberWithInt:@"%i,rating"];
    
    
    NSLog(@"%@",self.currentPost[@"rating"]);
    
    if ([self.yesNoLabel.text isEqualToString:@"YES"])
    {
//        self.yesNoLabel.text = [NSString stringWithFormat:@"YES"];
        self.yesNoLabel.textColor = [UIColor greenColor];
    }
    else if ([self.yesNoLabel.text isEqualToString:@"NO"])
    {
        self.yesNoLabel.textColor = [UIColor redColor];
    }
    
}



@end