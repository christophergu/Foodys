//
//  ShareViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ShareViewController.h"
#import <Parse/Parse.h>

@interface ShareViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UIButton *wouldGoAgainButton;
@property (strong, nonatomic) IBOutlet UILabel *wouldGoAgainYesNoLabel;
@property BOOL yesNoBool;
@property (strong, nonatomic) IBOutlet UILabel *sliderScoreLabel;
@property (strong, nonatomic) IBOutlet UISlider *mySlider;
@property int sliderIntValue;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *recommendToFriendsButton;
@property (strong, nonatomic) IBOutlet UIView *chooseFriendToWriteView;
@property (strong, nonatomic) IBOutlet UIButton *chooseFriendsToWriteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chooseFriendsDoneButton;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UILabel *cumulativeRestaurantRatingLabel;
@property (strong, nonatomic) IBOutlet UITextView *cumulativeRestaurantRatingsTextView;

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setUpBasicElementsForThisView];
    self.currentUser = [PFUser currentUser];
    self.yesNoBool = 0;
    
    [self cumulativeRestaurantRatingsLabelSetUp];
    
    // hiding the choose friends button
    self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    self.chooseFriendsDoneButton.enabled = NO;
    
//    int ya =[@"100" integerValue];
//    
//    NSLog(@"%d",ya);
}

-(void)setUpBasicElementsForThisView
{
    self.myTextView.layer.cornerRadius=8.0f;
    self.myTextView.layer.masksToBounds=YES;
    self.myTextView.layer.borderColor=[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.myTextView.layer.borderWidth= 1.0f;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayDate = [NSDate date];
    NSString *todayString = [dateFormat stringFromDate:todayDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@",todayString];
    if (self.chosenRestaurantDictionary)
    {
        self.subjectTextField.text = [NSString stringWithFormat:@"%@ on %@",self.chosenRestaurantDictionary[@"name"],self.chosenRestaurantDictionary[@"street_address"]];
    };
    
    [self.recommendToFriendsButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
}

-(void)cumulativeRestaurantRatingsLabelSetUp
{
    if ([self.cumulativeRestaurantRatingLabel.text isEqualToString:@""])
    {
        self.cumulativeRestaurantRatingsTextView.alpha = 0.0;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentUser[@"friends"] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendToChooseCellReuseID"];
    
    NSString *tempStringBeforeCutting = [NSString stringWithFormat:@"%@",self.currentUser[@"friends"][indexPath.row]];
    NSArray* cutStringArray = [tempStringBeforeCutting componentsSeparatedByString: @":"];
    
    PFQuery *friendToDisplayQuery = [PFUser query];
    [friendToDisplayQuery whereKey:@"objectId" equalTo:cutStringArray[1]];
    NSArray *arrayHolder = [friendToDisplayQuery findObjects];
    
    cell.textLabel.text = arrayHolder.firstObject[@"username"];
    return cell;
}

- (IBAction)onEndEditingAllButtonPressed:(id)sender
{
    [self.myTextView endEditing:YES];
    [self.subjectTextField endEditing:YES];
}

- (IBAction)onWouldGoAgainButtonPressed:(id)sender
{
    self.yesNoBool = !self.yesNoBool;
    if (self.yesNoBool) {
        self.wouldGoAgainYesNoLabel.text = @"YES";
        self.wouldGoAgainYesNoLabel.textColor = [UIColor greenColor];
    }
    else
    {
        self.wouldGoAgainYesNoLabel.text = @"NO";
        self.wouldGoAgainYesNoLabel.textColor = [UIColor redColor];
    }
}

- (IBAction)onMySliderChanged:(UISlider *)sender
{
    self.sliderIntValue = roundl([sender value]);
    self.sliderScoreLabel.text = [NSString stringWithFormat:@"%d", self.sliderIntValue];
}

- (IBAction)onChooseFriendsToWriteButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.chooseFriendToWriteView.frame = CGRectMake(0, 64, 320, 514);
                         self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                     }
                     completion:^(BOOL finished){
                         self.chooseFriendsDoneButton.enabled = YES;
                     }];
}

- (IBAction)onChooseFriendsButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.chooseFriendToWriteView.frame = CGRectMake(0, 529, 320, 514);
                         self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.0];
                     }
                     completion:^(BOOL finished){
                         self.chooseFriendsDoneButton.enabled = NO;
                     }];
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    PFObject *publicPost = [PFObject objectWithClassName:@"PublicPost"];
    publicPost[@"author"] = self.currentUser[@"username"];
    publicPost[@"authorObjectId"] = self.currentUser.objectId;
    publicPost[@"date"] = [formatter dateFromString:self.dateLabel.text];
    publicPost[@"title"] = self.subjectTextField.text;
    publicPost[@"body"] = self.myTextView.text;
    int rating = [self.sliderScoreLabel.text integerValue];
    publicPost[@"rating"] = @(rating);
    publicPost[@"wouldGoAgain"] = self.wouldGoAgainYesNoLabel.text;
    [publicPost saveInBackground];
    
    [self.currentUser addUniqueObject:publicPost forKey:@"postsMade"];
    [self.currentUser saveInBackground];
    
    
    
    
    PFObject *reviewedRestaurant = [PFObject objectWithClassName:@"ReviewedRestaurant"];
    reviewedRestaurant[@"name"] = self.subjectTextField.text;
    if ([self.cumulativeRestaurantRatingLabel.text isEqualToString:@""])
    {
        NSLog(@"cumulative rating is nil");
        if (reviewedRestaurant[@"ratingCounter"] == nil) {
            reviewedRestaurant[@"ratingCounter"] = @(1);
            reviewedRestaurant[@"rating"] = @(self.sliderIntValue);
        }
    }
    else
    {
        int addingToTheRatingCounter = [reviewedRestaurant[@"ratingCounter"] intValue];
        addingToTheRatingCounter += 1;
        reviewedRestaurant[@"ratingCounter"] =  @(addingToTheRatingCounter);
    }
    int averagedRatingHolder = [self.cumulativeRestaurantRatingLabel.text integerValue];
    reviewedRestaurant[@"rating"] = @((averagedRatingHolder + self.sliderIntValue)/[reviewedRestaurant[@"ratingCounter"] intValue]);
    
    [reviewedRestaurant saveInBackground];
}

@end
