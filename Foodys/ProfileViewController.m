//
//  ProfileViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/13/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.avatarImageView.image = [UIImage imageNamed:@"defaultUserImage"];
}

- (IBAction)onLogOutButtonPressed:(id)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogInSegue" sender:self];
}

@end
