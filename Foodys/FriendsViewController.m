//
//  FriendsViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/14/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendsViewController.h"
#import "CollectionViewCellWithImage.h"
#import <Parse/Parse.h>

@interface FriendsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.userArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCellWithImage *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCellReuseID" forIndexPath:indexPath];
    
    PFUser *user = self.userArray[indexPath.row];
    
    [user[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *photo = [UIImage imageWithData:data];
            cell.friendImageView.image = photo;
        }
    }];
    return cell;
}

@end
