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

@end

@implementation FriendsFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friendsFriendsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImageThatFlips *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    
    self.currentFriendUser = self.friendsFriendsArray[indexPath.row];
    
    [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
        }
    }];
    
    cell.flipped = NO;

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
    
    if (cell.flipped == NO)
    {
        [UIView animateWithDuration:1.0
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction)
                         animations:^
         {
             [UIView transitionFromView:cell.friendImageView
                                 toView:cell.detailView
                               duration:.5
                                options:UIViewAnimationOptionTransitionFlipFromRight
                             completion:nil];
         }
                         completion:^(BOOL finished)
         {
             [collectionView deselectItemAtIndexPath:indexPath animated:YES];
             cell.flipped = YES;
         }
         ];
    }
    else if (cell.flipped == YES)
    {
        [UIView animateWithDuration:1.0
                              delay:0
                            options:(UIViewAnimationOptionAllowUserInteraction)
                         animations:^
         {
             [UIView transitionFromView:cell.detailView
                                 toView:cell.friendImageView
                               duration:.5
                                options:UIViewAnimationOptionTransitionFlipFromRight
                             completion:nil];
         }
                         completion:^(BOOL finished)
         {
             [collectionView deselectItemAtIndexPath:indexPath animated:YES];
             cell.flipped = NO;
         }
         ];
    }
}

@end
