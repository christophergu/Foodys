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
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.myTextView.layer.cornerRadius=8.0f;
    self.myTextView.layer.masksToBounds=YES;
    self.myTextView.layer.borderColor=[[UIColor redColor]CGColor];
    self.myTextView.layer.borderWidth= 1.0f;

    self.currentUser = [PFUser currentUser];
    NSLog(@"%@",self.currentUser[@"friends"]);
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
@end
