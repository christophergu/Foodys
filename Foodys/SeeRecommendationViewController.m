//
//  SeeRecommendationViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/28/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SeeRecommendationViewController.h"
#import "RestaurantViewController.h"

@interface SeeRecommendationViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantRatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *reviewerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UITextView *recommendationBodyTextField;
@property (strong, nonatomic) IBOutlet UIImageView *ratingFaceImageView;
@property (strong, nonatomic) IBOutlet UILabel *restaurantTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *restaurantAddressLabel;


@end

@implementation SeeRecommendationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.avatarImageView.clipsToBounds = YES;
    PFFile *userImageFile = self.chosenRestaurantRecommendationObject[@"avatar"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.avatarImageView.image = [UIImage imageWithData:imageData];
        }
    }];
    self.restaurantRatingLabel.text = [NSString stringWithFormat:@"%@%%",self.chosenRestaurantRecommendationObject[@"rating"]];
    self.reviewerNameLabel.text = self.chosenRestaurantRecommendationObject[@"author"];
    self.restaurantTitleLabel.text = self.chosenRestaurantRecommendationObject[@"restaurantDictionary"][@"name"];
    self.restaurantAddressLabel.text = self.chosenRestaurantRecommendationObject[@"restaurantDictionary"][@"street_address"];
    self.recommendationBodyTextField.text = self.chosenRestaurantRecommendationObject[@"body"];
    
    if ([self.chosenRestaurantRecommendationObject[@"rating"] intValue] > 74)
    {
        self.ratingFaceImageView.image = [UIImage imageNamed:@"smiley_icon"];
    }
    else if ([self.chosenRestaurantRecommendationObject[@"rating"] intValue] < 26)
    {
        self.ratingFaceImageView.image = [UIImage imageNamed:@"frowny_icon"];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *postDate = self.chosenRestaurantRecommendationObject[@"date"];
    NSString *postString = [dateFormat stringFromDate:postDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@",postString];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RestaurantViewController *rvc = segue.destinationViewController;
    rvc.chosenRestaurantDictionary = self.chosenRestaurantRecommendationObject[@"restaurantDictionary"];
}

@end
