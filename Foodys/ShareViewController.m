//
//  ShareViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ShareViewController.h"
#import "RestaurantViewController.h"
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
@property int averagedRatingHolder;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFObject *reviewedRestaurant;

@property (strong, nonatomic) NSMutableArray *friendsToRecommendTo;
@property (strong, nonatomic) IBOutlet UIButton *getRestaurantInfoButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

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
    
    self.sliderIntValue = 50;
    
    NSLog(@"%@",self.chosenRestaurantDictionary);
    
    self.friendsToRecommendTo = [NSMutableArray new];
    
    self.doneButton.layer.cornerRadius=4.0f;
    self.doneButton.layer.masksToBounds=YES;
    self.doneButton.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.cameForFriend)
    {
        self.chooseFriendToWriteView.alpha = 1.0;
        [UIView animateWithDuration:0.5 animations:^{
                self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        }];
        self.chooseFriendsDoneButton.enabled = YES;
        
        [self.doneButton setTitle:@"Send Recommendation" forState:UIControlStateNormal];
    }
    else
    {
        self.chooseFriendToWriteView.alpha = 0.0;
        self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.0];
        self.chooseFriendsDoneButton.enabled = NO;
        
        [self.doneButton setTitle:@"Post Review" forState:UIControlStateNormal];

    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    NSLog(@"yea");
//    if (self.cameForFriend)
//    {
//        NSLog(@"ra %hhd",self.cameForFriend);
//
//        [UIView animateWithDuration:0.5
//                              delay:0.0
//                            options: UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//                             self.chooseFriendToWriteView.frame = CGRectMake(0, 64, 320, 514);
//                             self.chooseFriendsDoneButton.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
//                         }
//                         completion:^(BOOL finished){
//                             self.chooseFriendsDoneButton.enabled = YES;
//                         }];
//    }
//}

-(void)setUpBasicElementsForThisView
{
    self.navigationItem.title = self.chosenRestaurantDictionary[@"name"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayDate = [NSDate date];
    NSString *todayString = [dateFormat stringFromDate:todayDate];
    
    self.dateLabel.text = [NSString stringWithFormat:@"%@",todayString];
    if (self.chosenRestaurantDictionary)
    {
        if (self.chosenRestaurantDictionary[@"street_address"]!= (id)[NSNull null] && ![self.chosenRestaurantDictionary[@"region"] isEqualToString:@"_"])
        {
            self.subjectTextField.text = [NSString stringWithFormat:@"%@ on %@",self.chosenRestaurantDictionary[@"name"],self.chosenRestaurantDictionary[@"street_address"]];
        }
        else
        {
            self.subjectTextField.text = [NSString stringWithFormat:@"%@",self.chosenRestaurantDictionary[@"name"]];
        }
    };
    
    if (self.cameForFriend) {
        [self.recommendToFriendsButton.titleLabel setTextAlignment: NSTextAlignmentCenter];
        self.recommendToFriendsButton.enabled = YES;
        self.recommendToFriendsButton.alpha = 1.0;
    }
    else
    {
        self.recommendToFriendsButton.enabled = NO;
        self.recommendToFriendsButton.alpha = 0.0;
    }
    
    if (self.cameFromProfileRecommendations)
    {
        self.subjectTextField.enabled = NO;
        self.myTextView.text = self.chosenRestaurantRecommendationObject[@"body"];
        [self.myTextView setUserInteractionEnabled:NO];
        self.mySlider.value = [self.chosenRestaurantRecommendationObject[@"rating"] floatValue];
        self.sliderScoreLabel.text = [NSString stringWithFormat:@"%@",self.chosenRestaurantRecommendationObject[@"rating"]];
        self.mySlider.enabled = NO;
        self.getRestaurantInfoButton.alpha = 1.0;
        self.getRestaurantInfoButton.enabled = YES;
        self.wouldGoAgainYesNoLabel.text = self.chosenRestaurantRecommendationObject[@"wouldGoAgain"];
        if ([self.wouldGoAgainYesNoLabel.text isEqualToString:@"YES"]) {
            self.wouldGoAgainYesNoLabel.textColor = [UIColor greenColor];
        }
        else
        {
            self.wouldGoAgainYesNoLabel.textColor = [UIColor redColor];
        };
        // disable done button
    }
    else
    {
        self.getRestaurantInfoButton.alpha = 0.0;
        self.getRestaurantInfoButton.enabled = NO;
    }
    
    
    [self refreshRatingLabel];
}

#pragma mark - refreshing the rating label methods

-(void)refreshRatingLabel
{
    if (self.chosenRestaurantDictionary) {
        PFQuery *reviewedRestaurantQuery = [PFQuery queryWithClassName:@"ReviewedRestaurant"];
        [reviewedRestaurantQuery whereKey:@"name" equalTo:self.chosenRestaurantDictionary[@"name"]];
        
        [reviewedRestaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             self.cumulativeRestaurantRatingLabel.text = [NSString stringWithFormat:@"%@%%",self.reviewedRestaurant[@"rating"]];
         }];
    }
    else
    {
        self.cumulativeRestaurantRatingLabel.text = [NSString stringWithFormat:@"%@%%",self.reviewedRestaurant[@"rating"]];
    }
    
    [self cumulativeRestaurantRatingsLabelSetUp];
}

-(void)cumulativeRestaurantRatingsLabelSetUp
{
    // the blank text length is 6 by default, 7 with a percent sign
    if (self.cumulativeRestaurantRatingLabel.text.length == 0)
    {
        self.cumulativeRestaurantRatingsTextView.alpha = 0.0;
        self.cumulativeRestaurantRatingLabel.alpha = 0.0;
    }
    else
    {
        self.cumulativeRestaurantRatingsTextView.alpha = 1.0;
        self.cumulativeRestaurantRatingLabel.alpha = 1.0;
    }
}


#pragma mark - table view delegate methods

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


// add friends to send your recommendation to
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [(UITableView *)tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.friendsToRecommendTo addObject: self.currentUser[@"friends"][indexPath.row]];
    
    [self.myTableView reloadData];
    selectedCell.showsReorderControl = YES;
}

#pragma mark - button methods


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
    
    if (self.sliderIntValue > 25 && self.sliderIntValue < 75)
    {
        [self.mySlider setThumbImage:[UIImage imageNamed:@"meh_icon"] forState:UIControlStateNormal];
    }
    else if (self.sliderIntValue > 74)
    {
        [self.mySlider setThumbImage:[UIImage imageNamed:@"smiley_icon"] forState:UIControlStateNormal];
    }
    else if (self.sliderIntValue < 26)
    {
        [self.mySlider setThumbImage:[UIImage imageNamed:@"frowny_icon"] forState:UIControlStateNormal];
    }
    
    
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

#pragma mark - choose friends to recommend to methods

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
    
    self.recommendation = [PFObject objectWithClassName:@"Recommendation"];
    for (PFUser *receiver in self.friendsToRecommendTo)
    {
        [self.recommendation addUniqueObject:receiver forKey:@"receivers"];
    }
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    if (self.cameForFriend)
    {
        self.recommendation[@"name"] = self.chosenRestaurantDictionary[@"name"];
        self.recommendation[@"author"] = self.currentUser[@"username"];
        self.recommendation[@"avatar"] = self.currentUser[@"avatar"];
        self.recommendation[@"authorObjectId"] = self.currentUser.objectId;
        self.recommendation[@"date"] = [formatter dateFromString:self.dateLabel.text];
        self.recommendation[@"body"] = self.myTextView.text;
        int rating = [self.sliderScoreLabel.text integerValue];
        self.recommendation[@"rating"] = @(rating);
        self.recommendation[@"restaurantDictionary"] = self.chosenRestaurantDictionary;
        
        [self.recommendation saveInBackground];
    }
    else
    {
        PFObject *publicPost = [PFObject objectWithClassName:@"PublicPost"];
        publicPost[@"author"] = self.currentUser[@"username"];
        publicPost[@"authorObjectId"] = self.currentUser.objectId;
        publicPost[@"avatar"] = self.currentUser[@"avatar"];
        publicPost[@"date"] = [formatter dateFromString:self.dateLabel.text];
        publicPost[@"title"] = self.chosenRestaurantDictionary[@"name"];
        publicPost[@"body"] = self.myTextView.text;
        int rating = [self.sliderScoreLabel.text integerValue];
        publicPost[@"rating"] = @(rating);
        publicPost[@"restaurantDictionary"] = self.chosenRestaurantDictionary;
        
        [publicPost saveInBackground];
        
        [self.currentUser addUniqueObject:publicPost forKey:@"postsMade"];
        [self.currentUser saveInBackground];
    }
    
    PFQuery *reviewedRestaurantQuery = [PFQuery queryWithClassName:@"ReviewedRestaurant"];
    [reviewedRestaurantQuery whereKey:@"name" equalTo:self.chosenRestaurantDictionary[@"name"]];
    
    [reviewedRestaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.firstObject)
         {
             self.reviewedRestaurant = objects.firstObject;
         }
         else
         {
             self.reviewedRestaurant = [PFObject objectWithClassName:@"ReviewedRestaurant"];
         }
         
         self.reviewedRestaurant[@"name"] = self.chosenRestaurantDictionary[@"name"];
         
         if (self.cumulativeRestaurantRatingLabel.text.length == 0)
         {
             if (self.reviewedRestaurant[@"ratingCounter"] == nil) {
                 self.reviewedRestaurant[@"ratingCounter"] = @(1);
                 self.reviewedRestaurant[@"rating"] = @(self.sliderIntValue);
             }
         }
         else
         {
             int addingToTheRatingCounter = [self.reviewedRestaurant[@"ratingCounter"] intValue];
             addingToTheRatingCounter += 1;
             self.reviewedRestaurant[@"ratingCounter"] = @(addingToTheRatingCounter);
             
             self.averagedRatingHolder = [self.cumulativeRestaurantRatingLabel.text integerValue];
             self.reviewedRestaurant[@"rating"] = @((self.averagedRatingHolder*([self.reviewedRestaurant[@"ratingCounter"] intValue]-1) + self.sliderIntValue)/[self.reviewedRestaurant[@"ratingCounter"] intValue]);
         }
         
         [self refreshRatingLabel];
         [self.reviewedRestaurant saveInBackground];
     }];
    
    [self.myTextView endEditing:YES];
    [self performSegueWithIdentifier:@"unwindDoneSharingSegue" sender:self];
};

@end
