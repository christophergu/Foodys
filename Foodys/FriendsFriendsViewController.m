//
//  FriendsFriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendsFriendsViewController.h"
#import "CollectionViewCellWithImage.h"
#import <Parse/Parse.h>

@interface FriendsFriendsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) PFUser *currentFriendUser;

@end

@implementation FriendsFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friendsFriendsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    
    // used to get the PFUser with the data back
    NSString *tempStringBeforeCutting = [NSString stringWithFormat:@"%@",self.friendsFriendsArray[indexPath.row]];
    NSArray* cutStringArray = [tempStringBeforeCutting componentsSeparatedByString: @":"];
    
    PFQuery *friendToIncludeQuery = [PFUser query];
    [friendToIncludeQuery whereKey:@"objectId" equalTo:cutStringArray[1]];
    [friendToIncludeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.currentFriendUser = objects.firstObject;
        
        [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                cell.friendImageView.image = photo;
            }
        }];
    }];

    return cell;
}


//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    CollectionViewCellWithImageThatFlips *cell = (CollectionViewCellWithImageThatFlips *)[collectionView cellForItemAtIndexPath:indexPath];
//    
//    cell.addFriendButton.friendUser = self.userArray[indexPath.row];
//    
//    if (cell.flipped == NO)
//    {
//        [UIView animateWithDuration:1.0
//                              delay:0
//                            options:(UIViewAnimationOptionAllowUserInteraction)
//                         animations:^
//         {
//             [UIView transitionFromView:cell.friendImageView
//                                 toView:cell.detailView
//                               duration:.5
//                                options:UIViewAnimationOptionTransitionFlipFromRight
//                             completion:nil];
//         }
//                         completion:^(BOOL finished)
//         {
//             [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//             cell.flipped = YES;
//         }
//         ];
//    }
//    else if (cell.flipped == YES)
//    {
//        [UIView animateWithDuration:1.0
//                              delay:0
//                            options:(UIViewAnimationOptionAllowUserInteraction)
//                         animations:^
//         {
//             [UIView transitionFromView:cell.detailView
//                                 toView:cell.friendImageView
//                               duration:.5
//                                options:UIViewAnimationOptionTransitionFlipFromRight
//                             completion:nil];
//         }
//                         completion:^(BOOL finished)
//         {
//             [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//             cell.flipped = NO;
//         }
//         ];
//    }
//}

@end
