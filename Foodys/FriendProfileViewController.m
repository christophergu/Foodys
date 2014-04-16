//
//  FriendProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/15/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "FriendsFriendsViewController.h"

@interface FriendProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *friendsCounterLabel;
@property (strong, nonatomic) NSArray *userArray;

@end

@implementation FriendProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self friendsSetter];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.currentFriendUser[@"username"];
    
    if (self.currentFriendUser[@"avatar"]) {
        [self.currentFriendUser[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
            }
        }];
    }
}

- (void)friendsSetter
{
    self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",[self.currentFriendUser[@"friends"] count]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FriendsFriendsCollectionSegue"])
    {
        FriendsFriendsViewController *fvc = segue.destinationViewController;
        fvc.friendsFriendsArray = self.currentFriendUser[@"friends"];
    }
}

@end
