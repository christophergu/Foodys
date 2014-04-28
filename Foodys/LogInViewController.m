//
//  LogInViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/11/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>

@interface LogInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.currentUser)
    {
        [self performSegueWithIdentifier:@"TabBarSegue" sender:self];
    }
}



- (IBAction)onLogInButtonPressed:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error)
    {
      if (user)
      {
          NSLog(@"logged in");
          [self performSegueWithIdentifier:@"TabBarSegue" sender:self];
      }
      else
      {
          UIAlertView *logInFailAlert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Username or Password is Incorrect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [logInFailAlert show];
      }
    }];
    
    [self.passwordTextField endEditing:YES];
    [self.usernameTextField endEditing:YES];
}

- (IBAction)endEditingButton:(id)sender
{
    [self.passwordTextField endEditing:YES];
    [self.usernameTextField endEditing:YES];
}

- (IBAction)onSignUpButtonPressed:(id)sender
{
    
}

- (IBAction)onForgotButtonPressed:(id)sender
{
    
}

- (IBAction)onEndEditingButtonPressed:(id)sender
{
    [self.usernameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}

- (IBAction)unwindToBeginning:(UIStoryboardSegue *)unwindSegue
{
    [PFUser logOut];
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}

@end
