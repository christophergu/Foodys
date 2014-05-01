//
//  AddFriendsSureViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/30/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "AddFriendsSureViewController.h"

@interface AddFriendsSureViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UIButton *addFriendButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation AddFriendsSureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"%@", self.friendToConfirm);
    if (self.friendToConfirm[@"avatar"])
    {
        [self.friendToConfirm[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *photo = [UIImage imageWithData:data];
                self.avatarImageView.image = photo;
            }
        }];
    }
    else
    {
        self.avatarImageView.image = [UIImage imageNamed:@"defaultUserImage"];
    }
    self.avatarImageView.clipsToBounds = YES;
    
    self.nameLabel.text = self.friendToConfirm[@"username"];
    self.rankLabel.text = self.friendToConfirm[@"rank"];
    
    self.addFriendButton.layer.cornerRadius=4.0f;
    self.addFriendButton.layer.masksToBounds=YES;
    self.addFriendButton.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (IBAction)onAddFriendButtonPressed:(id)sender
{
    PFUser *currentUser = [PFUser currentUser];
    
    PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
    [friendRequest setObject:currentUser forKey:@"requestor"];
    [friendRequest setObject:self.friendToConfirm forKey:@"requestee"];
    

    
    
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self performSegueWithIdentifier:@"unwindAfterFriendSureSegue" sender:self];
        
//        UIAlertView *friendAddedAlert = [[UIAlertView alloc] initWithTitle:@"Friend Request Sent!"
//                                                                   message:[NSString stringWithFormat:@"You invited %@ to be your friend!",self.friendToConfirm[@"username"]]
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"OK"
//                                                         otherButtonTitles:nil];
//        [friendAddedAlert show];
    }];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
