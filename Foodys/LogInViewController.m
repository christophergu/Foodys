//
//  LogInViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/11/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onLogInButtonPressed:(id)sender
{
    //    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error)
    //     {
    //         if (user)
    //         {
    //             NSLog(@"logged in");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //         }
    //         else
    //         {
    //             UIAlertView *logInFailAlert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Username or Password is Incorrect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //             [logInFailAlert show];
    //         }
    //     }];
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
@end
