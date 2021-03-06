//
//  FriendsFriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendsFriendsViewController.h"
#import "CollectionViewCellWithImageThatFlips.h"
#import <Parse/Parse.h>

@interface FriendsFriendsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *friendsNamesArray;

@end

@implementation FriendsFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    self.myCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:31/255.0f green:189/255.0f blue:195/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friendsFriendsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImageThatFlips *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    
    self.currentFriendUser = self.friendsFriendsArray[indexPath.row];
    
    cell.usernameLabel.text = self.currentFriendUser[@"username"];
    cell.rankLabel.text = self.currentFriendUser[@"rank"];
    
    [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
            cell.friendDetailImageView.alpha = 0.5;
            cell.friendDetailImageView.image = photo;
        }
    }];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImageThatFlips *cell = (CollectionViewCellWithImageThatFlips *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([cell.usernameLabel.text isEqualToString:self.currentUser[@"username"]])
    {
        cell.addFriendButton.hidden = YES;
        cell.addFriendButton.enabled = NO;
        cell.usernameLabel.text = @"YOU";
    }
    else
    {
        cell.addFriendButton.hidden = NO;
        cell.addFriendButton.enabled = YES;
        cell.addFriendButton.friendUser = self.friendsFriendsArray[indexPath.row];
    }
    
    for (NSString *usernameString in self.friendsNamesArray)
    {
        if ([cell.usernameLabel.text isEqualToString:usernameString])
        {
            cell.addFriendButton.hidden = YES;
            cell.addFriendButton.enabled = NO;
        }
    }
}

@end
