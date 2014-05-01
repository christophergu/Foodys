//
//  AllUserBrowseViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AllUserBrowseViewController.h"
#import "AddFriendsSureViewController.h"
#import "CollectionViewCellWithImageThatFlips.h"
#import <Parse/Parse.h>

@interface AllUserBrowseViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) PFUser *currentFriendUser;
@property (strong, nonatomic) PFUser *currentFriendUserToSend;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *friendsNamesArray;
@property (strong, nonatomic) NSMutableArray *pendingFriendsArray;


@end

@implementation AllUserBrowseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friendsNamesArray = [NSMutableArray new];
    
    // because this current user line is too slow for this purpose when its in view will appear
    self.currentUser = [PFUser currentUser];
    
    PFQuery *getFriendsNamesQuery = [PFUser query];
    [getFriendsNamesQuery whereKey:@"username" equalTo:self.currentUser[@"username"]];
    [getFriendsNamesQuery includeKey:@"friends"];
    
    [getFriendsNamesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        NSArray *friendsArrayFromQuery = objects.firstObject[@"friends"];
        for (PFUser *friend in friendsArrayFromQuery)
        {
            [self.friendsNamesArray addObject: friend[@"username"]];
        }
    }];
    
    self.pendingFriendsArray = [NSMutableArray new];
    
    self.myCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.currentUser = [PFUser currentUser];
    
    NSLog(@"aaa %@",self.friendsNamesArray);
    if ([self.friendsNamesArray count] == 0)
    {
        PFQuery *getFriendsNamesQuery = [PFUser query];
        [getFriendsNamesQuery whereKey:@"username" equalTo:self.currentUser[@"username"]];
        [getFriendsNamesQuery includeKey:@"friends"];
        
        [getFriendsNamesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             NSArray *friendsArrayFromQuery = objects.firstObject[@"friends"];
             for (PFUser *friend in friendsArrayFromQuery)
             {
                 [self.friendsNamesArray addObject: friend[@"username"]];
             }
             [self.myCollectionView reloadData];
         }];
    }
    
    PFQuery *friendRequestsQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [friendRequestsQuery includeKey:@"requestee"];
    [friendRequestsQuery includeKey:@"requestor"];
    
    [friendRequestsQuery whereKey:@"requestor" equalTo:self.currentUser];
    [friendRequestsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *friendRequest in objects)
        {
            [self.pendingFriendsArray addObject: friendRequest[@"requestee"][@"username"]];
        }
        [self.myCollectionView reloadData];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImageThatFlips *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    
    self.currentFriendUser = self.userArray[indexPath.row];

    cell.usernameLabel.text = self.currentFriendUser[@"username"];
    cell.rankLabel.text = self.currentFriendUser[@"rank"];
    
    if ([cell.usernameLabel.text isEqualToString:self.currentUser[@"username"]])
    {
        cell.addFriendButton.hidden = YES;
        cell.addFriendButton.enabled = NO;
        cell.usernameLabel.text = @"YOU";
        cell.greenHiderView.alpha = 0.0;
    }
    else if ([self.pendingFriendsArray containsObject:self.currentFriendUser[@"username"]])
    {
        cell.addFriendButton.hidden = YES;
        cell.addFriendButton.enabled = NO;
        cell.friendRequestPendingLabel.hidden = NO;
        cell.greenHiderView.alpha = 0.75;
    }
    else
    {
        cell.addFriendButton.hidden = NO;
        cell.addFriendButton.enabled = YES;
        cell.addFriendButton.friendUser = self.userArray[indexPath.row];
        cell.greenHiderView.alpha = 0.75;
    }
    
    for (NSString *usernameString in self.friendsNamesArray)
    {
        NSLog(@"usernamestring %@",usernameString);
        
        if ([cell.usernameLabel.text isEqualToString:usernameString])
        {
            cell.addFriendButton.hidden = YES;
            cell.addFriendButton.enabled = NO;
            cell.greenHiderView.alpha = 0.0;
        }
    }
    

    [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
        }
    }];
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
}

- (IBAction)onAddButtonPressed:(AddFriendButton *)sender
{
    self.currentFriendUserToSend = sender.friendUser;
    [self performSegueWithIdentifier:@"AddFriendSureSegue" sender:self];
    
//    NSLog(@"%@",sender.friendUser);
//    PFUser *currentUser = [PFUser currentUser];
//
//    PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
//    [friendRequest setObject:currentUser forKey:@"requestor"];
//    [friendRequest setObject:sender.friendUser forKey:@"requestee"];
//    
//    UIAlertView *friendAddedAlert = [[UIAlertView alloc] initWithTitle:@"Friend Request Sent!"
//                                                          message:[NSString stringWithFormat:@"You invited %@ to be your friend!",sender.friendUser[@"username"]]
//                                                         delegate:self
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//    [friendAddedAlert show];
//    
//    [friendRequest saveInBackground];
}

- (IBAction)unwindAfterFriendSure:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddFriendsSureViewController *afsvc = segue.destinationViewController;
    afsvc.friendToConfirm = self.currentFriendUserToSend;
}

@end
