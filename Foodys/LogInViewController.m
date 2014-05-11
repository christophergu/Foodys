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

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface LogInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *autoLayoutScrollView;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) PFUser *currentUser;

@end


@implementation LogInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    
    self.logInButton.layer.cornerRadius=4.0f;
    self.logInButton.layer.masksToBounds=YES;
    self.logInButton.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isiPhone5)
    {
        // this is iphone 4 inch
    }
    else
    {
        //Iphone  3.5 inch
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardDidHideNotification object:nil];
    }

    PFUser *userNow = [PFUser currentUser];
    if (userNow)
    {
        [self performSegueWithIdentifier:@"TabBarSegue" sender:self];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGPoint point = CGPointMake(0, 150);
    [self.autoLayoutScrollView setContentOffset:point animated:YES];
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboard was hidden");
    CGPoint point = CGPointMake(0, -20);
    [self.autoLayoutScrollView setContentOffset:point animated:YES];
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

- (IBAction)onEndEditingButtonPressed:(id)sender
{
    [self.usernameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}

- (IBAction)usernameDidEndOnExit:(id)sender
{
    [self.passwordTextField endEditing:YES];
    [self.usernameTextField endEditing:YES];
}

- (IBAction)passwordTextFieldDidEndOnExit:(id)sender
{
    [self.passwordTextField endEditing:YES];
    [self.usernameTextField endEditing:YES];
    
    if (![self.passwordTextField.text isEqualToString: @""]&&![self.usernameTextField.text isEqualToString: @""])
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
    }
}


- (IBAction)unwindToBeginning:(UIStoryboardSegue *)unwindSegue
{
    [PFUser logOut];
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}

@end
