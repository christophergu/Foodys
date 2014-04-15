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

//    [self friendsSetter];
//    [self loadUsers];
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
    PFQuery *query = [PFUser query];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            //            NSLog(@"Sean has played %d games", count);
            self.friendsCounterLabel.text = [NSString stringWithFormat:@"%d",count];
        } else {
            // The request failed
        }
    }];
    
    
}

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
    if ([[segue identifier] isEqualToString:@"FriendsFriendsCollectionSegue"])
    {
        FriendsFriendsViewController *fvc = segue.destinationViewController;
        fvc.userArray = self.userArray;
    }
}

@end
