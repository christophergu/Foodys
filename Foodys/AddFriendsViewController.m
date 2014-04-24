//
//  AddFriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/23/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AddFriendsViewController.h"
#import <Parse/Parse.h>

@interface AddFriendsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) PFUser *potentialFriend;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation AddFriendsViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestorsToAddArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCellReuseID"];
    
    self.potentialFriend = self.requestorsToAddArray[indexPath.row][@"requestor"];
    cell.textLabel.text = self.potentialFriend[@"username"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [(UITableView *)tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.selectedFriends addObject: self.requestorsToAddArray[indexPath.row][@"requestor"]];
    
    [self.myTableView reloadData];
    selectedCell.showsReorderControl = YES;
}
//
//- (IBAction)onAddSelectedFriendsButtonPressed:(id)sender
//{
//    for (PFUser *friend in self.selectedFriends)
//    {
//        [self.currentUser addUniqueObject:friend forKey:@"friends"];
//        [self.currentUser saveInBackground];
//        
//        [self.selectedFriends removeObject:friend];
//        
//        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
//        [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
//        [friendRequestQuery whereKey:@"requestor" equalTo:friend];
//        
//        [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//         {
//             [objects.firstObject deleteInBackground];
//             [self.myTableView reloadData];
//         }];
//    }
//}
//
//- (IBAction)onDeleteSelectedFriendsButtonPressed:(id)sender
//{
//    for (PFUser *friend in self.selectedFriends)
//    {
//        [self.selectedFriends removeObject:friend];
//        
//        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
//        [friendRequestQuery whereKey:@"requestee" equalTo:self.currentUser];
//        [friendRequestQuery whereKey:@"requestor" equalTo:friend];
//
//        [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//         {
//             [objects.firstObject deleteInBackground];
//             [self.myTableView reloadData];
//         }];
//    }
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.selectedFriends = [NSMutableArray new];
    self.currentUser = [PFUser currentUser];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.myTableView reloadData];
}

@end
