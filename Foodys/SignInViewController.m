//
//  SignInViewController.m
//  Foodys
//
//  Created by Christopher Gu on 4/11/14.
//  Copyright (c) 2014 Christopher Gu. All rights reserved.
//

#import "SignInViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface SignInViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *autoLayoutScrollView;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation SignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signUpButton.layer.cornerRadius=4.0f;
    self.signUpButton.layer.masksToBounds=YES;
    self.signUpButton.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isiPhone5)
    {
        // this is iphone 4 inch
        NSLog(@"ya 4");
    }
    else
    {
        //Iphone  3.5 inch
        NSLog(@"nah 3.5");
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardDidHideNotification object:nil];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"showing");
    CGPoint point = CGPointMake(0, 50);
    [self.autoLayoutScrollView setContentOffset:point animated:YES];
    
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.5];
    //    [UIView setAnimationDelay:0];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    ////    self.topConstraint.constant = 10;
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboard was hidden");
    CGPoint point = CGPointMake(0, 0);
    [self.autoLayoutScrollView setContentOffset:point animated:YES];
}

- (IBAction)onSignUpButtonPressed:(id)sender
{
    [self createNewUser];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onEndEditingButtonPressed:(id)sender
{
    [self.usernameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
    [self.emailTextField endEditing:YES];
}

- (IBAction)emailTextFieldDidEndOnExit:(id)sender
{
    [self.usernameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
    [self.emailTextField endEditing:YES];
}

- (void)createNewUser
{
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    user.email = self.emailTextField.text;
    user[@"rank"] = @"Shy Foodie";
    NSDate *joinDate = [NSDate date];
    user[@"joinDate"] = joinDate;
    
    UIImage *pickedImage = [UIImage imageNamed:@"defaultUserImage"];
    NSData* data = UIImageJPEGRepresentation(pickedImage,1.0f);
    PFFile *imageFile = [PFFile fileWithData:data];
    user[@"avatar"] = imageFile;
    
    [user signUpInBackgroundWithTarget:self selector:@selector(handleSignUp:error:)];
}

- (void)handleSignUp:(NSNumber *)result error:(NSError *)error
{
    if (!error)
    {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            UIAlertView *logInFailAlert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Username or Password is Incorrect" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [logInFailAlert show];            }
        }];
    }
    else
    {
        UIAlertView *signUpErrorAlert = [[UIAlertView alloc] initWithTitle:@"Sign In Failed" message:[NSString stringWithFormat:@"%@",[error userInfo][@"error"]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [signUpErrorAlert show];
    }
}

@end
