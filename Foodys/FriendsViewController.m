//
//  FriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendProfileViewController.h"
#import "AllUserBrowseViewController.h"
#import "CollectionViewCellWithImage.h"
#import <Parse/Parse.h>

@interface FriendsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) PFUser *currentFriendUser;
@property (strong, nonatomic) NSArray *userArray;

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUsers];
}

#pragma mark - collection view delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.currentUser[@"friends"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];

    PFUser *currentFriendUser = self.currentUser[@"friends"][indexPath.row];
    self.currentFriendUser = (PFUser *)[currentFriendUser fetchIfNeeded];
    
    // fetchIfNeeded
    
    [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
        }
    }];
    return cell;
}

#pragma mark - segue methods or related

- (void)loadUsers
{
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         self.userArray = (id)objects;
     }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"FriendsProfileSegue"]) {
        FriendProfileViewController *fpvc = segue.destinationViewController;
        
        NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:sender];
        
        fpvc.currentFriendUser = self.currentUser[@"friends"][indexPath.row];
    }
    if ([[segue identifier] isEqualToString:@"AllUserBrowseSegue"])
    {
        AllUserBrowseViewController *aubvc = segue.destinationViewController;
        aubvc.userArray = self.userArray;
    }
}

@end
