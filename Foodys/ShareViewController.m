//
//  ShareViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/16/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ShareViewController.h"
#import <Parse/Parse.h>

@interface ShareViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) IBOutlet UIView *chooseFriendToWriteView;
@property (strong, nonatomic) IBOutlet UITableView *chooseFriendToWriteTableView;
@property (strong, nonatomic) IBOutlet UIButton *wouldGoAgainButton;
@property (strong, nonatomic) IBOutlet UILabel *wouldGoAgainYesNoLabel;
@property BOOL yesNoBool;
@property (strong, nonatomic) IBOutlet UILabel *sliderScoreLabel;
@property (strong, nonatomic) IBOutlet UISlider *mySlider;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.myTextView.layer.cornerRadius=8.0f;
    self.myTextView.layer.masksToBounds=YES;
    self.myTextView.layer.borderColor=[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.myTextView.layer.borderWidth= 1.0f;

    self.currentUser = [PFUser currentUser];
    self.yesNoBool = 0;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *todayDate = [NSDate date];
    NSString *todayString = [dateFormat stringFromDate:todayDate];

    self.dateLabel.text = [NSString stringWithFormat:@"%@",todayString];
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
    int discreteValue = roundl([sender value]);
    self.sliderScoreLabel.text = [NSString stringWithFormat:@"%d", discreteValue];
}

- (IBAction)onSegmentedControlPressed:(id)sender
{
    if (self.mySegmentedControl.selectedSegmentIndex == 0)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.chooseFriendToWriteView.frame = CGRectMake(0, 578, 320, 514);
                         }
                         completion:^(BOOL finished){
                         }];
    }
    else if (self.mySegmentedControl.selectedSegmentIndex == 1)
    {
        self.chooseFriendToWriteView.frame = CGRectMake(0, 578, 320, 514);

        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.chooseFriendToWriteView.frame = CGRectMake(0, 64, 320, 514);
                         }
                         completion:^(BOOL finished){
                         }];    }
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    PFObject *publicPost = [PFObject objectWithClassName:@"PublicPost"];
    publicPost[@"author"] = self.currentUser[@"username"];
    publicPost[@"date"] = [formatter dateFromString:self.dateLabel.text];
    publicPost[@"title"] = self.myTextView.text;
    publicPost[@"body"] = self.subjectTextField.text;
    publicPost[@"rating"] = self.sliderScoreLabel.text;
    publicPost[@"wouldGoAgain"] = self.wouldGoAgainYesNoLabel.text;
    [publicPost saveInBackground];
}

@end
