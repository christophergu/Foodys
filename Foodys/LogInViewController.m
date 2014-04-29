//
//  LogInViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/11/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "LogInViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "TestFont.h"

@interface LogInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UIScrollView *autoLayoutScrollView;
@property (strong, nonatomic) IBOutlet TestFont *fontLabel;
@end


@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fontLabel.font = [UIFont fontWithName:@"NotoSans-BoldItalic" size:self.fontLabel.font.pointSize];

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated]; [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil]; [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    if (self.currentUser)
    {
        [self performSegueWithIdentifier:@"TabBarSegue" sender:self];
    }
}






-(void)viewDidDisappear:(BOOL)animated { [super viewDidDisappear:animated]; [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (void)keyboardWasShown:(NSNotification*)aNotification{

    CGPoint point = CGPointMake(0, 50);
    [self.autoLayoutScrollView setContentOffset:point animated:YES];
    NSLog(@"keyboard was shown");
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    [UIView setAnimationDelay:0];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
////    self.topConstraint.constant = 10;
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification { NSLog(@"keyboard was hidden"); }


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
          UIAlertView *logInFailAlert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Username or Password is Incorrect or No Internet Connection" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
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
